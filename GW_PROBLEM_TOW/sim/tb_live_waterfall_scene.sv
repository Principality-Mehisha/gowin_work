`timescale 1ns/1ps
module tb_live_waterfall_scene;
    reg passed=0,clk=0,reset_n=0,update=0,clear=0;
    always #5 clk=~clk;
    reg [87:0] activity=0,held=0,history[0:179],held_file[0:0];
    reg [10:0] x=1800;
    reg [9:0] y=1000;
    wire [23:0] rgb;
    piano_scene #(.REALTIME(1)) dut(.clk(clk),.reset_n(reset_n),.frame_tick(1'b0),
        .update(update),.active(1'b1),.elapsed_ms(32'd0),.lit_keys(held),
        .clear(clear),.activity(activity),.x(x),.y(y),.test_pattern(1'b0),.rgb(rgb));
    reg [23:0] expected[0:1439999];
    reg input_valid=0,v0=0,v1=0,v2=0,v3=0;
    integer index0,index1,index2,index3,checked=0,file_handle,i,j;
    always @(posedge clk)begin
        #1;
        if(v3)begin
            if(rgb!==expected[index3])$fatal(1,"Live scene pipeline/palette mismatch index=%0d got=%h expected=%h",index3,rgb,expected[index3]);
            $fwrite(file_handle,"%c%c%c",rgb[23:16],rgb[15:8],rgb[7:0]);checked=checked+1;
        end
        v3=v2;v2=v1;v1=v0;v0=input_valid;
        index3=index2;index2=index1;index1=index0;index0=y*1600+x;
    end
    initial begin
        $readmemh("output/live_waterfall/history.hex",history);
        $readmemh("output/live_waterfall/held.hex",held_file);
        $readmemh("output/live_waterfall/expected.hex",expected);
        file_handle=$fopen("output/live_waterfall/live_waterfall_rtl.ppm","wb");
        $fwrite(file_handle,"P6\n1600 900\n255\n");
        repeat(3)@(negedge clk);reset_n=1;held=held_file[0];
        for(i=0;i<180;i=i+1)begin
            @(negedge clk);activity=history[i];clear=i==0;update=1;
            @(negedge clk);update=0;clear=0;
        end
        repeat(5)@(negedge clk);
        for(j=0;j<900;j=j+1)begin
            for(i=0;i<1600;i=i+1)begin x=i;y=j;input_valid=1;@(negedge clk);end
            input_valid=0;
            for(i=1600;i<1800;i=i+1)begin x=i;@(negedge clk);end
        end
        input_valid=0;x=1800;y=1000;repeat(4)@(negedge clk);$fclose(file_handle);
        if(checked!=1440000)$fatal(1,"Incomplete live scene render");
        passed=1;$display("PASS: live waterfall 1,440,000 RGB pixels, 88-key geometry, chord history, keyboard highlights and five-clock pipeline");$finish;
    end
    initial begin #20000000;$fatal(1,"Live scene timeout");end
endmodule
