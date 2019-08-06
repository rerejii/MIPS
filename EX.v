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
parameter ONE32 = 32'h1;
parameter ZERO32 = 32'h0;
parameter BLTZ_OR_BGEZ = BLTZ;
reg [31:0] HIreg = ZERO32;
reg [31:0] LOreg = ZERO32;

assign {Result, newPC} = ALU(Ins, Rdata1, Rdata2, Ed32, nextPC, HIreg, LOreg);
always @(posedge CLK)
	begin
		{HIreg, LOreg} <= MULT_DIV(Ins, Rdata1, Rdata2, HIreg, LOreg);
	end

// ----- MULT_DIV -------------------------------------------
function [63:0] MULT_DIV(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] HIreg,
	input [31:0] LOreg
);
	if(Ins[31:26] == R_FORM)
		begin
			case(Ins[5:0])
				MULT: MULT_DIV = Rdata1 * Rdata2;
				MULTU: MULT_DIV = Rdata1 * Rdata2;
				DIV: MULT_DIV = {(Rdata1 % Rdata2), (Rdata1 / Rdata2)};
				DIVU: MULT_DIV = {(Rdata1 % Rdata2), (Rdata1 / Rdata2)};
				default: MULT_DIV = {HIreg, LOreg};
			endcase
		end
	else MULT_DIV = {HIreg, LOreg};
endfunction // MULT_DIV

// ----- ALU -------------------------------------------
function [63:0] ALU(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC,
	input [31:0] HIreg,
	input [31:0] LOreg
);
	case(Ins[31:26])
		R_FORM: ALU = R_FUNC(Ins, Rdata1, Rdata2, Ed32, nextPC, HIreg, LOreg);
		J: ALU = J_FUNC(Ins, nextPC);
		JAL: ALU = J_FUNC(Ins, nextPC);
		default: ALU = I_FUNC(Ins, Rdata1, Rdata2, Ed32, nextPC);
	endcase
endfunction // ALU

// ----- R_FUNC -------------------------------------------
function [63:0] R_FUNC(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC,
	input [31:0] HIreg,
	input [31:0] LOreg
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
		JR: R_FUNC = {ZERO32, Rdata1}; // Rdata1の値に飛ぶ
		JALR: R_FUNC = {nextPC, Rdata1}; // 本来のPCをレジスタに退避
		// ===== Move ====
		MFHI: R_FUNC = {HIreg, Rdata1};  // HIregの値を返す
		MTHI: R_FUNC = {ZERO32, nextPC}; // HIregの値を更新(こっちでは何もしない)
		MFLO: R_FUNC = {LOreg, Rdata1};  // LOregの値を返す
		MTLO: R_FUNC = {ZERO32, nextPC}; // LOregの値を更新(こっちでは何もしない)
		MULT: R_FUNC = {ZERO32, nextPC}; // 乗算(こっちでは何もしない)
		MULTU: R_FUNC = {ZERO32, nextPC}; // 乗算(こっちでは何もしない)
		DIV: R_FUNC = {ZERO32, nextPC}; // 除算(こっちでは何もしない)
		DIVU: R_FUNC = {ZERO32, nextPC}; // 除算(こっちでは何もしない)
		// ===== default =====
		default: R_FUNC = {ZERO32, nextPC};
	endcase
endfunction // R_FUNC

// ----- I_FUNC -------------------------------------------
function [63:0] I_FUNC(
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC
);
	case(Ins[31:26])
		// ===== ALU(I) =====
		ADDI: I_FUNC = {Rdata1 + Ed32, nextPC};
		ADDIU: I_FUNC = {Rdata1 + Ed32, nextPC};
		SLTI: I_FUNC = (Rdata1 < Ed32) ? {ONE32, nextPC} : {ZERO32, nextPC};
		SLTIU: I_FUNC = (Rdata1 < Ed32) ? {ONE32, nextPC} : {ZERO32, nextPC};
		ANDI: I_FUNC = {Rdata1 & Ed32, nextPC};
		ORI: I_FUNC = {Rdata1 | Ed32, nextPC};
		XORI: I_FUNC = {Rdata1 ^ Ed32, nextPC};
		// ===== load =====
		LW: I_FUNC = {Rdata1 + Ed32, nextPC}; //ロードする座標を返す
		SW: I_FUNC = {Rdata1 + Ed32, nextPC}; //ストアする座標を返す
		// ===== Branch =====
		//BLTZ: I_FUNC = {ZERO32, nextPC}; //(BGEZも然り？)
		BLTZ_OR_BGEZ:
			begin
				case(Ins[20:16])
					BLTZ_r: I_FUNC = (Rdata1 < 0) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
					BGEZ_r: I_FUNC = (Rdata1 >= 0) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
				endcase
			end
		BEQ: I_FUNC = (Rdata1 == Rdata2) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
		BNE: I_FUNC = (Rdata1 != Rdata2) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
		BLEZ: I_FUNC = (Rdata1 <= 0) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
		BGTZ: I_FUNC = (Rdata1 > 0) ? {ZERO32, nextPC + (Ed32 << 2)} : {ZERO32, nextPC};
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
		JAL: J_FUNC = { nextPC, {nextPC[31:28], (Ins[25:0] << 2)} }; //戻りアドレスが$raレジスタにロードされる
		// ===== default =====
		default: J_FUNC = {ZERO32, nextPC};
	endcase
endfunction // J_FUNC

endmodule
