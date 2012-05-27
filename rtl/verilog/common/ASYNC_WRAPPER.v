/******************************************************************************
*                                                                             *
*                       Asynchronous 32-bit Memory Wrapper                    *
*                                                                             *
*******************************************************************************
*                                                                             *
*  Copyright (c) 2009 by Integrated Computer Systems Lab. (ICSL), KAIST       *
*                                                                             *
*  All rights reserved.                                                       *
*                                                                             *
*  Do Not duplicate without prior written consent of ICSL, KAIST.             *
*                                                                             *
*                                                                             *
*                                               Designed By Ji-Hoon Kim       *
*                                                          Duk-Hyun You       *
*                                                          Ki-Seok Kwon       *
*                                                           Eun-Joo Bae       *
*                                                           Won-Hee Son       *
*                                                                             *
*                                           Supervised By In-Cheol Park       *
*                                                                             *
*                                        E-mail : icpark@ee.kaist.ac.kr       *
*                                                                             *
******************************************************************************/

module ASYNC_WRAPPER #(AWIDTH = 12) (
	
	//<=> Sync. Bus or Core-A 
	input	wire	CLK, 
	input	wire	CSN, 
	input	wire	[AWIDTH-1:0]	ADDR, 
	input	wire	WEN, 
	input	wire	[3:0]	BE,
	input	wire	[31:0]	DI, 

	//<=> Async. Memory
	output	reg	async_CSN, 
	output	reg	[AWIDTH-1:0]	async_ADDR, 
	output	reg	async_WEN, 
	output	reg	[3:0]	async_BE,
	output	reg	[31:0]	async_DI, 
);
	
	always @ (posedge CLK) begin
		async_CSN <= CSN;
		async_ADDR <= ADDR;
		async_WEN <= WEN;
		async_BE <= BE;
		async_DI <= DI;
	end
	
endmodule
