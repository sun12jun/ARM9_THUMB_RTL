
`timescale 1ns / 10ps

`include "./ARM_THUMB_defines.v"

module EXEv2(
// IDtoEXE pipeline registers (IN)
	input wire [31:0] X,		//First operend
	input wire [31:0] Y,		//Second operend
	input wire [3:0]  RD_IN,		//Destination register number
	//input wire [31:0] LR_in,
	input wire [4:0]  SHAMT,
	input wire [4:0]  OPTYPE,
	input wire 		  XY_SEL,
	input wire		  VALIDRD_IN,
// Others (IN)
	input wire [3:0]  NZCV,		//NZCV from CPSR[31:28]	
	input wire [31:0] EXE_DF1,	//Data forwarded from EXE
	input wire [31:0] EXE_DF2,	//Data forwarded from EXE
	input wire [31:0] MEM_DF,	//Data forwarded from MEM
// Control Signals (IN)
	input wire [3:0]  HZ_CTRLX,	//CS from hazard detection unit
	input wire [3:0]  HZ_CTRLY,

// EXEtoMEM pipline registers (OUT)
	output wire [31:0]	Z_RESULT,
	//output wire [31:0]	LR_result,	//TYPE_BL instruction
	output wire [3:0]	RD_OUT,
	//output wire [31:0]	TYPE_BR_result,
// Others (OUT)
	output wire [3:0]	NZCVUPDATE,
	output wire 		VALIDRD_OUT
);


	wire [31:0] X_alu;
	wire [31:0] Y_alu;
	wire [31:0] Z_alu;
	wire [31:0] XY_alu;
	wire 		result_sel;
	wire [31:0] Z_temp;
	
	//SHIFTER Related	
	wire 		sh_dir;
	wire		sh_mux1;
	wire [3:0]	sh_mux2;
	wire [31:0] Z_shift;
	wire		C_shifter;

    //NZCV                                                                                                                                                                                                        
    wire N;                                                                                                                                                                                                       
    wire Z;                                                                                                                                                                                                       
    wire C;                                                                                                                                                                                                       
    wire V;
	
	assign N = NZCV[3];
	assign Z = NZCV[2];  	
	assign C = NZCV[1];  	
	assign V = NZCV[0];

	//NZCV UPDATE Related

	wire [1:0] updatetype;	
	wire [3:0] NZCV_temp;

	//OTHERS

	assign RD_OUT = RD_IN;
	assign Z_RESULT = Z_temp;
	assign VALIDRD_OUT = VALIDRD_IN;	

	//Choosing X

	MUX4to1 #(32) OPERTYPE_AND_X (
		.DI0	(EXE_DF1),
		.DI1	(EXE_DF2),
		.DI2	(MEM_DF),
		.DI3	(X),
		.SEL	(HZ_CTRLX),
		.DO		(X_alu)
	);

	//Choosing Y

	MUX4to1 #(32) OPERTYPE_AND_Y(
		.DI0	(EXE_DF1),
		.DI1	(EXE_DF2),
		.DI2	(MEM_DF),
		.DI3	(Y),
		.SEL	(HZ_CTRLY),
		.DO		(Y_alu)
	);

	//Choosing X or Y for special case

	assign XY_alu = (XY_SEL == 0) ? X_alu : Y_alu;

	//SHIFT

	shiftextract shiftertemp(
		.OPX	(XY_alu),
		.OPY	(SHAMT),
		.DIR	(sh_dir),
		.MUX_CTRL1	(sh_mux1),
		.MUX_CTRL2	(sh_mux2),
		.COUT		(C_shifter),
		.DOUT		(Z_shift)
	);

	//NZCV update

	NZCVupdater	NZCVup(
		.X			(X),
		.Y			(Y),
		.result		(Z_temp),
		.updatetype (updatetype),
		.NZCV		(NZCV),
		.NZCV_new	(NZCV_temp)
	);



	//SHIFT Related
	assign sh_dir = (OPTYPE == `TYPE_LSR) ? (1)		:		//TYPE_LSR
					((OPTYPE == `TYPE_ROR) ? (1)		:		//TYPE_ROR
					((OPTYPE == `TYPE_ASR) ? (1)		:		//TYPE_ASR
					0));								//TYPE_LSL, TYPE_BR, TYPE_BL

	assign sh_mux1 = (OPTYPE == `TYPE_LSR) ? (1)		:		//TYPE_LSR
					((OPTYPE == `TYPE_ROR) ? (1)		:		//TYPE_ROR
					((OPTYPE == `TYPE_ASR) ? (1)		:		//TYPE_ASR
					0));								//TYPE_LSL, TYPE_BR, TYPE_BL

	assign sh_mux2 = (OPTYPE == `TYPE_LSR) ? (4'b0001)	:		//TYPE_LSR
					((OPTYPE == `TYPE_ROR) ? (4'b1000)	:		//TYPE_ROR
					((OPTYPE == `TYPE_ASR) ? (4'b0100)	:		//TYPE_ASR
					((OPTYPE == `TYPE_LSL) ? (4'b0010)	: 4'bxxxx))); //TYPE_LSL

	//ALU except shift

	assign Z_alu = (OPTYPE == `TYPE_ADD) ? (X_alu + Y_alu) 	:		//TYPE_ADD
				  ((OPTYPE == `TYPE_SUB) ? (X_alu - Y_alu) 	:		//TYPE_SUB
				  ((OPTYPE == `TYPE_MUL) ? (X_alu * Y_alu)	:		//TYPE_MUL
				  ((OPTYPE == `TYPE_AND) ? (X_alu & Y_alu) 	:		//TYPE_AND
				  ((OPTYPE == `TYPE_OR)	? (X_alu | Y_alu) 	:		//TYPE_OR
				  ((OPTYPE == `TYPE_EOR) ? (X_alu ^ Y_alu) 	:		//TYPE_EOR
				  ((OPTYPE == `TYPE_NEG) ? (0-Y_alu) 		:		//TYPE_NEG
				  ((OPTYPE == `TYPE_MOV) ? (XY_alu)			:		//TYPE_MOV
				  ((OPTYPE == `TYPE_BIC) ? (X_alu & ~Y_alu)	: 		//TYPE_BIC
				  ((OPTYPE == `TYPE_NOT) ? (~Y_alu)			:		//TYPE_NOT
				  32'b0)))))))));

	//assign TYPE_BR_result = (OPTYPE == `TYPE_BR)	? (X_alu + Z_shift)	:		//TYPE_BR (SHAMT is 1)
	//				   ((OPTYPE == `TYPE_BL)	? (X_alu + Z_shift)	:		//TYPE_BL (SHAMT is either 1 or 12)
	//				   32'h00000000);

	//assign LR_result = (OPTYPE == `TYPE_BL) ? (LR_in | 1) : LR_in;	//Special case for TYPE_BL

	assign result_sel = (OPTYPE == `TYPE_ADD)  ? (1) 	:		//TYPE_ADD
						((OPTYPE == `TYPE_SUB) ? (1) 	:		//TYPE_SUB
						((OPTYPE == `TYPE_MUL) ? (1)		:		//TYPE_MUL
						((OPTYPE == `TYPE_AND) ? (1) 	:		//TYPE_AND
						((OPTYPE == `TYPE_OR)  ? (1) 	:		//TYPE_OR
						((OPTYPE == `TYPE_EOR) ? (1) 	:		//TYPE_EOR
						((OPTYPE == `TYPE_NEG) ? (1) 	:		//TYPE_NEG
						((OPTYPE == `TYPE_BR)  ? (1)		:		//TYPE_BR (SHAMT is 1)
						((OPTYPE == `TYPE_BL)  ? (1)		:		//TYPE_BL (SHAMT is either 1 or 12)
						((OPTYPE == `TYPE_MOV) ? (1)		:		//TYPE_MOV
						((OPTYPE == `TYPE_BIC) ? (1)		: 		//TYPE_BIC
						((OPTYPE == `TYPE_NOT) ? (1)		:		//TYPE_NOT
						0)))))))))));	//SHIFT OP

	//NZCV

	assign updatetype = (OPTYPE == `TYPE_ADD) ? 2'b10	:
					   ((OPTYPE == `TYPE_SUB) ? 2'b11	:
					   ((OPTYPE == `TYPE_MUL) ? 2'b01	:
					   ((OPTYPE == `TYPE_AND) ? 2'b01	:
					   ((OPTYPE == `TYPE_OR)	 ? 2'b01	:
					   ((OPTYPE == `TYPE_EOR) ? 2'b01	:
					   ((OPTYPE == `TYPE_NEG) ? 2'b01	:
					   ((OPTYPE == `TYPE_MOV) ? 2'b01	:
					   ((OPTYPE == `TYPE_BIC) ? 2'b01	:
				  	   ((OPTYPE == `TYPE_NOT) ? 2'b01	:
					   ((OPTYPE == `TYPE_LSL) ? 2'b01	:
					   ((OPTYPE == `TYPE_LSR) ? 2'b01	:
					   ((OPTYPE == `TYPE_ASR) ? 2'b01	:
					   ((OPTYPE == `TYPE_ROR) ? 2'b01	:
					   2'b00)))))))))))));	

	assign NZCVUPDATE[3:2] = NZCV_temp[3:2];
	assign NZCVUPDATE[1] = ((OPTYPE == `TYPE_LSR) ||
								(OPTYPE == `TYPE_ROR) ||
								(OPTYPE == `TYPE_ASR) ||
								(OPTYPE == `TYPE_LSL)) ? (C_shifter) : (NZCV_temp[1]);
	assign NZCVUPDATE[0] = NZCV_temp[0];


	//Selecting result

	assign Z_temp = (result_sel == 1) ? (Z_alu) : (Z_shift);
	



endmodule
