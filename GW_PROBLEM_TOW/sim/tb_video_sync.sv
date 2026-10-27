`timescale 1ns/1ps
module tb_video_sync;
    reg passed=0,clk=0,pclk=0,rst=0,tick=0,active=0;
    always #10 clk=~clk;
    always #4.62963 pclk=~pclk;
    reg [31:0] ms=0;
    reg [87:0] keys=0;
    wire update,va;
    wire [31:0] vm;
    wire [87:0] vk;
    playback_video_cdc dut(.sys_clk(clk),.sys_reset_n(rst),.pixel_clk(pclk),
        .pixel_reset_n(rst),.frame_tick(tick),.active(active),.elapsed_ms(ms),.keys(keys),
        .update(update),.video_active(va),.video_ms(vm),.video_keys(vk));
    reg [120:0] expected;
    integer deliveries=0,i;
    always @(posedge clk) if(rst && dut.req_sync!=dut.acknowledge)
        expected={active,ms,(active ? keys : 88'd0)};
    always @(posedge pclk) begin
        #1;
        if(rst && update) begin
            if({va,vm,vk}!==expected) $fatal(1,"Non-atomic playback snapshot");
            deliveries=deliveries+1;
        end
    end
    initial begin
        repeat(4)@(negedge clk);rst=1;
        for(i=0;i<200;i=i+1) begin
            @(negedge clk);active=i%3!=0;ms=i*1234567;
            keys=(88'd1<<(i%88)) | (88'd1<<((i+23)%88));
            @(negedge pclk);tick=1;@(negedge pclk);tick=0;
            wait(deliveries==i+1);
            repeat(3)@(negedge pclk);
        end
        // Reset both sides while a transfer is outstanding, then restart.
        @(negedge pclk);tick=1;@(negedge pclk);tick=0;rst=0;
        repeat(4)@(negedge pclk);rst=1;active=0;keys=0;ms=0;
        @(negedge pclk);tick=1;@(negedge pclk);tick=0;
        wait(deliveries==201);
        if(va || vk || vm) $fatal(1,"Reset/stop left stale display state");
        passed=1;$display("PASS: 201 coherent CDC snapshots, stop and outstanding-transfer reset");$finish;
    end
    initial begin #1000000;$fatal(1,"CDC timeout");end
endmodule
