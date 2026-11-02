`timescale 1ns/1ps
`include "../output/audio_effects/params.vh"
module tb_audio_effects;
    reg clk=0,rst=0,clear=0,valid=0,passed=0;
    always #10 clk=~clk;
    reg [1:0] mode=0;
    reg [6:0] amount=0;
    reg signed [15:0] sample=0;
    wire signed [15:0] output_sample;
    wire out_valid,busy,tail,error;
    wire [1:0] applied;
    reg [63:0] vectors[0:`FX_VECTORS-1],v;
    integer i,cycles,max_cycles=0,fd;
    audio_effects dut(.clk(clk),.reset_n(rst),.clear(clear),.in_valid(valid),
        .in_sample(sample),.mode(mode),.amount(amount),.out_sample(output_sample),
        .out_valid(out_valid),.busy(busy),.tail_active(tail),
        .applied_mode(applied),.deadline_error(error));
    initial begin
        $readmemh("output/audio_effects/vectors.hex",vectors);
        fd=$fopen("output/audio_effects/rtl_samples.hex","w");
        repeat(3)@(negedge clk);rst=1;
        for(i=0;i<`FX_VECTORS;i=i+1)begin
            v=vectors[i];
            @(negedge clk);mode=v[63:62];amount=v[61:55];sample=v[53:38];
            if(v[54])begin
                clear=1;@(negedge clk);clear=0;
                if(output_sample!=0 || busy || tail)$fatal(1,"Clear retained effects");
            end
            valid=1;@(negedge clk);valid=0;cycles=0;
            while(!out_valid && cycles<64)begin @(negedge clk);cycles=cycles+1;end
            if(cycles>max_cycles)max_cycles=cycles;
            if(cycles==64 || error || output_sample!==v[37:22] ||
               tail!==v[21] || applied!==v[20:19] || dut.wet_gain!==v[18:12])
                $fatal(1,"FX sample %0d mode=%0d: out=%0d exp=%0d gain=%0d/%0d tail=%0b/%0b cycles=%0d",
                    i,mode,output_sample,$signed(v[37:22]),dut.wet_gain,v[18:12],tail,v[21],cycles);
            $fdisplay(fd,"%04x",output_sample);
            repeat(2)@(negedge clk);
        end
        $fclose(fd);
        mode=1;clear=1;@(negedge clk);clear=0;
        valid=1;repeat(2)@(negedge clk);valid=0;
        if(!error)$fatal(1,"Missed effect deadline was not reported");
        clear=1;@(negedge clk);clear=0;
        if(error || output_sample!=0)$fatal(1,"Effect fault clear failed");
        passed=1;$display("PASS effects: %0d bit-exact vectors, all modes/amounts, shared RAM wrap/clear, fades, saturation, tail expiry, deadline fault; max %0d clocks",`FX_VECTORS,max_cycles);$finish;
    end
    initial begin #500000000;$fatal(1,"Effect vectors timeout");end
endmodule
