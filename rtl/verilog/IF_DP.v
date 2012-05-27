/********************************************************************************
 *																				*
 *		IF_DP.v  Ver 0.1													*
 *																				*
 *		Designed by	Yoon Dong Joon                                              *
 *																				*
 ********************************************************************************
 *																				*
 *		Support Verilog 2001 Syntax												*
 *																				*
 *		Update history : 2012.05.24	 original authored (Ver.0.1)				*
 *                  															*
 *		instruction fetch datapath					                            *
 *																				*
 ********************************************************************************/	

`timescale 1ns / 10ps

module IF_DP(
	//---------------------------------------------------------------------------
	//	input PC, instruction from memory
	//---------------------------------------------------------------------------
	input wire [31:0] PC,
	input wire [15:0] INST,

	//---------------------------------------------------------------------------
	//	From Pipeline register
	//---------------------------------------------------------------------------
	input wire PC_REL_SEL,
	input wire [31:0] PC_REL_OFFSET,

	//---------------------------------------------------------------------------
	//	Next PC, fetched instruction
	//---------------------------------------------------------------------------
	output wire [31:0] IF_PC,
	output wire [15:0] FINST
);

//-------------------------------------------------------------------------------
//	internal signals
//-------------------------------------------------------------------------------
wire	[31:0] pc_inc;
wire	[31:0] pc_rel;

wire	[31:0] npc;

//-------------------------------------------------------------------------------
//	Fetch operation
//-------------------------------------------------------------------------------
// PC incremeter
ADDER #(32) uAdder2(
	.A		(PC),
	.B		(32'd2),
	.C_in	(1'd0),

	.SUM	(pc_inc),
	.C_out	()
);

// relative PC for branch
ADDER #(32) uAdder(
	.A		(PC),
	.B		(PC_REL_OFFSET),
	.C_in	(1'b0),

	.SUM	(pc_rel),
	.C_out	()
);

// PC value MUX, absolute or relative(branch), normal incremented value
assign npc = (PC_REL_SEL)? pc_rel : pc_inc;

assign IF_PC = npc;
assign FINST = (PC_REL_SEL)? 16'd0 : INST;

endmodule
