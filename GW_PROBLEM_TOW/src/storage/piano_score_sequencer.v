// Event FIFO decouples bursty SD/FAT reads from the millisecond score clock.
// Automatic playback uses the score clock; guided playback waits per onset group.
module piano_score_sequencer #(
    parameter integer CLOCKS_PER_MS = 50000,
    parameter integer FIFO_BITS = 8,
    parameter integer PREFILL_EVENTS = 32
) (
    input wire clk, rst_n,
    input wire paused,
    input wire guide_mode,
    input wire guide_hit,
    input wire [6:0] guide_hit_note,
    input wire [15:0] guide_pressed,
    output reg guide_waiting,
    output reg [2:0] guide_group,
    output wire [87:0] guide_keys,
    input wire format_ok, stream_complete, stream_error,
    input wire [63:0] event_data,
    input wire event_valid,
    input wire dispatch_ready,
    output wire event_ready,
    output wire dispatch_valid,
    output wire dispatch_on,
    output wire [6:0] dispatch_note,
    output wire [7:0] dispatch_dynamics,
    output reg [55:0] notes,
    output reg [55:0] velocities,
    output reg [7:0] gates,
    output reg [7:0] triggers,
    output reg playing, finished, error,
    output reg [31:0] elapsed_ms
);
    localparam integer DEPTH = 1 << FIFO_BITS;
    reg [63:0] fifo [0:DEPTH-1];
    reg [FIFO_BITS-1:0] wr_ptr, rd_ptr;
    reg [FIFO_BITS:0] count;
    reg [63:0] head;
    reg [31:0] sub_ms;
    // One cycle after advancing rd_ptr is reserved for the synchronous RAM.
    reg head_wait;
    reg guide_open;
    reg [31:0] guide_time;
    reg [15:0] guide_mask, guide_hits, guide_armed;
    wire [7:0] slot = head[39:32];
    wire [7:0] note = head[47:40], velocity = head[55:48];
    wire active = playing && !paused && !error && !stream_error;
    assign event_ready = count < DEPTH && !error && !finished;
    wire push = event_valid && event_ready;
    wire head_valid = active && count != 0 && !head_wait;
    wire due = head_valid && !guide_mode && head[31:0] <= elapsed_ms;
    wire terminal = slot == 8'hff;
    // Keep a due note in the FIFO until the DDS accepts it. The terminal
    // record is consumed locally and does not enter the synth event stream.
    assign dispatch_valid = due && !terminal;
    assign dispatch_on = velocity != 0;
    assign dispatch_note = note[6:0];
    assign dispatch_dynamics = {velocity[6:0], 1'b0};
    // Finish collecting all records at one timestamp before publishing a target.
    // A boundary record stays at the FIFO head throughout the user's wait.
    wire guide_boundary = guide_open && (terminal || head[31:0] != guide_time);
    wire guide_pop = head_valid && guide_mode && !guide_waiting && !guide_boundary;
    wire pop = (due && (terminal || dispatch_ready)) || guide_pop;
    assign guide_keys = guide_waiting ? ({72'd0,guide_mask} << {guide_group,4'b0}) : 88'd0;
    always @(posedge clk) begin
        if (push) fifo[wr_ptr] <= event_data;
        head <= fifo[rd_ptr];
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0; head_wait <= 1;
            notes <= 0; velocities <= 0; gates <= 0; triggers <= 0;
            playing <= 0; finished <= 0; error <= 0; elapsed_ms <= 0; sub_ms <= 0;
            guide_open<=0;guide_time<=0;guide_mask<=0;guide_hits<=0;guide_armed<=0;
            guide_waiting<=0;guide_group<=0;
        end else begin
            triggers <= 0;
            head_wait <= pop || (count == 0);
            if (push) wr_ptr <= wr_ptr + 1'b1;
            if (pop) rd_ptr <= rd_ptr + 1'b1;
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
            endcase
            if (stream_error || (active && count == 0 && !guide_mode)) begin
                error <= 1; playing <= 0; gates <= 0;guide_waiting<=0;
            end else if (!error) begin
                if (!playing && !finished && format_ok &&
                    (count >= PREFILL_EVENTS || (stream_complete && count != 0)))
                    playing <= 1;
                if (active && !guide_mode) begin
                    if (sub_ms == CLOCKS_PER_MS - 1) begin
                        sub_ms <= 0; elapsed_ms <= elapsed_ms + 1'b1;
                    end else sub_ms <= sub_ms + 1'b1;
                end
                if (head_valid && guide_mode && !guide_waiting && guide_boundary) begin
                    guide_open<=0;
                    if(guide_mask!=0) begin
                        guide_waiting<=1;guide_hits<=0;guide_armed<=~guide_pressed;
                        elapsed_ms<=guide_time;
                    end
                end
                if(active && guide_mode && guide_waiting) begin
                    guide_armed<=guide_armed | ~guide_pressed;
                    if(guide_hit && guide_hit_note[6:4]==guide_group &&
                       guide_armed[guide_hit_note[3:0]])
                        guide_hits[guide_hit_note[3:0]]<=1;
                    if((guide_hits & guide_pressed & guide_mask)==guide_mask) begin
                        guide_waiting<=0;guide_mask<=0;guide_hits<=0;
                    end
                end
                if (pop) begin
                    if (slot == 255) begin
                        gates <= 0; playing <= 0; finished <= 1;
                    end else if(guide_mode) begin
                        if(!guide_open) begin
                            guide_open<=1;guide_time<=head[31:0];guide_group<=0;
                            guide_mask<=velocity!=0 ? (16'b1 << note[3:0]) : 16'd0;
                            if(velocity!=0)guide_group<=note[6:4];
                        end else if(velocity!=0) begin
                            if(guide_mask==0 || note[6:4]>guide_group) begin
                                guide_group<=note[6:4];guide_mask<=16'b1 << note[3:0];
                            end else if(note[6:4]==guide_group)
                                guide_mask<=guide_mask | (16'b1 << note[3:0]);
                        end
                    end else begin
                        notes[slot*7 +: 7] <= note[6:0];
                        gates[slot] <= velocity != 0;
                        if (velocity != 0) begin
                            velocities[slot*7 +: 7] <= velocity[6:0];
                            triggers[slot] <= 1;
                        end
                    end
                end
            end
        end
    end
endmodule
