//======================================================================
//  Module   : spi_adc
//  Function : Minimal SPI master that reads one conversion from a serial ADC
//             (MCP3202 / ADS7816 / ADC128S022 style: CS low, MSB first on the
//             rising edge, data returned on the falling edge).
//
//  The controller starts a conversion every SAMPLE_DIV clock cycles, shifts in
//  BITS bits, then raises dout_vld for one clock so the display can latch the
//  new value.
//======================================================================
`timescale 1ns / 1ps

module spi_adc #(
    parameter BITS       = 12,
    parameter CLK_FREQ   = 50_000_000,
    parameter SAMPLE_DIV = 50_000,     // sample period in clock cycles
    parameter CPOL       = 0
)(
    input                clk,
    input                rstn,
    output reg           cs_n,
    output reg           sclk,
    input                din,
    output reg [BITS-1:0] dout,
    output reg           dout_vld
);

    localparam DIV_W = 16;
    localparam HALF  = 8;              // half SCLK period in clocks (~1.5 MHz)

    reg [DIV_W-1:0] div_r;
    reg [DIV_W-1:0] tick_r;            // half-bit tick counter
    reg [5:0]       bit_r;
    reg [BITS-1:0]  sh_r;
    reg             busy;

    wire sample_tick = (div_r == SAMPLE_DIV[DIV_W-1:0] - 1'b1);
    wire half_tick   = (tick_r == HALF - 1);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            div_r    <= {DIV_W{1'b0}};
            tick_r   <= {DIV_W{1'b0}};
            bit_r    <= 6'd0;
            sh_r     <= {BITS{1'b0}};
            busy     <= 1'b0;
            cs_n     <= 1'b1;
            sclk     <= CPOL[0];
            dout     <= {BITS{1'b0}};
            dout_vld <= 1'b0;
        end
        else begin
            dout_vld <= 1'b0;

            if (!busy) begin
                // idle: wait for the sample period to elapse
                sclk <= CPOL[0];
                if (sample_tick) begin
                    div_r <= {DIV_W{1'b0}};
                    tick_r <= {DIV_W{1'b0}};
                    bit_r  <= 6'd0;
                    busy   <= 1'b1;
                    cs_n   <= 1'b0;      // assert chip select
                end
                else begin
                    div_r <= div_r + 1'b1;
                end
            end
            else if (half_tick) begin
                tick_r <= {DIV_W{1'b0}};
                // toggle the clock; sample on the rising edge
                if (sclk == CPOL[0]) begin
                    sclk <= ~CPOL[0];
                    sh_r <= {sh_r[BITS-2:0], din};
                end
                else begin
                    sclk <= CPOL[0];
                    if (bit_r == BITS - 1) begin
                        busy     <= 1'b0;
                        cs_n     <= 1'b1;
                        dout     <= {sh_r[BITS-2:0], din};
                        dout_vld <= 1'b1;
                    end
                    else begin
                        bit_r <= bit_r + 1'b1;
                    end
                end
            end
            else begin
                tick_r <= tick_r + 1'b1;
            end
        end
    end

endmodule
