// Mutually exclusive mono effects. One 8192x16 synchronous RAM is shared
// by delay, four feedback combs/two allpasses, and interpolated chorus.
// RAM contents are never reset; per-line fill counts hide stale words.
module audio_effects #(
    parameter integer FRAME_CYCLES=3072,
    parameter integer DELAY_SAMPLES=(64'd50000000*300+FRAME_CYCLES*500)/(FRAME_CYCLES*1000),
    parameter integer COMB0=497,COMB1=631,COMB2=719,COMB3=809,AP0=113,AP1=37,
    parameter integer CHORUS_BASE=244,CHORUS_DEPTH=49,
    parameter [31:0] LFO_STEP=(64'd4294967296*3*FRAME_CYCLES+250000000)/500000000,
    parameter integer DELAY_TAIL=64'd50000000*4/FRAME_CYCLES,
    parameter integer REVERB_TAIL=64'd50000000*3/FRAME_CYCLES,
    parameter integer CHORUS_TAIL=814
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
               CH_WAIT0=6,CH_SAVE0=7,CH_WAIT1=8,CH_SAVE1=9,CH_BLEND=10,CH_STORE=11;
    reg [3:0] state;
    reg signed [15:0] memory[0:8191];
    reg signed [15:0] memory_q,write_data;
    reg [12:0] read_address,write_address;
    reg write_enable;
    reg [12:0] position[0:5],filled[0:5];
    reg [2:0] line;
    reg warm;
    reg signed [15:0] dry,wet,tap0;
    reg signed [31:0] sum,ap_input,ap_next;
    reg [6:0] wet_gain,sample_gain;
    reg [15:0] tail_count;
    reg [31:0] lfo_phase;
    reg [7:0] fraction;
    reg [12:0] chorus_delay;
    reg signed [25:0] product;
    wire [6:0] bounded_amount=amount>100 ? 7'd100 : amount;
    // Maximum wet weight is 125/256. "100" is a safe preset intensity,
    // never unity feedback or a fully delayed signal without dry attack.
    wire [6:0] target_gain=mode==0 ? 7'd0 : bounded_amount+(bounded_amount>>2);
    wire [6:0] next_gain=(mode!=applied_mode || mode==0) ?
        (wet_gain!=0 ? wet_gain-1'b1 : 7'd0) :
        wet_gain<target_gain ? wet_gain+1'b1 :
        wet_gain>target_gain ? wet_gain-1'b1 : wet_gain;
    wire [15:0] folded=lfo_phase[31] ? ~lfo_phase[30:15] : lfo_phase[30:15];
    wire signed [16:0] triangle=$signed({1'b0,folded})-17'sd32768;
    wire signed [31:0] triangle_ext={{15{triangle[16]}},triangle};
    wire signed [31:0] delay_q8=CHORUS_BASE*256+((triangle_ext*CHORUS_DEPTH)>>>7);
    wire [12:0] requested_delay=delay_q8[20:8];
    wire signed [15:0] old_value=warm ? memory_q : 16'sd0;
    wire signed [31:0] old_ext={{16{old_value[15]}},old_value};
    wire signed [31:0] dry_ext={{16{dry[15]}},dry};
    wire signed [31:0] allpass_value=old_ext-(ap_input>>>1);
    wire signed [16:0] mult_a=state==CH_SAVE1 ?
        $signed({old_value[15],old_value})-$signed({tap0[15],tap0}) :
        $signed({wet[15],wet})-$signed({dry[15],dry});
    wire [7:0] mult_b=state==CH_SAVE1 ? fraction : {1'b0,sample_gain};
    assign busy=state!=IDLE;
    assign tail_active=applied_mode!=0 && wet_gain!=0 && tail_count!=0;
    function signed [15:0] saturate;
        input signed [31:0] value;
        begin
            if(value>32767)saturate=16'sh7fff;
            else if(value< -32768)saturate=16'sh8000;
            else saturate=value[15:0];
        end
    endfunction
    function [12:0] length;
        input [2:0] index;
        begin
            case(index)
                0:length=COMB0;1:length=COMB1;2:length=COMB2;
                3:length=COMB3;4:length=AP0;default:length=AP1;
            endcase
        end
    endfunction
    function [12:0] base;
        input [2:0] index;
        begin
            case(index)
                0:base=0;1:base=COMB0;2:base=COMB0+COMB1;
                3:base=COMB0+COMB1+COMB2;
                4:base=COMB0+COMB1+COMB2+COMB3;
                default:base=COMB0+COMB1+COMB2+COMB3+AP0;
            endcase
        end
    endfunction
    always @(posedge clk)begin
        if(state==READ_WAIT || state==CH_WAIT0 || state==CH_WAIT1)
            memory_q<=memory[read_address];
        if(reset_n && !clear && write_enable)memory[write_address]<=write_data;
    end
    integer i;
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            state<=IDLE;out_sample<=0;out_valid<=0;deadline_error<=0;
            read_address<=0;write_address<=0;write_data<=0;write_enable<=0;
            dry<=0;wet<=0;tap0<=0;sum<=0;ap_input<=0;ap_next<=0;
            wet_gain<=0;sample_gain<=0;tail_count<=0;applied_mode<=0;
            lfo_phase<=0;fraction<=0;chorus_delay<=0;line<=0;warm<=0;product<=0;
            for(i=0;i<6;i=i+1)begin position[i]<=0;filled[i]<=0;end
        end else if(clear)begin
            state<=IDLE;out_sample<=0;out_valid<=0;deadline_error<=0;write_enable<=0;
            wet_gain<=0;sample_gain<=0;tail_count<=0;applied_mode<=mode;lfo_phase<=0;
            for(i=0;i<6;i=i+1)begin position[i]<=0;filled[i]<=0;end
        end else begin
            out_valid<=0;write_enable<=0;
            if(in_valid && state!=IDLE)deadline_error<=1;
            case(state)
                IDLE:if(in_valid)begin
                    dry<=in_sample;sample_gain<=next_gain;wet_gain<=next_gain;
                    if(applied_mode==0)tail_count<=0;
                    else if(in_sample>4 || in_sample< -4)
                        tail_count<=applied_mode==1 ? DELAY_TAIL :
                                    applied_mode==2 ? REVERB_TAIL : CHORUS_TAIL;
                    else if(tail_count!=0)tail_count<=tail_count-1'b1;
                    if(mode!=applied_mode && wet_gain==0)begin
                        applied_mode<=mode;wet<=0;sample_gain<=0;tail_count<=0;lfo_phase<=0;
                        for(i=0;i<6;i=i+1)begin position[i]<=0;filled[i]<=0;end
                        state<=MIX;
                    end else case(applied_mode)
                        0:begin wet<=0;state<=MIX;end
                        1:begin
                            read_address<=position[0];warm<=filled[0]>=DELAY_SAMPLES;
                            state<=READ_WAIT;
                        end
                        2:begin
                            line<=0;sum<=0;read_address<=position[0];
                            warm<=filled[0]>=COMB0;state<=READ_WAIT;
                        end
                        3:begin
                            read_address<={4'd0,(position[0][8:0]-requested_delay[8:0])};
                            chorus_delay<=requested_delay;fraction<=delay_q8[7:0];
                            warm<=filled[0]>=requested_delay;state<=CH_WAIT0;
                        end
                    endcase
                end
                READ_WAIT:state<=CALC;
                CALC:begin
                    write_enable<=1;write_address<=read_address;
                    if(applied_mode==1)begin
                        wet<=old_value;write_data<=saturate(dry_ext+(old_ext>>>1));
                    end else if(line<4)begin
                        sum<=sum+old_ext;
                        write_data<=saturate((dry_ext>>>2)+old_ext-(old_ext>>>2));
                    end else begin
                        ap_next<=allpass_value;
                        write_data<=saturate(ap_input+(allpass_value>>>1));
                    end
                    state<=STORE;
                end
                STORE:begin
                    if(applied_mode==1)begin
                        position[0]<=position[0]==DELAY_SAMPLES-1 ? 13'd0 : position[0]+1'b1;
                        if(filled[0]<DELAY_SAMPLES)filled[0]<=filled[0]+1'b1;
                        state<=MIX;
                    end else begin
                        position[line]<=position[line]==length(line)-1 ? 13'd0 : position[line]+1'b1;
                        if(filled[line]<length(line))filled[line]<=filled[line]+1'b1;
                        if(line==5)begin wet<=saturate(ap_next);state<=MIX;end
                        else begin
                            if(line==3)ap_input<=sum>>>2;
                            if(line==4)ap_input<=ap_next;
                            line<=line+1'b1;
                            read_address<=base(line+1'b1)+position[line+1'b1];
                            warm<=filled[line+1'b1]>=length(line+1'b1);state<=READ_WAIT;
                        end
                    end
                end
                CH_WAIT0:state<=CH_SAVE0;
                CH_SAVE0:begin
                    tap0<=old_value;
                    read_address<={4'd0,(position[0][8:0]-chorus_delay[8:0]-9'd1)};
                    warm<=filled[0]>=chorus_delay+1'b1;state<=CH_WAIT1;
                end
                CH_WAIT1:state<=CH_SAVE1;
                CH_SAVE1:begin product<=mult_a*$signed({1'b0,mult_b});state<=CH_BLEND;end
                CH_BLEND:begin
                    wet<=saturate($signed(tap0)+(product>>>8));
                    write_address<=position[0];write_data<=dry;write_enable<=1;state<=CH_STORE;
                end
                CH_STORE:begin
                    position[0]<={4'd0,(position[0][8:0]+9'd1)};
                    if(filled[0]<512)filled[0]<=filled[0]+1'b1;
                    lfo_phase<=lfo_phase+LFO_STEP;state<=MIX;
                end
                MIX:begin product<=mult_a*$signed({1'b0,mult_b});state<=EMIT;end
                EMIT:begin
                    out_sample<=dry==0 && tail_count==0 ? 16'sd0 :
                        saturate(dry_ext+(product>>>8));
                    out_valid<=1;state<=IDLE;
                end
                default:state<=IDLE;
            endcase
        end
    end
endmodule
