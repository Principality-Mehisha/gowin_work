`timescale 1ns/1ps
module tb_hc05_test;
    reg clk=0;
    always #10 clk=~clk;
    localparam integer TICKS=16;
    localparam integer BIT_NS=TICKS*20;
    reg rx=1;
    wire tx, led_n;
    reg passed=0;
    hc05_test #(.CLK_HZ(50000000), .BAUD(3125000), .POWER_ON_CYCLES(16)) dut (
        .sys_clk(clk), .uart_rx(rx), .uart_tx(tx), .led_n(led_n));
    reg [7:0] received[0:8191];
    reg [7:0] value;
    integer received_count=0, checked_count=0, b;
    // Independent serial decoder verifies the physical TX wire and stop bits.
    initial forever begin
        @(negedge tx);
        #(BIT_NS/2);
        if (tx!==0) $fatal(1,"Invalid TX start bit");
        for (b=0;b<8;b=b+1) begin #(BIT_NS); value[b]=tx; end
        #(BIT_NS);
        if (tx!==1) $fatal(1,"Invalid TX stop bit");
        received[received_count]=value;
        received_count=received_count+1;
    end
    task send_byte(input [7:0] data, input bit bad_stop=0);
        integer j;
        begin
            @(negedge clk); rx=0;
            repeat(TICKS) @(negedge clk);
            for (j=0;j<8;j=j+1) begin
                rx=data[j]; repeat(TICKS) @(negedge clk);
            end
            rx=!bad_stop; repeat(TICKS) @(negedge clk);
            rx=1;
        end
    endtask
    task send_text(input string message);
        integer j;
        begin for (j=0;j<message.len();j=j+1) send_byte(message[j]); end
    endtask
    task expect_text(input string expected);
        integer j, timeout_cycles;
        begin
            timeout_cycles=0;
            while(received_count<checked_count+expected.len() && timeout_cycles<200000) begin
                @(posedge clk); timeout_cycles=timeout_cycles+1;
            end
            if (received_count<checked_count+expected.len()) $fatal(1,"Reply timeout: %s",expected);
            for (j=0;j<expected.len();j=j+1)
                if(received[checked_count+j]!==expected[j])
                    $fatal(1,"Reply byte %0d: got %02x expected %02x (%s)",
                        j,received[checked_count+j],expected[j],expected);
            checked_count=checked_count+expected.len();
        end
    endtask
    integer i, before_count;
    string payload, status;
    initial begin
        repeat(40) @(posedge clk);
        if (tx!==1 || led_n!==1) $fatal(1,"Power-on state");
        send_text("PING\015\n"); expect_text("PONG\015\n");
        send_text("LED 1\n"); expect_text("OK\015\n");
        if (led_n!==0) $fatal(1,"LED failed to turn on");
        send_text("LED 0\n"); expect_text("OK\015\n");
        if (led_n!==1) $fatal(1,"LED failed to turn off");
        send_text("ECHO hello\n"); expect_text("hello\015\n");
        send_text("ECHO \n"); expect_text("\015\n");
        send_text("ping\n"); expect_text("ERR CMD\015\n");
        send_text("LED 2\n"); expect_text("ERR CMD\015\n");
        // Exactly 64 characters is allowed; the 65th rejects the whole line.
        payload="";
        for (i=0;i<59;i=i+1) payload={payload,8'(65+i%26)};
        send_text({"ECHO ",payload,"\n"}); expect_text({payload,"\015\n"});
        send_text({"ECHO ",payload,"X\n"}); expect_text("ERR LONG\015\n");
        send_text("PING\n"); expect_text("PONG\015\n");
        if(dut.long_count!=1) $fatal(1,"Long-line count");
        // An errored line must not execute LED 1; recover at the next LF.
        send_text("LED "); send_byte("1",1);
        repeat(TICKS*3) @(negedge clk);
        send_text("\n");
        repeat(TICKS*20) @(posedge clk);
        if(led_n!==1 || received_count!=checked_count || dut.frame_count!=1)
            $fatal(1,"Framing-error discard failed");
        // Break produces one framing event, then the RX waits for idle.
        @(negedge clk); rx=0;
        repeat(TICKS*30) @(negedge clk); rx=1;
        repeat(TICKS*3) @(negedge clk);
        send_text("\nPING\n"); expect_text("PONG\015\n");
        if(dut.frame_count!=2) $fatal(1,"Break recovery");
        // Snapshot counters and verify every status byte, including leading zeros.
        status=$sformatf("LED=0 RX=%08X TX=%08X FE=00000002 OV=00000000 LEN=00000001\015\n",
            dut.rx_count+5,dut.tx_count);
        status=status.toupper();
        send_text("STAT\n"); expect_text(status);
        before_count=received_count;
        send_text("\n\015\n");
        repeat(TICKS*30) @(posedge clk);
        if(received_count!=before_count) $fatal(1,"Empty line replied");
        // Back-to-back RX while TX is busy, including FIFO pointer wrap.
        for(i=0;i<90;i=i+1) send_text("PING\n");
        for(i=0;i<90;i=i+1) expect_text("PONG\015\n");
        if(dut.overflow_count!=0) $fatal(1,"Unexpected queue overflow");
        // Sustained response amplification fills the queue. Only complete
        // PONGs may be sent; every command is accounted for as accepted/dropped.
        before_count=received_count;
        for(i=0;i<400;i=i+1) send_text("PING\n");
        repeat(TICKS*10*300) @(posedge clk);
        if(dut.overflow_count==0) $fatal(1,"Overload not exercised");
        for(i=0;i<400-dut.overflow_count;i=i+1) expect_text("PONG\015\n");
        if(received_count-before_count != 6*(400-dut.overflow_count))
            $fatal(1,"Partial response under overload");
        send_text("PING\n"); expect_text("PONG\015\n");
        if(received_count!=checked_count) $fatal(1,"Unexpected trailing bytes");
        passed=1;
        $display("PASS tb_hc05_test: serial commands, counters, errors, FIFO wrap/overload");
        $finish;
    end
    initial begin #100000000; $fatal(1,"Watchdog"); end
endmodule
