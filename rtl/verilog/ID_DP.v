/********************************************************************************
 *																				*
 *		ID_DP.v  Ver 0.1													*
 *																				*
 *		Designed by	Yoon Dong Joon                                              *
 *																				*
 ********************************************************************************
 *																				*
 *		Support Verilog 2001 Syntax												*
 *																				*
 *		Update history : 2012.05.24	 original authored (Ver.0.1)				*
 *																				*
 *		instruction decode datapath											    *
 *																				*
 ********************************************************************************/	

`timescale 1ns / 10ps
`include "./ARM_THUMB_defines.v"

module ID_DP(
	//---------------------------------------------------------------------------
	//	instruction from pipeline register
	//---------------------------------------------------------------------------
	input wire	[15:0]	INST,
	input wire	[31:0]	IF_PC,

	//---------------------------------------------------------------------------
	//	Register operand from register file
	//---------------------------------------------------------------------------
	input wire	[31:0]	RF_RD,
	input wire	[31:0]	RF_RN,
	input wire	[31:0]	RF_RM,

	//---------------------------------------------------------------------------
	//	input control signals
	//---------------------------------------------------------------------------
	//	from control path
	input wire	[2:0]	RN_SEL_DP,
	input wire	[2:0]	RM_SEL_DP,
	input wire	[6:0]	IMM_SEL_DP,
	input wire			SIGN_EXT_SEL_DP,
	input wire	[4:0]	SHT_SEL_DP,

	input wire	[6:0]	OPERATION_DP,

	//---------------------------------------------------------------------------
	//	Register operand output & shift amount
	//---------------------------------------------------------------------------
	output wire	[31:0]	OP_X,
	output wire	[31:0]	OP_Y,
	output wire	[7:0]	SHT_AMONUT,

	//---------------------------------------------------------------------------
	//	next pc for branch
	//---------------------------------------------------------------------------
	output wire	[31:0]	PC_OFFSET
);

//-------------------------------------------------------------------------------
//	internal signals
//-------------------------------------------------------------------------------
wire	[31:0] imm3;
wire	[31:0] imm5;
wire	[31:0] imm7;
wire	[31:0] imm8;
wire	[31:0] imm8s;
wire	[31:0] imm11;
wire	[31:0] imm11s;
wire	[31:0] imm_val;

wire	[31:0] shift5;
wire	[31:0] shift8;

wire	[31:0]  sht_val;

wire	[31:0] rn;
wire	[31:0] rm;

//-------------------------------------------------------------------------------
//	immediate value decoding & selection
//-------------------------------------------------------------------------------
assign	imm3 = {29'b0, INST[8:6]};
assign	imm5 = {27'b0, INST[10:6]};
assign	imm7 = {25'b0, INST[6:0]};
assign	imm8 = {24'b0, INST[7:0]};
assign	imm8s = { {24{INST[7]}}, INST[7:0]};
assign	imm11 = {21'b0, INST[10:0]};
assign	imm11s = { {21{INST[10]}}, INST[10:0]};

MUX7to1 #(32) uIMM_MUX(
	.DI0	(imm3),	
	.DI1	(imm5),	
	.DI2	(imm7),	
	.DI3	(imm8),	
	.DI4	(imm8s),	
	.DI5	(imm11),	
	.DI6	(imm11s),	
	.SEL	(IMM_SEL_DP),	
	.DO		(imm_val)
);

//-------------------------------------------------------------------------------
//	shift amount decoding & selection
//-------------------------------------------------------------------------------

assign	shift5 = {27'b0, INST[10:6]};
assign	shift8 = rm[7:0];

MUX5to1 #(32) uSHT_MUX(
	.DI0	(shift5),	
	.DI1	(shift8),	
	.DI2	(32'd12),	
	.DI3	(32'd2),	
	.DI4	(32'd1),	
	.SEL	(SHT_SEL_DP),	
	.DO		(sht_val)
);



//-------------------------------------------------------------------------------
//	Register operand decoding & selection
//-------------------------------------------------------------------------------
MUX3to1 #(32) uRn_MUX(
	.DI0	(IF_PC),	
	.DI1	(RF_RD),	
	.DI2	(RF_RN),	
	.SEL	(RN_SEL_DP),	
	.DO		(rn)
);

MUX3to1 #(32) uRm_MUX(
	.DI0	(imm_val),	
	.DI1	(RF_RM),	
	.DI2	(),	
	.SEL	(RM_SEL_DP),	
	.DO		(rm)
);


//-------------------------------------------------------------------------------
//	make pc value
//-------------------------------------------------------------------------------
assign PC_OFFSET = (OPERATION_DP==`BL_H2)? {imm_val[19:0], 12'd0} : {imm_val[30:0], 1'd0};	

//-------------------------------------------------------------------------------
//	PC Value selection & output assignment
//-------------------------------------------------------------------------------
assign SHT_AMONUT[7:0] = sht_val[7:0];
assign OP_X = rn;
assign OP_Y = rm;

endmodule
