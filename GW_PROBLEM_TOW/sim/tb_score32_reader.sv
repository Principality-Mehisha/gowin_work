`timescale 1ns/1ps
module tb_score32_reader;
    reg clk=0,rst_n=0,marimba=0,valid=0,file_done=0,accept=1,passed=0;
    reg [7:0] data=0,content[0:39];
    wire ready,event_valid,format_ok,complete;
    wire [63:0] event_data;
    wire [3:0] error;
    integer received=0;
    always #10 clk=~clk;
    piano_score_reader #(.DYNAMIC_FORMAT(1)) dut(
        .clk(clk),.rst_n(rst_n),.marimba_format(marimba),
        .data(data),.valid(valid),.ready(ready),.file_found(1'b1),
        .file_size(32'd40),.file_done(file_done),.event_data(event_data),
        .event_valid(event_valid),.event_ready(accept),.format_ok(format_ok),
        .complete(complete),.error_code(error));
    always @(posedge clk)if(rst_n && event_valid && accept)received=received+1;
    task run_case(input integer slots,slot,note,expected);
        reg [63:0] held;
        integer i,cycles;
        begin
            @(negedge clk);rst_n=0;valid=0;file_done=0;accept=1;received=0;
            for(i=0;i<40;i=i+1)content[i]=0;
            content[0]=marimba ? "M" : "P";content[1]=marimba ? "4" : "8";
            content[2]=marimba ? "2" : "8";content[3]="S";
            content[4]=1;content[5]=8;content[6]=slots;
            content[8]=8'he8;content[9]=3;content[12]=3;
            content[20]=slot;content[21]=note;content[22]=127;
            content[24]=1;content[28]=slot;content[29]=note;
            content[32]=2;content[36]=255;content[37]=255;
            repeat(3)@(negedge clk);rst_n=1;
            for(i=0;i<40 && error==0;i=i+1)begin
                // Exercise HOLD before allowing the second record through.
                if(i==24 && expected==0)begin
                    valid=0;accept=0;wait(event_valid);held=event_data;
                    repeat(12)begin @(negedge clk);
                        if(!event_valid || event_data!==held)$fatal(1,"Reader broke backpressure");
                    end
                    accept=1;
                end
                data=content[i];valid=1;
                cycles=0;
                do begin @(posedge clk);cycles=cycles+1;end
                while(!ready && error==0 && cycles<100);
                if(cycles>=100)$fatal(1,"Reader stalled");
                @(negedge clk);valid=0;
            end
            file_done=1;repeat(20)@(negedge clk);file_done=0;
            if(error!=expected)$fatal(1,"slots=%0d slot=%0d note=%0d error=%0d expected=%0d",
                                     slots,slot,note,error,expected);
            if(expected==0 && (!format_ok || !complete || received!=3))
                $fatal(1,"Valid 8/32-slot score incomplete");
        end
    endtask
    initial begin
        run_case(8,7,87,0);run_case(32,31,0,0);run_case(32,31,87,0);
        run_case(8,8,0,2);run_case(32,32,0,2);run_case(32,31,88,2);
        run_case(0,0,0,1);run_case(9,0,0,1);run_case(16,0,0,1);run_case(33,0,0,1);
        marimba=1;
        run_case(8,7,36,0);run_case(32,31,36,0);run_case(32,31,83,0);
        run_case(8,8,36,2);run_case(32,32,36,2);
        run_case(32,31,35,2);run_case(32,31,84,2);
        passed=1;$display("PASS 32-slot reader: legacy 8, slot31, both note ranges, invalid headers/slots/notes, backpressure");$finish;
    end
    initial begin #1000000;$fatal(1,"32-slot reader timeout");end
endmodule
