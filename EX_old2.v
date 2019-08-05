module EX(
	input CLK, //signal
	input RST, //signal
	input [31:0] Ins,
	input [31:0] Rdata1,
	input [31:0] Rdata2,
	input [31:0] Ed32,
	input [31:0] nextPC,
	output [31:0] Result,
	output [31:0] newPC,
  reg [31:0] HIreg,
  reg [31:0] LOreg
);

parameter ZERO = 32'h0;

always @(posedge CLK)
begin
  // R形式
	if(Ins[31:26] == R_FORM)
  begin
    Result = R_Result_func(Ins, Rdata1, Rdata2);
    newPC = R_PC_func(Ins, Rdata1, nextPC);
    HIreg = R_HI_func(Ins, Rdata1, Rdata2);
    LOreg = R_LO_func(Ins, Rdata1, Rdata2);
  end
  // J形式
  else if(Ins[31:26] == J || Ins[31:26] == JAL)
  begin
    Result = ZERO;
    newPC = J_PC_func(Ins, nextPC);
    HIreg = ZERO;
    LOreg = ZERO;
  end
  // I形式
  elss
  begin
    Result = I_Result_func(Ins, Rdata1, Ed32);
    newPC = I_PC_func(Ins, Rdata1, Rdata2, Ed32, nextPC);
    HIreg = ZERO;
    LOreg = ZERO;
  end
end // always @(posedge CLK)

// =============================================================================

// ------------------------------------------------
function [31:0] R_Result_func(
  input [31:0] Ins,
  input [31:0] Rdata1,
  input [31:0] Rdata2
)
  case(Ins[5:0])
    // ===== ALU =====
		ADD: R_Result_func = Rdata1 + Rdata2;
		ADDU: R_Result_func = Rdata1 + Rdata2;
		SUB: R_Result_func = Rdata1 - Rdata2;
		SUBU: R_Result_func = Rdata1 - Rdata2;
		AND: R_Result_func = Rdata1 + Rdata2;
		OR: R_Result_func = Rdata1 + Rdata2;
		XOR: R_Result_func = Rdata1 + Rdata2;
		NOR: R_Result_func = Rdata1 + Rdata2;
		SLT: R_Result_func = Rdata1 + Rdata2;
		SLTU: R_Result_func = Rdata1 + Rdata2;
    // ==== Shifts =====
		SLL: R_Result_func = Rdata1 + Rdata2;
    SRL: R_Result_func = Rdata1 + Rdata2;
    SRA: R_Result_func = Rdata1 + Rdata2;
    SLLV: R_Result_func = Rdata1 + Rdata2;
    SRLV: R_Result_func = Rdata1 + Rdata2;
    SRAV: R_Result_func = Rdata1 + Rdata2;
    // ===== Multiplication and division ===== (HI LO 商LO 余りHI)
    //MFHI: R_Result_func = Rdata1 + Rdata2;
    //MTHI: R_Result_func = Rdata1 + Rdata2;
    //MFLO: R_Result_func = Rdata1 + Rdata2;
    //MULTU: R_Result_func = Rdata1 + Rdata2;
    //DIV: R_Result_func = Rdata1 + Rdata2;
    //DIVU: R_Result_func = Rdata1 + Rdata2;
    // ===== default =====
    default: R_Result_func = ZERO;
  //endcase
endfunction // R_Result_func

// ------------------------------------------------
function [31:0] R_PC_func(
input [31:0] Ins,
input [31:0] Rdata1,
input [31:0] nextPC
)
  case(Ins[5:0])
    // ===== Jump =====
    JR: R_PC_func = Rdata1;
    JALR: R_PC_func = Rdata1;
    // ===== default =====
    default: R_PC_func = Rdata1;
  //endcase
endfunction // R_PC_func

// ------------------------------------------------
function [31:0] R_HI_func(
  input [31:0] Ins,
  input [31:0] Rdata1,
  input [31:0] Rdata2
)
  case(Ins[31:26])
    // ===== Multiplication and division ===== (HI LO 商LO 余りHI)
    MFHI: R_HI_func = Rdata1 + Rdata2;
    MTHI: R_HI_func = Rdata1 + Rdata2;
    MFLO: R_HI_func = Rdata1 + Rdata2;
    MULTU: R_HI_func = Rdata1 + Rdata2;
    DIV: R_HI_func = Rdata1 + Rdata2;
    DIVU: R_HI_func = Rdata1 + Rdata2;
  //endcase
endfunction // R_HI_func

// ------------------------------------------------
function [31:0] R_LO_func(
  input [31:0] Ins,
  input [31:0] Rdata1,
  input [31:0] Rdata2
)
  case(Ins[31:26])
    // ===== Multiplication and division ===== (HI LO 商LO 余りHI)
    MFHI: R_LO_func = Rdata1 + Rdata2;
    MTHI: R_LO_func = Rdata1 + Rdata2;
    MFLO: R_LO_func = Rdata1 + Rdata2;
    MULTU: R_LO_func = Rdata1 + Rdata2;
    DIV: R_LO_func = Rdata1 + Rdata2;
    DIVU: R_LO_func = Rdata1 + Rdata2;
  //endcase
endfunction // R_LO_func

// =============================================================================

// ------------------------------------------------
function [31:0] J_PC_func(
  input [31:0] Ins,
  input [31:0] nextPC
)
  case(Ins[31:26])
    // ===== Jump =====
    J: J_PC_func = {nextPC[31:28], (Ins[25:0] << 2)};
    JAL: J_PC_func = {nextPC[31:28], (Ins[25:0] << 2)}; //戻りアドレスが$raレジスタにロードされる
    // ===== default =====
    default: J_PC_func = nextPC;
  //endcase
endfunction // J_PC_func

// =============================================================================

// ------------------------------------------------
// load $s1, 384（$s2） （$s1＝mem[$s2＋384])
// addi $s1, $s2, -256 ($s1＝$s2＋（-256))
function  [31:0] I_Result_func(
  input [31:0] Ins,
  input [31:0] Rdata1,
  input [31:0] Ed32
)
  case(Ins[31:26])
    // ===== ALU(I) =====
    ADDI: I_Result_func = Rdata1 + Ed32;
    ADDIU: I_Result_func = Rdata1 + Ed32;
    SLTI: I_Result_func = Rdata1 + Ed32;
    ANDI: I_Result_func = Rdata1 + Ed32;
    ORI: I_Result_func = Rdata1 + Ed32;
    XORI: I_Result_func = Rdata1 + Ed32;
    //LUI: I_Result_func = Rdata1 + Ed32;
    // ===== load =====
    LW: I_Result_func = Rdata1 + Ed32;
    SW: I_Result_func = Rdata1 + Ed32;
    // ===== default =====
    default: I_Result_func = ZERO;
  //endcase
endfunction // I_Result_func


// ------------------------------------------------
// beq $s1, $s2, 64	 (if（$s1==$s2） PC＝PC+4+64*4)
function [31:0] I_PC_func(
  input [31:0] Ins,
  input [31:0] Rdata1,
  input [31:0] Rdata2,
  input [31:0] Ed32,
  input [31:0] nextPC
)
  case(Ins[31:26])
    BLTZ: I_PC_func = nextPC //(BGEZも然り？)
    BEQ: I_PC_func = nextPC;
    BNE: I_PC_func = nextPC;
    BLEZ: I_PC_func = nextPC;
    BGTZ: I_PC_func = nextPC;
    // ===== default =====
    default: I_PC_func = nextPC;
  //endcase
endfunction // I_PC_func

// =============================================================================
endmodule
