`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module tb_marimba_pressure;
    localparam UART_TICKS=8;
    reg clk=0,pclk=0,k2=1,rx=1,passed=0;
    always #10 clk=~clk;
    always #4.63 pclk=~pclk;
    reg [6:0] group_mask=7'b0000100;
    reg [11:0] voltages[0:15];
    reg [4:0] divider=0;
    reg [3:0] cursor=0,sample_key=0;
    reg sample_valid=0;
    reg [11:0] sample_data=3510;
    wire tick,enabled,clear;
    wire [7:0] leds;
    wire signed [15:0] pcm;
    piano_score_player #(.PRESSURE_ENABLE(1),.PRESSURE_CALIBRATION_LOG2(0),
        .PRESSURE_LONG_HOLD_FRAMES(4),.PITCH_GROUP_STABLE_CYCLES(3),
        .POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),.UART_CLK_HZ(76800),.UART_BAUD(9600)) dut(
        .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),.sd_miso(1'b1),
        .pitch_group(group_mask),.pressure_sample_valid(sample_valid),
        .pressure_sample_key(sample_key),.pressure_sample_data(sample_data),
        .upload_complete(1'b0),.upload_invalidated(1'b0),.uploaded_track(8'd0),
        .audio_analysis_active(enabled),.analysis_clear(clear),.analysis_sample_tick(tick),
        .analysis_pcm(pcm),.LEDs(leds),.HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN());
    always @(posedge clk)begin
        sample_valid<=0;
        if(!dut.rst_n)begin divider<=0;cursor<=0;end
        else if(divider==31)begin
            divider<=0;sample_valid<=1;sample_key<=cursor;sample_data<=voltages[cursor];
            cursor<=cursor+1'b1;
        end else divider<=divider+1'b1;
    end
    wire ready,result_valid,busy;
    wire [8:0] address;
    wire [31:0] result;
    piano_audio_analysis analysis(.clk(clk),.reset_n(dut.rst_n),.clear(clear),
        .sample_valid(tick && enabled),.sample_pcm(pcm),.out_ready(ready),
        .out_valid(result_valid),.out_address(address),.out_data(result),.completed_frames(),.busy(busy));
    reg [10:0] pixel_count=0;
    always @(posedge pclk)pixel_count<=pixel_count==999 ? 0 : pixel_count+1'b1;
    wire frame_tick=pixel_count==999;
    reg [8:0] read_address=0;
    wire [31:0] read_data;
    wire visible;
    analysis_frame_cdc frames(.sys_clk(clk),.sys_reset_n(dut.rst_n),.clear(clear),
        .write_valid(result_valid),.write_address(address),.write_data(result),
        .write_ready(ready),.pixel_clk(pclk),.pixel_reset_n(dut.rst_n),.frame_tick(frame_tick),
        .read_address(read_address),.read_data(read_data),.visible_valid(visible));
    integer captures=0,rows=0,strikes=0,heard=0,tail_ticks=0,i,input_file,result_file,saved;
    integer note_hits[0:83];
    reg recording=0,check_b5=1;
    reg [7:0] initial_gain;
    reg [31:0] expected[0:511];
    `include "uart_test_tasks.vh"
    task settle;
        begin wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);
            repeat(100)@(negedge clk);end
    endtask
    always @(posedge clk)if(dut.rst_n)begin
        if(dut.system.deadline_error || dut.system.pressure_overflow)$fatal(1,"Marimba pressure deadline/FIFO");
        if(tick && pcm!==dut.audio.left_sample)$fatal(1,"Analysis differs from DAC sample");
        if(pcm!=0)heard=heard+1;
        if(dut.system.marimba_mode && (dut.video_active || dut.video_keys))
            $fatal(1,"Marimba entered piano waterfall");
        if(dut.system.voices.marimba.event_valid && dut.system.voices.marimba.event_ready &&
           dut.system.voices.marimba.event_on)begin
            strikes=strikes+1;
            if(dut.system.voices.marimba.event_note<36 || dut.system.voices.marimba.event_note>83)
                $fatal(1,"Pressure reached unsupported marimba note");
            note_hits[dut.system.voices.marimba.event_note]=note_hits[dut.system.voices.marimba.event_note]+1;
            if(check_b5 && dut.system.voices.marimba.event_note!=83)
                $fatal(1,"Third group last key is not B5");
        end
        if(tick && !dut.system.voices.marimba.voice_busy && dut.system.voices.marimba_tail!=0)
            tail_ticks=tail_ticks+1;
        if(recording && (analysis.first_sample || (analysis.state==1 && tick && enabled && !clear)))begin
            if(captures<1024)$fdisplay(input_file,"%04x",pcm);
            captures=captures+1;
        end
        if(recording && result_valid && ready && rows<512)begin
            if(address!==rows[8:0])$fatal(1,"Marimba FFT row order");
            expected[rows]=result;$fdisplay(result_file,"%08x",result);rows=rows+1;
        end
    end
    initial begin
        for(i=0;i<84;i=i+1)note_hits[i]=0;
        for(i=0;i<16;i=i+1)voltages[i]=3510;
        input_file=$fopen("output/marimba_pressure/marimba_input.hex","w");
        result_file=$fopen("output/marimba_pressure/marimba_result.hex","w");
        wait(dut.rst_n);wait(dut.system.pressure_calibrated==16'hffff);settle();
        send_frame(0,'h44,0,0,0);settle();
        if(!dut.system.pressure_enable || enabled)$fatal(1,"Marimba pressure/idle setup");
        send_frame(0,'h50,1,0,0);settle();
        recording=1;voltages[15]=1900;
        wait(strikes==1);@(negedge clk);initial_gain=dut.system.voices.marimba.dynamics_by_note[47];
        repeat(8)@(posedge tick);
        voltages[15]=2700;repeat(8)@(posedge tick);
        voltages[15]=1300;repeat(8)@(posedge tick);
        if(strikes!=1 || dut.system.voices.marimba.dynamics_by_note[47]!=initial_gain ||
           !enabled || leds!=0)$fatal(1,"Held pressure altered/retriggered the marimba strike");
        voltages[15]=3510;wait(dut.system.pressure_pressed==0);
        repeat(100)@(negedge clk);
        if(!enabled || clear || leds!=8'hff)$fatal(1,"Release truncated natural marimba analysis tail");
        wait(rows==512);@(negedge clk);recording=0;
        $fclose(input_file);$fclose(result_file);
        wait(visible);
        for(i=0;i<512;i=i+1)begin
            @(negedge pclk);read_address=i;repeat(2)@(negedge pclk);
            if(read_data!==expected[i])$fatal(1,"Marimba analysis CDC torn/stale row");
        end
        if(captures!=1024 || !heard)$fatal(1,"No complete real marimba analysis frame");
        wait(!enabled);
        if(tail_ticks!=128 || !clear || strikes!=1)$fatal(1,"Natural modal/filter tail did not finish");
        // A new instrument clears the old publication, never relabels it.
        send_frame(0,'h43,0,0,0);settle();repeat(20)@(negedge pclk);
        if(visible || enabled)$fatal(1,"Old marimba frame survived timbre switch");
        send_frame(0,'h44,0,0,0);settle();saved=strikes;
        group_mask=7'b0001000;repeat(2000)@(negedge clk);voltages[0]=1900;
        repeat(12000)@(negedge clk);
        if(strikes!=saved || leds!=8'hff)$fatal(1,"Invalid marimba group sounded or lit LEDs");
        group_mask=1;repeat(12000)@(negedge clk);
        if(strikes!=saved)$fatal(1,"Invalid held key replayed after valid group selected");
        voltages[0]=3510;wait(dut.system.pressure_pressed==0);
        repeat(100)@(negedge clk);check_b5=0;saved=strikes;
        for(i=0;i<16;i=i+1)voltages[i]=1900;
        wait(strikes==saved+16);repeat(4)@(posedge tick);
        for(i=0;i<16;i=i+1)
            if(note_hits[36+i]!=1 || !dut.system.voices.marimba.active_modes[i*4])
                $fatal(1,"Missing/retriggered note in sixteen-key marimba chord");
        if(strikes!=saved+16 || !enabled || leds==8'hff)$fatal(1,"Marimba chord/analysis/LED ownership");
        send_frame(0,'h11,0,0,0);settle();
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;wait(dut.rst_n);
        if(enabled || !clear || leds!=8'hff)$fatal(1,"Marimba reset retained analysis/LEDs");
        passed=1;$display("PASS marimba pressure: real UART/pressure B5 and 16-key chord, attack-only gain, no retrigger, release/natural decay, 128-frame filter tail, exact DAC samples, 1024/512 FFT data, frame CDC, invalid group/rearm, timbre clear and reset");$finish;
    end
    initial begin #1000000000;$fatal(1,"Marimba pressure/analysis timeout");end
endmodule
