
module IF (
  input CLK, RST,
  input [31:0] newPC,
  output [31:0] nextPC, Ins,
  output reg [31:0] PC
);
  `include "common_param.vh"
  reg [31:0] IMem [0:IMEM_SIZE-1];

  initial begin
    $readmemb("IMem.txt", IMem, 8'h00, 8'h0f); // 命令メモリの初期化
  end

  always @ (posedge CLK) begin
    PC <= newPC; // PCをnewPCの値に更新
  end

  assign Ins = RST? 32'd0: IMem[PC>>2]; // 命令メモリから呼び出す
  assign nextPC = PC + 4; // add

endmodule
