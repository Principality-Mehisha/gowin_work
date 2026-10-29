`timescale 1ns/1ps
// Existing UART/SD/real-synth scenarios, additionally audit display ownership.
module tb_video_player;
    reg passed=0;
    wire done;
    uart_player_case normal(done);
    reg [87:0] expected_keys=0;
    integer piano_cycles=0,piano_ons=0,other_cycles=0;
    always @(posedge normal.clk) begin
        if(!normal.dut.rst_n) expected_keys=0;
        else if(!normal.dut.video_active || normal.dut.system.synth_stop) expected_keys=0;
        else if(normal.dut.system.synth_event_valid && normal.dut.system.synth_event_ready && normal.dut.system.synth_event_note<88) begin
            expected_keys[normal.dut.system.synth_event_note]=normal.dut.system.synth_event_on;
            if(normal.dut.system.synth_event_on)piano_ons=piano_ons+1;
        end
        #1;
        if(normal.dut.video_keys!==expected_keys)$fatal(1,"Displayed keys differ from actual piano events");
        if(normal.dut.video_elapsed_ms!==normal.dut.elapsed_ms)$fatal(1,"Independent video timeline");
        if(normal.dut.video_active) begin
            if(normal.dut.selected_track!=3 || !normal.dut.playing || normal.dut.system.failed)
                $fatal(1,"Display owned by wrong track/state");
            piano_cycles=piano_cycles+1;
        end else if(normal.dut.system.ringtone_active && normal.dut.selected_track!=3) other_cycles=other_cycles+1;
    end
    initial begin
        wait(done);#2;
        if(piano_cycles==0 || piano_ons==0 || other_cycles==0)$fatal(1,"Missing playback/display coverage");
        passed=1;$display("PASS: actual SD/UART playback time and accepted piano keys, other-track isolation, stop/restart/reset");$finish;
    end
    initial begin #200000000;$fatal(1,"Video player timeout");end
endmodule
