// Internal IDs 1..3 retain the legacy songs; 4..103=PN, 104..203=MB.
module score_file_name (
    input wire [7:0] track,
    output wire [87:0] file_name,
    output wire marimba, numbered
);
    wire [7:0] number=track>=104 ? track-8'd103 : track-8'd3;
    wire [7:0] hundreds=number==100 ? 8'd49 : 8'd48;
    wire [7:0] tens=8'd48+((number==100 ? 8'd0 : number)/10);
    wire [7:0] ones=8'd48+(number%10);
    assign numbered=track>=4 && track<=203;
    assign marimba=track==1 || track==2 || (track>=104 && track<=203);
    assign file_name=track==1 ? "ANDROID BIN" :
                     track==2 ? "RINGTONEBIN" :
                     track==3 ? "PIANO   BIN" :
                     {marimba ? 16'h4d42 : 16'h504e,hundreds,tens,ones,"   BIN"};
endmodule
