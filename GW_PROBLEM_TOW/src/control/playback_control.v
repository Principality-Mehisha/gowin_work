// Playback ownership, restart arbitration and latched error reporting.
module playback_control #(
    parameter integer SD_SCORE_ENABLE = 0
) (
    input wire clk, rst_n,
    input wire uart_play, uart_stop, uart_note_play,
    input wire mode_restart,
    input wire instrument_request, audition_marimba,
    input wire note_busy, playing, finished, failed, sequence_error,
    input wire [7:0] uart_track,
    input wire [3:0] sd_error_code, fat_error, score_error,
    output reg ringtone_active, ringtone_error,
    output reg [7:0] selected_track, last_error,
    output wire manual_mode, uart_start, control_restart, play_rst_n,
    output wire marimba_mode, storage_enable, storage_rst_n,
    output wire [7:0] player_state
);
    reg storage_restart;
    assign manual_mode = !ringtone_active;
    assign uart_start = uart_play && uart_track>=4 && uart_track<=203 &&
                        !(ringtone_active && selected_track==uart_track);
    assign control_restart = uart_start || uart_stop || uart_note_play || instrument_request || mode_restart;
    assign play_rst_n = rst_n && !control_restart;
    assign marimba_mode = ringtone_active ? (selected_track>=104 && selected_track<=203) :
                       audition_marimba;
    assign storage_enable = ringtone_active;
    assign storage_rst_n = play_rst_n && storage_enable && !storage_restart;
    // Error category occupies the high nibble: SD=1, FAT=2, score=3,
    // sequence=4, compute deadline=5. Values are latched before SD reset.
    wire [7:0] failure_code = sd_error_code!=0 ? {4'h1,sd_error_code} :
                              fat_error!=0 ? {4'h2,fat_error} :
                              score_error!=0 ? {4'h3,score_error} :
                              sequence_error ? 8'h40 : 8'h50;
    assign player_state = ringtone_error ? 8'd3 :
                            (ringtone_active ? (playing ? 8'd2 : 8'd1) :
                             (note_busy ? 8'd4 : 8'd0));
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ringtone_active <= (SD_SCORE_ENABLE != 0);
            // Optional startup playback now selects PN001, never an old filename.
            selected_track <= (SD_SCORE_ENABLE != 0) ? 8'd4 : 8'd0;
            ringtone_error <= 0; storage_restart <= 0; last_error<=0;
        end else begin
            storage_restart <= ringtone_active && (finished || failed);
            if (uart_stop) begin
                ringtone_active<=0; selected_track<=0; ringtone_error<=0; last_error<=0;
            end else if (uart_note_play || instrument_request) begin
                ringtone_active<=0; selected_track<=0; ringtone_error<=0; last_error<=0;
            end else if (uart_start) begin
                ringtone_active<=1; selected_track<=uart_track; ringtone_error<=0; last_error<=0;
            end else if (control_restart) begin
                ringtone_error<=0; last_error<=0;
            end else if (ringtone_active && (finished || failed)) begin
                ringtone_active <= 0;
                if (failed) begin
                    // Empty numbered slots are normal and do not latch an error.
                    if (selected_track>=4 && selected_track<=203 && fat_error==4) begin
                        ringtone_error<=0; last_error<=0; selected_track<=0;
                    end else begin ringtone_error <= 1; last_error<=failure_code; end
                end
            end
        end
    end
endmodule
