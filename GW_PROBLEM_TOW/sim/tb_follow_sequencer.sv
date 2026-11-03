`timescale 1ns/1ps
module tb_follow_sequencer;
    reg clk=0,rst_n=0,paused=0,mode=1,done=0,fault=0,valid=0,hit=0,passed=0;
    reg [63:0] data=0;
    reg [6:0] hit_note=0;
    reg [15:0] pressed=0;
    wire ready,dispatch,waiting,playing,finished,error;
    wire [2:0] group_id;
    wire [87:0] keys;
    wire [31:0] elapsed;
    integer n;
    always #10 clk=~clk;
    piano_score_sequencer #(.CLOCKS_PER_MS(4),.FIFO_BITS(3),.PREFILL_EVENTS(1)) dut(
        .clk(clk),.rst_n(rst_n),.paused(paused),.guide_mode(mode),.guide_hit(hit),
        .guide_hit_note(hit_note),.guide_pressed(pressed),.guide_waiting(waiting),
        .guide_group(group_id),.guide_keys(keys),.format_ok(1'b1),
        .stream_complete(done),.stream_error(fault),.event_data(data),.event_valid(valid),
        .dispatch_ready(1'b1),.event_ready(ready),.dispatch_valid(dispatch),
        .dispatch_on(),.dispatch_note(),.dispatch_dynamics(),.notes(),.velocities(),
        .gates(),.triggers(),.playing(playing),.finished(finished),.error(error),.elapsed_ms(elapsed));
    always @(posedge clk)if(rst_n && mode && dispatch)$fatal(1,"Guide dispatched automatic audio");
    task reset;
        begin @(negedge clk);rst_n=0;valid=0;hit=0;pressed=0;done=0;fault=0;paused=0;
            repeat(3)@(negedge clk);rst_n=1;end
    endtask
    task put(input integer t,s,note,v);
        begin @(negedge clk);data={8'd0,8'(v),8'(note),8'(s),32'(t)};valid=1;
            do @(posedge clk);while(!ready);
            @(negedge clk);valid=0;end
    endtask
    task press(input integer note);
        begin @(negedge clk);hit_note=note;pressed[note%16]=1;hit=1;
            @(negedge clk);hit=0;end
    endtask
    task expect_target(input integer note,input integer t);
        begin wait(waiting);#1;
            if(keys!==(88'b1<<note) || elapsed!=t)$fatal(1,"Wrong target note=%0d keys=%h time=%0d",note,keys,elapsed);
            repeat(12)@(negedge clk);
            if(!waiting || elapsed!=t || error)$fatal(1,"Guide advanced without a press");end
    endtask
    initial begin
        reset();
        // A complete group can span an empty FIFO and a delayed SD sector.
        put(100,0,54,100);repeat(30)@(negedge clk);
        if(waiting || error)$fatal(1,"Incomplete timestamp group published / underrun");
        paused=1;put(100,1,22,100);put(100,2,57,100);put(200,0,54,0);
        repeat(12)@(negedge clk);if(waiting)$fatal(1,"Paused guide collected a target");paused=0;
        wait(waiting);#1;
        if(group_id!=3 || keys!==((88'b1<<54)|(88'b1<<57)))$fatal(1,"Highest group chord wrong");
        press(22);repeat(4)@(negedge clk);if(!waiting)$fatal(1,"Lower group counted");
        pressed=0;repeat(2)@(negedge clk);press(54);
        repeat(4)@(negedge clk);if(!waiting)$fatal(1,"Partial chord counted");
        pressed=0;repeat(2)@(negedge clk);press(57);
        repeat(4)@(negedge clk);if(!waiting)$fatal(1,"Released chord key counted");
        press(54);wait(!waiting);pressed=0;
        put(300,0,22,100);put(400,0,22,0);expect_target(22,300);
        put(500,0,22,100);put(600,0,22,0);put(700,255,255,0);done=1;
        press(22);wait(!waiting);wait(waiting);repeat(16)@(negedge clk);
        if(elapsed!=500 || finished)$fatal(1,"Held repeated note skipped");
        // Even a queued stale hit while still held cannot satisfy the new step.
        press(22);repeat(8)@(negedge clk);if(!waiting)$fatal(1,"Stale held press counted");
        pressed=0;repeat(3)@(negedge clk);press(22);wait(finished);
        if(error || keys)$fatal(1,"EOF failed");
        // Every note, including all eight top-group keys; terminal at same time.
        for(n=0;n<88;n=n+1)begin
            reset();put(0,0,n,100);put(0,255,255,0);done=1;
            expect_target(n,0);press(n);wait(finished);
            if(error)$fatal(1,"Note %0d failed",n);
        end
        // Long wait applies FIFO backpressure; resumes without dropped records.
        reset();put(0,0,1,100);put(1,0,1,0);wait(waiting);
        for(n=2;n<9;n=n+1)put(n,0,1,0);
        repeat(10)@(negedge clk);if(ready || error)$fatal(1,"FIFO did not backpressure");
        press(1);wait(!waiting);pressed=0;put(20,255,255,0);done=1;wait(finished);
        reset();put(0,0,3,100);put(1,255,255,0);expect_target(3,0);
        fault=1;@(negedge clk);@(negedge clk);
        if(!error || waiting || keys)$fatal(1,"Stream error did not clear target");
        mode=0;reset();put(0,0,3,100);put(3,255,255,0);done=1;
        wait(finished);if(error || waiting)$fatal(1,"Automatic playback broken");
        passed=1;$display("PASS follow sequencer: all 88 targets, cross-group chord, fresh simultaneous presses, repeats, delayed refill, full FIFO, same-time EOF, errors, automatic mode");$finish;
    end
    initial begin #10000000;$fatal(1,"Follow sequencer timeout");end
endmodule
