// Ordered control/events 50->150 MHz; actual DAC samples/event ACKs 150->50 MHz.
// A transport restart resets both FIFO ends and advances the session tag.
module audio_domain_bridge (
    input wire sys_clk,audio_clk,reset_n,pll_locked,restart,
    input wire [15:0] config_in,
    input wire event_valid,event_on,event_update,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    output wire event_ready,
    output wire link_ready_sys,
    output wire engine_reset_n,
    output reg [15:0] audio_config,
    output reg audio_config_valid,
    output wire audio_event_valid,audio_event_on,audio_event_update,
    output wire [6:0] audio_event_note,
    output wire [7:0] audio_event_dynamics,
    input wire audio_event_ready,
    input wire dac_tick,
    input wire signed [15:0] dac_pcm,
    input wire source_active,piano_busy,audio_busy,synth_fault,effect_fault,
    output reg sample_valid,
    output reg signed [15:0] sample_pcm,
    output reg sample_active,piano_busy_sys,audio_busy_sys,synth_fault_sys,effect_fault_sys,
    output reg ack_valid,ack_on,ack_update,ack_marimba,ack_clear,
    output reg [6:0] ack_note,
    output reg bridge_fault
);
    wire link_reset_n=reset_n && pll_locked && !restart;
    reg [3:0] engine_release;
    always @(posedge audio_clk or negedge link_reset_n)
        if(!link_reset_n)engine_release<=0;
        else engine_release<={engine_release[2:0],1'b1};
    assign engine_reset_n=engine_release[3];
    reg [7:0] epoch,audio_epoch;
    reg [15:0] sent_config;
    reg pending_stop,pending_clear;
    reg [1:0] lock_sync;
    reg link_seen;
    wire [15:0] desired_config=config_in | {pending_clear,pending_stop,14'd0};
    wire config_changed=desired_config!=sent_config || pending_stop || pending_clear;
    wire command_wr_ready,command_valid,command_ready,command_domain_ready;
    assign link_ready_sys=lock_sync[1] && command_domain_ready;
    wire [31:0] command;
    wire command_wr_valid=config_changed || (event_valid && !config_in[15] && !config_in[14]);
    wire [31:0] command_wr_data=config_changed ?
        {1'b1,epoch,7'd0,desired_config} :
        {1'b0,epoch,6'd0,event_update,event_on,event_note,event_dynamics};
    assign event_ready=command_wr_ready && !config_changed && !config_in[15] && !config_in[14];
    wire write_config=command_wr_ready && config_changed;
    audio_cdc_fifo commands(
        .reset_n(link_reset_n),.wr_clk(sys_clk),.rd_clk(audio_clk),
        .wr_data(command_wr_data),.wr_valid(command_wr_valid && !restart),
        .wr_ready(command_wr_ready),.wr_domain_ready(command_domain_ready),.wr_almost_full(),
        .rd_data(command),.rd_valid(command_valid),.rd_ready(command_ready));
    reg ack_pending,return_overflow;
    reg [31:0] pending_ack;
    wire return_wr_ready,return_valid,return_almost_full;
    wire [31:0] returned;
    wire matching=audio_config_valid && command[30:23]==audio_epoch;
    assign audio_event_valid=command_valid && !command[31] && matching &&
                             !audio_config[14] && !audio_config[15] && !ack_pending;
    assign audio_event_update=command[16];
    assign audio_event_on=command[15];
    assign audio_event_note=command[14:8];
    assign audio_event_dynamics=command[7:0];
    wire fire=audio_event_valid && audio_event_ready;
    assign command_ready=(command[31] && !ack_pending) || (!command[31] && !matching) ||
                         (fire && !ack_pending);
    wire [31:0] return_word=dac_tick ?
        {1'b1,audio_epoch,return_overflow,effect_fault,synth_fault,audio_busy,
         piano_busy,source_active,1'b0,dac_pcm} : pending_ack;
    audio_cdc_fifo feedback(
        .reset_n(link_reset_n),.wr_clk(audio_clk),.rd_clk(sys_clk),
        .wr_data(return_word),.wr_valid(dac_tick || (ack_pending && !return_almost_full)),
        .wr_almost_full(return_almost_full),.wr_domain_ready(),
        .wr_ready(return_wr_ready),.rd_data(returned),.rd_valid(return_valid),.rd_ready(1'b1));
    always @(posedge audio_clk or negedge engine_reset_n) begin
        if(!engine_reset_n)begin
            audio_config<=0;audio_config_valid<=0;audio_epoch<=0;
            ack_pending<=0;pending_ack<=0;return_overflow<=0;
        end else begin
            if(command_valid && command_ready && command[31])begin
                audio_epoch<=command[30:23];audio_config<=command[15:0];audio_config_valid<=1;
                if(command[14])begin
                    pending_ack<={1'b0,command[30:23],1'b1,4'd0,command[9],17'd0};
                    ack_pending<=1;
                end
            end
            if(ack_pending && return_wr_ready && !dac_tick && !return_almost_full)ack_pending<=0;
            if(fire)begin
                pending_ack<={1'b0,audio_epoch,1'b0,4'd0,audio_config[9],command[16:0]};ack_pending<=1;
            end
            if(dac_tick && !return_wr_ready)return_overflow<=1;
        end
    end
    always @(posedge sys_clk or negedge reset_n) begin
        if(!reset_n)begin
            epoch<=0;sent_config<=16'hffff;pending_stop<=1;pending_clear<=1;
            sample_valid<=0;sample_pcm<=0;sample_active<=0;
            piano_busy_sys<=0;audio_busy_sys<=0;synth_fault_sys<=0;effect_fault_sys<=0;
            ack_valid<=0;ack_on<=0;ack_update<=0;ack_marimba<=0;ack_clear<=0;ack_note<=0;bridge_fault<=0;
            lock_sync<=0;link_seen<=0;
        end else begin
            lock_sync<={lock_sync[0],pll_locked};
            if(link_ready_sys && !restart)link_seen<=1;
            sample_valid<=0;ack_valid<=0;
            if(restart)begin
                epoch<=epoch+1'b1;sent_config<=16'hffff;pending_stop<=1;pending_clear<=1;
                link_seen<=0;
                sample_pcm<=0;sample_active<=0;piano_busy_sys<=0;audio_busy_sys<=0;
                synth_fault_sys<=0;effect_fault_sys<=0;bridge_fault<=0;
            end else begin
                if(!lock_sync[1] || !command_domain_ready)begin
                    sent_config<=16'hffff;pending_stop<=1;pending_clear<=1;
                    sample_pcm<=0;sample_active<=0;piano_busy_sys<=0;audio_busy_sys<=0;
                    if(link_seen)bridge_fault<=1;
                end else begin
                    pending_stop<=(pending_stop || config_in[14]) && !write_config;
                    pending_clear<=(pending_clear || config_in[15]) && !write_config;
                    if(write_config)sent_config<=desired_config;
                end
                if(return_valid && returned[30:23]==epoch)begin
                    if(returned[31])begin
                        sample_valid<=1;sample_pcm<=returned[15:0];sample_active<=returned[17];
                        piano_busy_sys<=returned[18];audio_busy_sys<=returned[19];
                        synth_fault_sys<=returned[20];effect_fault_sys<=returned[21];
                        if(returned[22])bridge_fault<=1;
                    end else begin
                        ack_valid<=1;ack_update<=returned[16];ack_on<=returned[15];ack_note<=returned[14:8];
                        ack_marimba<=returned[17];ack_clear<=returned[22];
                    end
                end
            end
        end
    end
endmodule
