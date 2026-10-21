// Four-mode, 24-note modal marimba using tabled frequencies and live DDS.
// Note indices 24..47 map to A2..G#4; note-off does not stop a strike.
module marimba_synth #(
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter MODE_FILE = "src/rom/marimba24.hex"
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
    output reg deadline_error
);
    localparam NOTE_FIRST = 7'd24;
    localparam NOTE_COUNT = 24;
    localparam IDLE=0, NOTE_START=1, MODE_LOAD=2, SINE_READ=3,
               INTERP_MUL=4, INTERP_USE=5, AMP_MUL=6, AMP_USE=7,
               DYN_MUL=8, DYN_USE=9, DECAY_MUL=10, DECAY_USE=11,
               MODE_COMMIT=12, ADVANCE=13;

    reg [3:0] state;
    reg [4:0] note_index;
    reg [1:0] mode_index;
    reg [23:0] pending;
    reg [7:0] dynamics_by_note [0:23];
    reg active_mode_cell [0:95];
    wire [95:0] active_modes;
    reg [31:0] phase_ram [0:95];
    reg [15:0] level_ram [0:95];
    reg [255:0] mode_rom [0:23];
    reg signed [15:0] sine_rom [0:255];
    reg [255:0] mode_row;
    reg [31:0] mode_step;
    reg [15:0] mode_decay, mode_level;
    reg [31:0] mode_phase;
    reg [7:0] note_dynamics;
    reg trigger_note;
    reg signed [15:0] sine_value, sine_next;
    reg [7:0] phase_fraction;
    reg signed [16:0] interpolated_sample;
    reg signed [31:0] amp_sample, scaled_sample;
    reg [15:0] next_level;
    reg signed [31:0] mix_accum;
    reg signed [31:0] mult_a;
    reg signed [15:0] mult_b;
    reg signed [47:0] mult_product;
    wire signed [47:0] mult_result = mult_a * mult_b;
    wire [6:0] mode_address = {note_index, mode_index};
    wire [63:0] selected_mode = select_mode(mode_row, mode_index);
    wire [31:0] stored_phase = phase_ram[mode_address];
    wire [15:0] stored_level = level_ram[mode_address];
    wire signed [16:0] sine_delta =
        $signed({sine_next[15], sine_next}) -
        $signed({sine_value[15], sine_value});
    wire [7:0] next_sine_address = phase_fraction[7:0];
    wire signed [31:0] scaled_mode_sample = scaled_sample;

    function [63:0] select_mode;
        input [255:0] row;
        input [1:0] index;
        begin
            case (index)
                0: select_mode = row[63:0];
                1: select_mode = row[127:64];
                2: select_mode = row[191:128];
                default: select_mode = row[255:192];
            endcase
        end
    endfunction

    genvar state_index;
    initial begin
        $readmemh(SINE_FILE, sine_rom);
        $readmemh(MODE_FILE, mode_rom);
    end

    generate
        for (state_index=0; state_index<96; state_index=state_index+1) begin: modal_state
            assign active_modes[state_index] = active_mode_cell[state_index];
            always @(posedge clk) begin
                if (state==MODE_COMMIT && mode_address==state_index[6:0]) begin
                    phase_ram[state_index] <= mode_phase + mode_step;
                    level_ram[state_index] <= next_level;
                end
            end
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n)
                    active_mode_cell[state_index] <= 0;
                else if (stop_all)
                    active_mode_cell[state_index] <= 0;
                else if (state==MODE_COMMIT &&
                         mode_address==state_index[6:0])
                    active_mode_cell[state_index] <= next_level != 0;
            end
        end
    endgenerate

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
                mult_b = $signed({8'd0, note_dynamics});
            end
            DECAY_MUL: begin
                mult_a = $signed({16'd0, mode_level});
                mult_b = $signed({1'b0, mode_decay[14:0]});
            end
            default: begin
                mult_a = 0;
                mult_b = 0;
            end
        endcase
    end

    assign event_ready = reset_n && !stop_all && (state == IDLE);

    always @(posedge clk) begin
        if (state == SINE_READ) begin
            sine_value <= sine_rom[mode_phase[31:24]];
            sine_next <= sine_rom[mode_phase[31:24] + 8'd1];
            phase_fraction <= mode_phase[23:16];
        end
        if (state == INTERP_MUL || state == AMP_MUL ||
            state == DYN_MUL || state == DECAY_MUL)
            mult_product <= mult_result;
    end

    output_limiter limiter (
        .clk(clk), .reset_n(reset_n), .clear(stop_all),
        .in_valid(mix_valid), .in_sample(mix_sample),
        .out_valid(pcm_valid), .out_sample(pcm),
        .limiting(limiting), .saturated(saturated)
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            note_index <= 0;
            mode_index <= 0;
            pending <= 0;
            trigger_note <= 0;
            mode_step <= 0;
            mode_decay <= 0;
            mode_level <= 0;
            mode_phase <= 0;
            note_dynamics <= 0;
            interpolated_sample <= 0;
            amp_sample <= 0;
            scaled_sample <= 0;
            next_level <= 0;
            mix_accum <= 0;
            mix_sample <= 0;
            mix_valid <= 0;
            deadline_error <= 0;
        end else if (stop_all) begin
            state <= IDLE;
            pending <= 0;
            trigger_note <= 0;
            mix_accum <= 0;
            mix_sample <= 0;
            mix_valid <= 0;
        end else begin
            mix_valid <= 0;
            if (sample_tick && state != IDLE)
                deadline_error <= 1;
            if (event_valid && event_ready && event_on &&
                event_note >= NOTE_FIRST &&
                event_note < NOTE_FIRST + NOTE_COUNT) begin
                pending[event_note - NOTE_FIRST] <= 1;
                dynamics_by_note[event_note - NOTE_FIRST] <= event_dynamics;
            end
            case (state)
                IDLE: if (sample_tick) begin
                    note_index <= 0;
                    mode_index <= 0;
                    mix_accum <= 0;
                    state <= NOTE_START;
                end
                NOTE_START: begin
                    mode_row <= mode_rom[note_index];
                    trigger_note <= pending[note_index];
                    pending[note_index] <= 0;
                    note_dynamics <= dynamics_by_note[note_index];
                    mode_index <= 0;
                    state <= MODE_LOAD;
                end
                MODE_LOAD: begin
                    if (!trigger_note && !active_modes[mode_address])
                        state <= ADVANCE;
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
                    next_level <= mult_product[30:15];
                    state <= MODE_COMMIT;
                end
                MODE_COMMIT: begin
                    if (note_index == NOTE_COUNT-1 && mode_index == 3) begin
                        mix_sample <= mix_accum + scaled_mode_sample;
                        mix_valid <= 1;
                        state <= IDLE;
                    end else begin
                        mix_accum <= mix_accum + scaled_mode_sample;
                        state <= ADVANCE;
                    end
                end
                ADVANCE: begin
                    if (mode_index == 3) begin
                        if (note_index == NOTE_COUNT-1) begin
                            mix_sample <= mix_accum;
                            mix_valid <= 1;
                            state <= IDLE;
                        end else begin
                            note_index <= note_index + 1'b1;
                            state <= NOTE_START;
                        end
                    end else begin
                        mode_index <= mode_index + 1'b1;
                        state <= MODE_LOAD;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
