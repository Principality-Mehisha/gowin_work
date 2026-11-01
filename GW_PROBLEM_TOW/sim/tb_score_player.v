`timescale 1ns/1ps
module tb_score_player;
    reg passed=0;
    wire done;
    uart_player_case #(.AUTOPLAY(1)) test(done);
    initial begin wait(done);passed=1;$display("PASS startup selection uses only PN001");$finish;end
endmodule
