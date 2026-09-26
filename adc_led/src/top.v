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
    output [7:0] led_o
);

    // Generate a deterministic reset after FPGA configuration.  The board
    // schematic does not provide a dedicated reset signal on AA13.
    reg [15:0] power_on_count = 16'd0;
    always @(posedge clk) begin
        if (power_on_count != 16'hffff)
            power_on_count <= power_on_count + 1'b1;
    end
    wire rstn = (power_on_count == 16'hffff);

    wire        adc_ready;
    wire [13:0] adc_value;
    wire [7:0]  mdrp_rdata_unused;

    reg         adc_request;
    reg         adc_ready_d;
    reg         conversion_pending;
    reg [15:0]  gap_count;
    reg         adc_seen;

    // Power-on LED test: light LED0..LED7 for 125 ms each.  Afterwards LED7
    // blinks if the ADC has never completed a conversion.
    reg [22:0]  selftest_count;
    reg [3:0]   selftest_step;
    reg [24:0]  heartbeat_count;

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
            adc_seen           <= 1'b0;
        end else begin
            adc_ready_d <= adc_ready;
            adc_request <= 1'b0;

            if (adc_value_valid)
                adc_seen <= 1'b1;

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

    // UG299 specifies voltage = adcvalue / 2048 for this ADC.  Therefore the
    // useful 0..1 V range is code 0..2048, not the complete 14-bit range.
    // Clamp over-range results and present an 11-bit 0..2047 value to adc_led;
    // bits [10:8] then form the required eight equal voltage ranges.
    wire [10:0] adc_code_1v =
        (adc_value >= 14'd2047) ? 11'd2047 : adc_value[10:0];
    wire [7:0] adc_led_o;

    adc_led #(
        .ADC_BITS   (11),
        .HYST       (0),
        .ACTIVE_LOW (1)
    ) u_display (
        .clk      (clk),
        .rstn     (rstn),
        .adc_data (adc_code_1v),
        .adc_dv   (adc_value_valid),
        .led_o    (adc_led_o)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            selftest_count  <= 23'd0;
            selftest_step   <= 4'd0;
            heartbeat_count <= 25'd0;
        end else begin
            heartbeat_count <= heartbeat_count + 1'b1;

            if (selftest_step < 4'd8) begin
                if (selftest_count == 23'd6_249_999) begin
                    selftest_count <= 23'd0;
                    selftest_step <= selftest_step + 1'b1;
                end else begin
                    selftest_count <= selftest_count + 1'b1;
                end
            end
        end
    end

    wire [7:0] selftest_led_o = ~(8'b0000_0001 << selftest_step[2:0]);
    wire [7:0] no_adc_led_o =
        heartbeat_count[24] ? 8'b0111_1111 : 8'b1111_1111;

    assign led_o = (selftest_step < 4'd8) ? selftest_led_o :
                   adc_seen               ? adc_led_o :
                                            no_adc_led_o;

endmodule
