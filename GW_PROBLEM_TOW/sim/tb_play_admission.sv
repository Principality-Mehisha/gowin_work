`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module tb_play_admission;
    localparam UART_TICKS=8;
    reg clk=0,rx=1,k2=1,passed=0;
    reg complete=0,invalidated=0;
    reg [7:0] uploaded=0;
    integer starts=0,saved;
    wire [7:0] leds;
    always #10 clk=~clk;
    piano_score_player #(.PRESSURE_ENABLE(1),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
        .NOTE_GATE_CYCLES(1000000),.NOTE_TAIL_CYCLES(1000000)) dut(
        .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),
        .pitch_group(7'd0),.pressure_sample_valid(1'b0),
        .pressure_sample_key(4'd0),.pressure_sample_data(12'd3510),
        .upload_complete(complete),.upload_invalidated(invalidated),.uploaded_track(uploaded),
        .sd_miso(1'b1),.sd_cs_n(),.sd_sck(),.sd_mosi(),
        .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.LEDs(leds));
    `include "uart_test_tasks.vh"
    always @(posedge clk)if(dut.rst_n)begin
        if(leds!==8'hff)$fatal(1,"SD/UI state leaked into pressure-only LEDs");
        if(dut.sd_active!==dut.system.control.ringtone_active)
            $fatal(1,"SD admission status is not the registered owner");
        if(dut.system.uart_start)starts=starts+1;
    end
    task settle;
        begin
            wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);
            repeat(100)@(negedge clk);
        end
    endtask
    initial begin
        wait(dut.rst_n);settle();
        if(dut.catalog_valid || dut.system.ringtone_active)$fatal(1,"Unexpected initial state");
        // Feedback is deliberately inconsistent with the real SD owner.
        // It must have no influence on the command-admission path.
        force dut.player_state=8'd2;
        send_frame(0,'h12,1,1,0);
        if(starts!=1 || dut.selected_track!=4 || !dut.system.ringtone_active)
            $fatal(1,"Cold selection depends on display state");
        settle();
        force dut.player_state=8'd0;
        send_frame(0,'h12,1,2,0);
        if(starts!=1 || dut.selected_track!=4)
            $fatal(1,"Cold request bypassed active SD owner via display state");
        settle();
        // A known uploaded slot remains selectable while the full catalog
        // is unknown, including changing from an already loading score.
        @(negedge clk);uploaded=5;complete=1;
        @(negedge clk);complete=0;
        send_frame(0,'h12,1,2,0);
        if(starts!=2 || dut.selected_track!=5)$fatal(1,"Known-slot selection rejected");
        settle();
        send_frame(0,'h12,1,2,0);
        if(starts!=2)$fatal(1,"Duplicate selection restarted SD");
        settle();
        @(negedge clk);invalidated=1;
        @(negedge clk);invalidated=0;
        send_frame(0,'h12,1,3,0);
        if(starts!=2 || dut.selected_track!=5)$fatal(1,"Unknown slot interrupted cold SD loading");
        settle();
        send_frame(0,'h11,0,0,0);settle();
        force dut.player_state=8'hff;
        send_frame(0,'h12,1,3,0);
        if(starts!=3 || dut.selected_track!=6)$fatal(1,"Idle admission still depends on feedback");
        settle();
        send_frame(0,'h11,0,0,0);settle();
        send_frame(0,'h42,0,0,0);wait(dut.system.note_busy);settle();
        saved=starts;
        send_frame(0,'h12,1,1,0);
        if(starts!=saved+1 || dut.selected_track!=4 || dut.system.note_busy)
            $fatal(1,"Cold SD selection failed to preempt audition");
        settle();
        release dut.player_state;
        send_frame(0,'h11,0,0,0);settle();
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;
        wait(dut.rst_n);repeat(10)@(negedge clk);
        if(dut.system.ringtone_active || dut.selected_track || dut.last_error)
            $fatal(1,"Reset did not clear SD owner");
        passed=1;
        $display("PASS selection admission: display-independent cold request, active-SD guard, known slot, duplicate, audition takeover and reset");
        $finish;
    end
    initial begin #100000000;$fatal(1,"Admission regression timeout");end
endmodule
