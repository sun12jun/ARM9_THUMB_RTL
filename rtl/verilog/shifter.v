module shiftextract(
	input wire [31:0]	OPX,
	input wire [4:0]	OPY,
	input wire			DIR,
	input wire			MUX_CTRL1,
	input wire [3:0]	MUX_CTRL2,
	output wire 		COUT,
	output wire	[31:0]	DOUT
);

	wire [31:0] shift_in1;
	wire [31:0] shift_in2;
	wire [4:0]  shamt;
	wire [63:0] shift_out;
	wire 		shift_c;
	
	//left = 0
	//right = 1
	assign	shamt = (DIR)? OPY : ~OPY;
	//left shift = 0
	//right shift = 1
	assign shift_in1 = (MUX_CTRL1) ? OPX : {OPX[0], 31'b0};

	MUX4to1	#(32)	MUX	(
						.DI0		(32'b0), 				// LSR
						.DI1		({1'b0, OPX[31:1]}), 	// LSL
						.DI2		({32{OPX[31]}}), 		// ASR
						.DI3		(OPX),	 				// ROR
						.SEL		(MUX_CTRL2),
						.DO			(shift_in2)
					);

	SHIFTER			SHIFT_EXTD (
						.DIN		({shift_in2, shift_in1}), 
						.SHAMT		(shamt), 
						.COUT		(shift_c),
						.DOUT		(shift_out)
					);

	assign	DOUT = shift_out[31:0];
	assign	COUT = (DIR) ? shift_c : shift_out[32];

endmodule

module SHIFTER ( 
	/* input */
	input	wire	[63:0]			DIN, 		// Operand to be shifted
	input	wire	[4:0]			SHAMT,		// Shift Amount

	/* output */
	output	wire					COUT,		// Carry Out
	output	wire	[63:0]			DOUT		// Shifted Value
);

	wire    [63:0]  lsr_mid0;
    wire    [63:0]  lsr_mid1;
    wire    [63:0]  lsr_mid2;
    wire    [63:0]  lsr_mid3;
	wire	[5:0]	mux_ctrl;

    assign lsr_mid0 = SHAMT[0] ? { 1'b0,      DIN[63:1]} : DIN;
    assign lsr_mid1 = SHAMT[1] ? { 2'b0, lsr_mid0[63:2]} : lsr_mid0;
    assign lsr_mid2 = SHAMT[2] ? { 4'b0, lsr_mid1[63:4]} : lsr_mid1;
    assign lsr_mid3 = SHAMT[3] ? { 8'b0, lsr_mid2[63:8]} : lsr_mid2;
    assign DOUT		= SHAMT[4] ? {16'b0, lsr_mid3[63:16]}: lsr_mid3;

	assign	mux_ctrl[0] =  SHAMT[4];	
	assign	mux_ctrl[1] = ~SHAMT[4] &  SHAMT[3];
	assign	mux_ctrl[2] = ~SHAMT[4] & ~SHAMT[3] &  SHAMT[2];
	assign	mux_ctrl[3] = ~SHAMT[4] & ~SHAMT[3] & ~SHAMT[2] &  SHAMT[1];	
	assign	mux_ctrl[4] = ~SHAMT[4] & ~SHAMT[3] & ~SHAMT[2] & ~SHAMT[1] &  SHAMT[0];	
	assign	mux_ctrl[5] = ~SHAMT[4] & ~SHAMT[3] & ~SHAMT[2] & ~SHAMT[1] & ~SHAMT[0];	

	MUX6to1	#(1)	MUX_C (
						.DI0		(lsr_mid3[15]),
						.DI1		(lsr_mid2[7]),
						.DI2		(lsr_mid1[3]),
						.DI3		(lsr_mid0[1]),
						.DI4		(DIN[0]),
						.DI5		(1'b0),
						.SEL		(mux_ctrl),
						.DO			(COUT)
					);

endmodule
