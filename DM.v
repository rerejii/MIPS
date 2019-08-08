// Result memory nextPC のどれかをレジスタに渡す
module DM(
  input CLK, RST,
  input [31:0] Adr, // Result memory nextPC
  input [31:0] Wdata, // データメモリにストアするデータ
  input [31:0] nextPC,
  input [31:0] Ins,
  output [31:0] Rdata // データメモリよりロードしたデータを上のモジュールに渡す
);

`include "common_param.vh"
parameter ONE32 = 32'h1;
parameter ZERO32 = 32'h0;
reg i = 32'h0;
reg [31:0] DMem [0:DMEM_SIZE-1];

initial begin
	for (i = 0; i < DMEM_SIZE; i = i + 1) begin
		DMem[i] <= 32'b0;
	end
end

assign Rdata = MUX;

always @(posedge CLK) begin
  case(Ins[31:26])
    SW: DMem[Adr>>2] <= Wdata;
  endcase
end // always

// ----- MUX -------------------------------------------
function [31:0] MUX(
  input [31:0] Adr, // Result memory nextPC
  input [31:0] Wdata, // データメモリにストアするデータ
  input [31:0] nextPC,
  input [31:0] Ins
);
case(Ins[31:26])
  LW: MUX = DMem[Adr>>2]; // ロードした値を返す
  SW: MUX = ZERO32; // ストア命令(Resultはなし)
  default: MUX = Adr; // Resultの値を返す
endcase // (Ins[31:26])
endfunction // MUX

// ----- endmodule -------------------------------------------
endmodule
