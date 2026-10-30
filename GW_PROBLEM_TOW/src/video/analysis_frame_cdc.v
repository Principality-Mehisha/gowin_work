// Two banks, one writer and one pixel reader. A bank remains immutable until
// a vertical-blank swap has returned its acknowledgement to the writer.
module analysis_frame_cdc (
    input wire sys_clk,sys_reset_n,clear,
    input wire write_valid,
    input wire [8:0] write_address,
    input wire [31:0] write_data,
    output wire write_ready,
    input wire pixel_clk,pixel_reset_n,frame_tick,
    input wire [8:0] read_address,
    output reg [31:0] read_data,
    output reg visible_valid
);
    reg [31:0] frames[0:1023];
    reg write_bank,read_bank,request,acknowledge,previous_clear;
    reg [7:0] epoch_counter;
    reg [7:0] epoch;
    wire [7:0] next_epoch=epoch_counter+1'b1;
    reg published_bank;
    reg [7:0] published_epoch;
    (* ASYNC_REG="TRUE" *) reg ack_meta_s0,ack_sync;
    (* ASYNC_REG="TRUE" *) reg req_meta_s0,req_sync;
    (* ASYNC_REG="TRUE" *) reg [7:0] epoch_meta_s0,epoch_sync;
    reg [7:0] seen_epoch;
    assign write_ready=request==ack_sync && !clear;
    always @(posedge sys_clk)if(write_valid && write_ready)
        frames[{write_bank,write_address}]<=write_data;
    always @(posedge pixel_clk)read_data<=frames[{read_bank,read_address}];
    always @(posedge sys_clk or negedge sys_reset_n)begin
        if(!sys_reset_n)begin
            write_bank<=1;request<=0;published_bank<=0;published_epoch<=0;
            ack_meta_s0<=0;ack_sync<=0;epoch_counter<=0;epoch<=0;previous_clear<=1;
        end else begin
            ack_meta_s0<=acknowledge;ack_sync<=ack_meta_s0;previous_clear<=clear;
            // Register Gray code at the source: a binary carry must not glitch
            // the bus sampled by the pixel-domain synchronizers.
            if(clear && !previous_clear)begin epoch_counter<=next_epoch;epoch<=(next_epoch>>1)^next_epoch;end
            if(write_valid && write_ready && write_address==511)begin
                published_bank<=write_bank;published_epoch<=epoch;
                request<=!request;write_bank<=!write_bank;
            end
        end
    end
    always @(posedge pixel_clk or negedge pixel_reset_n)begin
        if(!pixel_reset_n)begin
            req_meta_s0<=0;req_sync<=0;epoch_meta_s0<=0;epoch_sync<=0;
            acknowledge<=0;read_bank<=0;seen_epoch<=0;visible_valid<=0;
        end else begin
            req_meta_s0<=request;req_sync<=req_meta_s0;
            epoch_meta_s0<=epoch;epoch_sync<=epoch_meta_s0;
            if(frame_tick)begin
                if(seen_epoch!=epoch_sync)begin visible_valid<=0;seen_epoch<=epoch_sync;end
                if(req_sync!=acknowledge)begin
                    acknowledge<=req_sync;
                    if(published_epoch==epoch_sync)begin read_bank<=published_bank;visible_valid<=1;end
                end
            end
        end
    end
endmodule
