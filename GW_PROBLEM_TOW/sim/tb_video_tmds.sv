`timescale 1ns/1ps
module tb_tmds;
    reg passed=0, clk=0, reset_n=0;
    always #4.629630 clk=~clk;
    reg [7:0] data=0;
    reg de=0,c0=0,c1=0;
    wire [9:0] symbol;
    tmds_encoder dut(.pixel_clk(clk),.reset_n(reset_n),.data(data),
        .de(de),.c0(c0),.c1(c1),.symbol(symbol));
    reg [7:0] d0=0,d1=0,recovered,qm;
    reg [2:0] ctrl0=0,ctrl1=0;
    reg valid0=0,valid1=0;
    reg [9:0] expected_control;
    integer i,j,ones,transitions,rd=0,checked=0;
    always @(posedge clk) begin
        #1;
        if(reset_n) begin
            if(valid1) begin
                if(!ctrl1[2]) begin
                    case(ctrl1[1:0])
                        0:expected_control=10'b1101010100;
                        1:expected_control=10'b0010101011;
                        2:expected_control=10'b0101010100;
                        3:expected_control=10'b1010101011;
                    endcase
                    if(symbol !== expected_control || dut.disparity !== 0)
                        $fatal(1,"Control symbol/pipeline mismatch");
                    rd=0;
                end else begin
                    qm=symbol[9] ? ~symbol[7:0] : symbol[7:0];
                    recovered[0]=qm[0];
                    for(j=1;j<8;j=j+1)
                        recovered[j]=symbol[8] ? (qm[j]^qm[j-1]) : ~(qm[j]^qm[j-1]);
                    if(recovered !== d1) $fatal(1,"TMDS decoded byte/pipeline mismatch");
                    transitions=0;
                    for(j=1;j<8;j=j+1) transitions=transitions+(qm[j]!=qm[j-1]);
                    if(transitions>4) $fatal(1,"Transition minimization failed");
                    ones=0;
                    for(j=0;j<10;j=j+1) ones=ones+symbol[j];
                    rd=rd+2*ones-10;
                    if(rd!=$signed(dut.disparity) || rd < -8 || rd > 8)
                        $fatal(1,"Invalid running disparity");
                    checked=checked+1;
                end
            end
            valid1=valid0; valid0=1;
            d1=d0; d0=data;
            ctrl1=ctrl0; ctrl0={de,c1,c0};
        end
    end
    initial begin
        repeat(3) @(negedge clk);
        reset_n=1;
        for(i=0;i<8200;i=i+1) begin
            de=(i>=4 && i<8196);
            {c1,c0}=i;
            if(i<2052) data=i-4;
            else if(i<4100) data=255-(i-4);
            else data=$random;
            @(negedge clk);
        end
        de=0;
        repeat(3) @(negedge clk);
        if(checked!=8192) $fatal(1,"Incomplete TMDS regression");
        $display("PASS: controls, 8192 TMDS samples, three-stage alignment, disparity and transitions");
        passed=1;
        $finish;
    end
endmodule
