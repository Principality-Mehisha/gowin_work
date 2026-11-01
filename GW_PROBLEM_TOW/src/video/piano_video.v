// Video remains locked/visible when playback stops. Only the scene is cleared.
module piano_video (
    input wire sys_clk, reset_n, active,
    input wire clear,
    input wire [31:0] elapsed_ms,
    input wire [87:0] keys,
    input wire [1:0] display_mode,
    input wire audio_active,analysis_clear,sample_tick,
    input wire signed [15:0] sample_pcm,
    output wire [2:0] tmds_data_p,tmds_data_n,
    output wire tmds_clk_p,tmds_clk_n
);
    wire pixel_clk,serial_clk,locked;
    video_clock clocks(.sys_clk(sys_clk),.reset(!reset_n),
        .serial_clk(serial_clk),.pixel_clk(pixel_clk),.locked(locked));
    wire clocks_ready=locked && reset_n;
    reg [3:0] release_pipe,sys_release;
    always @(posedge pixel_clk or negedge clocks_ready) begin
        if(!clocks_ready) release_pipe<=0;
        else release_pipe<={release_pipe[2:0],1'b1};
    end
    always @(posedge sys_clk or negedge clocks_ready) begin
        if(!clocks_ready) sys_release<=0;
        else sys_release<={sys_release[2:0],1'b1};
    end
    wire video_reset_n=release_pipe[3];
    wire frame_tick,update,video_active;
    wire [31:0] video_ms;
    wire [87:0] video_keys;
    wire [87:0] video_activity;
    wire video_clear;
    wire [1:0] video_mode;
    playback_video_cdc #(.REALTIME(1)) display_cdc(.sys_clk(sys_clk),.sys_reset_n(sys_release[3]),
        .pixel_clk(pixel_clk),.pixel_reset_n(video_reset_n),.frame_tick(frame_tick),
        .active(active),.clear(clear),.elapsed_ms(elapsed_ms),.keys(keys),.display_mode(display_mode),.video_mode(video_mode),
        .video_clear(video_clear),.video_activity(video_activity),
        .update(update),.video_active(video_active),.video_ms(video_ms),.video_keys(video_keys));
    wire analysis_ready,analysis_write_valid,analysis_visible;
    wire [8:0] analysis_write_address,analysis_read_address;
    wire [31:0] analysis_write_data,analysis_read_data;
    wire clear_analysis=analysis_clear || !audio_active;
    piano_audio_analysis analyzer(.clk(sys_clk),.reset_n(sys_release[3]),.clear(clear_analysis),
        .sample_valid(sample_tick && audio_active),.sample_pcm(sample_pcm),
        .out_ready(analysis_ready),.out_valid(analysis_write_valid),
        .out_address(analysis_write_address),.out_data(analysis_write_data),.completed_frames(),.busy());
    analysis_frame_cdc analysis_frames(.sys_clk(sys_clk),.sys_reset_n(sys_release[3]),.clear(clear_analysis),
        .write_valid(analysis_write_valid),.write_address(analysis_write_address),.write_data(analysis_write_data),
        .write_ready(analysis_ready),.pixel_clk(pixel_clk),.pixel_reset_n(video_reset_n),.frame_tick(frame_tick),
        .read_address(analysis_read_address),.read_data(analysis_read_data),.visible_valid(analysis_visible));
    wire [7:0] red,green,blue;
    wire hsync,vsync,de;
    video_source #(.REALTIME(1)) source(.pixel_clk(pixel_clk),.reset_n(video_reset_n),.test_pattern(1'b0),
        .update(update),.active(video_active),.elapsed_ms(video_ms),.lit_keys(video_keys),
        .clear(video_clear),.activity(video_activity),
        .display_mode(video_mode),.analysis_valid(analysis_visible),.analysis_data(analysis_read_data),
        .analysis_address(analysis_read_address),.frame_tick(frame_tick),.red(red),.green(green),.blue(blue),
        .hsync(hsync),.vsync(vsync),.de(de));
    dvi_tx tx(.pixel_clk(pixel_clk),.serial_clk(serial_clk),.reset_n(video_reset_n),
        .serial_reset_n(video_reset_n),
        .red(red),.green(green),.blue(blue),.hsync(hsync),.vsync(vsync),.de(de),
        .tmds_data_p(tmds_data_p),.tmds_data_n(tmds_data_n),
        .tmds_clk_p(tmds_clk_p),.tmds_clk_n(tmds_clk_n));
endmodule
