// ADC_DATA must be stable at SAMPLE_CYCLE. Conversion latency and output edge
// are board-specific; adjust SAMPLE_CYCLE/SLOT_CYCLES after checking the ADC.
module pressure_adc_scan #(
    parameter integer SLOT_CYCLES = 1500,
    parameter integer ADC_HALF_CYCLES = 50,
    parameter integer SAMPLE_CYCLE = SLOT_CYCLES - 10
) (
    input wire clk, reset_n,
    input wire [11:0] adc_data,
    output reg [3:0] select,
    output wire select_n,
    output reg adc_clk,
    output reg sample_valid,
    output reg [3:0] sample_key,
    output reg [11:0] sample_data
);
    reg [15:0] slot_count, adc_count;
    reg [11:0] adc_meta, adc_sync;
    assign select_n = 1'b0;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            slot_count<=0; adc_count<=0; select<=0; adc_clk<=0;
            sample_valid<=0; sample_key<=0; sample_data<=0;
            adc_meta<=0; adc_sync<=0;
        end else begin
            // Synchronizers do not establish bus coherence; scheduled capture
            // still requires the ADC's complete word to be stable.
            adc_meta<=adc_data;
            adc_sync<=adc_meta;
            sample_valid<=0;
            if (adc_count==ADC_HALF_CYCLES-1) begin
                adc_count<=0; adc_clk<=~adc_clk;
            end else adc_count<=adc_count+1'b1;
            if (slot_count==SAMPLE_CYCLE) begin
                sample_valid<=1;
                sample_key<=select;
                sample_data<=adc_sync;
            end
            if (slot_count==SLOT_CYCLES-1) begin
                slot_count<=0; select<=select+1'b1;
            end else slot_count<=slot_count+1'b1;
        end
    end
endmodule
