// Board-level shell: keep logic in named submodules for isolated verification.
module GW_PROBLEM_TOW #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer DEFAULT_MARIMBA = 1,
    parameter integer VIDEO_ENABLE = 1,
    parameter integer DDR_ENABLE = 1
) (
    input wire sys_clk, KEY0, KEY1, KEY2,
    input wire uart_rx,
    output wire uart_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs,
    output wire [2:0] tmds_data_p, tmds_data_n,
    output wire tmds_clk_p, tmds_clk_n,
    output wire [14:0] ddr_addr, output wire [2:0] ddr_bank,
    output wire ddr_cs,ddr_ras,ddr_cas,ddr_we,
    output wire ddr_ck,ddr_ck_n,ddr_cke,ddr_odt,ddr_reset_n,
    output wire [1:0] ddr_dm,
    inout wire [15:0] ddr_dq,
    inout wire [1:0] ddr_dqs,ddr_dqs_n
);
    wire player_reset_n, video_active;
    wire [31:0] video_elapsed_ms;
    wire [87:0] video_keys;
    wire ddr_ready,ddr_fault,ddr_request,ddr_cancel,ddr_request_ready,ddr_response_valid;
    wire [10:0] ddr_address;
    wire [127:0] ddr_response_data;
    piano_score_player #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE),
                         .DEFAULT_MARIMBA(DEFAULT_MARIMBA),
                         .EXTERNAL_CLARINET_TABLES(DDR_ENABLE)) score_player (
        .sys_clk(sys_clk), .KEY0(KEY0), .KEY1(KEY1), .KEY2(KEY2),
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .LEDs(LEDs), .player_reset_n(player_reset_n), .video_active(video_active),
        .video_elapsed_ms(video_elapsed_ms), .video_keys(video_keys),
        .ddr_ready(ddr_ready),.ddr_fault(ddr_fault),.ddr_request(ddr_request),.ddr_cancel(ddr_cancel),
        .ddr_address(ddr_address),.ddr_request_ready(ddr_request_ready),
        .ddr_response_valid(ddr_response_valid),.ddr_response_data(ddr_response_data)
    );
    generate if(DDR_ENABLE!=0)begin: external_memory
        audio_ddr3 memory(.sys_clk(sys_clk),.reset_n(player_reset_n),.cancel(ddr_cancel),
            .request(ddr_request),.address(ddr_address),.request_ready(ddr_request_ready),
            .response_valid(ddr_response_valid),.response_data(ddr_response_data),
            .ready(ddr_ready),.fault(ddr_fault),.fault_code(),
            .ddr_addr(ddr_addr),.ddr_bank(ddr_bank),.ddr_cs(ddr_cs),.ddr_ras(ddr_ras),
            .ddr_cas(ddr_cas),.ddr_we(ddr_we),.ddr_ck(ddr_ck),.ddr_ck_n(ddr_ck_n),
            .ddr_cke(ddr_cke),.ddr_odt(ddr_odt),.ddr_reset_n(ddr_reset_n),.ddr_dm(ddr_dm),
            .ddr_dq(ddr_dq),.ddr_dqs(ddr_dqs),.ddr_dqs_n(ddr_dqs_n));
    end else begin: internal_memory
        assign ddr_ready=1;assign ddr_fault=0;assign ddr_request_ready=0;
        assign ddr_response_valid=0;assign ddr_response_data=0;
        assign ddr_addr=0;assign ddr_bank=0;assign ddr_cs=1;assign ddr_ras=1;
        assign ddr_cas=1;assign ddr_we=1;assign ddr_ck=0;assign ddr_ck_n=1;
        assign ddr_cke=0;assign ddr_odt=0;assign ddr_reset_n=0;assign ddr_dm=0;
        assign ddr_dq=16'bz;assign ddr_dqs=2'bz;assign ddr_dqs_n=2'bz;
    end endgenerate
    generate if (VIDEO_ENABLE != 0) begin: display_enabled
        piano_video video(.sys_clk(sys_clk), .reset_n(player_reset_n),
            .active(video_active), .elapsed_ms(video_elapsed_ms), .keys(video_keys),
            .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
            .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));
    end else begin: display_disabled
        assign tmds_data_p=0; assign tmds_data_n=0;
        assign tmds_clk_p=0; assign tmds_clk_n=0;
    end endgenerate
endmodule
