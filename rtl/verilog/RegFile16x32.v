
`timescale 1ns / 10ps

module RegFile16x32 (
	input	wire					CLK, 
	input	wire					RST,
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

	always @ (posedge CLK)	begin
//			if(~Contention & ~WEN_A)	ram[WA_A] <= W_DA;
//			if(~WEN_B)	ram[WA_B] <= W_DB;
	if(RST) begin
		ram[0] <= 32'd0;
		ram[1] <= 32'd0;
		ram[2] <= 32'd0;
		ram[3] <= 32'd0;
		ram[4] <= 32'd0;
		ram[5] <= 32'd0;
		ram[6] <= 32'd0;
		ram[7] <= 32'd0;
		ram[8] <= 32'd0;
		ram[9] <= 32'd0;
		ram[10] <= 32'd0;
		ram[11] <= 32'd0;
		ram[12] <= 32'd0;
		ram[13] <= 32'd0;
		ram[14] <= 32'd0;
		ram[15] <= 32'd0;
	end
	else begin
		if(~WEN_A)	ram[WA_A] <= W_DA;
	end
end

endmodule

