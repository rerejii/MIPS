//`include "common_param.vh"


//input CLK, RST;
//output [31:0] PC, Result;
//wire [31:0] newPC, nextPC, Ins;
//wire [31:0] Rdata1, Rdata2, Ed32, Wdata;
//EX EX0 (.CLK(CLK), .RST(RST), .Ins(Ins), .Rdata1(Rdata1), .Rdata2(Rdata2),
//      .Ed32(Ed32), .nextPC(nextPC), .Result(Result), .newPC(newPC));

module EX(
	input CLK, //signal
	input RST, //signal
	input [31:0] Ins,
	input [31;0] Rdata1,
	input [31;0] Rdata2,
	input [31:0] Ed32,
	//input [25:0] Jadr,
	input [31:0] nextPC,
	//input ALU, //signal
	//input zero //nonzero, //signal
	output [31;0] Result,
	output [31;0] newPC,
	wire [31:0] MUX2_to_ALU
	wire [31:0] ALU_to_zero/nonzero,
	//wire zero/nonzero_to_MUX4, //signal
	wire [31:0] sh2_to_adder,
	wire [31:0] adder_to_MUX4,
	wire [31:0] MUX4_to_MUX5,
);

// 掛け算は High Low の二つのレジスタを作って
// それをレジスタが読み込み書き込む形に

//書き込まれないResultは値なんでもいい

always @(posedge CLK)
	if(calALU == )
end

//function [31:0] calALU(
//	input [31:0] Ins,
//	input [31;0] Rdata1,
//	input [31;0] Rdata2,
//)



// ALU
//function [31:0] calALU
//	case(Ins[0:5])
//		R_FORM:
//			case(Ins[31:26])
//				ADD: calALU = Rdata1 + Rdata2;
//				ADDU: calALU = Rdata1 + Rdata2;
//				SUB: calALU = Rdata1 - Rdata2;
//				SUBU: calALU = Rdata1 - Rdata2;
//				AND: calALU = Rdata1 + Rdata2;
//				OR: calALU = Rdata1 + Rdata2;
//				XOR: calALU = Rdata1 + Rdata2;
//				NOR: calALU = Rdata1 + Rdata2;
//				SLT: calALU = Rdata1 + Rdata2;
//				SLTU: calALU = Rdata1 + Rdata2;


		ADDI:
		ADDIU:
		SLTI:
		SLTIU:
		ANDI:
		ORI:
		XORI
		LUI:



		end
endfunction



always @(CLK)
	begin
		case(ALU)
			// Func:function(ALU) Op==6'd0
			ADD: ;
			ADDU;
			SUB;
			SUBU;
			AND;
			OR;
			XOR;
			NOR;
			SLT;
			SLTU;
			// Op:operation codes (w/o function code)
			ADDI;
			ADDIU;
			SLTI;
			SLTIU;
			ANDI;
			ORI;
			XORI;
			LUI;

			SLL;
			SRL;
			SRA;
			SLLV;
			SRLV;
			SRAV;

	end
