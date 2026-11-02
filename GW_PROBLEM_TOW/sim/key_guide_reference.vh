// Highest occupied group, then all occupied keys within it; no scan-FSM model.
function automatic [383:0] reference_frame;
    input [87:0] held;
    input enabled;
    input [143:0] palette;
    integer note,group,key,highest;
    reg [23:0] rgb,grb;
    begin
        reference_frame=0;highest=-1;
        for(note=0;note<88;note=note+1)
            if(enabled && held[note])highest=note;
        if(highest>=0)begin
            group=highest/16;rgb=palette[group*24 +: 24];
            grb={rgb[15:8],rgb[23:16],rgb[7:0]};
            for(key=0;key<16;key=key+1)begin
                note=group*16+key;
                if(note<88 && held[note])
                    reference_frame[(15-key)*24 +: 24]=grb;
            end
        end
    end
endfunction
