// 88 chromatic piano pitches, A0..C8, for Tang Mega 60K + NEO Dock.
// KEY1: first press starts A0, subsequent presses advance, C8 wraps to A0.
// KEY0: pause/resume the selected note. KEY2: reset to silent, before A0.
module piano_88 #(
    parameter integer DEBOUNCE_CYCLES    = 1_000_000,
    parameter integer AUDIO_START_CYCLES = 2_500_000,
    parameter integer POWER_ON_CYCLES    = 65_536,
    parameter ROM_FILE = "src/piano_bank.hex"
) (
    input  wire sys_clk,
    input  wire KEY0,
    input  wire KEY1,
    input  wire KEY2,
    output wire HP_BCK,
    output wire HP_WS,
    output wire HP_DIN,
    output wire PA_EN
);
    GSR GSR_INST (.GSRI(1'b1));

    // Explicit POR also initializes the design when KEY2 is high at download.
    reg [31:0] power_on_count = 32'd0;
    always @(posedge sys_clk) begin
        if (power_on_count < POWER_ON_CYCLES)
            power_on_count <= power_on_count + 32'd1;
    end
    wire reset_request_n = KEY2 && (power_on_count == POWER_ON_CYCLES);
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n) begin
        if (!reset_request_n)
            reset_sync <= 2'b00;
        else
            reset_sync <= {reset_sync[0], 1'b1};
    end
    wire rst_n = reset_sync[1];

    wire next_press;
    wire toggle_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) u_next (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(next_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) u_toggle (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(toggle_press)
    );

    reg [6:0] note_select;
    reg has_selected;
    reg play_enabled;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            note_select  <= 7'd0;
            has_selected <= 1'b0;
            play_enabled <= 1'b0;
        end else if (next_press) begin
            if (!has_selected || note_select == 7'd87)
                note_select <= 7'd0;
            else
                note_select <= note_select + 7'd1;
            has_selected <= 1'b1;
            play_enabled <= 1'b1;
        end else if (toggle_press && has_selected) begin
            play_enabled <= ~play_enabled;
        end
    end

    reg [31:0] audio_start_count;
    reg audio_ready;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            audio_start_count <= 32'd0;
            audio_ready       <= 1'b0;
        end else if (!audio_ready) begin
            if (audio_start_count == AUDIO_START_CYCLES - 1)
                audio_ready <= 1'b1;
            else
                audio_start_count <= audio_start_count + 32'd1;
        end
    end

    wire sample_tick;
    wire signed [15:0] pcm;
    piano_pcm_voice #(.ROM_FILE(ROM_FILE)) u_voice (
        .clk(sys_clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .audio_ready(audio_ready), .note_select(note_select),
        .play_enabled(play_enabled), .pcm(pcm)
    );
    pt8211_tx #(.BCK_HALF_DIV(48), .AMP_START_CYCLES(AUDIO_START_CYCLES)) u_audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(pcm), .pcm_right(pcm), .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
endmodule
