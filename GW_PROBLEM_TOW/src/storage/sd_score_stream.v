// SD sector access -> fixed numbered slot -> score validation -> timed events.
module sd_score_stream #(
    parameter integer SD_POWER_WAIT_CYCLES = 500000,
    parameter integer SD_INIT_HALF_DIV = 63,
    parameter integer SD_READ_HALF_DIV = 63,
    parameter integer CLOCKS_PER_MS = 50000
) (
    input wire clk, rst_n, paused, catalog_cached,
    input wire [7:0] selected_track,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    input wire dispatch_ready,
    output wire dispatch_valid, dispatch_on,
    output wire [6:0] dispatch_note,
    output wire [7:0] dispatch_dynamics,
    output wire initialized, file_found, playing, finished, sequence_error,
    output wire [3:0] sd_error_code, fat_error, score_error,
    output wire [55:0] notes, velocities,
    output wire [7:0] gates, triggers,
    output wire [31:0] elapsed_ms,
    output wire [199:0] catalog_mask,
    output wire catalog_done
);
    wire stream_error = sd_error_code != 0 || fat_error != 0 || score_error != 0;
    wire sd_ready, sd_start, sd_valid, sd_done, sd_error;
    wire [31:0] sd_lba;
    wire [7:0] sd_data;
    wire [8:0] sd_index;
    wire [87:0] requested_name;
    wire marimba_format;
    score_file_name name_map(.track(selected_track),.file_name(requested_name),
        .marimba(marimba_format),.numbered());
    sd_spi_reader #(
        .POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .INIT_HALF_DIV(SD_INIT_HALF_DIV), .READ_HALF_DIV(SD_READ_HALF_DIV)
    ) sd (
        .clk(clk), .rst_n(rst_n),
        .read_start(sd_start), .read_lba(sd_lba),
        .read_ready(sd_ready), .busy(), .initialized(initialized), .high_capacity(),
        .data(sd_data), .data_index(sd_index), .data_valid(sd_valid), .data_ready(1'b1),
        .read_done(sd_done), .error_pulse(sd_error), .error_code(sd_error_code),
        .debug_failure(), .sd_cs_n(sd_cs_n), .sd_sck(sd_sck),
        .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .write_start(1'b0), .write_lba(32'd0), .write_data(8'd0),
        .write_index(), .write_done()
    );
    wire [7:0] file_data;
    wire file_valid, file_ready, file_done;
    wire [31:0] file_size;
    fixed_slot_reader slot_reader(
        .clk(clk),.rst_n(rst_n),.scan_catalog(!catalog_cached),
        .slot_index(selected_track-8'd4),.file_name(requested_name),
        .sd_ready(sd_ready),.sd_start(sd_start),.sd_lba(sd_lba),
        .sd_data(sd_data),.sd_index(sd_index),.sd_valid(sd_valid),
        .sd_done(sd_done),.sd_error(sd_error),
        .data(file_data),.valid(file_valid),.ready(file_ready),
        .file_found(file_found),.file_done(file_done),.probe_done(),
        .file_size(file_size),.error_code(fat_error),
        .catalog_mask(catalog_mask),.catalog_done(catalog_done));
    wire [63:0] event_data;
    wire event_valid, event_ready, format_ok, complete;
    piano_score_reader #(.DYNAMIC_FORMAT(1)) decoder (
        .marimba_format(marimba_format),
        .clk(clk), .rst_n(rst_n),
        .data(file_data), .valid(file_valid),
        .ready(file_ready), .file_found(file_found), .file_size(file_size),
        .file_done(file_done), .event_data(event_data), .event_valid(event_valid),
        .event_ready(event_ready), .format_ok(format_ok), .complete(complete),
        .error_code(score_error)
    );
    piano_score_sequencer #(.CLOCKS_PER_MS(CLOCKS_PER_MS)) sequencer (
        .clk(clk), .rst_n(rst_n),
        .paused(paused),
        .format_ok(format_ok), .stream_complete(complete), .stream_error(stream_error),
        .event_data(event_data), .event_valid(event_valid), .event_ready(event_ready),
        .dispatch_ready(dispatch_ready), .dispatch_valid(dispatch_valid),
        .dispatch_on(dispatch_on), .dispatch_note(dispatch_note),
        .dispatch_dynamics(dispatch_dynamics),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .playing(playing), .finished(finished), .error(sequence_error), .elapsed_ms(elapsed_ms)
    );
endmodule
