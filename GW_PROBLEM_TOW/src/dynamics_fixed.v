// Replace this source with pressure-sensor input when that hardware is added.
// Preserve the unsigned Q0.8 interface consumed by the synth event path.
module dynamics_fixed (
    input wire [6:0] note,
    output wire [7:0] dynamics
);
    assign dynamics = 8'd192; // Current fixed level: 192/256 = 0.75.
endmodule
