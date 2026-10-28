// Single outstanding request mailbox: 50 MHz audio -> 100 MHz DDR user clock.
// Mailboxes remain stable until the acknowledgement crosses two registers.
// Reset/cancel discards an in-flight response; it cannot become a later note.
module ddr_asset_service #(
    parameter integer ASSET_WORDS=1575,
    parameter integer TIMEOUT_CYCLES=65536
)(
    input wire sys_clk, reset_n, cancel,
    input wire request, input wire [10:0] address,
    output wire request_ready, output reg response_valid,
    output reg [127:0] response_data,
    output wire ready, output wire fault,
    input wire ui_clk, ui_reset, calibrated,
    output wire [2:0] cmd, output wire cmd_en,
    output wire [28:0] addr, input wire cmd_ready,
    output wire [127:0] wr_data, output wire wr_data_en, wr_data_end,
    output wire [15:0] wr_data_mask, input wire wr_data_rdy,
    input wire [127:0] rd_data, input wire rd_data_valid, rd_data_end,
    output reg ui_fault
);
    reg request_toggle, busy, discarded;
    reg [10:0] request_mailbox;
    reg ack_toggle;
    reg [127:0] response_mailbox;
    reg initialized;
    (* ASYNC_REG="TRUE" *) reg ack_meta_s0, ack_sync;
    (* ASYNC_REG="TRUE" *) reg req_meta_s0, req_sync;
    (* ASYNC_REG="TRUE" *) reg ready_meta_s0, ready_sync;
    (* ASYNC_REG="TRUE" *) reg fault_meta_s0, fault_sync;
    assign ready=ready_sync && !fault_sync;
    assign fault=fault_sync;
    assign request_ready=ready && !busy && !cancel;
    always @(posedge sys_clk or negedge reset_n) begin
        if(!reset_n) begin
            request_toggle<=0; request_mailbox<=0; busy<=0; discarded<=0;
            ack_meta_s0<=0; ack_sync<=0; ready_meta_s0<=0; ready_sync<=0;
            fault_meta_s0<=0; fault_sync<=0; response_data<=0; response_valid<=0;
        end else begin
            ack_meta_s0<=ack_toggle; ack_sync<=ack_meta_s0;
            ready_meta_s0<=initialized; ready_sync<=ready_meta_s0;
            fault_meta_s0<=ui_fault; fault_sync<=fault_meta_s0;
            response_valid<=0;
            if(cancel && busy) discarded<=1;
            if(busy && ack_sync==request_toggle) begin
                busy<=0;
                if(!discarded && !cancel && !fault_sync) begin
                    response_data<=response_mailbox; response_valid<=1;
                end
            end
            if(request && request_ready) begin
                request_mailbox<=address; request_toggle<=!request_toggle;
                busy<=1; discarded<=0;
            end
        end
    end
    always @(posedge ui_clk or negedge reset_n) begin
        if(!reset_n) begin req_meta_s0<=0; req_sync<=0; end
        else begin req_meta_s0<=request_toggle; req_sync<=req_meta_s0; end
    end
    localparam WAIT_INIT=0, SEED_ADDR=1, SEED_WAIT=2, WRITE=3, GAP=4,
        VERIFY_ADDR=5, VERIFY_WAIT=6, READ_CMD=7, READ_WAIT=8,
        CHECK=9, IDLE=10, CAPTURE=11, STOP=12, DECIDE=13;
    reg [3:0] state;
    reg [10:0] index, read_address;
    reg [1:0] write_gap;
    reg verifying;
    reg [127:0] read_buffer;
    reg read_end,check_failed;
    reg [$clog2(TIMEOUT_CYCLES+1)-1:0] watchdog;
    wire [127:0] seed_data;
    ddr_asset_seed seed(.clk(ui_clk),.address(index),.data(seed_data));
    wire write_submit=state==WRITE && calibrated && !ui_reset && !ui_fault && cmd_ready && wr_data_rdy;
    wire read_submit=state==READ_CMD && calibrated && !ui_reset && !ui_fault && cmd_ready;
    assign cmd=state==WRITE ? 3'b000 : 3'b001;
    assign cmd_en=write_submit || read_submit;
    assign addr={15'd0,(state==WRITE ? index : read_address),3'b000};
    assign wr_data=seed_data;
    assign wr_data_en=write_submit;
    assign wr_data_end=write_submit;
    assign wr_data_mask=0;
    wire waiting=state==WRITE || state==READ_CMD || state==READ_WAIT;
    wire progress=write_submit || read_submit || rd_data_valid;
    always @(posedge ui_clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=WAIT_INIT; index<=0; read_address<=0; write_gap<=0;
            initialized<=0; ui_fault<=0; verifying<=1; watchdog<=0;
            response_mailbox<=0; ack_toggle<=0; read_buffer<=0; read_end<=0;check_failed<=0;
        end else if(ui_reset) begin
            // A controller reset after serving data is a fault, not a silent
            // mailbox restart. Recovery requires the board's reset button.
            if(initialized || state!=WAIT_INIT) begin ui_fault<=1; initialized<=0; state<=STOP; end
        end else if(!ui_fault) begin
            if(!waiting || progress) watchdog<=0;
            else watchdog<=watchdog+1'b1;
            case(state)
                WAIT_INIT: if(calibrated) begin index<=0; state<=SEED_ADDR; end
                SEED_ADDR: state<=SEED_WAIT;
                SEED_WAIT: state<=WRITE;
                WRITE: if(write_submit) begin write_gap<=2; state<=GAP; end
                GAP: if(write_gap!=0) write_gap<=write_gap-1'b1;
                    else if(index==ASSET_WORDS-1) begin index<=0; verifying<=1; state<=VERIFY_ADDR; end
                    else begin index<=index+1'b1; state<=SEED_ADDR; end
                VERIFY_ADDR: begin read_address<=index; state<=VERIFY_WAIT; end
                VERIFY_WAIT: state<=READ_CMD;
                READ_CMD: if(read_submit) begin
                    if(rd_data_valid) begin read_buffer<=rd_data; read_end<=rd_data_end; state<=CHECK; end
                    else state<=READ_WAIT;
                end
                READ_WAIT: if(rd_data_valid) begin read_buffer<=rd_data; read_end<=rd_data_end; state<=CHECK; end
                // Separate the wide comparison from the address/counter CEs.
                // Runtime return data also crosses this fixed one-cycle stage.
                CHECK:begin
                    check_failed<=!read_end || (verifying && read_buffer!=seed_data);
                    state<=DECIDE;
                end
                DECIDE: if(check_failed) begin
                    ui_fault<=1; initialized<=0; state<=STOP;
                end else if(verifying) begin
                    if(index==ASSET_WORDS-1) begin initialized<=1; verifying<=0; state<=IDLE; end
                    else begin index<=index+1'b1; state<=VERIFY_ADDR; end
                end else begin response_mailbox<=read_buffer; ack_toggle<=req_sync; state<=IDLE; end
                IDLE: if(req_sync!=ack_toggle) state<=CAPTURE;
                CAPTURE: if(request_mailbox>=ASSET_WORDS) begin ui_fault<=1; initialized<=0; state<=STOP; end
                    else begin read_address<=request_mailbox; state<=READ_CMD; end
                default: state<=STOP;
            endcase
            // Faults override the state/result after the normal FSM update.
            // Unused address updates on a fault edge are harmless; this avoids
            // routing the watchdog/calibration decode into every counter CE.
            if((waiting && !progress && watchdog==TIMEOUT_CYCLES-1) ||
               (state!=WAIT_INIT && !calibrated))begin
                ui_fault<=1; initialized<=0; state<=STOP;
            end
        end
    end
endmodule
