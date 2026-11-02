// SD piano guide: the highest held note selects one 16-note color group.
// Snapshot and scan the keys off the audio path; serialize complete frames.
module ws2812_key_guide #(
    parameter integer BIT_CYCLES=63,
    parameter integer T0H_CYCLES=15,
    parameter integer T1H_CYCLES=45,
    parameter integer RESET_CYCLES=15000,
    parameter integer REFRESH_CYCLES=100000
) (
    input wire clk,reset_n,active,
    input wire [87:0] keys,
    input wire [143:0] palette_rgb,
    output reg data_out
);
    localparam WAIT_RESET=2'd0,SCAN=2'd1,PREPARE=2'd2,SEND=2'd3;
    localparam integer DATA_CYCLES=16*24*BIT_CYCLES;
    localparam integer IDLE_CYCLES=REFRESH_CYCLES-DATA_CYCLES-89;
    localparam integer WAIT_LIMIT=IDLE_CYCLES>RESET_CYCLES ? IDLE_CYCLES : RESET_CYCLES;
    localparam integer WAIT_BITS=WAIT_LIMIT<2 ? 1 : $clog2(WAIT_LIMIT);
    localparam integer BIT_BITS=BIT_CYCLES<2 ? 1 : $clog2(BIT_CYCLES);
    reg [1:0] state;
    reg started;
    reg [WAIT_BITS-1:0] wait_count;
    reg [BIT_BITS-1:0] bit_count;
    reg [87:0] scan_keys;
    reg [6:0] scan_note;
    reg [2:0] scan_group;
    reg [15:0] scan_mask,frame_mask;
    reg [23:0] frame_rgb,shift_data;
    reg [3:0] pixel;
    reg [4:0] bit_index;
    wire [WAIT_BITS-1:0] wait_last=started ? IDLE_CYCLES-1 : RESET_CYCLES-1;
    wire [BIT_BITS-1:0] high_last=shift_data[23] ? T1H_CYCLES-1 : T0H_CYCLES-1;
    wire [15:0] scan_key=16'b1 << scan_note[3:0];
    wire [23:0] selected_rgb=palette_rgb[scan_group*24 +: 24];
    function [23:0] pixel_grb;
        input [3:0] index;
        begin
            pixel_grb=frame_mask[index] ?
                {frame_rgb[15:8],frame_rgb[23:16],frame_rgb[7:0]} : 24'd0;
        end
    endfunction
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=WAIT_RESET;started<=0;data_out<=0;
            wait_count<=0;bit_count<=0;scan_keys<=0;scan_note<=0;scan_group<=0;
            scan_mask<=0;frame_mask<=0;frame_rgb<=0;shift_data<=0;
            pixel<=0;bit_index<=23;
        end else case(state)
            WAIT_RESET:begin
                data_out<=0;
                if(wait_count==wait_last) begin
                    wait_count<=0;scan_keys<=active ? keys : 88'd0;
                    scan_note<=0;scan_group<=0;scan_mask<=0;state<=SCAN;
                end else wait_count<=wait_count+1'b1;
            end
            SCAN:begin
                scan_keys<={1'b0,scan_keys[87:1]};
                if(scan_keys[0]) begin
                    if(scan_note[6:4]!=scan_group) begin
                        scan_group<=scan_note[6:4];scan_mask<=scan_key;
                    end else scan_mask<=scan_mask | scan_key;
                end
                if(scan_note==87)state<=PREPARE;
                else scan_note<=scan_note+1'b1;
            end
            PREPARE:begin
                frame_mask<=scan_mask;frame_rgb<=selected_rgb;
                pixel<=0;bit_index<=23;bit_count<=0;
                shift_data<=scan_mask[0] ?
                    {selected_rgb[15:8],selected_rgb[23:16],selected_rgb[7:0]} : 24'd0;
                data_out<=1;state<=SEND;
            end
            SEND:begin
                if(bit_count==BIT_CYCLES-1) begin
                    bit_count<=0;
                    if(bit_index!=0) begin
                        shift_data<={shift_data[22:0],1'b0};
                        bit_index<=bit_index-1'b1;data_out<=1;
                    end else if(pixel!=15) begin
                        pixel<=pixel+1'b1;bit_index<=23;
                        shift_data<=pixel_grb(pixel+1'b1);data_out<=1;
                    end else begin
                        data_out<=0;started<=1;wait_count<=0;state<=WAIT_RESET;
                    end
                end else begin
                    bit_count<=bit_count+1'b1;
                    if(bit_count==high_last)data_out<=0;
                end
            end
            default:begin
                state<=WAIT_RESET;started<=0;data_out<=0;wait_count<=0;
            end
        endcase
    end
endmodule
