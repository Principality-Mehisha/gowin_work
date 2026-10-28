`timescale 1ns/1ps
module tb_ddr_clarinet;
    reg passed=0,clk=0,ui_clk=0,reset_n=0,ui_reset=1,calibrated=0;
    always #10 clk=~clk;
    always #5 ui_clk=~ui_clk;
    reg stop_all=0,tick=0,event_valid=0,event_on=0;
    reg [6:0] note=50;
    reg [7:0] dynamics=192;
    wire ref_ready,ext_ready,ready,fault,request,request_ready,response_valid;
    wire [10:0] address;
    wire [127:0] response;
    wire ref_valid,ext_valid,ref_deadline,ext_deadline;
    wire signed [15:0] ref_pcm,ext_pcm;
    wire signed [31:0] ref_mix,ext_mix;
    wire ref_mix_valid,ext_mix_valid;
    wire [2:0] cmd;
    wire cmd_en,cmd_ready,wr_ready,wr_en,wr_end,rd_valid,rd_end;
    wire [28:0] addr;
    wire [127:0] wr_data,rd_data;
    wire [15:0] mask;
    wire [31:0] writes,reads;
    integer n,v,f,cycle,max_cycles=0,frames=0;
    reg ref_seen,ext_seen,ref_mix_seen,ext_mix_seen;
    reg signed [15:0] reference_pcm,external_pcm;
    reg signed [31:0] reference_mix,external_mix;
    clarinet_synth reference(.clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(event_valid),.event_on(event_on),.event_note(note),.event_dynamics(dynamics),
        .pitch_ratio(18'd193274),.event_ready(ref_ready),.pcm(ref_pcm),.pcm_valid(ref_valid),
        .mix_sample(ref_mix),.mix_valid(ref_mix_valid),.deadline_error(ref_deadline));
    clarinet_synth #(.EXTERNAL_TABLES(1)) external_synth(.clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(event_valid),.event_on(event_on),.event_note(note),.event_dynamics(dynamics),
        .pitch_ratio(18'd193274),.event_ready(ext_ready),.pcm(ext_pcm),.pcm_valid(ext_valid),
        .mix_sample(ext_mix),.mix_valid(ext_mix_valid),.deadline_error(ext_deadline),.tables_ready(ready),
        .table_request(request),.table_address(address),.table_request_ready(request_ready),
        .table_response_valid(response_valid),.table_response_data(response));
    ddr_asset_service service(.sys_clk(clk),.reset_n(reset_n),.cancel(stop_all),
        .request(request),.address(address),.request_ready(request_ready),.response_valid(response_valid),
        .response_data(response),.ready(ready),.fault(fault),.ui_clk(ui_clk),.ui_reset(ui_reset),
        .calibrated(calibrated),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),.cmd_ready(cmd_ready),
        .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),.wr_data_rdy(wr_ready),
        .rd_data(rd_data),.rd_data_valid(rd_valid),.rd_data_end(rd_end),.ui_fault());
    ddr_native_model memory(.clk(ui_clk),.reset(!reset_n || ui_reset),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
        .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
        .cmd_ready(cmd_ready),.wr_data_rdy(wr_ready),.rd_data(rd_data),.rd_data_valid(rd_valid),
        .rd_data_end(rd_end),.freeze(1'b0),.corrupt(1'b0),.end_fault(1'b0),.writes(writes),.reads(reads));
    task send(input bit on_value,input integer pitch,input integer velocity);
        begin
            @(negedge clk);while(!ext_ready || !ref_ready)@(negedge clk);
            note=pitch;dynamics=velocity;event_on=on_value;event_valid=1;
            @(negedge clk);event_valid=0;
        end
    endtask
    task frame;
        begin
            @(negedge clk);tick=1;ref_seen=0;ext_seen=0;ref_mix_seen=0;ext_mix_seen=0;
            for(cycle=0;cycle<3072;cycle=cycle+1)begin
                @(negedge clk);tick=0;
                if(ref_valid)begin reference_pcm=ref_pcm;ref_seen=1;end
                if(ext_valid)begin external_pcm=ext_pcm;ext_seen=1;if(cycle>max_cycles)max_cycles=cycle;end
                if(ref_mix_valid)begin reference_mix=ref_mix;ref_mix_seen=1;end
                if(ext_mix_valid)begin external_mix=ext_mix;ext_mix_seen=1;end
            end
            if(!ref_seen || !ext_seen || !ref_mix_seen || !ext_mix_seen ||
                ref_deadline || ext_deadline || fault)$fatal(1,"DDR synthesis missed sample deadline");
            if(reference_pcm!==external_pcm || reference_mix!==external_mix)
                $fatal(1,"Audio differs note=%d velocity=%d frame=%d ref=%d ddr=%d",note,dynamics,frames,reference_pcm,external_pcm);
            frames=frames+1;
        end
    endtask
    initial begin
        repeat(5)@(negedge clk);reset_n=1;repeat(5)@(negedge clk);ui_reset=0;calibrated=1;
        wait(ready);
        for(n=50;n<=94;n=n+1)for(v=0;v<7;v=v+1)begin
            @(negedge clk);stop_all=1;@(negedge clk);stop_all=0;
            case(v)
                0:send(1,n,32);1:send(1,n,64);2:send(1,n,128);3:send(1,n,160);
                4:send(1,n,192);5:send(1,n,240);6:send(1,n,255);
            endcase
            repeat(3)frame();send(0,n,0);frame();
        end
        send(1,69,192);repeat(4096)frame();send(0,69,0);repeat(700)frame();
        // Interrupt an outstanding table read, then start a different note.
        send(1,50,128);@(negedge clk);tick=1;@(negedge clk);tick=0;
        wait(request && request_ready);@(negedge clk);stop_all=1;@(negedge clk);stop_all=0;
        send(1,94,255);repeat(8)frame();
        passed=1;$display("PASS: DDR vs ROM bit-exact PCM/mix, 45 pitches x 7 velocities, attack/release/cached sustain/cancel; frames=%d max=%d/3072 cycles",frames,max_cycles);$finish;
    end
    initial begin #600000000;$fatal(1,"DDR clarinet test timeout");end
endmodule
