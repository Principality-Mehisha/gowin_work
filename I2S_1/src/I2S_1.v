//==========================================================================
// Tang Mega 60K + NEO Dock 音频波形测试顶层
//
// KEY0、KEY1、KEY2 均为低电平按下：
//   上电或KEY2复位后：正弦波
//   KEY1可靠按下并松开：切换到三角波
//   KEY0可靠按下并松开：切换到方波
//
// KEY0和KEY1使用20 ms计数消抖，并且只在稳定释放时切换。
// KEY2直接作为低有效系统复位，不经过复位同步器。
//
// 系统时钟：50 MHz
// 音频采样率：约 48.828125 kHz
// 输出音调：约 440 Hz
//==========================================================================

module I2S_1 (
    input  wire sys_clk,

    input  wire KEY0,
    input  wire KEY1,
    input  wire KEY2,

    output wire HP_BCK,
    output wire HP_WS,
    output wire HP_DIN,
    output wire PA_EN
);

    // 440 Hz相位步进量：
    // 440 * 2^32 / 48828.125 = 38702809
    localparam [31:0] PHASE_STEP = 32'd38702809;
    localparam integer DEBOUNCE_CYCLES = 1_000_000;

    localparam [1:0] WAVE_SINE     = 2'd0;
    localparam [1:0] WAVE_TRIANGLE = 2'd1;
    localparam [1:0] WAVE_SQUARE   = 2'd2;

    //--------------------------------------------------------------------------
    // KEY0、KEY1输入同步
    // KEY2不进入此同步逻辑，它直接作为sys_rst_n使用。
    //--------------------------------------------------------------------------

    reg [1:0] key0_sync;
    reg [1:0] key1_sync;

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            key0_sync <= 2'b11;
        else
            key0_sync <= {key0_sync[0], KEY0};
    end

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            key1_sync <= 2'b11;
        else
            key1_sync <= {key1_sync[0], KEY1};
    end

    //--------------------------------------------------------------------------
    // 按键消抖与释放事件检测
    //
    // 只有输入连续保持新电平20 ms，才更新消抖后的状态。
    // 必须先确认一次稳定按下，再确认一次稳定松开，才输出一个时钟周期的
    // release_pulse，避免按下抖动或松开抖动导致重复切换。
    //--------------------------------------------------------------------------

    reg [19:0] key0_count;
    reg [19:0] key1_count;
    reg        key0_debounced;
    reg        key1_debounced;
    reg        key0_pressed;
    reg        key1_pressed;
    reg        key0_release_pulse;
    reg        key1_release_pulse;

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2) begin
            key0_count         <= 20'd0;
            key0_debounced     <= 1'b1;
            key0_pressed       <= 1'b0;
            key0_release_pulse <= 1'b0;
        end else begin
            key0_release_pulse <= 1'b0;

            if (key0_sync[1] == key0_debounced) begin
                key0_count <= 20'd0;
            end else if (key0_count == DEBOUNCE_CYCLES - 1) begin
                key0_count     <= 20'd0;
                key0_debounced <= key0_sync[1];

                if (!key0_sync[1]) begin
                    key0_pressed <= 1'b1;
                end else if (key0_pressed) begin
                    key0_pressed       <= 1'b0;
                    key0_release_pulse <= 1'b1;
                end
            end else begin
                key0_count <= key0_count + 20'd1;
            end
        end
    end

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2) begin
            key1_count         <= 20'd0;
            key1_debounced     <= 1'b1;
            key1_pressed       <= 1'b0;
            key1_release_pulse <= 1'b0;
        end else begin
            key1_release_pulse <= 1'b0;

            if (key1_sync[1] == key1_debounced) begin
                key1_count <= 20'd0;
            end else if (key1_count == DEBOUNCE_CYCLES - 1) begin
                key1_count     <= 20'd0;
                key1_debounced <= key1_sync[1];

                if (!key1_sync[1]) begin
                    key1_pressed <= 1'b1;
                end else if (key1_pressed) begin
                    key1_pressed       <= 1'b0;
                    key1_release_pulse <= 1'b1;
                end
            end else begin
                key1_count <= key1_count + 20'd1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // 波形模式寄存器
    // 模式在按键松开后改变，并一直保持到下一次按键事件或KEY2复位。
    //--------------------------------------------------------------------------

    reg [1:0] waveform_select;

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            waveform_select <= WAVE_SINE;
        else if (key1_release_pulse)
            waveform_select <= WAVE_TRIANGLE;
        else if (key0_release_pulse)
            waveform_select <= WAVE_SQUARE;
    end

    //--------------------------------------------------------------------------
    // 32位DDS相位累加器
    //
    // 每产生一个新的音频采样点，相位增加PHASE_STEP。
    //--------------------------------------------------------------------------

    wire sample_tick;
    reg  [31:0] phase_accumulator;

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            phase_accumulator <= 32'd0;
        else if (sample_tick)
            phase_accumulator <= phase_accumulator + PHASE_STEP;
    end

    //--------------------------------------------------------------------------
    // 64点正弦波查找表
    //
    // 使用四分之一周期对称性，只保存0～90度的17个采样值。
    // 正弦波峰值设为24576，保留一定的幅度余量。
    //--------------------------------------------------------------------------

    function signed [15:0] sine_lut;
        input [5:0] index;

        reg [4:0]  lut_address;
        reg [15:0] magnitude;

        begin
            // 第二、第四象限需要反向读取四分之一波表。
            if (index[4])
                lut_address = 5'd16 - {1'b0, index[3:0]};
            else
                lut_address = {1'b0, index[3:0]};

            case (lut_address)
                5'd0:  magnitude = 16'd0;
                5'd1:  magnitude = 16'd2409;
                5'd2:  magnitude = 16'd4795;
                5'd3:  magnitude = 16'd7134;
                5'd4:  magnitude = 16'd9405;
                5'd5:  magnitude = 16'd11585;
                5'd6:  magnitude = 16'd13654;
                5'd7:  magnitude = 16'd15591;
                5'd8:  magnitude = 16'd17378;
                5'd9:  magnitude = 16'd18998;
                5'd10: magnitude = 16'd20434;
                5'd11: magnitude = 16'd21674;
                5'd12: magnitude = 16'd22705;
                5'd13: magnitude = 16'd23518;
                5'd14: magnitude = 16'd24104;
                5'd15: magnitude = 16'd24458;
                5'd16: magnitude = 16'd24576;
                default:
                    magnitude = 16'd0;
            endcase

            // index[5]表示正弦波的负半周期。
            if (index[5])
                sine_lut = -$signed(magnitude);
            else
                sine_lut =  $signed(magnitude);
        end
    endfunction

    wire signed [15:0] sine_pcm;

    assign sine_pcm = sine_lut(phase_accumulator[31:26]);

    //--------------------------------------------------------------------------
    // 三角波
    //
    // 先产生0～65535～0的无符号三角波，再转换成以0为中心的
    // 有符号波形，最后乘以3/4，峰值约为24576。
    //--------------------------------------------------------------------------

    wire [15:0] triangle_offset;
    wire signed [15:0] triangle_full_scale;
    wire signed [15:0] triangle_pcm;

    assign triangle_offset =
        phase_accumulator[31]
            ? ~phase_accumulator[30:15]
            :  phase_accumulator[30:15];

    assign triangle_full_scale =
        $signed(triangle_offset ^ 16'h8000);

    assign triangle_pcm =
        triangle_full_scale - (triangle_full_scale >>> 2);

    //--------------------------------------------------------------------------
    // 方波，幅值为正负24576
    //--------------------------------------------------------------------------

    wire signed [15:0] square_pcm;

    assign square_pcm =
        phase_accumulator[31] ? -16'sd24576 : 16'sd24576;

    //--------------------------------------------------------------------------
    // 根据锁存的波形模式选择输出波形
    //--------------------------------------------------------------------------

    reg signed [15:0] selected_pcm;

    always @(*) begin
        case (waveform_select)
            WAVE_SINE:
                selected_pcm = sine_pcm;

            WAVE_TRIANGLE:
                selected_pcm = triangle_pcm;

            WAVE_SQUARE:
                selected_pcm = square_pcm;

            default:
                selected_pcm = 16'sd0;
        endcase
    end

    //--------------------------------------------------------------------------
    // PT8211串行音频发送模块
    //
    // 左右声道连接相同的PCM数据，因此耳机两侧播放相同声音。
    //--------------------------------------------------------------------------

    I2S_1_communication #(
        .CLK_FREQ_HZ      (50_000_000),
        .BCK_HALF_DIV     (16),
        .AMP_START_CYCLES (2_500_000)
    ) u_I2S_1_communication (
        .sys_clk     (sys_clk),
        .sys_rst_n   (KEY2),

        .pcm_left    (selected_pcm),
        .pcm_right   (selected_pcm),
        .sample_tick (sample_tick),

        .HP_BCK      (HP_BCK),
        .HP_WS       (HP_WS),
        .HP_DIN      (HP_DIN),
        .PA_EN       (PA_EN)
    );

endmodule
