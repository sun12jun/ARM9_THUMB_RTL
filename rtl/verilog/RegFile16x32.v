
`timescale 1ns / 10ps

module RegFile16x32 (
	input	wire					CLK, 
	input	wire					WEN_A,
//	input	wire					WEN_B,
	input	wire		[31:0]		W_DA,		
//	input	wire		[31:0]		W_DB,		

	input	wire		[3:0]		RA_A,
	input	wire		[3:0]		RA_B,
	input	wire		[3:0]		RA_C,

	input	wire		[3:0]		WA_A,
//	input	wire		[3:0]		WA_B,
	output	wire		[31:0]		GRF_X,
	output	wire		[31:0]		GRF_Y,
	output	wire		[31:0]		GRF_Z
);

	reg		[31:0]		ram[15 : 0];

	assign	GRF_X = ram[RA_A];
	assign	GRF_Y = ram[RA_B];
	assign	GRF_Z = ram[RA_C];

//	wire	Contention = (WA_A==WA_B) & ~WEN_B;
//
//	always @ (posedge CLK)
//	begin
//			if(~Contention & ~WEN_A)	ram[WA_A] <= W_DA;
//			if(~WEN_B)	ram[WA_B] <= W_DB;
//	end

endmodule

