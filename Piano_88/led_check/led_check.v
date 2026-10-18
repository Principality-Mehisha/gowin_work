// Check the four physical outputs used by piano_88 without accessing the SD.
module led_check (
    input wire sys_clk,
    input wire KEY0,
    input wire KEY1,
    output wire [3:0] LEDs
);
    reg [15:0] por_count = 16'd0;
    wire rst_n = &por_count;
    always @(posedge sys_clk)
        if (!rst_n)
            por_count <= por_count + 16'd1;

    wire next_press;
    wire restart_press;
    button_debounce next_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(next_press)
    );
    button_debounce restart_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(restart_press)
    );

    // Start with all four off. Each KEY0 press advances one step:
    // LED0, LED1, LED2, LED3, all on, all off.
    reg [2:0] step;
    reg [3:0] lit;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n)
            step <= 3'd0;
        else if (restart_press)
            step <= 3'd0;
        else if (next_press)
            step <= step == 3'd5 ? 3'd0 : step + 3'd1;
    end

    always @* begin
        case (step)
            3'd1: lit = 4'b0001;
            3'd2: lit = 4'b0010;
            3'd3: lit = 4'b0100;
            3'd4: lit = 4'b1000;
            3'd5: lit = 4'b1111;
            default: lit = 4'b0000;
        endcase
    end
    assign LEDs = ~lit;
endmodule
