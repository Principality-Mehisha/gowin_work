module sd_music_player #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000,
    parameter integer POWER_ON_CYCLES = 65_536,
    parameter integer SD_POWER_WAIT_CYCLES = 500_000,
    parameter integer SD_INIT_HALF_DIV = 63,
    parameter integer FIFO_ADDRESS_BITS = 13,
    parameter integer PREFILL_SAMPLES = 4096,
    parameter integer AMP_START_CYCLES = 2_500_000
) (
    input wire sys_clk,
    input wire KEY0,
    input wire KEY1,
    input wire KEY2,
    output wire sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input wire sd_miso,
    output wire HP_BCK,
    output wire HP_WS,
    output wire HP_DIN,
    output wire PA_EN,
    output wire [3:0] LEDs
);
    GSR GSR_INST (.GSRI(1'b1));
    reg [31:0] power_count = 0;
    always @(posedge sys_clk) begin
        if (power_count < POWER_ON_CYCLES)
            power_count <= power_count + 1'b1;
    end
    wire reset_request_n = KEY2 && power_count == POWER_ON_CYCLES;
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n) begin
        if (!reset_request_n)
            reset_sync <= 0;
        else
            reset_sync <= {reset_sync[0], 1'b1};
    end
    wire rst_n = reset_sync[1];
    wire toggle_press, replay_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) u_pause (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(toggle_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) u_replay (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(replay_press)
    );
    wire stream_rst_n = rst_n && !replay_press;
    reg paused;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n)
            paused <= 0;
        else if (replay_press)
            paused <= 0;
        else if (toggle_press)
            paused <= ~paused;
    end

    wire sd_ready, sd_start, sd_done, sd_error, sd_initialized;
    wire [31:0] sd_lba;
    wire [7:0] sd_data;
    wire [8:0] sd_index;
    wire sd_valid;
    wire [3:0] sd_error_code;
    sd_spi_reader #(
        .POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES), .INIT_HALF_DIV(SD_INIT_HALF_DIV)
    ) u_sd (
        .clk(sys_clk), .rst_n(stream_rst_n),
        .read_start(sd_start), .read_lba(sd_lba), .read_ready(sd_ready), .busy(),
        .initialized(sd_initialized), .high_capacity(),
        .data(sd_data), .data_index(sd_index), .data_valid(sd_valid), .data_ready(1'b1),
        .read_done(sd_done), .error_pulse(sd_error), .error_code(sd_error_code),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso)
    );
    wire [7:0] file_data;
    wire file_valid, file_ready, file_found, file_done;
    wire [31:0] file_size;
    wire [3:0] fat_error;
    fat_file_reader u_file (
        .clk(sys_clk), .rst_n(stream_rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba),
        .sd_data(sd_data), .sd_index(sd_index), .sd_valid(sd_valid),
        .sd_done(sd_done), .sd_error(sd_error),
        .data(file_data), .valid(file_valid), .ready(file_ready),
        .mounted(), .file_found(file_found), .file_size(file_size),
        .file_done(file_done), .error_code(fat_error)
    );
    wire signed [15:0] decoded_pcm;
    wire decoded_valid, decoded_ready, format_ok, audio_end;
    wire [3:0] wav_error;
    wav_pcm_reader u_wav (
        .clk(sys_clk), .rst_n(stream_rst_n),
        .data(file_data), .valid(file_valid), .ready(file_ready),
        .file_size(file_size), .file_done(file_done),
        .pcm(decoded_pcm), .pcm_valid(decoded_valid), .pcm_ready(decoded_ready),
        .format_ok(format_ok), .audio_end(audio_end), .error_code(wav_error)
    );

    localparam integer FIFO_DEPTH = 1 << FIFO_ADDRESS_BITS;
    reg [15:0] fifo [0:FIFO_DEPTH-1];
    reg [FIFO_ADDRESS_BITS-1:0] write_ptr, read_ptr;
    reg [FIFO_ADDRESS_BITS:0] count;
    reg [15:0] fifo_read;
    reg signed [15:0] pcm;
    reg playing, finished, underrun;
    wire failed = sd_error_code != 0 || fat_error != 0 || wav_error != 0 || underrun;
    wire sample_tick;
    assign decoded_ready = count < FIFO_DEPTH && !failed;
    wire push = decoded_valid && decoded_ready;
    wire pop = sample_tick && playing && !paused && !failed && count != 0;
    always @(posedge sys_clk) begin
        if (push)
            fifo[write_ptr] <= decoded_pcm;
        fifo_read <= fifo[read_ptr];
    end
    always @(posedge sys_clk or negedge stream_rst_n) begin
        if (!stream_rst_n) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
            pcm <= 0;
            playing <= 0;
            finished <= 0;
            underrun <= 0;
        end else begin
            if (push)
                write_ptr <= write_ptr + 1'b1;
            if (pop)
                read_ptr <= read_ptr + 1'b1;
            case ({push,pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
            endcase
            if (failed) begin
                playing <= 0;
                pcm <= 0;
            end else begin
                if (!playing && !finished && format_ok
                    && (count >= PREFILL_SAMPLES || (audio_end && count != 0)))
                    playing <= 1;
                if (sample_tick) begin
                    if (paused || !playing)
                        pcm <= 0;
                    else if (count != 0)
                        pcm <= fifo_read;
                    else begin
                        pcm <= 0;
                        playing <= 0;
                        if (audio_end)
                            finished <= 1;
                        else
                            underrun <= 1;
                    end
                end
            end
        end
    end
    pt8211_tx #(.BCK_HALF_DIV(48), .AMP_START_CYCLES(AMP_START_CYCLES)) u_audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(pcm), .pcm_right(pcm), .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    assign LEDs = ~{failed, (playing && !paused), file_found, sd_initialized};
endmodule
