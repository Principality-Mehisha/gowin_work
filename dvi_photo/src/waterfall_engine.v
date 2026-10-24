`timescale 1ns/1ps
`include "score_config.vh"
// Update geometry only in vertical blanking; support chords/repeated pitches.
module waterfall_engine (
    input wire clk, input wire reset_n, input wire frame_tick,
    output reg [63:0] valid,
    output wire [703:0] left_bus, right_bus,
    output wire [447:0] pitch_bus,
    output wire [1023:0] top_bus, bottom_bus,
    output reg [63:0] hand,
    output reg [87:0] lit_keys,
    output reg [15:0] frame_number,
    output wire busy,
    output reg overflow
);
    reg [10:0] note_left [0:63], note_right [0:63];
    reg signed [15:0] note_top [0:63], note_bottom [0:63];
    reg [6:0] pitch [0:63];
    reg [87:0] working_keys;
    reg [`SCORE_ADDR_WIDTH-1:0] address;
    wire [63:0] rom_data;
    reg [63:0] event_data;
    piano_score_rom score(.clk(clk), .address(address), .data(rom_data));
    wire [15:0] event_start = event_data[63:48];
    wire [15:0] event_duration = event_data[47:32];
    wire [6:0] event_pitch = event_data[31:25];
    reg signed [15:0] spawn_bottom;
    reg signed [15:0] spawn_top;
    reg clear_slots;
    reg [3:0] state;
    reg selected_valid;
    reg signed [15:0] selected_top, selected_bottom;
    reg [6:0] selected_pitch;
    reg selected_lit, selected_expired;
    reg signed [15:0] next_top, next_bottom;
    reg [5:0] slot;
    reg [6:0] searched;
    localparam IDLE=0, UPDATE=1, FETCH=2, WAIT_ROM=3, CHECK=4, ALLOCATE=5,
        KEY_CHECK=6, KEY_WRITE=7, FIND_READ=8;
    assign busy = state != IDLE;
    genvar g;
    generate for (g=0; g<64; g=g+1) begin: slots
        assign pitch_bus[g*7+:7] = pitch[g];
        assign left_bus[g*11+:11] = note_left[g];
        assign right_bus[g*11+:11] = note_right[g];
        assign top_bus[g*16+:16] = note_top[g];
        assign bottom_bus[g*16+:16] = note_bottom[g];
        reg do_update, do_allocate;
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin do_update <= 0; do_allocate <= 0; end
            else begin
                do_update <= state == KEY_CHECK && slot == g && selected_valid;
                do_allocate <= state == FIND_READ && slot == g && !valid[g];
            end
        end
        // Independent enables keep loop clearing off the geometry write path.
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                note_left[g] <= 0; note_right[g] <= 0;
                pitch[g] <= 0; hand[g] <= 0;
            end else if (do_allocate) begin
                note_left[g] <= event_data[24:14];
                note_right[g] <= event_data[13:3];
                pitch[g] <= event_pitch; hand[g] <= event_data[2];
            end
        end
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin note_top[g] <= 0; note_bottom[g] <= 0; end
            else if (do_update) begin
                note_top[g] <= next_top;
                note_bottom[g] <= next_bottom;
            end else if (do_allocate) begin
                note_top[g] <= spawn_top; note_bottom[g] <= spawn_bottom;
            end
        end
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) valid[g] <= 0;
            else if (clear_slots) valid[g] <= 0;
            else if (do_update && selected_expired) valid[g] <= 0;
            else if (do_allocate) valid[g] <= 1;
        end
    end endgenerate
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE; lit_keys <= 0;
            working_keys <= 0; frame_number <= 0; address <= 0;
            slot <= 0; searched <= 0; overflow <= 0;
            selected_valid <= 0; selected_pitch <= 0;
            selected_top <= 0; selected_bottom <= 0; selected_lit <= 0;
            selected_expired <= 0; next_top <= 0; next_bottom <= 0;
            spawn_top <= 0; spawn_bottom <= 0; clear_slots <= 0; event_data <= 0;
        end else begin
            clear_slots <= state == IDLE && frame_tick && frame_number == `SCORE_LOOP_FRAMES-1;
            if (frame_tick && busy) overflow <= 1;
            case (state)
                IDLE: if (frame_tick) begin
                    slot <= 0;
                    working_keys <= 0;
                    if (frame_number == `SCORE_LOOP_FRAMES-1) begin
                        frame_number <= 0; address <= 0;
                        lit_keys <= 0; state <= FETCH;
                    end else begin
                        frame_number <= frame_number + 1'b1;
                        state <= UPDATE;
                    end
                end
                UPDATE: begin
                    selected_valid <= valid[slot];
                    selected_top <= note_top[slot];
                    selected_bottom <= note_bottom[slot];
                    selected_pitch <= pitch[slot];
                    state <= KEY_CHECK;
                end
                KEY_CHECK: begin
                    next_top <= selected_top + 16'sd4;
                    next_bottom <= selected_bottom + 16'sd4;
                    selected_expired <= selected_top >= 16'sd716;
                    selected_lit <= selected_valid && selected_top < 16'sd716
                        && selected_bottom >= 16'sd716;
                    state <= KEY_WRITE;
                end
                KEY_WRITE: begin
                    if (selected_lit) working_keys[selected_pitch] <= 1;
                    slot <= slot + 1'b1;
                    state <= slot == 63 ? FETCH : UPDATE;
                end
                FETCH: begin lit_keys <= working_keys; state <= WAIT_ROM; end
                WAIT_ROM: begin event_data <= rom_data; state <= CHECK; end
                CHECK: begin
                    spawn_bottom <= (frame_number - event_start) << 2;
                    if (address < `SCORE_COUNT && event_start <= frame_number) begin
                        slot <= 0; searched <= 0; state <= FIND_READ;
                    end else state <= IDLE;
                end
                FIND_READ: begin
                    spawn_top <= spawn_bottom - (event_duration << 2);
                    selected_valid <= valid[slot];
                    state <= ALLOCATE;
                end
                ALLOCATE: begin
                    if (!selected_valid) begin
                        address <= address + 1'b1; state <= FETCH;
                    end else if (searched == 63) begin
                        overflow <= 1; state <= IDLE;
                    end else begin
                        slot <= slot + 1'b1; searched <= searched + 1'b1; state <= FIND_READ;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
