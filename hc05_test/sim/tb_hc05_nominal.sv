`timescale 1ns/1ps
// Real 50 MHz / 115200 settings, with a remote endpoint at exact 115200 baud.
module tb_hc05_nominal;
    reg clk=0, rx=1, passed=0;
    always #10 clk=~clk;
    localparam real BIT_NS=1000000000.0/115200;
    wire tx, led_n;
    hc05_test dut(.sys_clk(clk),.uart_rx(rx),.uart_tx(tx),.led_n(led_n));
    string expected="PONG\015\n";
    reg [7:0] value;
    integer k, j;
    task send_byte(input [7:0] data);
        integer i;
        begin
            rx=0; #(BIT_NS);
            for(i=0;i<8;i=i+1) begin rx=data[i]; #(BIT_NS); end
            rx=1; #(BIT_NS);
        end
    endtask
    initial begin
        #2000000;
        send_byte("P");send_byte("I");send_byte("N");send_byte("G");send_byte(10);
    end
    initial begin
        for(k=0;k<6;k=k+1) begin
            @(negedge tx); #(BIT_NS/2);
            if(tx!==0) $fatal(1,"Nominal start bit");
            for(j=0;j<8;j=j+1) begin #(BIT_NS); value[j]=tx; end
            #(BIT_NS);
            if(tx!==1 || value!==expected[k]) $fatal(1,"Nominal baud reply");
        end
        passed=1; $display("PASS tb_hc05_nominal: actual 50 MHz / 115200"); $finish;
    end
    initial begin #30000000; $fatal(1,"Nominal watchdog"); end
endmodule
