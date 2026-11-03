// Independent test wiring: physical mux address -> logical Excel row (zero-based).
function [3:0] pressure_key_for_select;
    input [3:0] address;
    begin
        case(address)
            4'd12: pressure_key_for_select=4'd0;
            4'd8: pressure_key_for_select=4'd1;
            4'd7: pressure_key_for_select=4'd2;
            4'd3: pressure_key_for_select=4'd3;
            4'd2: pressure_key_for_select=4'd4;
            4'd6: pressure_key_for_select=4'd5;
            4'd9: pressure_key_for_select=4'd6;
            4'd13: pressure_key_for_select=4'd7;
            4'd14: pressure_key_for_select=4'd8;
            4'd10: pressure_key_for_select=4'd9;
            4'd5: pressure_key_for_select=4'd10;
            4'd1: pressure_key_for_select=4'd11;
            4'd0: pressure_key_for_select=4'd12;
            4'd4: pressure_key_for_select=4'd13;
            4'd11: pressure_key_for_select=4'd14;
            4'd15: pressure_key_for_select=4'd15;
            default: pressure_key_for_select=4'd0;
        endcase
    end
endfunction
