// 88 chromatic piano pitches, A0..C8, for Tang Mega 60K + NEO Dock.
// KEY1: first press starts A0, subsequent presses advance, C8 wraps to A0.
// KEY0: pause/resume the selected note. KEY2: reset to silent, before A0.
module piano_88 #(
    parameter integer DEBOUNCE_CYCLES    = 1_000_000,
    parameter integer AUDIO_START_CYCLES = 2_500_000,
    parameter integer POWER_ON_CYCLES    = 65_536,
    parameter ROM_FILE = "src/piano_bank.hex",
    parameter integer USE_SD = 1,
    // Zero lets the FAT reader accept both super-floppy volumes and MBR
    // partitions. Override this only when the card layout is known.
    parameter [31:0] SD_VOLUME_START_LBA = 0
) (
    input  wire sys_clk,
    input  wire KEY0,
    input  wire KEY1,
    input  wire KEY2,
    output wire HP_BCK,
    output wire HP_WS,
    output wire HP_DIN,
    output wire PA_EN,
    output wire sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs
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
    wire [17:0] sample_addr;
    wire [7:0] sample_data;
    wire bank_write_en;
    wire [13:0] bank_write_addr;
    wire [7:0] bank_write_data;
    wire bank_ready;
    wire [17:0] loaded_base;
    wire sd_initialized;
    wire sd_file_found;
    wire sd_loading;
    wire sd_error;
    wire [3:0] sd_error_code;
    wire [23:0] sd_debug_boot_bytes;
    wire [23:0] sd_debug_failure;
    wire [17:0] desired_base;
    wire [31:0] desired_step;
    piano_sample_map u_desired_map (
        .note_index(note_select),
        .sample_base(desired_base),
        .sample_step(desired_step)
    );
    generate
        if (USE_SD) begin : g_sd_bank
            sd_piano_bank_reader #(
                .VOLUME_START_LBA(SD_VOLUME_START_LBA)
            ) u_bank (
                .clk(sys_clk), .rst_n(rst_n),
                .desired_base(desired_base),
                .bank_ready(bank_ready), .loaded_base(loaded_base),
                .bank_write_en(bank_write_en),
                .bank_write_addr(bank_write_addr),
                .bank_write_data(bank_write_data),
                .loading(sd_loading), .sd_initialized(sd_initialized),
                .file_found(sd_file_found), .error(sd_error),
                .error_code(sd_error_code),
                .debug_boot_bytes(sd_debug_boot_bytes),
                .debug_failure(sd_debug_failure),
                .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi),
                .sd_miso(sd_miso)
            );
        end else begin : g_rom_bank
            assign bank_ready = 1'b1;
            assign loaded_base = 18'd0;
            assign bank_write_en = 1'b0;
            assign bank_write_addr = 14'd0;
            assign bank_write_data = 8'd0;
            assign sd_initialized = 1'b0;
            assign sd_file_found = 1'b0;
            assign sd_loading = 1'b0;
            assign sd_error = 1'b0;
            assign sd_error_code = 4'd0;
            assign sd_debug_boot_bytes = 24'd0;
            assign sd_debug_failure = 24'd0;
            assign sd_cs_n = 1'b1;
            assign sd_sck = 1'b0;
            assign sd_mosi = 1'b1;
        end
    endgenerate
    reg [7:0] sample_bank [0:15359];
    reg [7:0] sample_ram_data;
    always @(posedge sys_clk) begin
        if (bank_write_en)
            sample_bank[bank_write_addr] <= bank_write_data;
        sample_ram_data <= sample_bank[sample_addr[13:0]];
    end
    assign sample_data = sample_ram_data;

    piano_pcm_voice #(
        .ROM_FILE(ROM_FILE), .USE_EXTERNAL_RAM(USE_SD)
    ) u_voice (
        .clk(sys_clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .audio_ready(audio_ready), .note_select(note_select),
        .play_enabled(play_enabled), .sample_addr(sample_addr),
        .sample_data(sample_data), .bank_ready(bank_ready), .pcm(pcm)
    );
    pt8211_tx #(.BCK_HALF_DIV(48), .AMP_START_CYCLES(AUDIO_START_CYCLES)) u_audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(pcm), .pcm_right(pcm), .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    // Native SD errors show the command, last R1 and state at failure.
    // FAT errors retain the boot signature and first-byte diagnostic.
    wire [23:0] debug_bytes = sd_error_code >= 1 && sd_error_code <= 10
                           ? sd_debug_failure : sd_debug_boot_bytes;
    reg [2:0] debug_page;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n)
            debug_page <= 0;
        else if (sd_error && toggle_press)
            debug_page <= debug_page == 6 ? 3'd0 : debug_page + 1'b1;
    end
    reg [3:0] debug_nibble;
    always @* begin
        case (debug_page)
            1: debug_nibble = debug_bytes[3:0];
            2: debug_nibble = debug_bytes[7:4];
            3: debug_nibble = debug_bytes[11:8];
            4: debug_nibble = debug_bytes[15:12];
            5: debug_nibble = debug_bytes[19:16];
            6: debug_nibble = debug_bytes[23:20];
            default: debug_nibble = sd_error_code;
        endcase
    end
    assign LEDs = sd_error ? ~debug_nibble
                           : ~{sd_error, sd_loading, sd_file_found, sd_initialized};
endmodule
