// Eight existing Piano_88 voices share one synchronous recorded-piano ROM.
module piano_polyphony #(
    parameter ROM_FILE = "src/piano_bank.hex"
) (
    input wire clk, rst_n, sample_tick, audio_ready, paused, mute,
    input wire [55:0] notes, velocities,
    input wire [7:0] gates, triggers,
    output reg signed [15:0] pcm
);
    reg [7:0] bank [0:262143];
    initial $readmemh(ROM_FILE, bank);
    wire [17:0] addresses [0:7];
    wire signed [15:0] samples [0:7];
    reg [7:0] bank_data;
    reg [7:0] phase;
    reg running;
    wire [2:0] voice_index = phase[6:4];
    always @(posedge clk) bank_data <= bank[addresses[voice_index]];
    genvar i;
    generate for (i = 0; i < 8; i = i + 1) begin: voices
        wire voice_tick = running && phase == i*16 && !paused;
        // A new note resets just its voice, including repeated same-pitch notes.
        wire voice_rst_n = rst_n && !triggers[i];
        piano_pcm_voice #(.USE_EXTERNAL_RAM(1), .EXTERNAL_FULL_BANK(1)) voice (
            .clk(clk), .rst_n(voice_rst_n), .sample_tick(voice_tick),
            .audio_ready(audio_ready), .note_select(notes[i*7 +: 7]),
            .play_enabled(gates[i]), .sample_addr(addresses[i]),
            .sample_data(bank_data), .bank_ready(1'b1), .pcm(samples[i])
        );
    end endgenerate
    wire signed [7:0] gain = $signed({1'b0, velocities[voice_index*7 +: 7]});
    wire signed [23:0] weighted = samples[voice_index] * gain;
    reg signed [31:0] sum;
    wire signed [31:0] mixed = sum + ($signed(weighted) >>> 9);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin phase <= 0; running <= 0; sum <= 0; pcm <= 0; end
        else if (sample_tick) begin phase <= 0; running <= 1; sum <= 0; end
        else if (running) begin
            phase <= phase + 1'b1;
            if (phase[3:0] == 12) begin
                sum <= mixed;
                if (voice_index == 7) begin
                    running <= 0;
                    if (paused || mute) pcm <= 0;
                    else if (mixed > 30000) pcm <= 16'sd30000;
                    else if (mixed < -30000) pcm <= -16'sd30000;
                    else pcm <= mixed[15:0];
                end
            end
        end
    end
endmodule
