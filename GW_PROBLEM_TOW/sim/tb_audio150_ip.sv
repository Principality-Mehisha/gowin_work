`timescale 1ns/1ps
module tb_audio150_ip;
    reg clk=0,read_clk=0,reset_n=0,passed=0;
    always #10 clk=~clk;
    always #7 read_clk=~read_clk;
    GSR GSR(.GSRI(1'b1));
    wire audio_clk,locked,audio_reset_n;
    audio_clock150 clock_ip(.sys_clk(clk),.reset_n(reset_n),
        .audio_clk(audio_clk),.locked(locked),.audio_reset_n(audio_reset_n));
    reg fifo_reset_n=0,wr_valid=0,rd_ready=0;
    reg [31:0] wr_data=0;
    wire wr_ready,rd_valid;
    wire [31:0] rd_data;
    integer written=0,read=0,audio_edges=0,start_edges,n,seed=912;
    reg [31:0] expected[0:1023];
    audio_cdc_fifo fifo(.reset_n(fifo_reset_n),.wr_clk(clk),.rd_clk(read_clk),
        .wr_data(wr_data),.wr_valid(wr_valid),.wr_ready(wr_ready),
        .wr_almost_full(),.wr_domain_ready(),
        .rd_data(rd_data),.rd_valid(rd_valid),.rd_ready(rd_ready));
    always @(posedge clk)if(fifo_reset_n && wr_valid && wr_ready)begin
        expected[written]=wr_data;written=written+1;
    end
    always @(posedge read_clk)if(fifo_reset_n && rd_valid && rd_ready)begin
        if(read>=written || rd_data!==expected[read])
            $fatal(1,"Official FIFO order/data at %0d: %h/%h",read,rd_data,expected[read]);
        read=read+1;
    end
    always @(posedge audio_clk)if(audio_reset_n)audio_edges=audio_edges+1;
    initial begin
        repeat(8)@(negedge clk);reset_n=1;fifo_reset_n=1;
        for(n=0;n<512;n=n+1)begin
            @(negedge clk);wr_data=32'h5a000000+n;wr_valid=1;
            @(posedge clk);while(!wr_ready)@(posedge clk);
            @(negedge clk);wr_valid=0;
            repeat($urandom_range(0,2))@(negedge clk);
        end
        wait(read==512);
        @(negedge clk);fifo_reset_n=0;
        repeat(8)@(negedge clk);written=0;read=0;fifo_reset_n=1;
        for(n=0;n<64;n=n+1)begin
            @(negedge clk);wr_valid=1;wr_data=32'ha5000000+n;
            @(posedge clk);while(!wr_ready)@(posedge clk);
            @(negedge clk);wr_valid=0;
        end
        wait(read==64);wait(audio_reset_n);
        @(negedge clk);start_edges=audio_edges;
        repeat(1000)@(negedge clk);
        if(audio_edges-start_edges<2998 || audio_edges-start_edges>3002)
            $fatal(1,"Official PLL frequency not 150 MHz: %0d edges",audio_edges-start_edges);
        @(negedge clk);reset_n=0;repeat(8)@(negedge clk);
        if(locked || audio_reset_n)$fatal(1,"Audio PLL/reset did not clear");
        reset_n=1;wait(audio_reset_n);
        passed=1;
        $display("PASS official audio IP: Gowin PLL 50->150 MHz startup/reset/relock, FIFO 576 ordered words, unrelated clock phases/backpressure/wrap/reset");
        $finish;
    end
    always @(negedge read_clk)rd_ready<=fifo_reset_n && $urandom_range(0,3)!=0;
    initial begin #10000000;$fatal(1,"Audio IP timeout");end
endmodule
