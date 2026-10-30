// Real PCM -> Hann-windowed, normalized 1024-point radix-2 FFT.
// One in-place synchronous RAM and four time-shared butterfly multipliers.
// Capture and compute are sequential: processing never stalls the audio path.
module piano_audio_analysis #(
    parameter WINDOW_FILE="src/video/analysis_window.hex",
    parameter TWIDDLE_FILE="src/video/analysis_twiddle.hex"
) (
    input wire clk,reset_n,clear,sample_valid,
    input wire signed [15:0] sample_pcm,
    input wire out_ready,
    output wire out_valid,
    output wire [8:0] out_address,
    output wire [31:0] out_data,
    output reg [31:0] completed_frames,
    output wire busy
);
    localparam WAIT_TRIGGER=0,CAPTURE=1,FLUSH=2,READ_A=3,READ_B=4,
        MULTIPLY=5,ROTATE=6,WRITE_A=7,WRITE_B=8,MAG_READ=9,MAG_ABS=10,
        MAG_LOG=11,EMIT=12;
    reg [3:0] state;
    reg [31:0] fft_ram[0:1023];
    reg signed [15:0] wave_ram[0:511];
    reg signed [15:0] window_rom[0:1023];
    reg [31:0] twiddle_rom[0:511];
    initial begin $readmemh(WINDOW_FILE,window_rom);$readmemh(TWIDDLE_FILE,twiddle_rom);end
    reg [9:0] capture_index,capture_address,trigger_wait;
    reg signed [15:0] previous_pcm,window_q;
    reg signed [31:0] window_product;
    reg capture_commit;
    reg [3:0] stage;
    reg [9:0] half_size,group_base,j;
    reg [8:0] twiddle_index;
    reg [9:0] stride;
    wire [9:0] address_a=group_base+j;
    wire [9:0] address_b=address_a+half_size;
    wire [10:0] next_group={1'b0,group_base}+({1'b0,half_size}<<1);
    reg [31:0] a_q,fft_q,twiddle_q;
    wire [31:0] b_q=fft_q,bin_q=fft_q;
    reg signed [31:0] product_rc,product_is,product_rs,product_ic;
    reg signed [17:0] rotated_r,rotated_i;
    wire signed [18:0] a_r=$signed(a_q[31:16]),a_i=$signed(a_q[15:0]);
    wire signed [18:0] sum_r=(a_r+rotated_r)>>>1,sum_i=(a_i+rotated_i)>>>1;
    wire signed [18:0] diff_r=(a_r-rotated_r)>>>1,diff_i=(a_i-rotated_i)>>>1;
    reg [8:0] bin_index;
    reg signed [15:0] wave_q;
    reg [16:0] magnitude;
    reg [8:0] previous_y;
    reg [31:0] packed_result;
    wire [15:0] abs_r=bin_q[31] ? -$signed(bin_q[31:16]) : bin_q[31:16];
    wire [15:0] abs_i=bin_q[15] ? -$signed(bin_q[15:0]) : bin_q[15:0];
    function [9:0] reverse10;
        input [9:0] value;integer k;
        begin for(k=0;k<10;k=k+1)reverse10[k]=value[9-k];end
    endfunction
    function [8:0] wave_y;
        input signed [15:0] value;reg signed [16:0] position;
        begin position=17'sd256-(value>>>7);wave_y=position>511 ? 9'd511 : position[8:0];end
    endfunction
    // A monotonic log2 amplitude approximation, with 1/16-octave interpolation.
    // An uncalibrated visual scale; neither SPL nor a power-spectrum estimate.
    function [9:0] log_height;
        input [16:0] value;integer k,top,level,height;reg found;
        begin
            top=0;found=0;
            for(k=16;k>=0;k=k-1)if(value[k] && !found)begin top=k;found=1;end
            if(top>=4)level=top*16+((value>>(top-4))&15);
            else level=top*16+((value<<(4-top))&15);
            height=level>48 ? (level-48)*3 : 0;
            log_height=height>511 ? 10'd511 : height[9:0];
        end
    endfunction
    assign out_valid=state==EMIT && !clear;
    assign out_address=bin_index;
    assign out_data=packed_result;
    assign busy=state!=WAIT_TRIGGER;
    wire fft_write=!clear && (capture_commit || state==WRITE_A || state==WRITE_B);
    wire [9:0] fft_write_address=capture_commit ? capture_address : (state==WRITE_A ? address_a : address_b);
    wire [31:0] fft_write_data=capture_commit ? {window_product[30:15],16'd0} :
        (state==WRITE_A ? {sum_r[15:0],sum_i[15:0]} : {diff_r[15:0],diff_i[15:0]});
    wire [9:0] fft_read_address=state==READ_B ? address_b : (state==MAG_READ ? {1'b0,bin_index} : address_a);
    wire first_sample=state==WAIT_TRIGGER && sample_valid && out_ready &&
        ((previous_pcm<0 && sample_pcm>=0) || trigger_wait==1023);
    wire wave_write=!clear && (first_sample || (state==CAPTURE && sample_valid && capture_index<512));
    // No bulk RAM reset: only complete, epoch-tagged output frames become visible.
    always @(posedge clk) begin
        window_q<=window_rom[capture_index];
        if(fft_write)fft_ram[fft_write_address]<=fft_write_data;
        fft_q<=fft_ram[fft_read_address];
        if(wave_write)wave_ram[first_sample ? 9'd0 : capture_index[8:0]]<=sample_pcm;
        if(state==READ_A)twiddle_q<=twiddle_rom[twiddle_index];
        if(state==READ_B)a_q<=fft_q;
        if(state==MAG_READ)wave_q<=wave_ram[bin_index];
    end
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)begin
            state<=WAIT_TRIGGER;capture_index<=0;capture_address<=0;trigger_wait<=0;
            previous_pcm<=0;window_product<=0;capture_commit<=0;
            stage<=0;half_size<=1;group_base<=0;j<=0;stride<=512;twiddle_index<=0;
            product_rc<=0;product_is<=0;product_rs<=0;product_ic<=0;
            rotated_r<=0;rotated_i<=0;bin_index<=0;magnitude<=0;previous_y<=256;
            packed_result<=0;completed_frames<=0;
        end else if(clear)begin
            state<=WAIT_TRIGGER;capture_index<=0;capture_commit<=0;trigger_wait<=0;previous_pcm<=0;
        end else begin
            capture_commit<=0;
            if(sample_valid)previous_pcm<=sample_pcm;
            case(state)
                WAIT_TRIGGER: if(sample_valid && out_ready)begin
                    if((previous_pcm<0 && sample_pcm>=0) || trigger_wait==1023)begin
                        window_product<=sample_pcm*window_q;capture_address<=0;
                        capture_commit<=1;capture_index<=1;state<=CAPTURE;
                    end else trigger_wait<=trigger_wait+1'b1;
                end
                CAPTURE: if(sample_valid)begin
                    window_product<=sample_pcm*window_q;capture_address<=reverse10(capture_index);
                    capture_commit<=1;
                    if(capture_index==1023)begin capture_index<=0;state<=FLUSH;end
                    else capture_index<=capture_index+1'b1;
                end
                FLUSH:begin stage<=0;half_size<=1;group_base<=0;j<=0;stride<=512;twiddle_index<=0;state<=READ_A;end
                READ_A:state<=READ_B;
                READ_B:state<=MULTIPLY;
                MULTIPLY:begin
                    product_rc<=$signed(b_q[31:16])*$signed(twiddle_q[31:16]);
                    product_is<=$signed(b_q[15:0])*$signed(twiddle_q[15:0]);
                    product_rs<=$signed(b_q[31:16])*$signed(twiddle_q[15:0]);
                    product_ic<=$signed(b_q[15:0])*$signed(twiddle_q[31:16]);
                    state<=ROTATE;
                end
                ROTATE:begin
                    rotated_r<=($signed({product_rc[31],product_rc})-$signed({product_is[31],product_is}))>>>15;
                    rotated_i<=($signed({product_rs[31],product_rs})+$signed({product_ic[31],product_ic}))>>>15;
                    state<=WRITE_A;
                end
                WRITE_A:state<=WRITE_B;
                WRITE_B:begin
                    state<=READ_A;
                    if(j==half_size-1'b1)begin
                        j<=0;twiddle_index<=0;
                        if(next_group==1024)begin
                            group_base<=0;
                            if(stage==9)begin bin_index<=0;previous_y<=256;state<=MAG_READ;end
                            else begin stage<=stage+1'b1;half_size<=half_size<<1;stride<=stride>>1;end
                        end else group_base<=next_group[9:0];
                    end else begin j<=j+1'b1;twiddle_index<=twiddle_index+stride;end
                end
                MAG_READ:state<=MAG_ABS;
                MAG_ABS:begin magnitude<={1'b0,abs_r}+{1'b0,abs_i};state<=MAG_LOG;end
                MAG_LOG:begin
                    packed_result<={4'd0,(wave_y(wave_q)<previous_y ? wave_y(wave_q) : previous_y),
                        (wave_y(wave_q)>previous_y ? wave_y(wave_q) : previous_y),log_height(magnitude)};
                    previous_y<=wave_y(wave_q);state<=EMIT;
                end
                EMIT:if(out_ready)begin
                    if(bin_index==511)begin state<=WAIT_TRIGGER;trigger_wait<=0;completed_frames<=completed_frames+1'b1;end
                    else begin bin_index<=bin_index+1'b1;state<=MAG_READ;end
                end
                default:state<=WAIT_TRIGGER;
            endcase
        end
    end
endmodule
