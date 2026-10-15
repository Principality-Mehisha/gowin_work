// Recorded piano PCM, following Croatian_Rhapsody_PCM's mu-law ROM.
// One synchronous ROM port is time-multiplexed for two-point interpolation.
module piano_pcm_voice #(
    parameter ROM_FILE = "src/piano_bank.hex"
) (
    input wire clk,
    input wire rst_n,
    input wire sample_tick,
    input wire audio_ready,
    input wire [6:0] note_select,
    input wire play_enabled,
    output reg signed [15:0] pcm
);
    localparam [31:0] END_POSITION = 32'd1_006_632_960; // 15360 << 16
    reg [7:0] pcm_rom [0:262143];
    initial $readmemh(ROM_FILE, pcm_rom);
    reg [17:0] rom_addr;
    reg [7:0] rom_byte;
    always @(posedge clk)
        rom_byte <= pcm_rom[rom_addr];

    function signed [15:0] decode_ulaw;
        input [7:0] code;
        reg [7:0] bits;
        reg [15:0] magnitude;
        begin
            bits = ~code;
            magnitude = (({12'd0, bits[3:0]} << 3) + 16'd132) << bits[6:4];
            magnitude = magnitude - 16'd132;
            decode_ulaw = bits[7] ? (16'd0 - magnitude) : magnitude;
        end
    endfunction

    reg [6:0] active_note;
    reg active_play;
    reg [31:0] position;
    reg [15:0] envelope;
    reg [31:0] note_age;
    reg voice_done;
    reg finish_pending;
    wire [17:0] sample_base;
    wire [31:0] sample_step;
    piano_sample_map u_map (
        .note_index(active_note), .sample_base(sample_base),
        .sample_step(sample_step)
    );
    wire [31:0] advanced_position = position + sample_step;
    wire at_end = advanced_position >= END_POSITION;
    wire [31:0] next_position = advanced_position >= END_POSITION
                               ? END_POSITION - 32'd65536 : advanced_position;
    wire finishing = note_age != 0 && at_end
                   && position == END_POSITION - 32'd65536;
    wire changing = active_note != note_select || active_play != play_enabled;

    // The ROM has a faded, zero-valued end. Hold the final sample for one
    // output frame before asserting voice_done so the release is audible.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_note <= 0;
            active_play <= 0;
            position <= 0;
            envelope <= 0;
            note_age <= 0;
            voice_done <= 0;
            finish_pending <= 0;
        end else if (sample_tick) begin
            if (!audio_ready) begin
                active_note <= note_select;
                active_play <= 0;
                position <= 0;
                envelope <= 0;
                note_age <= 0;
                voice_done <= 0;
                finish_pending <= 0;
            end else if (changing) begin
                if (envelope > 16'd512) begin
                    envelope <= envelope - 16'd512;
                    position <= next_position;
                end else begin
                    active_note <= note_select;
                    active_play <= play_enabled;
                    position <= 0;
                    envelope <= 0;
                    note_age <= 0;
                    voice_done <= 0;
                    finish_pending <= 0;
                end
            end else if (active_play && !voice_done) begin
                if (finish_pending) begin
                    voice_done <= 1;
                    finish_pending <= 0;
                    envelope <= 0;
                end else begin
                    if (note_age != 0) begin
                        if (finishing)
                            finish_pending <= 1;
                        else
                            position <= next_position;
                    end
                    if (note_age != 32'hffffffff)
                        note_age <= note_age + 1'b1;
                    if (note_age < 32) begin
                        if (envelope >= 16'd63487)
                            envelope <= 16'd65535;
                        else
                            envelope <= envelope + 16'd2048;
                    end else if (envelope > 16'd12000)
                        envelope <= envelope - ((envelope - 16'd12000) >> 12) - 1'b1;
                    else
                        envelope <= 16'd12000;
                end
            end else if (!active_play) begin
                position <= 0;
                envelope <= 0;
                note_age <= 0;
                voice_done <= 0;
                finish_pending <= 0;
            end
        end
    end

    reg [3:0] read_state;
    reg signed [15:0] sample_a;
    reg signed [16:0] interpolated;
    wire signed [15:0] sample_b = decode_ulaw(rom_byte);
    wire signed [16:0] difference = $signed({sample_b[15], sample_b})
                                   - $signed({sample_a[15], sample_a});
    wire signed [16:0] fraction = $signed({1'b0, position[15:0]});
    wire signed [33:0] interpolation_product = difference * fraction;
    wire signed [16:0] interpolation_delta = $signed(interpolation_product[32:16]);
    wire signed [16:0] gain = $signed({1'b0, envelope});
    wire signed [33:0] gain_product = interpolated * gain;
    wire [15:0] next_index = position[31:16] == 16'd15359
                            ? 16'd15359 : position[31:16] + 16'd1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state <= 0;
            rom_addr <= 0;
            sample_a <= 0;
            interpolated <= 0;
            pcm <= 0;
        end else if (sample_tick) begin
            read_state <= 1;
        end else begin
            case (read_state)
                1: begin
                    rom_addr <= sample_base + {2'd0, position[31:16]};
                    read_state <= 2;
                end
                2: read_state <= 3;
                3: begin
                    sample_a <= decode_ulaw(rom_byte);
                    rom_addr <= sample_base + {2'd0, next_index};
                    read_state <= 4;
                end
                4: read_state <= 5;
                5: begin
                    interpolated <= $signed({sample_a[15], sample_a}) + interpolation_delta;
                    read_state <= 6;
                end
                6: begin
                    pcm <= (audio_ready && !voice_done)
                           ? $signed(gain_product[31:16]) : 16'sd0;
                    read_state <= 0;
                end
                default: read_state <= 0;
            endcase
        end
    end
endmodule
