`timescale 1ns/1ps
// Run the existing fault cases separately to avoid the Starter Edition's
// design-size slowdown for four simultaneous official PLL/FIFO instances.
// The normal PN/MB transport case is also exercised by tb_video_player.
module tb_uart_player_crc;
    wire passed;
    uart_player_case #(.IMAGE("output/fixed_slots/bad_crc.hex"),.ERROR('h26)) test(passed);
    initial begin wait(passed);$display("PASS isolated numbered player CRC fault/recovery");$finish;end
endmodule
module tb_uart_player_format;
    wire passed;
    uart_player_case #(.IMAGE("output/fixed_slots/bad_format.hex"),.ERROR('h31)) test(passed);
    initial begin wait(passed);$display("PASS isolated numbered player format fault/recovery");$finish;end
endmodule
module tb_uart_player_empty;
    wire passed;
    uart_player_case #(.IMAGE("output/fixed_slots/empty.hex"),.EMPTY(1)) test(passed);
    initial begin wait(passed);$display("PASS isolated numbered player empty slot/recovery");$finish;end
endmodule
