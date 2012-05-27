/******************************************************************************
*                                                                             *
*                               Core-A Processor                              *
*                                                                             *
* 				     MUX	                              *
*                                                                             *
*******************************************************************************
*                                                                             *
*  Copyright (c) 2008 by Integrated Computer Systems Lab. (ICSL), KAIST       *
*                                                                             *
*  All rights reserved.                                                       *
*                                                                             *
*  Do Not duplicate without prior written consent of ICSL, KAIST.             *
*                                                                             *
*                                                                             *
*                                                  Designed By Ji-Hoon Kim    *
*                                                             Duk-Hyun You    *
*                                                             Ki-Seok Kwon    *
*                                                              Eun-Joo Bae    *
*                                                              Won-Hee Son    *
*                                                                             *
*                                              Supervised By In-Cheol Park    *
*                                                                             *
*                                            E-mail : icpark@ee.kaist.ac.kr   *
*                                                                             *
*******************************************************************************/

`timescale 1ns / 10ps
// DI0 SERIES OF MUXES
// ENCODING OF MUX_CTRL MUST BE ONE HOT.
//
module MUX3to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[2:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2);
endmodule

module MUX4to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[3:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3);
endmodule

module MUX5to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[4:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4);
endmodule

module MUX6to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[5:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4) |
				 ({ BITWIDTH {SEL[5]}} & DI5);
endmodule

module MUX7to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[BITWIDTH-1:0]		DI6,
	input	wire	[6:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4) |
				 ({ BITWIDTH {SEL[5]}} & DI5) |
				 ({ BITWIDTH {SEL[6]}} & DI6);
endmodule

module MUX8to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[BITWIDTH-1:0]		DI6,
	input	wire	[BITWIDTH-1:0]		DI7,
	input	wire	[7:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4) |
				 ({ BITWIDTH {SEL[5]}} & DI5) |
				 ({ BITWIDTH {SEL[6]}} & DI6) |
				 ({ BITWIDTH {SEL[7]}} & DI7);
endmodule

module MUX9to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[BITWIDTH-1:0]		DI6,
	input	wire	[BITWIDTH-1:0]		DI7,
	input	wire	[BITWIDTH-1:0]		DI8,
	input	wire	[8:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4) |
				 ({ BITWIDTH {SEL[5]}} & DI5) |
				 ({ BITWIDTH {SEL[6]}} & DI6) |
				 ({ BITWIDTH {SEL[7]}} & DI7) |
				 ({ BITWIDTH {SEL[8]}} & DI8);
endmodule

module MUX10to1 #(parameter	BITWIDTH = 32)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[BITWIDTH-1:0]		DI6,
	input	wire	[BITWIDTH-1:0]		DI7,
	input	wire	[BITWIDTH-1:0]		DI8,
	input	wire	[BITWIDTH-1:0]		DI9,
	input	wire	[9:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO = ({ BITWIDTH {SEL[0]}} & DI0) |
				 ({ BITWIDTH {SEL[1]}} & DI1) |
				 ({ BITWIDTH {SEL[2]}} & DI2) |
				 ({ BITWIDTH {SEL[3]}} & DI3) |
				 ({ BITWIDTH {SEL[4]}} & DI4) |
				 ({ BITWIDTH {SEL[5]}} & DI5) |
				 ({ BITWIDTH {SEL[6]}} & DI6) |
				 ({ BITWIDTH {SEL[7]}} & DI7) |
				 ({ BITWIDTH {SEL[8]}} & DI8) |
				 ({ BITWIDTH {SEL[9]}} & DI9);
endmodule

module MUX16to1 #(parameter BITWIDTH = 1)	(
	input	wire	[BITWIDTH-1:0]		DI0,
	input	wire	[BITWIDTH-1:0]		DI1,
	input	wire	[BITWIDTH-1:0]		DI2,
	input	wire	[BITWIDTH-1:0]		DI3,
	input	wire	[BITWIDTH-1:0]		DI4,
	input	wire	[BITWIDTH-1:0]		DI5,
	input	wire	[BITWIDTH-1:0]		DI6,
	input	wire	[BITWIDTH-1:0]		DI7,
	input	wire	[BITWIDTH-1:0]		DI8,
	input	wire	[BITWIDTH-1:0]		DI9,
	input	wire	[BITWIDTH-1:0]		DI10,
	input	wire	[BITWIDTH-1:0]		DI11,
	input	wire	[BITWIDTH-1:0]		DI12,
	input	wire	[BITWIDTH-1:0]		DI13,
	input	wire	[BITWIDTH-1:0]		DI14,
	input	wire	[BITWIDTH-1:0]		DI15,
	input	wire	[15:0]				SEL,
	output	wire	[BITWIDTH-1:0]		DO
);
	
	assign DO	= ({ BITWIDTH {SEL[0]}} & DI0)
				| ({ BITWIDTH {SEL[1]}} & DI1)
				| ({ BITWIDTH {SEL[2]}} & DI2)
				| ({ BITWIDTH {SEL[3]}} & DI3)
				| ({ BITWIDTH {SEL[4]}} & DI4)
				| ({ BITWIDTH {SEL[5]}} & DI5)
				| ({ BITWIDTH {SEL[6]}} & DI6)
				| ({ BITWIDTH {SEL[7]}} & DI7)
				| ({ BITWIDTH {SEL[8]}} & DI8)
				| ({ BITWIDTH {SEL[9]}} & DI9)
				| ({ BITWIDTH {SEL[10]}} & DI10)
				| ({ BITWIDTH {SEL[11]}} & DI11)
				| ({ BITWIDTH {SEL[12]}} & DI12)
				| ({ BITWIDTH {SEL[13]}} & DI13)
				| ({ BITWIDTH {SEL[14]}} & DI14)
				| ({ BITWIDTH {SEL[15]}} & DI15);
endmodule

