/******************************************************************************
*                                                                             *
*                               Core-A Processor                              *
*                                                                             *
* 				   REGISTERS                                  *
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

module REG	#(parameter	BITWIDTH = 1) (
	input	wire						CLK,
	input	wire						RST,
	input	wire						EN,
	input	wire	[BITWIDTH-1 : 0]	D,
	output	reg		[BITWIDTH-1 : 0]	Q
);

	always @ (posedge CLK)
	begin 
		if (RST)		Q <= 0; 
		else if (EN)	Q <= D;
	end

endmodule

// NEGATIVE LEVEL-SENSITIVE LATCH (NO RST, NO WE)
module LatchN #(parameter	BITWIDTH = 1) (
	input	wire						CLK, 
	input	wire	[BITWIDTH-1 : 0]	D, 
	output	reg		[BITWIDTH-1 : 0]	Q 
);

	always @ (CLK or D)
	begin 
		if (~CLK) Q <= D;
	end

endmodule

// NEGATIVE EDGE-TRIGGERED FLIPFLOP (NO RST, NO WE)
module SyncRegN #(parameter	BITWIDTH = 1) (
	input	wire						CLK, 
	input	wire	[BITWIDTH-1 : 0]	D, 
	output	reg		[BITWIDTH-1 : 0]	Q 
);

	always @ (negedge CLK)
	begin 
		Q <= D;
	end

endmodule

// POSITIVE EDGE-TRIGGERED FLIPFLOP (SET, NO WE)
module PipeRegS #(parameter  BITWIDTH = 1) (
	input   wire                        CLK,
	input   wire                        SET,
	input	wire						EN,
	input   wire    [BITWIDTH-1 : 0]    D,
	output  reg     [BITWIDTH-1 : 0]    Q
);

	always @ (posedge CLK)
	begin   
		if (SET)		Q <= 1; 
		else if (EN)	Q <= D; 
	end

endmodule

// POSITIVE EDGE-TRIGGERED FLIPFLOP (RST, WE)
module PipeReg #(parameter	BITWIDTH = 1) (
	input	wire						CLK,
	input	wire						RST,
	input	wire						EN,
	input	wire	[BITWIDTH-1 : 0]	D,
	output	reg		[BITWIDTH-1 : 0]	Q
);

	always @ (posedge CLK)
	begin 
		if (RST)		Q <= 0; 
		else if (EN)	Q <= D;
	end

endmodule

