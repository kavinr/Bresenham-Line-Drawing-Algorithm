// File: linedraw.v
// This is the linedraw design for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module linedraw (
  input wire go,
  output wire busy,
  input wire [7:0] stax,
  input wire [7:0] stay,
  input wire [7:0] endx,
  input wire [7:0] endy,
  output wire wr,
  output wire [15:0] addr,
  input wire pclk
  );

parameter [1:0] IDLE = 2'd0;
parameter [1:0] RUN = 2'd1;
parameter [1:0] DONE = 2'd2;

reg [1:0] state;
reg signed [8:0] err;
reg signed [7:0] x, y;
wire signed [7:0] deltax, deltay, dx, dy, x0, x1, y0, y1, next_x, next_y, xa, ya, xb, yb;
wire signed [8:0] err_next, err1, err2, e2;

wire  in_loop, right, down, complete, e2_lt_dx, e2_gt_dy;

//FSM
always @ (posedge pclk)
begin
  case (state)
    IDLE : if (go)
             state <= RUN;
           else
             state <= IDLE;

    RUN : if (complete)
             state   <= DONE;
          else
             state   <= RUN;

    DONE : if (go)
             state <= RUN;
           else
             state <= IDLE;

    default : state <= IDLE;
  endcase
 end



//Line Drawing Algorithm

//Data Path for dx, dy, right, down
assign x0 =  stax;
assign x1 =  endx;
assign deltax = x1 - x0;
assign right = ~(deltax[7]);
assign dx = (!right) ? (-deltax) : (deltax);

assign y0 = stay;
assign y1 = endy;
assign deltay = y1 - y0;
assign down = ~(deltay[7]);
assign dy = (down) ? (-deltay) : (deltay);

//Data Path for Error

assign e2 = err << 1;
assign e2_gt_dy = (e2 > dy) ? 1 : 0;
assign e2_lt_dx = (e2 < dx) ? 1 : 0;
assign err1 = e2_gt_dy ? (err + dy) : err;
assign err2 = e2_lt_dx ? (err1 + dx) : err1;
assign err_next = (in_loop) ? err2 : (dx + dy);
assign in_loop = (state == RUN);

//Data Path for X and Y
assign next_x = (in_loop) ? xb : x0;
assign xb = e2_gt_dy ? xa : x;
assign xa = right ? (x + 1) : (x - 1);

assign next_y = (in_loop) ? yb : y0;
assign yb = e2_lt_dx ? ya : y;
assign ya = down ? (y + 1) : (y - 1);

assign complete = ( (x == x1) && (y == y1) );

always @(posedge pclk)
 begin
    err <= err_next;
    x <= next_x;
    y <= next_y;
 end

assign busy = in_loop;
assign wr = in_loop;
assign addr = {y,x};

endmodule
