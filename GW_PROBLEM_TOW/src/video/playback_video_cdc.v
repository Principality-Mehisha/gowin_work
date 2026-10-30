// Bundled-data request/acknowledge mailbox; source bus stays stable until ACK.
module playback_video_cdc (
    input wire sys_clk, sys_reset_n, pixel_clk, pixel_reset_n, frame_tick,
    input wire active,
    input wire [1:0] display_mode,
    output reg [1:0] video_mode,
    input wire [31:0] elapsed_ms,
    input wire [87:0] keys,
    output reg update,
    output reg video_active,
    output reg [31:0] video_ms,
    output reg [87:0] video_keys
);
    reg request, acknowledge;
    (* syn_async_reg = 1 *) reg req_meta, req_sync;
    (* syn_async_reg = 1 *) reg ack_meta, ack_sync;
    reg [122:0] mailbox;
    always @(posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n) begin req_meta<=0; req_sync<=0; acknowledge<=0; mailbox<=0; end
        else begin
            req_meta<=request; req_sync<=req_meta;
            if (req_sync != acknowledge) begin
                mailbox<={display_mode,active,elapsed_ms,(active ? keys : 88'd0)}; acknowledge<=req_sync;
            end
        end
    end
    // Pixel reset also resets sys-side handshake via top-level shared reset.
    reg delivered;
    always @(posedge pixel_clk or negedge pixel_reset_n) begin
        if (!pixel_reset_n) begin
            request<=0; ack_meta<=0; ack_sync<=0; delivered<=0;
            update<=0; video_mode<=0; video_active<=0; video_ms<=0; video_keys<=0;
        end else begin
            ack_meta<=acknowledge; ack_sync<=ack_meta; update<=0;
            if (frame_tick && request==ack_sync) request<=!request;
            if (ack_sync != delivered) begin
                {video_mode,video_active,video_ms,video_keys}<=mailbox;
                delivered<=ack_sync; update<=1;
            end
        end
    end
endmodule
