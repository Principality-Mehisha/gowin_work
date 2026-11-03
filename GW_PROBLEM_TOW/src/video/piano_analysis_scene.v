// Five pixel-clock stages, matching the existing waterfall RGB/DE latency.
module piano_analysis_scene #(parameter FONT_FILE="src/video/analysis_font.hex",
    parameter integer SAMPLE_RATE_RATIO=1) (
    input wire clk,reset_n,
    input wire [1:0] display_mode,
    input wire [10:0] x,
    input wire [9:0] y,
    input wire visible_valid,
    input wire [31:0] read_data,
    output wire [8:0] read_address,
    output reg [23:0] rgb
);
    wire [10:0] offset_x=x-11'd288;
    assign read_address=offset_x[9:1];
    reg [10:0] x1,x2;
    reg [9:0] y1,y2;
    reg [31:0] data2;
    reg [7:0] character1;
    reg [4:0] glyph2;
    reg [4:0] font_rows[0:1023];
    initial $readmemh(FONT_FILE,font_rows);
    reg text1,text2,text3;
    reg [1:0] mode3;
    reg [23:0] rgb3,rgb4;
    wire [10:0] gx=x2-11'd288;
    wire [9:0] gy=y2-10'd192;
    wire [8:0] wave_min=data2[27:19],wave_max=data2[18:10];
    wire [9:0] spectrum=data2[9:0];
    wire text_on=text2 && x2[3:1]<5 && glyph2[4-x2[3:1]];
    function [7:0] label_char;
        input [1:0] mode,line;
        input [6:0] index;
        input valid;
        begin
            label_char=" ";
            case(line)
                0:case(index)
                    0:label_char="A";1:label_char="U";2:label_char="D";3:label_char="I";4:label_char="O";
                    6:label_char=mode==1 ? "S" : "W";7:label_char=mode==1 ? "P" : "A";
                    8:label_char=mode==1 ? "E" : "V";9:label_char=mode==1 ? "C" : "E";
                    10:label_char=mode==1 ? "T" : "F";11:label_char=mode==1 ? "R" : "O";
                    12:label_char=mode==1 ? "U" : "R";13:label_char="M";
                    default:label_char=" ";
                endcase
                1:case(index)
                    0:label_char="0";16:label_char=mode==1 ? "2" : "8";
                    17:label_char=mode==1 ? "K" : " ";
                    32:label_char=mode==1 ? "4" : "1";33:label_char=mode==1 ? "K" : "6";
                    48:label_char=mode==1 ? "6" : "2";49:label_char=mode==1 ? "K" : "4";
                    62:label_char=mode==1 ? "8" : "3";63:label_char=mode==1 ? "K" : "1";
                    65:label_char=mode==1 ? "H" : "M";66:label_char=mode==1 ? "Z" : "S";
                    default:label_char=" ";
                endcase
                2:if(!valid)case(index)
                    0:label_char="W";1:label_char="A";2:label_char="I";3:label_char="T";4:label_char="I";
                    5:label_char="N";6:label_char="G";8:label_char="F";9:label_char="O";10:label_char="R";
                    12:label_char="A";13:label_char="U";14:label_char="D";15:label_char="I";16:label_char="O";
                    default:label_char=" ";
                endcase else case(index)
                    0:label_char=mode==1 ? "1" : "5";1:label_char=mode==1 ? "0" : "1";
                    2:label_char="2";3:label_char=mode==1 ? "4" : " ";
                    5:label_char=mode==1 ? "F" : "S";6:label_char=mode==1 ? "F" : "A";
                    7:label_char=mode==1 ? "T" : "M";8:label_char=mode==1 ? " " : "P";
                    9:label_char=mode==1 ? "/" : "L";10:label_char=mode==1 ? " " : "E";
                    11:label_char=mode==1 ? "H" : "S";12:label_char=mode==1 ? "A" : " ";
                    13:label_char=mode==1 ? "N" : "/";14:label_char=mode==1 ? "N" : " ";
                    15:label_char=mode==1 ? " " : "3";16:label_char=mode==1 ? " " : "1";
                    18:label_char=mode==1 ? "L" : "M";19:label_char=mode==1 ? "O" : "S";20:label_char=mode==1 ? "G" : " ";
                    default:label_char=" ";
                endcase
                default:label_char=" ";
            endcase
            if(SAMPLE_RATE_RATIO==3 && line==1)begin
                if(mode==1)case(index)
                    16:label_char="6";17:label_char="K";
                    32:label_char="1";33:label_char="2";34:label_char="K";
                    48:label_char="1";49:label_char="8";50:label_char="K";
                    61:label_char="2";62:label_char="4";63:label_char="K";
                    default:begin end
                endcase else case(index)
                    16:label_char="3";17:label_char=" ";
                    32:label_char="5";33:label_char=" ";
                    48:label_char="8";49:label_char=" ";
                    62:label_char="1";63:label_char="0";
                    default:begin end
                endcase
            end
            if(SAMPLE_RATE_RATIO==3 && line==2 && valid && mode==2)begin
                if(index==15)label_char="1";
                if(index==16)label_char="0";
            end
        end
    endfunction
    wire [1:0] line_number=y<128 ? 2'd0 : (y<768 ? 2'd1 : 2'd2);
    wire font_region=x>=288 && x<1456 &&
        ((y>=96 && y<112) || (y>=736 && y<752) || (y>=800 && y<816));
    reg [23:0] color;
    always @* begin
        color=24'h0b1020;
        if(y2<144)color=24'h101b30;
        if(x2>=288 && x2<1312 && y2>=192 && y2<704)begin
            color=24'h0e182a;
            if(gx[7:0]==0 || gy[6:0]==0)color=24'h24344e;
            if(display_mode==2 && gy==256)color=24'h43566e;
            if(visible_valid)begin
                if(display_mode==1 && spectrum!=0 && {1'b0,gy}>=11'd512-{1'b0,spectrum})
                    color=gx[0] ? 24'h37b9d8 : 24'h8be5ff;
                if(display_mode==2 && gy>=wave_min && gy<=wave_max)
                    color=24'h70edac;
            end
        end
        if(((x2==287 || x2==1312) && y2>=191 && y2<=704) ||
           ((y2==191 || y2==704) && x2>=287 && x2<=1312))color=24'h586e8d;
    end
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            x1<=0;x2<=0;y1<=0;y2<=0;data2<=0;character1<=0;glyph2<=0;text1<=0;text2<=0;text3<=0;mode3<=0;
            rgb3<=0;rgb4<=0;rgb<=0;
        end else begin
            x1<=x;y1<=y;x2<=x1;y2<=y1;data2<=read_data;
            character1<=label_char(display_mode,line_number,(x>>4)-7'd18,visible_valid);
            glyph2<=font_rows[{character1[6:0],y1[3:1]}];text1<=font_region;text2<=text1;
            text3<=text_on;mode3<=display_mode;
            rgb3<=x2<1600 && y2<900 ? color : 24'd0;
            rgb4<=text3 ? (mode3==1 ? 24'h9aeaff : 24'h9ef5bc) : rgb3;
            rgb<=rgb4;
        end
    end
endmodule
