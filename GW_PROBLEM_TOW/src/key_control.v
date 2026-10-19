module key_filter #(
    parameter integer STABLE_CYCLES = 153600
) (
    input wire clk, reset_n, key_n,
    output reg held, output reg pressed, output reg released
);
    reg [1:0] synchronizer;
    reg [19:0] stable_count;
    wire down = ~synchronizer[1];
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            synchronizer <= 2'b11;
            held <= 0; pressed <= 0; released <= 0; stable_count <= 0;
        end else begin
            synchronizer <= {synchronizer[0], key_n};
            pressed <= 0; released <= 0;
            if (down == held) stable_count <= 0;
            else if (stable_count == STABLE_CYCLES-1) begin
                held <= down;
                pressed <= down;
                released <= ~down;
                stable_count <= 0;
            end else stable_count <= stable_count + 1'b1;
        end
    end
endmodule

// Replace this module when the pressure sensor is introduced.
module dynamics_fixed (
    input wire [6:0] note,
    output wire [7:0] dynamics
);
    assign dynamics = 8'd192; // Unsigned Q0.8, exactly 0.75.
endmodule

module key_audition #(
    parameter integer DEBOUNCE_CYCLES = 153600
) (
    input wire clk, reset_n, key_play_n, key_stop_n,
    input wire event_ready,
    output reg event_valid, output reg event_on,
    output reg [6:0] event_note,
    output wire [7:0] event_dynamics,
    output reg stop_all
);
    wire play_held, play_press, play_release;
    wire stop_held, stop_press, stop_release;
    reg [6:0] next_note, held_note;
    reg blocked;
    key_filter #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) play_filter (
        .clk(clk), .reset_n(reset_n), .key_n(key_play_n),
        .held(play_held), .pressed(play_press), .released(play_release));
    key_filter #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) stop_filter (
        .clk(clk), .reset_n(reset_n), .key_n(key_stop_n),
        .held(stop_held), .pressed(stop_press), .released(stop_release));
    dynamics_fixed dynamics_source (.note(event_note), .dynamics(event_dynamics));
    always @(posedge clk or negedge reset_n)
        if (!reset_n) stop_all<=0;
        else stop_all<=stop_held | stop_press;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            next_note <= 0; held_note <= 0; blocked <= 0;
            event_valid <= 0; event_on <= 0; event_note <= 0;
        end else if (stop_all) begin
            event_valid <= 0;
            blocked <= play_held;
        end else begin
            if (event_valid && event_ready) event_valid <= 0;
            if (play_release) begin
                blocked <= 0;
                event_valid <= ~blocked;
                event_on <= 0;
                event_note <= held_note;
            end else if (play_press && !blocked) begin
                event_valid <= 1;
                event_on <= 1;
                event_note <= next_note;
                held_note <= next_note;
                next_note <= (next_note == 87) ? 0 : next_note + 1'b1;
            end
        end
    end
endmodule
