`timescale 1ns/1ps
module tb_serializer_reset;
    reg clk=0,rst=0,passed=0;
    always #10 clk=~clk;
    GSR GSR(.GSRI(1'b1));
    wire [2:0] dp,dn;
    wire cp,cn;
    piano_video dut(.sys_clk(clk),.reset_n(rst),.active(1'b0),.clear(1'b0),
        .elapsed_ms(32'd0),.keys(88'd0),.display_mode(2'd0),.audio_active(1'b0),
        .analysis_clear(1'b1),.sample_tick(1'b0),.sample_pcm(16'sd0),
        .tmds_data_p(dp),.tmds_data_n(dn),.tmds_clk_p(cp),.tmds_clk_n(cn));
    reg [23:0] rgb=24'h31be92;
    reg [29:0] expected[0:4095];
    integer writes=0,cursor=-1,bit_index=0,decoded=0,total=0,i,j,attempt;
    reg [29:0] word_bits=0;
    reg previous_clock=0,checking=0,aligned=0,found;
    realtime last_falling_serial,last_rising_pixel,last_falling_pixel;
    reg check_duty=0;
    always @(negedge dut.serial_clk)last_falling_serial=$realtime;
    always @(negedge dut.pixel_clk)begin
        last_falling_pixel=$realtime;
        if(check_duty && ($realtime-last_rising_pixel<5.53 || $realtime-last_rising_pixel>5.58))
            $fatal(1,"Official CLKDIV /5 duty cycle does not match SDC edges");
        if(dut.video_reset_n)rgb<={rgb[22:0],rgb[23]^rgb[22]^rgb[21]^rgb[16]};
    end
    always @(posedge dut.pixel_clk)begin
        if(check_duty && ($realtime-last_falling_pixel<3.68 || $realtime-last_falling_pixel>3.73))
            $fatal(1,"Official CLKDIV /5 low duration differs from SDC");
        last_rising_pixel=$realtime;
    end
    always @(posedge dut.serializer_release[2])
        if($realtime-last_falling_serial>0.01)$fatal(1,"Serializer reset did not release on falling FCLK");
    always @(posedge dut.pixel_clk)begin
        if(!dut.video_reset_n)writes=0;
        else if(writes<4096)begin
            expected[writes]={dut.tx.symbols[2],dut.tx.symbols[1],dut.tx.symbols[0]};
            writes=writes+1;
        end
    end
    always @(dut.serial_clk)begin
        #0.1;
        if(!checking || !dut.serializer_release[2])begin
            previous_clock=cp;aligned=0;bit_index=0;cursor=-1;
        end else begin
            if((^{dp,dn,cp,cn})===1'bx || dn!==~dp || cn!==~cp)
                $fatal(1,"Serializer differential/unknown output");
            if(!aligned && previous_clock && !cp)begin aligned=1;bit_index=0;end
            if(aligned)begin
                if(cp!==(bit_index>=5))$fatal(1,"Forwarded clock word alignment");
                word_bits[bit_index]=dp[0];
                word_bits[10+bit_index]=dp[1];
                word_bits[20+bit_index]=dp[2];
                if(bit_index==9)begin
                    if(cursor<0)begin
                        found=0;
                        for(j=0;j<writes;j=j+1)
                            if(expected[j]===word_bits && !found)begin cursor=j;found=1;end
                        if(!found)$fatal(1,"First decoded serializer word not in pixel stream");
                    end else begin
                        cursor=cursor+1;
                        if(cursor>=writes || word_bits!==expected[cursor])
                            $fatal(1,"Serializer skipped/duplicated/tore a TMDS word");
                    end
                    decoded=decoded+1;total=total+1;bit_index=0;
                end else bit_index=bit_index+1;
            end
            previous_clock=cp;
        end
    end
    initial begin
        force dut.red=rgb[23:16];
        force dut.green=rgb[15:8];
        force dut.blue=rgb[7:0];
        repeat(10)@(negedge clk);rst=1;
        for(attempt=0;attempt<3;attempt=attempt+1)begin
            wait(dut.serializer_release[2]);repeat(100)@(posedge dut.pixel_clk);check_duty=1;
            checking=1;decoded=0;wait(decoded==500);
            checking=0;check_duty=0;#3.1;rst=0;repeat(10)@(negedge clk);rst=1;
        end
        passed=1;
        $display("PASS serializer reset: %0d exact three-lane TMDS words, falling-FCLK release, verified 60%% PCLK duty, DDR clock framing and three reset/relock attempts",total);
        $finish;
    end
    initial begin #30000000;$fatal(1,"Serializer reset/decode timeout");end
endmodule
