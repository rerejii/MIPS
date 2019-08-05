module EX(
	input CLK, //signal
	input RST, //signal
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC,
	output [31:0] Result,
	output [31:0] newPC
);
`include "common_param.vh"
reg [31:0] HIreg;
reg [31:0] LOreg;
parameter ONE32 = 32'h1;
parameter ZERO32 = 32'h0;
assign {Result, newPC} = ALU(Ins, Rdata1, Rdata2, Ed32, nextPC);

always @(posedge CLK)
	begin
		HIreg <= 0;
		LOreg <= 0;
	end

// ----- ALU -------------------------------------------
function [63:0] ALU(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC
);
	case(Ins[31:26])
		R_FORM: ALU = R_FUNC(Ins, Rdata1, Rdata2, Ed32, nextPC);
		J: ALU = J_FUNC(Ins, nextPC);
		JAL: ALU = J_FUNC(Ins, nextPC);
		default: ALU = I_FUNC(Ins, Rdata1, Ed32, nextPC);
	endcase
endfunction // ALU

// ----- R_FUNC -------------------------------------------
function [63:0] R_FUNC(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC
);
	case(Ins[5:0])
		// ===== ALU =====
		//符号あり・なしではオーバーフロー時の処理が違うが、今回オーバーフローは発生しないと仮定
		ADD: R_FUNC = {Rdata1 + Rdata2, nextPC};
		ADDU: R_FUNC = {Rdata1 + Rdata2, nextPC};
		SUB: R_FUNC = {Rdata1 - Rdata2, nextPC};
		SUBU: R_FUNC = {Rdata1 - Rdata2, nextPC};
		AND: R_FUNC = {Rdata1 & Rdata2, nextPC};
		OR: R_FUNC = {Rdata1 | Rdata2, nextPC};
		XOR: R_FUNC = {Rdata1 ^ Rdata2, nextPC};
		NOR: R_FUNC = { ~(Rdata1 | Rdata2), nextPC};
		SLT:
			begin
				if(Rdata1 < Rdata2) R_FUNC = {ONE32, nextPC};
				else R_FUNC = {ZERO32, nextPC};
			end
		SLTU:
			begin
				if(Rdata1 < Rdata2) R_FUNC = {ONE32, nextPC};
				else R_FUNC = {ZERO32, nextPC};
			end
		// ==== Shifts =====
		// $d = $t << C
		SLL: R_FUNC = {(Rdata1 << Ed32), nextPC};
		SRL: R_FUNC = {(Rdata1 >> Ed32), nextPC};
		// 符号付き変数 signed でなければ算術シフトがされない？
		SRA: R_FUNC = {Rdata1 >>> Ed32, nextPC};
		SLLV: R_FUNC = {(Rdata1 << Rdata2), nextPC};
		SRLV: R_FUNC = {(Rdata1 >> Rdata2), nextPC};
		SRAV: R_FUNC = {(Rdata1 >>> Rdata2), nextPC};
		// ===== Jump =====
		JR: R_FUNC = {ZERO32, Rdata1};
		JALR: R_FUNC = {nextPC, Rdata1}; // 本来のPCをレジスタに退避
		// ===== default =====
		default: R_FUNC = {ZERO32, nextPC};
	endcase
endfunction // R_FUNC

// ----- I_FUNC -------------------------------------------
function [63:0] I_FUNC(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Ed32,
	input [31:0] nextPC
);
	case(Ins[31:26])
		// ===== ALU(I) =====
		ADDI: I_FUNC = {Rdata1 + Ed32, nextPC};
		ADDIU: I_FUNC = {Rdata1 + Ed32, nextPC};
		SLTI:
			begin
				if(Rdata1 < Ed32) I_FUNC = {ONE32, nextPC};
				else I_FUNC = {ZERO32, nextPC};
			end
		ANDI: I_FUNC = {Rdata1 & Ed32, nextPC};
		ORI: I_FUNC = {Rdata1 | Ed32, nextPC};
		XORI: I_FUNC = {Rdata1 ^ Ed32, nextPC};
		// ===== load =====
		LW: I_FUNC = {Rdata1 + Ed32, nextPC}; //未実装
		SW: I_FUNC = {Rdata1 + Ed32, nextPC}; //未実装
		// ===== Branch =====
		BLTZ: I_FUNC = {ZERO32, nextPC}; //(BGEZも然り？)
		BEQ: I_FUNC = {ZERO32, nextPC};
		BNE: I_FUNC = {ZERO32, nextPC};
		BLEZ: I_FUNC = {ZERO32, nextPC};
		BGTZ: I_FUNC = {ZERO32, nextPC};
		// ===== default =====
		default: I_FUNC = {ZERO32, nextPC};
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
		J: J_FUNC = { ZERO32, {nextPC[31:28], (Ins[25:0] << 2)} };
		JAL: J_FUNC = { ZERO32, {nextPC[31:28], (Ins[25:0] << 2)} }; //戻りアドレスが$raレジスタにロードされる
		// ===== default =====
		default: J_FUNC = {ZERO32, nextPC};
	endcase
endfunction // J_FUNC

endmodule
