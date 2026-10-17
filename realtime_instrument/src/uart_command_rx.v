`timescale 1ns/1ps

// 8-N-1 UART command receiver. Commands:
//   0x90, note : note on
//   0x80, note : note off
//   0xB0, val  : select timbre/effect bank
module uart_command_rx #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_i,
    output reg        event_valid,
    output reg        event_down,
    output reg [6:0]  event_note,
    output reg        timbre_valid,
    output reg [1:0]  timbre_select
);
    localparam integer BIT_TICKS = CLK_HZ / BAUD;
    reg rx_meta, rx_sync;
    reg busy;
    reg [31:0] tick_count;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg [7:0] command;
    reg       have_command;
    reg [1:0] data_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1; rx_sync <= 1'b1;
            busy <= 1'b0; tick_count <= 0; bit_count <= 0;
            shift_reg <= 0; command <= 0; have_command <= 1'b0;
            data_count <= 0;
            event_valid <= 1'b0; event_down <= 1'b0; event_note <= 0;
            timbre_valid <= 1'b0; timbre_select <= 0;
        end else begin
            rx_meta <= rx_i;
            rx_sync <= rx_meta;
            event_valid <= 1'b0;
            timbre_valid <= 1'b0;
            if (!busy) begin
                if (!rx_sync) begin
                    busy <= 1'b1;
                    tick_count <= BIT_TICKS / 2;
                    bit_count <= 0;
                end
            end else if (tick_count == BIT_TICKS - 1) begin
                tick_count <= 0;
                if (bit_count == 0) begin
                    bit_count <= 1;
                end else if (bit_count <= 8) begin
                    shift_reg[bit_count - 1] <= rx_sync;
                    bit_count <= bit_count + 1;
                end else begin
                    busy <= 1'b0;
                    if (!have_command) begin
                        command <= shift_reg;
                        have_command <= 1'b1;
                        data_count <= 0;
                    end else begin
                        have_command <= 1'b0;
                        if ((command == 8'h90) || (command == 8'h80)) begin
                            event_valid <= 1'b1;
                            event_down <= (command == 8'h90);
                            event_note <= shift_reg[6:0];
                        end else if (command == 8'hb0) begin
                            timbre_valid <= 1'b1;
                            timbre_select <= shift_reg[1:0];
                        end
                    end
                end
            end else begin
                tick_count <= tick_count + 1;
            end
        end
    end
endmodule
