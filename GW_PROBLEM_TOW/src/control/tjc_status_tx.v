// Native TJC commands, recmod=0. Each snapshot updates page0.n0..n5:
// state, track, error, result, sequence, command; then note/instrument text.
// payload: {clarinet,marimba,selected_note[6:0],state,track,error,result,sequence,command}.
module tjc_status_tx (
    input wire clk, rst_n,
    input wire [56:0] snapshot,
    input wire valid,
    output wire ready,
    output reg [7:0] byte_data,
    output wire byte_valid,
    input wire byte_ready
);
    reg busy;
    reg [56:0] saved;
    reg [2:0] field;
    reg [1:0] fence;
    reg [5:0] pos;
    reg [7:0] value;
    reg [3:0] hundreds, tens, ones;
    reg [4:0] digits;
    reg [7:0] semitones, pitch_class, octave, note_letter;
    reg sharp;
    reg [4:0] note_length;
    wire [5:0] instrument_length=saved[56] ? 6'd6 : (saved[55] ? 6'd8 : 6'd4);
    assign ready = !busy;
    assign byte_valid = busy;
    always @* begin
        case(field)
            0: value=saved[47:40]; 1: value=saved[39:32];
            2: value=saved[31:24]; 3: value=saved[23:16];
            4: value=saved[15:8]; default: value=saved[7:0];
        endcase
        hundreds=value/100; tens=(value%100)/10; ones=value%10;
        digits=(value>=100) ? 3 : ((value>=10) ? 2 : 1);
        // Piano index 0=A0, 3=C1, 87=C8. Use ASCII '#' for sharp notes.
        semitones={1'b0,saved[54:48]}+8'd9;
        pitch_class=semitones%12;
        octave=semitones/12;
        sharp=(pitch_class==1 || pitch_class==3 || pitch_class==6 ||
               pitch_class==8 || pitch_class==10);
        case(pitch_class)
            0,1: note_letter="C";
            2,3: note_letter="D";
            4: note_letter="E";
            5,6: note_letter="F";
            7,8: note_letter="G";
            9,10: note_letter="A";
            default: note_letter="B";
        endcase
        note_length=sharp ? 3 : 2;
        case(pos)
            0: byte_data="p"; 1: byte_data="a"; 2: byte_data="g";
            3: byte_data="e"; 4: byte_data="0"; 5: byte_data=".";
            6: byte_data="n"; 7: byte_data="0"+field; 8: byte_data=".";
            9: byte_data="v"; 10: byte_data="a"; 11: byte_data="l";
            12: byte_data="=";
            default: begin
                byte_data=8'hff;
                if (pos==13) byte_data="0"+((digits==3)?hundreds:((digits==2)?tens:ones));
                else if (pos==14 && digits>=2) byte_data="0"+((digits==3)?tens:ones);
                else if (pos==15 && digits==3) byte_data="0"+ones;
            end
        endcase
        if (field==6) begin
            case(pos)
                0: byte_data="e"; 1: byte_data="v"; 2: byte_data="e";
                3: byte_data="r"; 4: byte_data="y"; 5: byte_data=".";
                6: byte_data="t"; 7: byte_data="N"; 8: byte_data="o";
                9: byte_data="t"; 10: byte_data="e"; 11: byte_data=".";
                12: byte_data="t"; 13: byte_data="x"; 14: byte_data="t";
                15: byte_data="="; 16: byte_data=8'h22;
                17: byte_data=note_letter;
                18: byte_data=sharp ? "#" : "0"+octave;
                19: byte_data=sharp ? "0"+octave : 8'h22;
                20: byte_data=sharp ? 8'h22 : 8'hff;
                default: byte_data=8'hff;
            endcase
        end
        if (field==7) begin
            // Native screen text uses GB2312: piano / marimba / clarinet.
            case(pos)
                0: byte_data="e"; 1: byte_data="v"; 2: byte_data="e";
                3: byte_data="r"; 4: byte_data="y"; 5: byte_data=".";
                6: byte_data="t"; 7: byte_data="I"; 8: byte_data="n";
                9: byte_data="s"; 10: byte_data="t"; 11: byte_data="r";
                12: byte_data="u"; 13: byte_data="m"; 14: byte_data="e";
                15: byte_data="n"; 16: byte_data="t"; 17: byte_data=".";
                18: byte_data="t"; 19: byte_data="x"; 20: byte_data="t";
                21: byte_data="="; 22: byte_data=8'h22;
                23: byte_data=saved[55] ? 8'hc2 : 8'hb8;
                24: byte_data=saved[55] ? 8'hed : 8'hd6;
                25: byte_data=saved[55] ? 8'hc1 : 8'hc7;
                26: byte_data=saved[55] ? 8'hd6 : 8'hd9;
                27: byte_data=saved[55] ? 8'hb0 : 8'h22;
                28: byte_data=saved[55] ? 8'hcd : 8'hff;
                29: byte_data=saved[55] ? 8'hc7 : 8'hff;
                30: byte_data=saved[55] ? 8'hd9 : 8'hff;
                31: byte_data=8'h22;
                default: byte_data=8'hff;
            endcase
            if (saved[56] && pos>=23) begin
                case(pos)
                    23: byte_data=8'hb5; 24: byte_data=8'ha5;
                    25: byte_data=8'hbb; 26: byte_data=8'hc9;
                    27: byte_data=8'hb9; 28: byte_data=8'hdc;
                    29: byte_data=8'h22;
                    default: byte_data=8'hff;
                endcase
            end
        end
        // Discard any partial screen command left by an FPGA reset mid-TX.
        if (fence!=0) byte_data=8'hff;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin busy<=0; saved<=0; field<=0; pos<=0; fence<=0; end
        else if (!busy) begin
            if (valid) begin saved<=snapshot; field<=0; pos<=0; busy<=1; fence<=3; end
        end else if (byte_ready) begin
            if (fence!=0) fence<=fence-1'b1;
            else if ((field==6 && pos==20+note_length) ||
                     (field==7 && pos==26+instrument_length) ||
                     (field<6 && pos==15+digits)) begin
                pos<=0;
                if (field==7) busy<=0;
                else field<=field+1'b1;
            end else pos<=pos+1'b1;
        end
    end
endmodule
