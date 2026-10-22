// Included inside benches with clk, rx and UART_TICKS. Independent bit-banging.
task send_byte;
 input [7:0] value;
 integer b;
 begin
  @(negedge clk); rx=0; repeat(UART_TICKS) @(negedge clk);
  for(b=0;b<8;b=b+1) begin rx=value[b]; repeat(UART_TICKS) @(negedge clk); end
  rx=1; repeat(UART_TICKS) @(negedge clk);
 end
endtask
task send_frame;
 input [7:0] sequence_number, command, argument, extra1, extra2;
 reg [7:0] checksum;
 begin
  checksum=1+sequence_number+command+argument+extra1+extra2;
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(sequence_number);
  send_byte(command);send_byte(argument);send_byte(extra1);send_byte(extra2);
  send_byte(checksum);send_byte('h0d);
  repeat(8) @(negedge clk);
 end
endtask
