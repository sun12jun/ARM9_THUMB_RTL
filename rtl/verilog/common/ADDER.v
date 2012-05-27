/********************************************************************************
 *																				*
 *		ADDER.v  Ver 0.1														*
 *																				*
 *		Designed by	Yoon Dong Joon                                              *
 *																				*
 ********************************************************************************
 *																				*
 *		Support Verilog 2001 Syntax												*
 *																				*
 *		Update history : 2012.05.24	 original authored (Ver.0.1)				*
 *																				*		
 *		Combonational adder														*
 *																				*
 ********************************************************************************/	
`timescale 1ns / 10ps

module ADDER #(parameter WIDTH=32) (
	//---------------------------------------------------------------------------
	//	2 input
	//---------------------------------------------------------------------------
	input wire [WIDTH-1:0] A,
	input wire [WIDTH-1:0] B,
	input wire C_in,
	
	//---------------------------------------------------------------------------
	//	SUM & Carry
	//---------------------------------------------------------------------------
	output wire [WIDTH-1:0] SUM,
	output wire C_out
	);

//-------------------------------------------------------------------------------
//	Internal Signal & parameter
//-------------------------------------------------------------------------------
wire [WIDTH:0] iSUM;

assign iSUM = A + B + C_in;

assign SUM = iSUM[WIDTH-1:0];
assign C_out = iSUM[WIDTH];

endmodule
	
