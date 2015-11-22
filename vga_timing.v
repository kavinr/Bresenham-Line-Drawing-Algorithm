// File: vga_timing.v
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_timing (
  output wire [10:0] vcount,
  output wire vsync,
  output wire vblnk,
  output wire [10:0] hcount,
  output wire hsync,
  output wire hblnk,
  input wire pclk
  );


reg [10:0] vcnt = 11'd0;
reg [10:0] hcnt = 11'd0;
wire eol;   //End of line

//-------Horizontal Pixel Counter-------------//
always @(posedge pclk)
begin
 if (hcnt == 1055) begin
  hcnt <= 11'd0;
 end else begin
  hcnt <= hcount + 1;
 end
end

assign hcount = hcnt;

//-------Horizontal Control Signals Logic--------------//
assign hblnk = (hcnt >= 11'd800 );
assign hsync = (hcnt >= 11'd840) && (hcnt <= 11'd967);
assign eol = (hcnt == 11'd1055);

//-------Vertical Pixel Counter--------------//
always @(posedge pclk)
begin
 if ((vcnt == 627) && (hcnt == 1055)) begin
  vcnt <= 11'd0;
 end else if (eol) begin
  vcnt <= vcnt + 1;
 end
end

assign vcount = vcnt;

//-------Vertical Control Signals Logic--------------//
assign vblnk = (vcnt >= 11'd600);
assign vsync = (vcnt >= 11'd601) && (vcnt <= 11'd604);

endmodule
