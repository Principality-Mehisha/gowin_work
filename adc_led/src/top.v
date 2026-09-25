//======================================================================
//  Tang Mega 60K on-chip ADC to binary LED display
//
//  ADCV is a dedicated analogue differential input of the GW5AT-60:
//    ADCVP = L10  (external 0..1 V signal)
//    ADCVN = M9   (analogue ground / signal return)
//
//  The dedicated ADC balls are consumed directly by the ADC_SAR hard macro
//  and therefore do not appear as top-level ports or ordinary CST IO_LOCs.
//======================================================================
`timescale 1ns / 1ps

module top #(
    // Delay between completed conversions.  1024 clocks = 20.48 us at 50 MHz.
    parameter SAMPLE_GAP = 1024
)(
    input        clk,
    input        rstn,
    output [7:0] led_o
);

    wire        adc_ready;
    wire [13:0] adc_value;
    wire [7:0]  mdrp_rdata_unused;

    reg         adc_request;
    reg         adc_ready_d;
    reg         conversion_pending;
    reg [15:0]  gap_count;

    wire adc_value_valid = adc_ready & ~adc_ready_d;

    // Voltage mode, ADCV channel.  The generated IP divides the 50 MHz clock
    // by 8, giving a 6.25 MHz ADC clock (inside the specified 0.5..8 MHz range).
    Gowin_ADC u_adc (
        .adcrdy       (adc_ready),
        .adcvalue     (adc_value),
        .mdrp_rdata   (mdrp_rdata_unused),
        .adcmode      (1'b1),
        .vsenctl      (3'b000),
        .clk          (clk),
        .drstn        (rstn),
        .adcreqi      (adc_request),
        .mdrp_clk     (1'b0),
        .mdrp_wdata   (8'b0),
        .mdrp_a_inc   (1'b0),
        .mdrp_opcode  (2'b00)
    );

    // ADCREQI is a one-clock pulse.  Do not issue another conversion until
    // ADCRDY has produced a rising edge for the current request.
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            adc_request        <= 1'b0;
            adc_ready_d        <= 1'b0;
            conversion_pending <= 1'b0;
            gap_count          <= SAMPLE_GAP - 1;
        end else begin
            adc_ready_d <= adc_ready;
            adc_request <= 1'b0;

            if (conversion_pending) begin
                if (adc_value_valid) begin
                    conversion_pending <= 1'b0;
                    gap_count <= SAMPLE_GAP - 1;
                end
            end else if (gap_count != 0) begin
                gap_count <= gap_count - 1'b1;
            end else begin
                adc_request <= 1'b1;
                conversion_pending <= 1'b1;
            end
        end
    end

    // The top three bits of the 14-bit ADC result form eight equal ranges.
    adc_led #(
        .ADC_BITS   (14),
        .HYST       (0),
        .ACTIVE_LOW (1)
    ) u_display (
        .clk      (clk),
        .rstn     (rstn),
        .adc_data (adc_value),
        .adc_dv   (adc_value_valid),
        .led_o    (led_o)
    );

endmodule
