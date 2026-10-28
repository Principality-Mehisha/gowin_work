// Measured, parameter-only clarinet: 45 pitches, three dynamics, 32 partials.
// No note PCM. Spectral attack/sustain, relative phases and envelope/noise
// parameters come from offline Iowa recording analysis. One shared multiplier.
module clarinet_synth #(
    parameter SINE_FILE="src/rom/sine256.hex",
    parameter FREQ_FILE="src/rom/frequency88.hex",
    parameter VOICING_FILE="src/rom/clarinet45.hex",
    parameter ENVELOPE_FILE="src/rom/clarinet45_env.hex",
    parameter integer EXTERNAL_TABLES=0
) (
    input wire clk,reset_n,sample_tick,stop_all,
    input wire event_valid,event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    input wire [17:0] pitch_ratio,
    output wire event_ready,
    output reg signed [31:0] mix_sample,
    output reg mix_valid,
    output wire signed [15:0] pcm,
    output wire pcm_valid,limiting,saturated,
    output reg deadline_error,
    input wire tables_ready,
    output wire table_request,
    output wire [10:0] table_address,
    input wire table_request_ready, table_response_valid,
    input wire [127:0] table_response_data
);
    localparam IDLE=0,META_READ0=1,META_GET0=2,META_READ1=3,META_GET1=4,
        META_BLEND=5,META_USE=6,PREP=7,ENV_CURVE=8,ENV_CURVE_USE=9,
        TUNE=10,TUNE_USE=11,PARAM_READ0=12,PARAM_GET0=13,PARAM_READ1=14,PARAM_GET1=15,
        ATTACK_BLEND=16,ATTACK_USE=17,SUSTAIN_BLEND=18,SUSTAIN_USE=19,
        COLOR_BLEND=20,COLOR_USE=21,SINE_READ=22,INTERP=23,INTERP_USE=24,
        WEIGHT=25,WEIGHT_USE=26,ADVANCE=27,NOISE_BLEND=28,NOISE_USE=29,
        NOISE_MUL=30,NOISE_USE2=31,ENVELOPE=32,ENV_USE=33,GAIN=34,GAIN_USE=35,
        DYNAMICS=36,OUTPUT=37,CACHED_READ=38,CACHED_USE=39,
        PITCH_MOD=40,PITCH_USE=41,EXPRESSION=42,EXPR_USE=43,MULTIPLY=44;
    reg [5:0] state;
    reg [4:0] harmonic;
    reg [2:0] meta_field;
    reg gate,coeff_valid,frame_cached;
    reg [7:0] settle_age;
    reg [6:0] held_note;
    reg [7:0] dynamics,profile_lo,profile_hi;
    reg [8:0] blend;
    reg [15:0] envelope,envelope_work,frame_envelope,color,frame_color,release_age;
    reg [15:0] note_age,frame_expression;
    reg signed [17:0] breath_control,frame_pitch_delta;
    reg [17:0] frame_pitch_ratio;
    reg [15:0] attack_step,release_step,color_step,frame_gain,noise_attack,noise_sustain,noise_gain;
    reg [31:0] phase,frame_phase,pitch_word,pitch_step,harmonic_phase;
    reg [35:0] harmonic_step;
    reg [15:0] attack_weight,sustain_weight,weight;
    reg [7:0] phase_offset,fraction;
    reg signed [15:0] sine_rom[0:255];
    reg [31:0] frequency_rom[0:87];
    reg [39:0] param_q,param_lo,param_hi;
    reg [95:0] meta_q,meta_lo,meta_hi;
    reg [23:0] coeff_ram[0:31]; // {weight16,phase8}; validity is reset, RAM is not.
    reg [23:0] coeff_q;
    reg signed [15:0] sine_value,sine_next;
    reg signed [16:0] interpolated;
    reg signed [31:0] accumulator,shaped_sample,enveloped_sample,gained_sample;
    reg signed [31:0] mult_a;
    reg signed [17:0] mult_b;
    reg signed [49:0] product;
    reg signed [31:0] operand_a;
    reg signed [17:0] operand_b;
    reg [5:0] multiply_return;
    wire multiply_start=state==META_BLEND || state==ENV_CURVE || state==ATTACK_BLEND || state==SUSTAIN_BLEND ||
           state==COLOR_BLEND || state==INTERP || state==WEIGHT || state==NOISE_BLEND ||
           state==NOISE_MUL || state==ENVELOPE || state==GAIN || state==DYNAMICS ||
           state==PITCH_MOD || state==EXPRESSION;
    reg [49:0] tuning_product;
    reg [15:0] lfsr;
    reg signed [17:0] noise_fast,noise_slow,noise_centered;
    wire signed [17:0] noise_raw={{2{lfsr[15]}},lfsr};
    wire signed [17:0] next_noise_fast=noise_fast+((noise_raw-noise_fast)>>>1);
    wire signed [17:0] next_noise_slow=noise_slow+((noise_raw-noise_slow)>>>4);
    wire signed [16:0] sine_delta=$signed({sine_next[15],sine_next})-$signed({sine_value[15],sine_value});
    wire [31:0] read_phase=harmonic_phase+{phase_offset,24'd0};
    wire [6:0] incoming_index=event_note-7'd50;
    // A supported note blooms and relaxes; very small, smoothed pressure
    // fluctuations affect level and intonation. Every score note rearticulates.
    wire signed [17:0] next_breath=breath_control+((noise_raw-breath_control)>>>6);
    wire signed [17:0] frame_breath=note_age[5:0]==0 ? next_breath : breath_control;
    wire [16:0] onset_pitch={8'd0,note_age[8:0]}*17'd114;
    wire signed [17:0] pitch_start=note_age<512 ? -18'sd114+$signed({10'd0,onset_pitch[16:9]}) : 18'sd0;
    wire [15:0] expression_base=note_age<2048 ? 16'd24576+{3'd0,note_age[10:0],2'b0} :
        (note_age<16382 ? 16'd32767-((note_age-16'd2048)>>1) : 16'd25600);
    wire signed [18:0] expression_wide=$signed({3'd0,expression_base})+
                                                   ($signed({frame_breath[17],frame_breath})>>>2);
    wire [15:0] effective_attack=attack_step<81 ? 16'd81 : attack_step;
    wire [15:0] effective_release=release_step<51 ? 16'd51 : release_step;
    wire signed [49:0] target_weight_wide=$signed({34'd0,attack_weight})+(product>>>15);
    wire [15:0] target_weight=target_weight_wide[15:0];
    function [15:0] smooth_weight;
        input [15:0] old_value,target;
        reg signed [16:0] delta,step;
        begin
            delta=$signed({1'b0,target})-$signed({1'b0,old_value});step=delta>>>3;
            if(delta>0 && step==0)step=1;
            smooth_weight=$signed({1'b0,old_value})+step;
        end
    endfunction
    function [7:0] smooth_phase;
        input [7:0] old_value,target;
        reg signed [7:0] delta,step;
        begin
            delta=target-old_value;step=delta>>>3;
            if(delta>0 && step==0)step=1;
            smooth_phase=old_value+step;
        end
    endfunction
    wire [15:0] chosen_weight=coeff_valid ? smooth_weight(coeff_q[23:8],target_weight) : target_weight;
    wire [7:0] chosen_phase=coeff_valid ? smooth_phase(coeff_q[7:0],param_lo[39:32]) : param_lo[39:32];
    assign event_ready=reset_n && !stop_all && state==IDLE && !sample_tick &&
                       (EXTERNAL_TABLES==0 || tables_ready);
    // One DDR burst contains all three dynamics for one pitch/harmonic.
    // Fetch both interpolation endpoints together, halving runtime requests.
    assign table_request=EXTERNAL_TABLES!=0 && reset_n && !stop_all &&
        (state==META_READ0 || state==META_READ1 || state==PARAM_READ0);
    wire [5:0] incoming_held_index=held_note-7'd50;
    assign table_address=state==PARAM_READ0 ? {incoming_held_index,harmonic} :
        11'd1440+{3'd0,(state==META_READ1 ? profile_hi : profile_lo)};
    function [39:0] layer;
        input [127:0] row;
        input [7:0] profile_index;
        begin
            if(profile_index>=90)layer=row[119:80];
            else if(profile_index>=45)layer=row[79:40];
            else layer=row[39:0];
        end
    endfunction
    initial begin
        $readmemh(SINE_FILE,sine_rom);$readmemh(FREQ_FILE,frequency_rom);
    end
    generate if(EXTERNAL_TABLES==0) begin: internal_tables
        reg [39:0] voicing_rom[0:4319];
        reg [95:0] env_rom[0:134];
        initial begin
            $readmemh(VOICING_FILE,voicing_rom);$readmemh(ENVELOPE_FILE,env_rom);
        end
        always @(posedge clk) begin
            if(state==META_READ0)meta_q<=env_rom[profile_lo];
            if(state==META_READ1)meta_q<=env_rom[profile_hi];
            if(state==PARAM_READ0)param_q<=voicing_rom[{profile_lo,harmonic}];
            if(state==PARAM_READ1)param_q<=voicing_rom[{profile_hi,harmonic}];
        end
    end else begin: external_tables
        always @* begin meta_q=0;param_q=0;end
    end endgenerate
    always @* begin
        mult_a=0;mult_b=0;
        case(state)
            META_BLEND: begin
                mult_a=$signed({1'b0,meta_hi[meta_field*16 +:16]})-$signed({1'b0,meta_lo[meta_field*16 +:16]});
                mult_b=$signed({9'd0,blend});
            end
            ENV_CURVE: begin mult_a=$signed({16'd0,envelope_work});mult_b=$signed({2'd0,envelope_work});end
            ATTACK_BLEND: begin
                mult_a=$signed({1'b0,param_hi[15:0]})-$signed({1'b0,param_lo[15:0]});mult_b=$signed({9'd0,blend});
            end
            SUSTAIN_BLEND: begin
                mult_a=$signed({1'b0,param_hi[31:16]})-$signed({1'b0,param_lo[31:16]});mult_b=$signed({9'd0,blend});
            end
            COLOR_BLEND: begin mult_a=$signed({1'b0,sustain_weight})-$signed({1'b0,attack_weight});mult_b=$signed({2'd0,frame_color});end
            INTERP: begin mult_a=sine_delta;mult_b=$signed({10'd0,fraction});end
            WEIGHT: begin mult_a=interpolated;mult_b=$signed({2'd0,weight});end
            NOISE_BLEND: begin mult_a=$signed({1'b0,noise_sustain})-$signed({1'b0,noise_attack});mult_b=$signed({2'd0,frame_color});end
            NOISE_MUL: begin mult_a=noise_centered;mult_b=$signed({2'd0,noise_gain});end
            ENVELOPE: begin mult_a=shaped_sample;mult_b=$signed({2'd0,frame_envelope});end
            GAIN: begin mult_a=enveloped_sample;mult_b=$signed({2'd0,frame_gain});end
            PITCH_MOD: begin mult_a=$signed({14'd0,pitch_ratio});mult_b=frame_pitch_delta;end
            EXPRESSION: begin mult_a=gained_sample;mult_b=$signed({2'd0,frame_expression});end
            DYNAMICS: begin mult_a=gained_sample;mult_b=$signed({10'd0,dynamics});end
            default: begin mult_a=0;mult_b=0;end
        endcase
    end
    always @(posedge clk) begin
        if(state==COLOR_BLEND || state==CACHED_READ)coeff_q<=coeff_ram[harmonic];
        if(state==TUNE)tuning_product<=pitch_word*frame_pitch_ratio;
        // Register the DDR configuration's operands before the DSP, separating
        // the state/operand mux from the multiply's input setup requirement.
        if(EXTERNAL_TABLES!=0 && multiply_start)begin operand_a<=mult_a;operand_b<=mult_b;end
        if(EXTERNAL_TABLES==0 && multiply_start)product<=mult_a*mult_b;
        if(EXTERNAL_TABLES!=0 && state==MULTIPLY)product<=operand_a*operand_b;
        if(state==SINE_READ)begin
            sine_value<=sine_rom[read_phase[31:24]];
            sine_next<=sine_rom[read_phase[31:24]+8'd1];fraction<=read_phase[23:16];
        end
    end
    output_limiter #(.MASTER_SHIFT(1)) limiter (
        .clk(clk),.reset_n(reset_n),.clear(stop_all),.in_valid(mix_valid),.in_sample(mix_sample),
        .out_valid(pcm_valid),.out_sample(pcm),.limiting(limiting),.saturated(saturated));
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)begin
            state<=IDLE;harmonic<=0;meta_field<=0;gate<=0;coeff_valid<=0;held_note<=50;frame_cached<=0;settle_age<=0;
            multiply_return<=IDLE;
            dynamics<=0;profile_lo<=0;profile_hi<=0;blend<=0;envelope<=0;envelope_work<=0;
            note_age<=0;frame_expression<=32767;breath_control<=0;frame_pitch_delta<=0;frame_pitch_ratio<=193274;
            frame_envelope<=0;color<=0;frame_color<=0;release_age<=0;
            attack_step<=64;release_step<=32;color_step<=32;frame_gain<=4096;
            noise_attack<=0;noise_sustain<=0;noise_gain<=0;
            phase<=0;frame_phase<=0;pitch_word<=0;pitch_step<=0;harmonic_phase<=0;harmonic_step<=0;
            attack_weight<=0;sustain_weight<=0;weight<=0;phase_offset<=0;
            param_lo<=0;param_hi<=0;meta_lo<=0;meta_hi<=0;interpolated<=0;
            accumulator<=0;shaped_sample<=0;enveloped_sample<=0;gained_sample<=0;
            mix_sample<=0;mix_valid<=0;deadline_error<=0;lfsr<=16'h1ace;
            noise_fast<=0;noise_slow<=0;noise_centered<=0;
        end else if(stop_all)begin
            state<=IDLE;gate<=0;coeff_valid<=0;envelope<=0;frame_envelope<=0;color<=0;frame_cached<=0;settle_age<=0;
            phase<=0;dynamics<=0;accumulator<=0;mix_sample<=0;mix_valid<=0;
            noise_fast<=0;noise_slow<=0;noise_centered<=0;release_age<=0;
            note_age<=0;breath_control<=0;
        end else begin
            mix_valid<=0;
            if(sample_tick && state!=IDLE)deadline_error<=1;
            if(event_valid && event_ready && event_note>=50 && event_note<=94)begin
                if(event_on && event_dynamics!=0)begin
                    held_note<=event_note;gate<=1;dynamics<=event_dynamics;
                    pitch_word<=frequency_rom[event_note-21];release_age<=0;settle_age<=0;note_age<=0;
                    if(event_dynamics<=64)begin profile_lo<=incoming_index;profile_hi<=incoming_index;blend<=0;end
                    else if(event_dynamics<=160)begin
                        profile_lo<=incoming_index;profile_hi<=8'd45+incoming_index;
                        blend<=((event_dynamics-32'd64)*32'd256)/32'd96;
                    end else if(event_dynamics<=240)begin
                        profile_lo<=8'd45+incoming_index;profile_hi<=8'd90+incoming_index;
                        blend<=((event_dynamics-32'd160)*32'd256)/32'd80;
                    end else begin profile_lo<=8'd90+incoming_index;profile_hi<=8'd90+incoming_index;blend<=0;end
                    phase<=0;envelope<=0;color<=0;coeff_valid<=0;
                    lfsr<=16'h1ace+{9'd0,event_note};noise_fast<=0;noise_slow<=0;
                end else if(event_note==held_note)gate<=0;
            end
            case(state)
                IDLE: if(sample_tick)begin
                    if(!gate && envelope==0)begin mix_sample<=0;mix_valid<=1;end
                    else begin
                        frame_phase<=phase;meta_field<=0;harmonic<=0;accumulator<=0;
                        // After 128 fixed-target frames, the bounded coefficient
                        // slew has converged exactly. Reuse it without recomputing
                        // the unchanged ROM blends; audio arithmetic is identical.
                        frame_cached<=coeff_valid && color==32767 && settle_age==128;
                        state<=(coeff_valid && color==32767 && settle_age==128) ? PREP : META_READ0;
                    end
                end
                META_READ0:if(EXTERNAL_TABLES==0 || table_request_ready)state<=META_GET0;
                META_GET0:if(EXTERNAL_TABLES==0 || table_response_valid)begin
                    meta_lo<=EXTERNAL_TABLES!=0 ? table_response_data[95:0] : meta_q;state<=META_READ1;end
                META_READ1:if(EXTERNAL_TABLES==0 || table_request_ready)state<=META_GET1;
                META_GET1:if(EXTERNAL_TABLES==0 || table_response_valid)begin
                    meta_hi<=EXTERNAL_TABLES!=0 ? table_response_data[95:0] : meta_q;state<=META_BLEND;end
                META_BLEND:state<=META_USE;
                META_USE:begin
                    case(meta_field)
                        0:attack_step<=meta_lo[15:0]+$signed(product>>>8);
                        1:release_step<=meta_lo[31:16]+$signed(product>>>8);
                        2:color_step<=meta_lo[47:32]+$signed(product>>>8);
                        3:frame_gain<=meta_lo[63:48]+$signed(product>>>8);
                        4:noise_attack<=meta_lo[79:64]+$signed(product>>>8);
                        5:noise_sustain<=meta_lo[95:80]+$signed(product>>>8);
                    endcase
                    if(meta_field==5)state<=PREP;
                    else begin meta_field<=meta_field+1'b1;state<=META_BLEND;end
                end
                PREP:begin
                    if(color==32767 && settle_age<128)settle_age<=settle_age+1'b1;
                    if(note_age[5:0]==0)breath_control<=next_breath;
                    frame_pitch_delta<=pitch_start+(frame_breath>>>6);
                    frame_expression<=expression_wide<0 ? 16'd0 : (expression_wide>32767 ? 16'd32767 : expression_wide[15:0]);
                    if(gate)begin
                        if({1'b0,envelope}+{1'b0,effective_attack}>=17'd32767)begin envelope<=32767;envelope_work<=32767;end
                        else begin envelope<=envelope+effective_attack;envelope_work<=envelope+effective_attack;end
                        release_age<=0;
                    end else begin
                        if(envelope<=effective_release)begin envelope<=0;envelope_work<=0;end
                        else begin envelope<=envelope-effective_release;envelope_work<=envelope-effective_release;end
                        if(release_age!=65535)release_age<=release_age+1'b1;
                    end
                    if({1'b0,color}+{1'b0,color_step}>=17'd32767)begin color<=32767;frame_color<=32767;end
                    else begin color<=color+color_step;frame_color<=color+color_step;end
                    state<=ENV_CURVE;
                end
                ENV_CURVE:state<=ENV_CURVE_USE;
                ENV_CURVE_USE:begin frame_envelope<=product[30:15];state<=PITCH_MOD;end
                PITCH_MOD:state<=PITCH_USE;
                PITCH_USE:begin frame_pitch_ratio<=pitch_ratio+$signed(product>>>16);state<=TUNE;end
                TUNE:state<=TUNE_USE;
                TUNE_USE:begin
                    pitch_step<=tuning_product[47:16];harmonic_step<={4'd0,tuning_product[47:16]};
                    harmonic_phase<=frame_phase;phase<=frame_phase+tuning_product[47:16];state<=frame_cached ? CACHED_READ : PARAM_READ0;
                end
                PARAM_READ0:if(EXTERNAL_TABLES==0 || table_request_ready)state<=PARAM_GET0;
                CACHED_READ:state<=CACHED_USE;
                CACHED_USE:begin
                    weight<=coeff_q[23:8];phase_offset<=coeff_q[7:0];
                    state<=harmonic_step>=36'h078000000 ? ADVANCE : SINE_READ;
                end
                PARAM_GET0:if(EXTERNAL_TABLES==0 || table_response_valid)begin
                    if(EXTERNAL_TABLES!=0)begin
                        param_lo<=layer(table_response_data,profile_lo);
                        param_hi<=layer(table_response_data,profile_hi);state<=ATTACK_BLEND;
                    end else begin param_lo<=param_q;state<=PARAM_READ1;end
                end
                PARAM_READ1:state<=PARAM_GET1;
                PARAM_GET1:begin param_hi<=param_q;state<=ATTACK_BLEND;end
                ATTACK_BLEND:state<=ATTACK_USE;
                ATTACK_USE:begin attack_weight<=param_lo[15:0]+$signed(product>>>8);state<=SUSTAIN_BLEND;end
                SUSTAIN_BLEND:state<=SUSTAIN_USE;
                SUSTAIN_USE:begin sustain_weight<=param_lo[31:16]+$signed(product>>>8);state<=COLOR_BLEND;end
                COLOR_BLEND:state<=COLOR_USE;
                COLOR_USE:begin
                    coeff_ram[harmonic]<={chosen_weight,chosen_phase};weight<=chosen_weight;phase_offset<=chosen_phase;
                    state<=harmonic_step>=36'h078000000 ? ADVANCE : SINE_READ;
                end
                SINE_READ:state<=INTERP;
                INTERP:state<=INTERP_USE;
                INTERP_USE:begin interpolated<=$signed({sine_value[15],sine_value})+$signed(product[24:8]);state<=WEIGHT;end
                WEIGHT:state<=WEIGHT_USE;
                WEIGHT_USE:begin accumulator<=accumulator+$signed(product[46:15]);state<=ADVANCE;end
                ADVANCE:begin
                    if(harmonic==31)begin coeff_valid<=1;state<=NOISE_BLEND;end
                    else begin harmonic<=harmonic+1'b1;harmonic_step<=harmonic_step+{4'd0,pitch_step};harmonic_phase<=harmonic_phase+frame_phase;state<=frame_cached ? CACHED_READ : PARAM_READ0;end
                end
                NOISE_BLEND:state<=NOISE_USE;
                NOISE_USE:begin
                    noise_gain<=noise_attack+$signed(product>>>15);
                    noise_fast<=next_noise_fast;noise_slow<=next_noise_slow;
                    noise_centered<=next_noise_fast-next_noise_slow;
                    lfsr<={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};state<=NOISE_MUL;
                end
                NOISE_MUL:state<=NOISE_USE2;
                NOISE_USE2:begin shaped_sample<=accumulator+$signed(product[46:15]);state<=ENVELOPE;end
                ENVELOPE:state<=ENV_USE;
                ENV_USE:begin enveloped_sample<=$signed(product[46:15]);state<=GAIN;end
                GAIN:state<=GAIN_USE;
                GAIN_USE:begin gained_sample<=$signed(product[43:12]);state<=EXPRESSION;end
                EXPRESSION:state<=EXPR_USE;
                EXPR_USE:begin gained_sample<=$signed(product[46:15]);state<=DYNAMICS;end
                DYNAMICS:state<=OUTPUT;
                OUTPUT:begin
                    mix_sample<=$signed(product[39:8]);mix_valid<=1;state<=IDLE;
                    if(note_age!=65535)note_age<=note_age+1'b1;
                end
                MULTIPLY:state<=multiply_return;
                default:state<=IDLE;
            endcase
            if(EXTERNAL_TABLES!=0 && multiply_start)begin
                // Every arithmetic launch state is followed by its use state.
                multiply_return<=state+1'b1;state<=MULTIPLY;
            end
        end
    end
endmodule
