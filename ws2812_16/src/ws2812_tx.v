// WS2812B-F5 transmitter. Timing constants require a 50 MHz input clock.
// frame_grb[LED_COUNT*24-1 -: 24] is the first (nearest) LED.
module ws2812_tx #(
    parameter integer LED_COUNT = 16
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [LED_COUNT*24-1:0] frame_grb,
    output reg  data_o,
    output wire busy,
    output reg  done
);
    localparam integer FRAME_BITS = LED_COUNT * 24;
    localparam [1:0] BOOT_LOW = 2'd0, IDLE = 2'd1,
                     SEND = 2'd2, LATCH_LOW = 2'd3;
    reg [1:0] state;
    reg [FRAME_BITS-1:0] shift_reg;
    reg [15:0] bits_left;
    reg [5:0] cycle_count;
    reg [13:0] low_count;

    assign busy = (state != IDLE);

    always @(posedge clk) begin
        if (!rst_n) begin
            state       <= BOOT_LOW;
            shift_reg   <= {FRAME_BITS{1'b0}};
            bits_left   <= 16'd0;
            cycle_count <= 6'd0;
            low_count   <= 14'd0;
            data_o      <= 1'b0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                BOOT_LOW, LATCH_LOW: begin
                    data_o <= 1'b0;
                    if (low_count == 14'd14999) begin
                        low_count <= 14'd0;
                        state <= IDLE;
                        done <= (state == LATCH_LOW);
                    end else
                        low_count <= low_count + 1'b1;
                end
                IDLE: begin
                    data_o <= 1'b0;
                    if (start) begin
                        // Snapshot the complete frame; changes while busy are ignored.
                        shift_reg <= frame_grb;
                        bits_left <= FRAME_BITS;
                        cycle_count <= 6'd0;
                        data_o <= 1'b1;
                        state <= SEND;
                    end
                end
                SEND: begin
                    if (cycle_count == 6'd61) begin
                        cycle_count <= 6'd0;
                        if (bits_left == 16'd1) begin
                            data_o <= 1'b0;
                            low_count <= 14'd0;
                            state <= LATCH_LOW;
                        end else begin
                            shift_reg <= shift_reg << 1;
                            bits_left <= bits_left - 1'b1;
                            data_o <= 1'b1;
                        end
                    end else begin
                        cycle_count <= cycle_count + 1'b1;
                        // High: 15 clocks for 0; 45 clocks for 1.
                        // Total: 62 clocks/bit (1.24 us), with registered output.
                        if (cycle_count == (shift_reg[FRAME_BITS-1] ? 6'd44 : 6'd14))
                            data_o <= 1'b0;
                    end
                end
                default: begin
                    state <= BOOT_LOW;
                    low_count <= 14'd0;
                    data_o <= 1'b0;
                end
            endcase
        end
    end
endmodule
