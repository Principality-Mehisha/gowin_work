// Seven static F5 pixels. RGB parameters are serialized as GRB, MSB first.
// Defaults below are clock counts for 50 MHz, per the supplied F5 datasheet.
module ws2812_static #(
    parameter [7:0] COLOR_LEVEL=8'd64,
    parameter [23:0] LED0_RGB={COLOR_LEVEL,8'd0,8'd0},
    parameter [23:0] LED1_RGB={8'd0,COLOR_LEVEL,8'd0},
    parameter [23:0] LED2_RGB={8'd0,8'd0,COLOR_LEVEL},
    parameter [23:0] LED3_RGB={COLOR_LEVEL,COLOR_LEVEL,8'd0},
    parameter [23:0] LED4_RGB={COLOR_LEVEL,8'd0,COLOR_LEVEL},
    parameter [23:0] LED5_RGB={8'd0,COLOR_LEVEL,COLOR_LEVEL - 8'd20},
    parameter [23:0] LED6_RGB={COLOR_LEVEL - 8'd35,COLOR_LEVEL,COLOR_LEVEL - 8'd8},
    parameter integer BIT_CYCLES=63,
    parameter integer T0H_CYCLES=15,
    parameter integer T1H_CYCLES=45,
    parameter integer RESET_CYCLES=15000,
    parameter integer REFRESH_CYCLES=1000000
) (
    input wire clk, reset_n,
    output reg data_out,
    output wire [143:0] group_palette
);
    assign group_palette={LED5_RGB,LED4_RGB,LED3_RGB,LED2_RGB,LED1_RGB,LED0_RGB};
    localparam integer DATA_CYCLES=7*24*BIT_CYCLES;
    localparam integer IDLE_CYCLES=REFRESH_CYCLES-DATA_CYCLES;
    localparam integer WAIT_LIMIT=IDLE_CYCLES>RESET_CYCLES ? IDLE_CYCLES : RESET_CYCLES;
    localparam integer WAIT_BITS=WAIT_LIMIT<2 ? 1 : $clog2(WAIT_LIMIT);
    localparam integer BIT_BITS=BIT_CYCLES<2 ? 1 : $clog2(BIT_CYCLES);
    localparam WAIT_RESET=1'b0, SEND=1'b1;
    reg state, started;
    reg [WAIT_BITS-1:0] wait_count;
    reg [BIT_BITS-1:0] bit_count;
    reg [2:0] pixel;
    reg [4:0] bit_index;
    reg [23:0] shift_data;
    wire [WAIT_BITS-1:0] wait_last=started ? IDLE_CYCLES-1 : RESET_CYCLES-1;
    wire [BIT_BITS-1:0] high_last=shift_data[23] ? T1H_CYCLES-1 : T0H_CYCLES-1;
    function [23:0] pixel_grb;
        input [2:0] index;
        reg [23:0] rgb;
        begin
            case(index)
                0: rgb=LED0_RGB;
                1: rgb=LED1_RGB;
                2: rgb=LED2_RGB;
                3: rgb=LED3_RGB;
                4: rgb=LED4_RGB;
                5: rgb=LED5_RGB;
                6: rgb=LED6_RGB;
                default: rgb=24'd0;
            endcase
            pixel_grb={rgb[15:8],rgb[23:16],rgb[7:0]};
        end
    endfunction
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=WAIT_RESET; started<=0; data_out<=0;
            wait_count<=0; bit_count<=0; pixel<=0; bit_index<=23; shift_data<=0;
        end else case(state)
            WAIT_RESET: begin
                data_out<=0;
                if(wait_count==wait_last) begin
                    wait_count<=0; bit_count<=0;
                    pixel<=0; bit_index<=23; shift_data<=pixel_grb(0);
                    data_out<=1; state<=SEND;
                end else wait_count<=wait_count+1'b1;
            end
            SEND: begin
                if(bit_count==BIT_CYCLES-1) begin
                    bit_count<=0;
                    if(bit_index!=0) begin
                        shift_data<={shift_data[22:0],1'b0};
                        bit_index<=bit_index-1'b1;
                        data_out<=1;
                    end else if(pixel!=6) begin
                        pixel<=pixel+1'b1; bit_index<=23;
                        shift_data<=pixel_grb(pixel+1'b1);
                        data_out<=1;
                    end else begin
                        // Keep low long enough for all seven pixels to latch.
                        data_out<=0; started<=1; wait_count<=0; state<=WAIT_RESET;
                    end
                end else begin
                    bit_count<=bit_count+1'b1;
                    if(bit_count==high_last) data_out<=0;
                end
            end
            default: begin
                state<=WAIT_RESET; started<=0; data_out<=0; wait_count<=0;
            end
        endcase
    end
endmodule
