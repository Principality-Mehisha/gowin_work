//======================================================================
//  Module   : top
//  Function : Tang Mega 60K - ADC input shown as a binary count on 8 LEDs
//  Device   : GW5AT-LV60PG484AC1/I0  (GW5AT-60B, PBGA484A)
//
//  Two ADC front-ends are provided; pick one with the ADC_IF parameter:
//
//    ADC_IF = "PAR"  parallel ADC (or any converter that presents a parallel
//                    result): adc_data[ADC_BITS-1:0] plus an adc_dv one-clock
//                    valid strobe.  This is the default.
//
//    ADC_IF = "SPI"  serial ADC such as MCP3202 / ADS7816 / ADC128S022: the
//                    FPGA drives adc_cs_n / adc_sclk and shifts in adc_din,
//                    producing one conversion per SAMPLE_DIV clock periods.
//                    Here SPI_BITS defines the converter resolution.
//
//  Ports of the front-end that is not selected are left unconstrained, so the
//  fitter only ever sees the pins you actually use.
//
//  The LED mapping itself lives in adc_led.v.
//======================================================================
`timescale 1ns / 1ps

module top #(
    parameter ADC_BITS   = 8,           // parallel ADC resolution
    parameter HYST       = 2,           // ADC hysteresis in 8-bit LSBs
    parameter ADC_IF     = "PAR",       // "PAR" or "SPI"
    // SPI front-end only
    parameter CLK_FREQ   = 50_000_000,
    parameter SAMPLE_DIV = 50_000,      // 1 kHz conversion rate
    parameter SPI_BITS   = 12,          // serial ADC resolution
    parameter SPI_CPOL   = 0            // 0: SCLK idles low, data on rising edge
)(
    input                  clk,         // 50 MHz, pin V22
    input                  rstn,        // active-low reset, pin AA13

    input  [ADC_BITS-1:0]  adc_data,    // parallel ADC result (ADC_IF = "PAR")
    input                  adc_dv,      // parallel ADC valid strobe

    output                 adc_cs_n,    // serial ADC chip select (ADC_IF = "SPI")
    output                 adc_sclk,    // serial ADC clock
    input                  adc_din,     // serial ADC data in

    output [7:0]           led_o
);

    generate
        //--------------------------------------------------------------
        // Parallel front-end
        //--------------------------------------------------------------
        if (ADC_IF != "SPI") begin : g_par
            // Park the unused serial pins at their idle levels and keep
            // adc_din observed, rather than leaving outputs undriven.
            wire unused_din = adc_din;

            assign adc_cs_n = 1'b1;
            assign adc_sclk = SPI_CPOL[0];

            adc_led #(
                .ADC_BITS  (ADC_BITS),
                .HYST      (HYST),
                .ACTIVE_LOW(1)
            ) u_disp (
                .clk     (clk),
                .rstn    (rstn),
                .adc_data(adc_data),
                .adc_dv  (adc_dv),
                .led_o   (led_o)
            );
        end
        //--------------------------------------------------------------
        // Serial (SPI) front-end
        //--------------------------------------------------------------
        else begin : g_spi
            wire [SPI_BITS-1:0] spi_data;
            wire                spi_dv;

            spi_adc #(
                .BITS      (SPI_BITS),
                .CLK_FREQ  (CLK_FREQ),
                .SAMPLE_DIV(SAMPLE_DIV),
                .CPOL      (SPI_CPOL)
            ) u_spi (
                .clk      (clk),
                .rstn     (rstn),
                .cs_n     (adc_cs_n),
                .sclk     (adc_sclk),
                .din      (adc_din),
                .dout     (spi_data),
                .dout_vld (spi_dv)
            );

            adc_led #(
                .ADC_BITS  (SPI_BITS),
                .HYST      (HYST),
                .ACTIVE_LOW(1)
            ) u_disp (
                .clk     (clk),
                .rstn    (rstn),
                .adc_data(spi_data),
                .adc_dv  (spi_dv),
                .led_o   (led_o)
            );
        end
    endgenerate

endmodule
