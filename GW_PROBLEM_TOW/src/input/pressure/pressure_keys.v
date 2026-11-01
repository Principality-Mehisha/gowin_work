// Independent calibration, filtering, hysteresis and hold tracking for 16 keys.
// Keep all keys released during the initial CALIBRATION_SAMPLES scan frames.
module pressure_keys #(
    parameter integer CALIBRATION_LOG2 = 5,
    parameter integer FILTER_SHIFT = 2,
    parameter integer PRESS_THRESHOLD = 64,
    parameter integer RELEASE_THRESHOLD = 32,
    parameter integer CONFIRM_FRAMES = 3,
    parameter integer LONG_HOLD_FRAMES = 1042,
    parameter integer DYNAMICS_SHIFT = 3,
    parameter integer SOFT_TOUCH_BOOST = 1
) (
    input wire clk, reset_n, sample_valid,
    input wire [3:0] sample_key,
    input wire [11:0] sample_data,
    output reg [15:0] calibrated, pressed, long_held,
    output wire [127:0] gains,
    output wire [191:0] forces,
    output wire [127:0] hold_progress,
    output reg edge_valid, edge_on,
    output reg [3:0] edge_key,
    output reg [7:0] edge_gain
);
    localparam integer CALIBRATION_SAMPLES = 1 << CALIBRATION_LOG2;
    localparam integer HOLD_MAX = LONG_HOLD_FRAMES * 8;
    localparam integer HOLD_BITS = HOLD_MAX < 2 ? 1 : $clog2(HOLD_MAX+1);
    reg [11:0] baseline [0:15];
    reg [15:0] filtered [0:15]; // Q12.4 preserves sub-code filter increments.
    reg [23:0] calibration_sum [0:15];
    reg [11:0] calibration_count [0:15];
    reg [15:0] confirm_count [0:15];
    reg [HOLD_BITS-1:0] held_frames [0:15];
    reg [7:0] gain [0:15];
    reg [11:0] force_value [0:15];
    wire signed [16:0] difference =
        $signed({1'b0,sample_data,4'b0}) -
        $signed({1'b0,filtered[sample_key]});
    wire signed [16:0] next_filtered =
        $signed({1'b0,filtered[sample_key]}) + (difference >>> FILTER_SHIFT);
    wire [11:0] code = next_filtered[15:4];
    wire [11:0] pressure = baseline[sample_key] > code ?
                          baseline[sample_key]-code : 12'd0;
    wire [11:0] scaled_gain = pressure >> DYNAMICS_SHIFT;
    wire [7:0] linear_gain = scaled_gain > 255 ? 8'd255 :
                            scaled_gain == 0 ? 8'd1 : scaled_gain[7:0];
    // Raise soft touches with a monotonic curve; preserve all gains >= 192.
    // Press/release thresholds still operate on the original ADC code drop.
    wire [7:0] soft_gain = linear_gain < 32 ?
                          8'd32 + {linear_gain[6:0],1'b0} :
                          linear_gain < 64 ? 8'd64 + linear_gain :
                          linear_gain < 192 ? 8'd96 + {1'b0,linear_gain[7:1]} :
                          linear_gain;
    wire [7:0] new_gain = SOFT_TOUCH_BOOST ? soft_gain : linear_gain;
    wire [23:0] calibration_total = calibration_sum[sample_key]+sample_data;
    wire [11:0] calibration_average = calibration_total[CALIBRATION_LOG2 +: 12];
    genvar k,level;
    generate for(k=0;k<16;k=k+1) begin: debug_values
        assign gains[k*8 +: 8]=gain[k];
        assign forces[k*12 +: 12]=force_value[k];
        for(level=0;level<8;level=level+1) begin: hold_steps
            assign hold_progress[k*8+level]=pressed[k] &&
                held_frames[k]>=(level+1)*LONG_HOLD_FRAMES;
        end
    end endgenerate
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            calibrated<=0; pressed<=0; long_held<=0;
            edge_valid<=0; edge_on<=0; edge_key<=0; edge_gain<=0;
            for(i=0;i<16;i=i+1) begin
                baseline[i]<=0; filtered[i]<=0;
                calibration_sum[i]<=0; calibration_count[i]<=0;
                confirm_count[i]<=0; held_frames[i]<=0;
                gain[i]<=0; force_value[i]<=0;
            end
        end else begin
            edge_valid<=0;
            if(sample_valid) begin
                if(!calibrated[sample_key]) begin
                    calibration_sum[sample_key]<=calibration_total;
                    calibration_count[sample_key]<=calibration_count[sample_key]+1'b1;
                    if(calibration_count[sample_key]==CALIBRATION_SAMPLES-1) begin
                        baseline[sample_key]<=calibration_average;
                        filtered[sample_key]<={calibration_average,4'b0};
                        calibrated[sample_key]<=1;
                    end
                end else begin
                    filtered[sample_key]<=next_filtered[15:0];
                    force_value[sample_key]<=pressure;
                    if(!pressed[sample_key]) begin
                        held_frames[sample_key]<=0;
                        long_held[sample_key]<=0;
                        if(pressure>=PRESS_THRESHOLD) begin
                            if(confirm_count[sample_key]==CONFIRM_FRAMES-1) begin
                                pressed[sample_key]<=1;
                                gain[sample_key]<=new_gain;
                                confirm_count[sample_key]<=0;
                                edge_valid<=1; edge_on<=1;
                                edge_key<=sample_key; edge_gain<=new_gain;
                            end else confirm_count[sample_key]<=confirm_count[sample_key]+1'b1;
                        end else confirm_count[sample_key]<=0;
                    end else begin
                        if(held_frames[sample_key]<HOLD_MAX)
                            held_frames[sample_key]<=held_frames[sample_key]+1'b1;
                        if(held_frames[sample_key]>=LONG_HOLD_FRAMES-1)
                            long_held[sample_key]<=1;
                        // Freeze the last effective gain throughout release
                        // confirmation; near-zero pressure must not kill R.
                        if(pressure<=RELEASE_THRESHOLD) begin
                            if(confirm_count[sample_key]==CONFIRM_FRAMES-1) begin
                                pressed[sample_key]<=0; long_held[sample_key]<=0;
                                held_frames[sample_key]<=0;
                                confirm_count[sample_key]<=0;
                                edge_valid<=1; edge_on<=0;
                                edge_key<=sample_key; edge_gain<=gain[sample_key];
                            end else confirm_count[sample_key]<=confirm_count[sample_key]+1'b1;
                        end else begin
                            confirm_count[sample_key]<=0;
                            gain[sample_key]<=new_gain;
                        end
                    end
                end
            end
        end
    end
endmodule
