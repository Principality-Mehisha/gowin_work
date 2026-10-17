`timescale 1ns/1ps

// Active-low 4x4 matrix scanner. A key transition produces one event.
module matrix_keypad_4x4 #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer SCAN_HZ = 2_000
) (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] rows_n,
    input  wire [3:0] cols_n,
    output reg        event_valid,
    output reg        event_down,
    output reg  [6:0] event_note
);
    localparam integer DIVISOR = (CLK_HZ / (SCAN_HZ * 4)) < 1 ? 1 : (CLK_HZ / (SCAN_HZ * 4));
    reg [31:0] div_count;
    reg [1:0] row_index;
    reg [15:0] key_state;
    reg [3:0] col_sync;
    reg [1:0] decoded_col;
    reg       decoded_valid;
    reg [3:0] current_row_mask;
    reg [3:0] old_row_mask;
    reg [3:0] delta_row;
    reg [1:0] delta_col;

    always @* begin
        rows_n = 4'b1111;
        rows_n[row_index] = 1'b0;
        decoded_valid = 1'b0;
        decoded_col = 2'd0;
        if (!col_sync[0]) begin decoded_valid = 1'b1; decoded_col = 2'd0; end
        else if (!col_sync[1]) begin decoded_valid = 1'b1; decoded_col = 2'd1; end
        else if (!col_sync[2]) begin decoded_valid = 1'b1; decoded_col = 2'd2; end
        else if (!col_sync[3]) begin decoded_valid = 1'b1; decoded_col = 2'd3; end
        current_row_mask = ~col_sync;
        old_row_mask = key_state[{row_index, 2'b00} +: 4];
        delta_row = current_row_mask ^ old_row_mask;
        delta_col = delta_row[0] ? 2'd0 :
                    delta_row[1] ? 2'd1 :
                    delta_row[2] ? 2'd2 : 2'd3;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_count <= 0;
            row_index <= 0;
            col_sync <= 4'hf;
            key_state <= 0;
            event_valid <= 1'b0;
            event_down <= 1'b0;
            event_note <= 0;
        end else begin
            event_valid <= 1'b0;
            col_sync <= cols_n;
            if (div_count == DIVISOR - 1) begin
                div_count <= 0;
                row_index <= row_index + 2'd1;
                // Compare the complete row, allowing simultaneous keys and
                // detecting a release even while another key remains held.
                if (delta_row != 0) begin
                    key_state[{row_index, 2'b00} +: 4] <= current_row_mask;
                    event_valid <= 1'b1;
                    event_down <= current_row_mask[delta_col];
                    event_note <= 7'd60 + {3'd0, row_index, delta_col};
                end
            end else begin
                div_count <= div_count + 1;
            end
        end
    end
endmodule
