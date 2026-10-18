// Event FIFO decouples SD sector latency from the millisecond score clock.
module piano_score_sequencer #(
    parameter integer CLOCKS_PER_MS = 50000,
    parameter integer FIFO_BITS = 8,
    parameter integer PREFILL_EVENTS = 32
) (
    input wire clk, rst_n,
    input wire paused,
    input wire format_ok, stream_complete, stream_error,
    input wire [63:0] event_data,
    input wire event_valid,
    output wire event_ready,
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
    wire [7:0] slot = head[39:32];
    wire [7:0] note = head[47:40], velocity = head[55:48];
    wire active = playing && !paused && !error && !stream_error;
    assign event_ready = count < DEPTH && !error && !finished;
    wire push = event_valid && event_ready;
    wire pop = active && count != 0 && !head_wait && head[31:0] <= elapsed_ms;
    always @(posedge clk) begin
        if (push) fifo[wr_ptr] <= event_data;
        head <= fifo[rd_ptr];
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0; head_wait <= 1;
            notes <= 0; velocities <= 0; gates <= 0; triggers <= 0;
            playing <= 0; finished <= 0; error <= 0; elapsed_ms <= 0; sub_ms <= 0;
        end else begin
            triggers <= 0;
            head_wait <= pop || (count == 0);
            if (push) wr_ptr <= wr_ptr + 1'b1;
            if (pop) rd_ptr <= rd_ptr + 1'b1;
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
            endcase
            if (stream_error || (active && count == 0)) begin
                error <= 1; playing <= 0; gates <= 0;
            end else if (!error) begin
                if (!playing && !finished && format_ok &&
                    (count >= PREFILL_EVENTS || (stream_complete && count != 0)))
                    playing <= 1;
                if (active) begin
                    if (sub_ms == CLOCKS_PER_MS - 1) begin
                        sub_ms <= 0; elapsed_ms <= elapsed_ms + 1'b1;
                    end else sub_ms <= sub_ms + 1'b1;
                end
                if (pop) begin
                    if (slot == 255) begin
                        gates <= 0; playing <= 0; finished <= 1;
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
