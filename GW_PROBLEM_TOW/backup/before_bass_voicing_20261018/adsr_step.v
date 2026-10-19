// One shared envelope arithmetic unit, evaluated once per voice per 48 kHz frame.
module adsr_step #(
    parameter [23:0] ATTACK_STEP = 24'd69906,
    parameter [23:0] DECAY_STEP = 24'd711,
    parameter [23:0] SUSTAIN_LEVEL = 24'd3145728,
    parameter integer RELEASE_SHIFT = 14
) (
    input wire gate, trigger,
    input wire [2:0] state_in,
    input wire [23:0] level_in, release_step_in,
    output reg [2:0] state_out,
    output reg [23:0] level_out, release_step_out
);
    localparam OFF=0, ATTACK=1, DECAY=2, SUSTAIN=3, RELEASE=4;
    reg [24:0] attack_sum, release_rounded;
    always @* begin
        state_out = state_in;
        level_out = level_in;
        release_step_out = release_step_in;
        attack_sum = {1'b0, level_in} + ATTACK_STEP;
        release_rounded = {1'b0, level_in} + ((25'd1 << RELEASE_SHIFT)-1);
        if (trigger) begin
            level_out = ATTACK_STEP;
            state_out = gate ? ATTACK : RELEASE;
            release_step_out = (ATTACK_STEP >> RELEASE_SHIFT) + 1'b1;
        end else if (!gate && state_in != OFF && state_in != RELEASE) begin
            state_out = RELEASE;
            release_step_out = release_rounded >> RELEASE_SHIFT;
            if (release_step_out == 0) release_step_out = 1;
        end else begin
            case (state_in)
                OFF: level_out = 0;
                ATTACK: if (attack_sum >= 25'h0ffffff) begin
                    level_out = 24'hffffff; state_out = DECAY;
                end else level_out = attack_sum[23:0];
                DECAY: if (level_in <= SUSTAIN_LEVEL + DECAY_STEP) begin
                    level_out = SUSTAIN_LEVEL; state_out = SUSTAIN;
                end else level_out = level_in - DECAY_STEP;
                SUSTAIN: level_out = SUSTAIN_LEVEL;
                RELEASE: if (level_in <= release_step_in) begin
                    level_out = 0; state_out = OFF;
                end else level_out = level_in - release_step_in;
                default: begin level_out=0; state_out=OFF; end
            endcase
        end
    end
endmodule

// Register arithmetic candidates before the state-selection mux. This keeps
// RAM output -> envelope arithmetic -> DSP input out of a single clock path.
module adsr_pipeline #(
    parameter [23:0] ATTACK_STEP=24'd69906,
    parameter [23:0] DECAY_STEP=24'd711,
    parameter [23:0] SUSTAIN_LEVEL=24'd3145728,
    parameter integer RELEASE_SHIFT=14
) (
    input wire clk, capture, gate, trigger, valid_in,
    input wire [2:0] state_in,
    input wire [23:0] level_in, release_step_in,
    output reg [2:0] state_out,
    output reg [23:0] level_out, release_step_out
);
    localparam OFF=0, ATTACK=1, DECAY=2, SUSTAIN=3, RELEASE=4;
    reg [23:0] attack_level, decay_level, release_level, release_from_here;
    reg attack_done, decay_done, release_done;
    reg [23:0] old_level, old_release;
    reg [2:0] old_state;
    reg gate_q, trigger_q, valid_q;
    wire [24:0] attack_sum = {1'b0,level_in}+ATTACK_STEP;
    wire [24:0] release_rounded = {1'b0,level_in}+((25'd1<<RELEASE_SHIFT)-1);
    always @(posedge clk) if (capture) begin
        attack_level<=attack_sum[23:0];
        attack_done<=(level_in >= (24'hffffff-ATTACK_STEP));
        decay_level<=level_in-DECAY_STEP;
        decay_done<=(level_in<=SUSTAIN_LEVEL+DECAY_STEP);
        release_level<=level_in-release_step_in;
        release_done<=(level_in<=release_step_in);
        release_from_here<=release_rounded >> RELEASE_SHIFT;
        old_level<=level_in; old_release<=release_step_in; old_state<=state_in;
        gate_q<=gate; trigger_q<=trigger;
        valid_q<=valid_in;
    end
    always @* begin
        state_out=old_state;
        level_out=old_level;
        release_step_out=old_release;
        if (trigger_q) begin
            level_out=ATTACK_STEP;
            state_out=gate_q ? ATTACK : RELEASE;
            release_step_out=(ATTACK_STEP>>RELEASE_SHIFT)+1'b1;
        end else if (!valid_q) begin
            state_out=OFF; level_out=0; release_step_out=0;
        end else if (!gate_q && old_state!=OFF && old_state!=RELEASE) begin
            state_out=RELEASE;
            release_step_out=release_from_here==0 ? 24'd1 : release_from_here;
        end else case(old_state)
            OFF: level_out=0;
            ATTACK: if (attack_done) begin
                level_out=24'hffffff; state_out=DECAY;
            end else level_out=attack_level;
            DECAY: if (decay_done) begin
                level_out=SUSTAIN_LEVEL; state_out=SUSTAIN;
            end else level_out=decay_level;
            SUSTAIN: level_out=SUSTAIN_LEVEL;
            RELEASE: if (release_done) begin
                level_out=0; state_out=OFF;
            end else level_out=release_level;
            default: begin level_out=0; state_out=OFF; end
        endcase
    end
endmodule
