module SingleClockMIPS (CLK, RST, PC, Result);
`include "common_param.vh"
  input CLK, RST;
  output [31:0] PC, Result;

  wire [31:0] newPC, nextPC, Ins;
  wire [31:0] Rdata1, Rdata2, Ed32, Wdata;

// IF IF0 (.CLK(CLK), .RST(RST), .newPC(newPC), .PC, .nextPC, .Ins);
// ID ID0 (.CLK(CLK), .RST(RST), .Ins(Ins), .Wdata(Wdata),
//       .Rdata1(Rdata1), .Rdata2(Rdata2), .Ed32(Ed32));
EX EX0 (.CLK(CLK), .RST(RST), .Ins(Ins), .Rdata1(Rdata1), .Rdata2(Rdata2),
      .Ed32(Ed32), .nextPC(nextPC), .Result(Result), .newPC(newPC));
// MA MA0 (.CLK(CLK), .RST(RST), .Adr(Result), .Wdata(Rdata2), .nextPC(nextPC),
//       .Ins(Ins), .Rdata(Wdata));

endmodule
