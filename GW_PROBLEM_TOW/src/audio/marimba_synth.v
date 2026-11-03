// PCM-fitted 48-note modal marimba with velocity-sensitive modes, a short
// mallet transient and a separate body/tube resonator.
// MIDI notes 36..83 map to the fitted C2..B5 range.
module marimba_synth #(
    parameter integer EXTERNAL_LIMITER=0,
    parameter integer EXTERNAL_SINE=0,
    parameter integer SAMPLE_RATE_RATIO=1,
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter MODE_FILE = "src/rom/marimba48.hex",
    parameter ATTACK_FILE = "src/rom/marimba_attack48.hex"
) (
    input wire clk, reset_n, sample_tick, stop_all,
    input wire event_valid, event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    output wire event_ready,
    output reg signed [31:0] mix_sample,
    output reg mix_valid,
    output wire signed [15:0] pcm,
    output wire pcm_valid, limiting, saturated,
    output wire signed [31:0] output_mix,
    output wire output_mix_valid,
    output reg deadline_error,
    output wire voice_busy,
    output wire [7:0] sine_read_address,
    output wire sine_read_enable,
    input wire signed [15:0] external_sine_value,external_sine_next
);
    localparam NOTE_FIRST = 7'd36;
    localparam NOTE_COUNT = 48;
    localparam IDLE=0, NOTE_START=1, MODE_LOAD=2, SINE_READ=3,
               INTERP_MUL=4, INTERP_USE=5, AMP_MUL=6, AMP_USE=7,
               DYN_MUL=8, DYN_USE=9, DECAY_MUL=10, DECAY_USE=11,
               MODE_COMMIT=12, NOISE_LOAD=13, NOISE_MUL=14,
               NOISE_USE=15, NOISE_DYN=16, NOISE_DYN_USE=17,
               NOISE_COMMIT=18, ADVANCE=19;

    reg [4:0] state;
    localparam RATE_BITS=SAMPLE_RATE_RATIO<2 ? 1 : $clog2(SAMPLE_RATE_RATIO);
    reg [RATE_BITS-1:0] rate_phase;
    reg time_step;
    reg [5:0] note_index;
    reg [1:0] mode_index;
    reg [NOTE_COUNT-1:0] pending, active_noise;
    reg [NOTE_COUNT*4-1:0] active_modes;
    assign voice_busy=(|pending) || (|active_modes) || (|active_noise);
    reg [7:0] dynamics_by_note [0:NOTE_COUNT-1] /* synthesis syn_ramstyle="registers" */;
    // One synchronous read port and one write port per state memory. Keep
    // reset/stop on the small validity vectors, never on the RAM contents.
    reg [47:0] mode_state_ram [0:255]; // {phase[31:0], level[15:0]}
    reg [31:0] noise_state_ram [0:63]; // {level[15:0], lfsr[15:0]}
    reg [47:0] mode_state_q;
    reg [31:0] noise_state_q;
    // 0..191: one 64-bit mode; 192..239: one 32-bit attack in the low half.
    reg [63:0] mode_rom [0:255];
    reg [63:0] selected_mode;
    wire [31:0] attack_row=selected_mode[31:0];
    reg [31:0] mode_step, mode_phase;
    reg [15:0] mode_decay, mode_level;
    reg [15:0] noise_level, noise_step, noise_lfsr;
    reg [7:0] note_dynamics;
    reg trigger_note;
    wire signed [15:0] sine_value, sine_next;
    assign sine_read_address=mode_phase[31:24];
    assign sine_read_enable=state==SINE_READ;
    generate if(EXTERNAL_SINE)begin: shared_sine
        assign sine_value=external_sine_value;
        assign sine_next=external_sine_next;
    end else begin: local_sine
        sine_pair_rom #(.SINE_FILE(SINE_FILE)) lookup(
            .clk(clk),.enable(sine_read_enable),.address(sine_read_address),
            .value(sine_value),.next_value(sine_next));
    end endgenerate
    reg [7:0] phase_fraction;
    reg signed [16:0] interpolated_sample;
    reg signed [31:0] amp_sample, scaled_sample, noise_amp, noise_sample;
    reg [15:0] next_level, next_noise_level;
    reg signed [31:0] mix_accum;
    reg signed [31:0] mult_a;
    reg signed [15:0] mult_b;
    reg signed [47:0] mult_product;
    wire signed [47:0] mult_result = mult_a * mult_b;
    wire [7:0] mode_address = {note_index, mode_index};
    // Fetch the next mode on the clock that advances its index. NOTE_START
    // always fetches mode zero, including when the previous note ended at 3.
    // This hides the synchronous RAM latency inside existing FSM cycles.
    wire [7:0] mode_read_address = state == NOTE_START ? {note_index, 2'd0} :
        ((state == MODE_COMMIT || state == ADVANCE) && mode_index != 3) ?
        mode_address + 8'd1 : mode_address;
    // Mode 3 consumes its parameters before fetching the attack, so this
    // single read port needs no extra FSM clocks or parallel wide-row ROM.
    wire attack_fetch=state==MODE_LOAD && mode_index==3;
    wire parameter_fetch=state==NOTE_START || attack_fetch ||
        ((state==MODE_COMMIT || state==ADVANCE) && mode_index!=3);
    wire [7:0] parameter_address=attack_fetch ? 8'd192+{2'd0,note_index} : mode_read_address;
    wire [31:0] stored_phase = mode_state_q[47:16];
    wire [15:0] stored_level = mode_state_q[15:0];
    wire [15:0] stored_noise_level = noise_state_q[31:16];
    wire [15:0] stored_noise_lfsr = noise_state_q[15:0];
    wire signed [16:0] sine_delta =
        $signed({sine_next[15], sine_next}) -
        $signed({sine_value[15], sine_value});
    wire [7:0] bright_dynamics =
        {4'd0, note_dynamics[7:4]} *
        {4'd0, note_dynamics[7:4]};
    wire signed [8:0] noise_centered =
        $signed({1'b0, noise_lfsr[7:0]}) - 9'sd128;
    wire signed [31:0] filtered_sample;
    wire filtered_valid;

    function [15:0] next_lfsr;
        input [15:0] current;
        reg feedback;
        begin
            feedback = current[15] ^ current[13] ^
                       current[12] ^ current[10];
            next_lfsr = {current[14:0], feedback};
            if (next_lfsr == 0) next_lfsr = 16'h1ace;
        end
    endfunction

    // Initialization-only arrays retain the existing measured file format.
    // They have no runtime read ports; only the packed 64-bit ROM is read.
    reg [255:0] initial_modes[0:NOTE_COUNT-1];
    reg [31:0] initial_attacks[0:NOTE_COUNT-1];
    integer init_note,init_mode;
    initial begin
        $readmemh(MODE_FILE,initial_modes);
        $readmemh(ATTACK_FILE,initial_attacks);
        for(init_note=0;init_note<256;init_note=init_note+1)mode_rom[init_note]=0;
        for(init_note=0;init_note<NOTE_COUNT;init_note=init_note+1)begin
            for(init_mode=0;init_mode<4;init_mode=init_mode+1)
                mode_rom[init_note*4+init_mode]=initial_modes[init_note][init_mode*64 +:64];
            mode_rom[192+init_note]={32'd0,initial_attacks[init_note]};
        end
    end

    always @* begin
        mult_a = 0;
        mult_b = 0;
        case (state)
            INTERP_MUL: begin
                mult_a = sine_delta;
                mult_b = {8'd0, phase_fraction};
            end
            AMP_MUL: begin
                mult_a = interpolated_sample;
                mult_b = $signed({1'b0, mode_level[14:0]});
            end
            DYN_MUL: begin
                mult_a = amp_sample;
                mult_b = $signed({8'd0, mode_index == 0 ?
                                  note_dynamics : bright_dynamics});
            end
            DECAY_MUL: begin
                mult_a = $signed({16'd0, mode_level});
                mult_b = $signed({1'b0, mode_decay[14:0]});
            end
            NOISE_MUL: begin
                mult_a = noise_centered;
                mult_b = $signed({1'b0, noise_level[14:0]});
            end
            NOISE_DYN: begin
                mult_a = noise_amp;
                mult_b = $signed({8'd0, bright_dynamics});
            end
            default: begin
                mult_a = 0;
                mult_b = 0;
            end
        endcase
    end

    assign event_ready = reset_n && !stop_all && state == IDLE;

    always @(posedge clk) begin
        if(parameter_fetch)selected_mode<=mode_rom[parameter_address];
        mode_state_q <= mode_state_ram[mode_read_address];
        if (reset_n && !stop_all && state == MODE_COMMIT)
            mode_state_ram[mode_address] <= {mode_phase + mode_step, next_level};
        // Noise is fetched once at NOTE_START, well before NOISE_LOAD. The
        // mutually exclusive read/write enables avoid a read-first SP RAM
        // mode that this device does not implement; write output is unused.
        if (reset_n && !stop_all && state == NOISE_COMMIT)
            noise_state_ram[note_index] <= {next_noise_level,next_lfsr(noise_lfsr)};
        else if (state == NOTE_START)
            noise_state_q <= noise_state_ram[note_index];
        if (state == SINE_READ) begin
            phase_fraction <= mode_phase[23:16];
        end
        if (state == INTERP_MUL || state == AMP_MUL ||
            state == DYN_MUL || state == DECAY_MUL ||
            state == NOISE_MUL || state == NOISE_DYN)
            mult_product <= mult_result;
    end

    marimba_body_filter #(.SAMPLE_RATE_RATIO(SAMPLE_RATE_RATIO)) body_filter (
        .clk(clk), .reset_n(reset_n), .clear(stop_all),
        .in_valid(mix_valid), .in_sample(mix_sample),
        .out_valid(filtered_valid), .out_sample(filtered_sample)
    );

    assign output_mix=filtered_sample;
    assign output_mix_valid=filtered_valid;
    generate if (EXTERNAL_LIMITER == 0) begin: internal_output
    output_limiter limiter (
        .clk(clk), .reset_n(reset_n), .clear(stop_all),
        .in_valid(filtered_valid), .in_sample(filtered_sample),
        .out_valid(pcm_valid), .out_sample(pcm),
        .limiting(limiting), .saturated(saturated)
    );
    end else begin: external_output
        assign pcm=16'sd0;
        assign pcm_valid=1'b0;
        assign limiting=1'b0;
        assign saturated=1'b0;
    end endgenerate

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE; note_index <= 0; mode_index <= 0;
            rate_phase<=0;time_step<=1;
            pending <= 0; active_modes <= 0; active_noise <= 0;
            mode_step <= 0; mode_decay <= 0; mode_level <= 0; mode_phase <= 0;
            noise_level <= 0; noise_step <= 0; noise_lfsr <= 16'h1ace;
            note_dynamics <= 0; trigger_note <= 0;
            interpolated_sample <= 0; amp_sample <= 0; scaled_sample <= 0;
            noise_amp <= 0; noise_sample <= 0;
            next_level <= 0; next_noise_level <= 0; mix_accum <= 0;
            mix_sample <= 0; mix_valid <= 0; deadline_error <= 0;
        end else if (stop_all) begin
            state <= IDLE; pending <= 0;
            rate_phase<=0;time_step<=1;
            active_modes <= 0; active_noise <= 0;
            mix_accum <= 0; mix_sample <= 0; mix_valid <= 0;
        end else begin
            mix_valid <= 0;
            if (sample_tick && state != IDLE) deadline_error <= 1;
            if (event_valid && event_ready && event_on &&
                event_note >= NOTE_FIRST &&
                event_note < NOTE_FIRST + NOTE_COUNT) begin
                pending[event_note - NOTE_FIRST] <= 1;
                dynamics_by_note[event_note - NOTE_FIRST] <= event_dynamics;
            end
            case (state)
                IDLE: if (sample_tick) begin
                    time_step<=rate_phase==0;
                    rate_phase<=rate_phase==SAMPLE_RATE_RATIO-1 ? 0 : rate_phase+1'b1;
                    note_index <= 0; mode_index <= 0;
                    mix_accum <= 0; state <= NOTE_START;
                end
                NOTE_START: begin
                    trigger_note <= pending[note_index];
                    pending[note_index] <= 0;
                    note_dynamics <= dynamics_by_note[note_index];
                    mode_index <= 0; state <= MODE_LOAD;
                end
                MODE_LOAD: begin
                    if (!trigger_note && !active_modes[mode_address])
                        state <= mode_index == 3 ? NOISE_LOAD : ADVANCE;
                    else begin
                        mode_step <= selected_mode[63:32];
                        mode_decay <= selected_mode[15:0];
                        mode_phase <= trigger_note ? 32'd0 : stored_phase;
                        mode_level <= trigger_note ? selected_mode[31:16] :
                                      stored_level;
                        state <= SINE_READ;
                    end
                end
                SINE_READ: state <= INTERP_MUL;
                INTERP_MUL: state <= INTERP_USE;
                INTERP_USE: begin
                    interpolated_sample <=
                        $signed({sine_value[15], sine_value}) +
                        $signed(mult_product[24:8]);
                    state <= AMP_MUL;
                end
                AMP_MUL: state <= AMP_USE;
                AMP_USE: begin
                    amp_sample <= $signed(mult_product[46:15]);
                    state <= DYN_MUL;
                end
                DYN_MUL: state <= DYN_USE;
                DYN_USE: begin
                    scaled_sample <= $signed(mult_product[39:8]);
                    state <= DECAY_MUL;
                end
                DECAY_MUL: state <= DECAY_USE;
                DECAY_USE: begin
                    next_level <= time_step ? mult_product[30:15] : mode_level;
                    state <= MODE_COMMIT;
                end
                MODE_COMMIT: begin
                    active_modes[mode_address] <= next_level != 0;
                    mix_accum <= mix_accum + scaled_sample;
                    if (mode_index == 3) state <= NOISE_LOAD;
                    else begin
                        mode_index <= mode_index + 1'b1;
                        state <= MODE_LOAD;
                    end
                end
                NOISE_LOAD: begin
                    if (!trigger_note && !active_noise[note_index])
                        state <= ADVANCE;
                    else begin
                        noise_level <= trigger_note ? attack_row[31:16] :
                                       stored_noise_level;
                        noise_step <= attack_row[15:0];
                        noise_lfsr <= trigger_note ?
                            // Seed by MIDI pitch, preserving B2..F5 exactly
                            // when lower notes are added before them.
                            (16'h1a9f + {10'd0, note_index} + NOTE_FIRST) :
                            stored_noise_lfsr;
                        state <= NOISE_MUL;
                    end
                end
                NOISE_MUL: state <= NOISE_USE;
                NOISE_USE: begin
                    noise_amp <= $signed(mult_product >>> 7);
                    state <= NOISE_DYN;
                end
                NOISE_DYN: state <= NOISE_DYN_USE;
                NOISE_DYN_USE: begin
                    noise_sample <= $signed(mult_product >>> 8);
                    next_noise_level <= !time_step ? noise_level :
                        (noise_level <= noise_step ? 16'd0 : noise_level - noise_step);
                    state <= NOISE_COMMIT;
                end
                NOISE_COMMIT: begin
                    active_noise[note_index] <= next_noise_level != 0;
                    mix_accum <= mix_accum + noise_sample;
                    state <= ADVANCE;
                end
                ADVANCE: begin
                    if (mode_index != 3) begin
                        mode_index <= mode_index + 1'b1;
                        state <= MODE_LOAD;
                    end else if (note_index == NOTE_COUNT-1) begin
                        mix_sample <= mix_accum;
                        mix_valid <= 1; state <= IDLE;
                    end else begin
                        note_index <= note_index + 1'b1;
                        state <= NOTE_START;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
