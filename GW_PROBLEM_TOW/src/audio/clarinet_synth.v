// Real-time monophonic Bb clarinet, sounding MIDI 50..94 (D3..Bb6).
// ROMs contain a sine function, pitch words and harmonic weights, never PCM.
// Eight additive partials share one pipelined multiplier. High partials are
// suppressed before Nyquist; held notes sustain until a matching note-off.
module clarinet_synth #(
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter FREQ_FILE = "src/rom/frequency88.hex",
    parameter VOICING_FILE = "src/rom/clarinet45.hex"
) (
    input wire clk, reset_n, sample_tick, stop_all,
    input wire event_valid, event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    input wire [17:0] pitch_ratio,
    output wire event_ready,
    output reg signed [31:0] mix_sample,
    output reg mix_valid,
    output wire signed [15:0] pcm,
    output wire pcm_valid, limiting, saturated,
    output reg deadline_error
);
    localparam IDLE=0, TUNE=1, TUNE_USE=2, HARMONIC=3, SINE_READ=4,
               INTERP=5, INTERP_USE=6, WEIGHT=7, WEIGHT_USE=8,
               ADVANCE=9, ENVELOPE=10, ENV_USE=11, DYNAMICS=12, OUTPUT=13;
    reg [3:0] state;
    reg [2:0] harmonic;
    reg gate;
    reg [6:0] held_note;
    reg [7:0] dynamics;
    reg [15:0] envelope, frame_envelope;
    reg [31:0] phase, frame_phase, pitch_word, pitch_step;
    reg [35:0] harmonic_step;
    reg [31:0] harmonic_phase;
    reg [127:0] weights;
    reg [15:0] weight;
    reg signed [15:0] sine_rom [0:255];
    reg [31:0] frequency_rom [0:87];
    reg [127:0] voicing_rom [0:44];
    reg signed [15:0] sine_value, sine_next;
    reg [7:0] fraction;
    reg signed [16:0] interpolated;
    reg signed [31:0] accumulator, shaped_sample, enveloped_sample;
    reg signed [31:0] mult_a;
    reg signed [17:0] mult_b;
    reg signed [49:0] product;
    reg [49:0] tuning_product;
    reg [15:0] lfsr;
    wire signed [16:0] sine_delta = $signed({sine_next[15],sine_next}) -
                                               $signed({sine_value[15],sine_value});
    wire signed [8:0] breath = $signed({1'b0,lfsr[7:0]}) - 9'sd128;
    assign event_ready = reset_n && !stop_all && state==IDLE && !sample_tick;
    initial begin
        $readmemh(SINE_FILE, sine_rom);
        $readmemh(FREQ_FILE, frequency_rom);
        $readmemh(VOICING_FILE, voicing_rom);
    end
    always @* begin
        mult_a=0; mult_b=0;
        case(state)
            INTERP: begin mult_a=sine_delta; mult_b=$signed({10'd0,fraction}); end
            WEIGHT: begin mult_a=interpolated; mult_b=$signed({2'd0,weight}); end
            ENVELOPE: begin mult_a=shaped_sample; mult_b=$signed({2'd0,frame_envelope}); end
            DYNAMICS: begin mult_a=enveloped_sample; mult_b=$signed({10'd0,dynamics}); end
            default: begin mult_a=0; mult_b=0; end
        endcase
    end
    always @(posedge clk) begin
        if(state==TUNE) tuning_product <= pitch_word * pitch_ratio;
        if(state==INTERP || state==WEIGHT || state==ENVELOPE || state==DYNAMICS)
            product <= mult_a * mult_b;
        if(state==SINE_READ) begin
            sine_value <= sine_rom[harmonic_phase[31:24]];
            sine_next <= sine_rom[harmonic_phase[31:24]+8'd1];
            fraction <= harmonic_phase[23:16];
        end
    end
    output_limiter #(.MASTER_SHIFT(1)) limiter (
        .clk(clk),.reset_n(reset_n),.clear(stop_all),
        .in_valid(mix_valid),.in_sample(mix_sample),
        .out_valid(pcm_valid),.out_sample(pcm),.limiting(limiting),.saturated(saturated)
    );
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=IDLE; harmonic<=0; gate<=0; held_note<=50; dynamics<=0;
            envelope<=0; frame_envelope<=0; phase<=0; frame_phase<=0;
            pitch_word<=0; pitch_step<=0; harmonic_step<=0; harmonic_phase<=0;
            weights<=0; weight<=0; interpolated<=0; accumulator<=0;
            shaped_sample<=0; enveloped_sample<=0; mix_sample<=0; mix_valid<=0;
            deadline_error<=0; lfsr<=16'h1ace;
        end else if(stop_all) begin
            state<=IDLE; gate<=0; envelope<=0; frame_envelope<=0;
            phase<=0; dynamics<=0; accumulator<=0; mix_sample<=0; mix_valid<=0;
        end else begin
            mix_valid<=0;
            if(sample_tick && state!=IDLE) deadline_error<=1;
            if(event_valid && event_ready && event_note>=50 && event_note<=94) begin
                if(event_on && event_dynamics!=0) begin
                    held_note<=event_note; gate<=1; dynamics<=event_dynamics;
                    pitch_word<=frequency_rom[event_note-21];
                    weights<=voicing_rom[event_note-50];
                    phase<=0; envelope<=0; lfsr<=16'h1ace+event_note;
                end else if(event_note==held_note) gate<=0;
            end
            case(state)
                IDLE: if(sample_tick) begin
                    // About 16 ms attack and 32 ms release at the board Fs.
                    if(gate) begin
                        if(envelope>=32639) begin envelope<=32767; frame_envelope<=32767; end
                        else begin envelope<=envelope+128; frame_envelope<=envelope+128; end
                    end else begin
                        if(envelope<=64) begin envelope<=0; frame_envelope<=0; end
                        else begin envelope<=envelope-64; frame_envelope<=envelope-64; end
                    end
                    accumulator<=0; harmonic<=0; frame_phase<=phase; state<=TUNE;
                end
                TUNE: state<=TUNE_USE;
                TUNE_USE: begin
                    pitch_step<=tuning_product[47:16];
                    harmonic_step<={4'd0,tuning_product[47:16]};
                    harmonic_phase<=frame_phase;
                    phase<=frame_phase+tuning_product[47:16]; state<=HARMONIC;
                end
                HARMONIC: begin
                    weight<=weights[harmonic*16 +: 16];
                    // 0.46875 Fs leaves a guard below the Nyquist boundary.
                    if(harmonic_step>=36'h078000000) state<=ADVANCE;
                    else state<=SINE_READ;
                end
                SINE_READ: state<=INTERP;
                INTERP: state<=INTERP_USE;
                INTERP_USE: begin
                    interpolated<=$signed({sine_value[15],sine_value}) + $signed(product>>>8);
                    state<=WEIGHT;
                end
                WEIGHT: state<=WEIGHT_USE;
                WEIGHT_USE: begin accumulator<=accumulator+$signed(product>>>15); state<=ADVANCE; end
                ADVANCE: begin
                    if(harmonic==7) begin
                        // Small deterministic breath component, under the same envelope.
                        shaped_sample<=accumulator+($signed(breath)<<<1); state<=ENVELOPE;
                        lfsr<={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
                    end else begin
                        harmonic<=harmonic+1'b1;
                        harmonic_step<=harmonic_step+{4'd0,pitch_step};
                        harmonic_phase<=harmonic_phase+frame_phase; state<=HARMONIC;
                    end
                end
                ENVELOPE: state<=ENV_USE;
                ENV_USE: begin enveloped_sample<=$signed(product>>>15); state<=DYNAMICS; end
                DYNAMICS: state<=OUTPUT;
                OUTPUT: begin mix_sample<=$signed(product>>>8); mix_valid<=1; state<=IDLE; end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
