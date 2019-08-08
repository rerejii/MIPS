module ID(
  input CLK, RST,
  input [31:0] Ins,
  input [31:0] Wdata,
  output [31:0] Rdata1,
  output [31:0] Rdata2,
  output [31;0] Ed32
);

`include "common_param.vh"
parameter ONE32 = 32'h1;
parameter ZERO32 = 32'h0;
parameter ZERO27 = 27'h0;
parameter ZERO16 = 16'h0;
parameter J_WADR = 5'b11111;
parameter TRUE = 1'b1;
parameter FALSE = 1'b1;
wire [31:0] Wadr;
wire wflg;
reg i = 32'h0;
reg [31:0] REGFILE [0:REGFILE_SIZE-1];

initial begin
	for (i = 0; i < REGFILE_SIZE; i = i + 1) begin
		REGFILE[i] <= 32'b0;
	end
end

assign {Rdata1, Rdata2, Ed32, Wadr, Wflg} = IDEC(Ins)

always @(posedge CLK) begin
  if (wflg == 1) REGFILE[Wadr] <= Wdata;
end

// ----- IDEC -------------------------------------------
function [101:0] IDEC(
  input [31:0]  Ins
);
  case(Ins[31:26])
    R_FORM: R_FUNC(Ins);
    J: J_FUNC(Ins);
    JAL: J_FUNC(Ins);
    default: I_FUNC(Ins);
    // {Rdata1, Rdata2, Ed32, Wadr, Wflg}
  endcase
endfunction

// ----- R_FUNC -------------------------------------------
function [101:0] R_FUNC(
	input [31:0] Ins
);
	case(Ins[5:0])
		// ===== ALU =====
		//符号あり・なしではオーバーフロー時の処理が違うが、今回オーバーフローは発生しないと仮定
		ADD: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		ADDU: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SUB: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SUBU: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		AND: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		OR: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		XOR: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		NOR: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SLT: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SLTU: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		// ==== Shifts =====
		SLL: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SRL: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SRA: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SLLV: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SRLV: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		SRAV: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};
		// ===== Jump =====
		JR: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // Rdata1の値に飛ぶ
		JALR: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE}; // 本来のPCをレジスタに退避
		// ===== Move ====
		MFHI: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};  // HIregの値を返す
		MTHI: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // HIregの値を更新(こっちでは何もしない)
		MFLO: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], TRUE};  // LOregの値を返す
		MTLO: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // LOregの値を更新(こっちでは何もしない)
		MULT: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // 乗算(こっちでは何もしない)
		MULTU: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // 乗算(こっちでは何もしない)
		DIV: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // 除算(こっちでは何もしない)
    DIVU: R_FUNC = {REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE}; // 除算(こっちでは何もしない)
		// ===== default =====
		default: R_FUNC ={REGFILE[Ins[25:21]], REGFILE[Ins[20:16]], {ZERO27, Ins[10:6]}, Ins[15:11], FALSE};
	endcase
endfunction // R_FUNC


// ----- I_FUNC -------------------------------------------
function [63:0] I_FUNC(
	input [31:0] Ins
);
	case(Ins[31:26])
		// ===== ALU(I) =====
		ADDI: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		ADDIU: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		SLTI: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		SLTIU: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		ANDI: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		ORI: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		XORI: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		// ===== load =====
		LW: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], TRUE};
		SW: I_FUNC = {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		// ===== Branch =====
		//BLTZ: I_FUNC = {ZERO32, nextPC}; //(BGEZも然り？)
		BLTZ_OR_BGEZ: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		BEQ: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		BNE: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		BLEZ: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		BGTZ: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
		// ===== default =====
		default: {REGFILE[Ins[25:21]], ZERO32, {ZERO16, Ins[15:0]}, Ins[20:16], FALSE};
	endcase
endfunction // I_FUNC


// ----- J_FUNC -------------------------------------------
function [63:0] J_FUNC(
	input [31:0] Ins,
	input [31:0] nextPC
);
	//endcase
	case(Ins[31:26])
		// ===== Jump =====
		J: J_FUNC = {ZERO32, ZERO32, ZERO32, ZERO32, FALSE};
		JAL: J_FUNC = {ZERO32, ZERO32, ZERO32, J_WADR, TRUE};//戻りアドレスが$raレジスタにロードされる
		// ===== default =====
		default: J_FUNC = {ZERO32, nextPC};
	endcase
endfunction // J_FUNC

// ----- endmodule -------------------------------------------
endmodule
