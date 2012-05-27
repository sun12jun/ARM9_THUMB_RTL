
`timescale 1ns / 10ps

module COND(
	input wire	[15:0]	IR,
	input wire	[31:0]	CPSR,

	output wire			COND_TRUE
);

	wire [3:0]  cond;
	wire 		cpsr_n;
	wire 		cpsr_z;
	wire 		cpsr_c;
	wire 		cpsr_v;

	assign cpsr_n = CPSR[31];
	assign cpsr_z = CPSR[30];
	assign cpsr_c = CPSR[29];
	assign cpsr_v = CPSR[28];

	wire EQ,NE,CS,CC,MI,PL,VS,VC,HI,LS,GE,LT,GT,LE,AL;

	assign cond[3:0] 	= IR[11:8];

	assign EQ = (cond == 4'b0000 && cpsr_z==1)?  1'b1 : 1'b0;	
	assign NE = (cond == 4'b0001 && cpsr_z==0) ? 1'b1 : 1'b0;	
	assign CS = (cond == 4'b0010 && cpsr_c==1)?  1'b1 : 1'b0;	
	assign CC = (cond == 4'b0011 && cpsr_c==0)?  1'b1 : 1'b0;	
	assign MI = (cond == 4'b0100 && cpsr_n==1)?  1'b1 : 1'b0;	
	assign PL = (cond == 4'b0101 && cpsr_n==0)?  1'b1 : 1'b0;	
	assign VS = (cond == 4'b0110 && cpsr_v==1)?  1'b1 : 1'b0;	
	assign VC = (cond == 4'b0111 && cpsr_v==0)?  1'b1 : 1'b0;	
	assign HI = (cond == 4'b1000 && cpsr_c==1 && cpsr_z==0)? 1'b1 : 1'b0;	
	assign LS = (cond == 4'b1001 && cpsr_c==0 && cpsr_z==1)? 1'b1 : 1'b0;	
	assign GE = (cond == 4'b1010 && ((cpsr_n==1 && cpsr_v==1)||(cpsr_n==0 && cpsr_v==0)))? 1'b1 : 1'b0;	
	assign LT = (cond == 4'b1011 && ((cpsr_n==1 && cpsr_v==0)||(cpsr_n==0 && cpsr_v==1)))? 1'b1 : 1'b0;	
	assign GT = (cond == 4'b1100 && (cpsr_z==0 && ((cpsr_n==1 && cpsr_v==1)||(cpsr_n==0 && cpsr_v==0))))? 1'b1 : 1'b0;		
	assign LE = (cond == 4'b1101 && (cpsr_z==1 && ((cpsr_n==1 && cpsr_v==0)||(cpsr_n==0 && cpsr_v==1))))? 1'b1 : 1'b0;
	assign AL = (cond == 4'b1110)? 1'b1 : 1'b0;	

	assign COND_TRUE = (EQ||NE||CS||CC||MI||PL||VS||VC||HI||LS||GE||LT||GT||LE||AL);

endmodule
