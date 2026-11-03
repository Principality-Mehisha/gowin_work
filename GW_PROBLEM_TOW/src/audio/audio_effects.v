// 0 dry, 1 feedback delay, 2 tremolo (level), 3 vibrato (pitch).
// Delay/vibrato share synchronous RAM; fill counts hide stale contents.
module audio_effects #(
    parameter integer FRAME_CYCLES=3072,
    parameter integer CLOCK_HZ=50000000,
    parameter integer CONTROL_RATE_RATIO=1,
    parameter integer DELAY_SAMPLES=(64'd1*CLOCK_HZ*300+FRAME_CYCLES*500)/(FRAME_CYCLES*1000),
    parameter integer VIBRATO_BASE=64'd80*CLOCK_HZ/50000000,
    parameter integer VIBRATO_DEPTH=64'd32*CLOCK_HZ/50000000,
    parameter [31:0] LFO_STEP=(64'd4294967296*5*FRAME_CYCLES+CLOCK_HZ/2)/CLOCK_HZ,
    parameter integer DELAY_TAIL=64'd1*CLOCK_HZ*4/FRAME_CYCLES,
    parameter integer VIBRATO_TAIL=VIBRATO_BASE+VIBRATO_DEPTH+2
) (
    input wire clk,reset_n,clear,in_valid,
    input wire signed [15:0] in_sample,
    input wire [1:0] mode,
    input wire [6:0] amount,
    output reg signed [15:0] out_sample,
    output reg out_valid,deadline_error,
    output wire busy,tail_active,
    output reg [1:0] applied_mode
);
    localparam IDLE=0,READ_WAIT=1,CALC=2,STORE=3,MIX=4,EMIT=5,
               V_WAIT0=6,V_SAVE0=7,V_WAIT1=8,V_SAVE1=9,V_BLEND=10,V_STORE=11,
               T_CALC=12,T_GAIN=13;
    reg [3:0] state;
    localparam RAM_BITS=DELAY_SAMPLES>8191 ? 14 : 13;
    localparam TAIL_MAX=DELAY_TAIL>VIBRATO_TAIL ? DELAY_TAIL : VIBRATO_TAIL;
    localparam TAIL_BITS=TAIL_MAX<2 ? 1 : $clog2(TAIL_MAX+1);
    localparam CONTROL_BITS=CONTROL_RATE_RATIO<2 ? 1 : $clog2(CONTROL_RATE_RATIO);
    reg [CONTROL_BITS-1:0] control_phase;
    wire control_step=control_phase==0;
    reg signed [15:0] memory[0:(1<<RAM_BITS)-1];
    reg signed [15:0] memory_q,write_data;
    reg [RAM_BITS-1:0] read_address,write_address,position,filled;
    reg write_enable,warm;
    reg signed [15:0] dry,wet,tap0;
    reg [6:0] wet_gain;
    reg [8:0] vibrato_mix,sample_gain;
    reg [TAIL_BITS-1:0] tail_count;
    reg [31:0] lfo_phase;
    reg [7:0] fraction;
    reg [8:0] vibrato_delay;
    reg signed [25:0] product;
    wire [6:0] bounded_amount=amount>100 ? 7'd100 : amount;
    // Depth ramps by one Q0.8 unit per sample. Delay retains its old mix.
    wire [6:0] target_gain=mode==0 ? 7'd0 : bounded_amount+(bounded_amount>>2);
    wire [6:0] next_gain=!control_step ? wet_gain : (mode!=applied_mode || mode==0) ?
        (wet_gain!=0 ? wet_gain-1'b1 : 7'd0) :
        wet_gain<target_gain ? wet_gain+1'b1 :
        wet_gain>target_gain ? wet_gain-1'b1 : wet_gain;
    // Vibrato is fully pitch-modulated after the fade, not a chorus mix.
    // Its amount controls delay excursion, independently of bypass fading.
    wire want_vibrato=mode==3 && applied_mode==3 && bounded_amount!=0;
    wire [8:0] next_vibrato_mix=!control_step ? vibrato_mix : want_vibrato ?
        (vibrato_mix<256 ? vibrato_mix+1'b1 : 9'd256) :
        (vibrato_mix!=0 ? vibrato_mix-1'b1 : 9'd0);
    wire [15:0] folded=lfo_phase[31] ? ~lfo_phase[30:15] : lfo_phase[30:15];
    wire signed [16:0] triangle=$signed({1'b0,folded})-17'sd32768;
    wire signed [31:0] triangle_ext={{15{triangle[16]}},triangle};
    wire signed [31:0] delay_excursion=(triangle_ext*VIBRATO_DEPTH)*$signed({1'b0,next_gain});
    wire signed [31:0] delay_q8=VIBRATO_BASE*256+(delay_excursion>>>14);
    wire [8:0] requested_delay=delay_q8[16:8];
    wire signed [15:0] old_value=warm ? memory_q : 16'sd0;
    wire signed [31:0] old_ext={{16{old_value[15]}},old_value};
    wire signed [31:0] dry_ext={{16{dry[15]}},dry};
    wire signed [16:0] mult_a=state==V_SAVE1 ?
        $signed({old_value[15],old_value})-$signed({tap0[15],tap0}) :
        state==T_CALC ? $signed({dry[15],dry}) :
        $signed({wet[15],wet})-$signed({dry[15],dry});
    wire [8:0] mult_b=state==V_SAVE1 ? {1'b0,fraction} :
        state==T_CALC ? {1'b0,folded[15:8]} : sample_gain;
    assign busy=state!=IDLE;
    assign tail_active=tail_count!=0 &&
        ((applied_mode==1 && wet_gain!=0) || (applied_mode==3 && vibrato_mix!=0));
    function signed [15:0] saturate;
        input signed [31:0] value;
        begin
            if(value>32767)saturate=16'sh7fff;
            else if(value< -32768)saturate=16'sh8000;
            else saturate=value[15:0];
        end
    endfunction
    always @(posedge clk)begin
        if(state==READ_WAIT || state==V_WAIT0 || state==V_WAIT1)
            memory_q<=memory[read_address];
        if(reset_n && !clear && write_enable)memory[write_address]<=write_data;
    end
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            state<=IDLE;out_sample<=0;out_valid<=0;deadline_error<=0;control_phase<=0;
            read_address<=0;write_address<=0;write_data<=0;write_enable<=0;
            dry<=0;wet<=0;tap0<=0;wet_gain<=0;sample_gain<=0;vibrato_mix<=0;
            tail_count<=0;applied_mode<=0;lfo_phase<=0;fraction<=0;
            vibrato_delay<=0;warm<=0;product<=0;position<=0;filled<=0;
        end else if(clear)begin
            state<=IDLE;out_sample<=0;out_valid<=0;deadline_error<=0;write_enable<=0;control_phase<=0;
            wet_gain<=0;sample_gain<=0;vibrato_mix<=0;tail_count<=0;
            applied_mode<=mode;lfo_phase<=0;position<=0;filled<=0;
        end else begin
            out_valid<=0;write_enable<=0;
            if(in_valid && state!=IDLE)deadline_error<=1;
            case(state)
                IDLE:if(in_valid)begin
                    control_phase<=control_phase==CONTROL_RATE_RATIO-1 ? 0 : control_phase+1'b1;
                    dry<=in_sample;wet_gain<=next_gain;vibrato_mix<=next_vibrato_mix;
                    sample_gain<=applied_mode==3 ? next_vibrato_mix : {2'd0,next_gain};
                    if(applied_mode==0 || applied_mode==2)tail_count<=0;
                    else if(in_sample>4 || in_sample< -4)
                        tail_count<=applied_mode==1 ? DELAY_TAIL : VIBRATO_TAIL;
                    else if(tail_count!=0)tail_count<=tail_count-1'b1;
                    if(mode!=applied_mode && wet_gain==0 && vibrato_mix==0)begin
                        applied_mode<=mode;wet<=0;sample_gain<=0;tail_count<=0;lfo_phase<=0;
                        position<=0;filled<=0;state<=MIX;
                    end else case(applied_mode)
                        0:begin wet<=0;state<=MIX;end
                        1:begin
                            read_address<=position;warm<=filled>=DELAY_SAMPLES;state<=READ_WAIT;
                        end
                        2:state<=T_CALC;
                        3:begin
                            read_address<={4'd0,(position[8:0]-requested_delay)};
                            vibrato_delay<=requested_delay;fraction<=delay_q8[7:0];
                            warm<=filled>=requested_delay;state<=V_WAIT0;
                        end
                    endcase
                end
                READ_WAIT:state<=CALC;
                CALC:begin
                    wet<=old_value;write_data<=saturate(dry_ext+(old_ext>>>1));
                    write_enable<=1;write_address<=read_address;state<=STORE;
                end
                STORE:begin
                    position<=position==DELAY_SAMPLES-1 ? 13'd0 : position+1'b1;
                    if(filled<DELAY_SAMPLES)filled<=filled+1'b1;
                    state<=MIX;
                end
                T_CALC:begin product<=mult_a*$signed({1'b0,mult_b});state<=T_GAIN;end
                T_GAIN:begin
                    // Equivalent to amplitude modulation down to ~3% at
                    // amount=100. The signed intermediate is never wrapped.
                    wet<=saturate(dry_ext-(product>>>7));
                    lfo_phase<=lfo_phase+LFO_STEP;state<=MIX;
                end
                V_WAIT0:state<=V_SAVE0;
                V_SAVE0:begin
                    tap0<=old_value;
                    read_address<={4'd0,(position[8:0]-vibrato_delay-9'd1)};
                    warm<=filled>=vibrato_delay+1'b1;state<=V_WAIT1;
                end
                V_WAIT1:state<=V_SAVE1;
                V_SAVE1:begin product<=mult_a*$signed({1'b0,mult_b});state<=V_BLEND;end
                V_BLEND:begin
                    wet<=saturate($signed(tap0)+(product>>>8));
                    write_address<=position;write_data<=dry;write_enable<=1;state<=V_STORE;
                end
                V_STORE:begin
                    position<={4'd0,(position[8:0]+9'd1)};
                    if(filled<512)filled<=filled+1'b1;
                    lfo_phase<=lfo_phase+LFO_STEP;state<=MIX;
                end
                MIX:begin product<=mult_a*$signed({1'b0,mult_b});state<=EMIT;end
                EMIT:begin
                    out_sample<=dry==0 && tail_count==0 ? 16'sd0 : saturate(dry_ext+(product>>>8));
                    out_valid<=1;state<=IDLE;
                end
                default:state<=IDLE;
            endcase
        end
    end
endmodule
