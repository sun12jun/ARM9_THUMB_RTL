/********************************************************************************
 *																				*
 *		ID_CP.v  Ver 0.1													*
 *																				*
 *		Designed by	Yoon Dong Joon                                              *
 *																				*
 ********************************************************************************
 *																				*
 *		Support Verilog 2001 Syntax												*
 *																				*
 *		Update history : 2012.05.24	 original authored (Ver.0.1)				*
 *                  															*
 *		instruction decode control path					                        *
 *																				*
 ********************************************************************************/	

`timescale 1ns / 10ps
`include "./ARM_THUMB_defines.v"

module ID_CP(
	//---------------------------------------------------------------------------
	//	instruction from pipeline register(IR2)
	//---------------------------------------------------------------------------
	input wire	[15:0]	INST,

	//---------------------------------------------------------------------------
	//	CPSR
	//---------------------------------------------------------------------------
	input wire	[31:0]	CPSR,

	//---------------------------------------------------------------------------
	//	condition check for branch
	//---------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------
	//	register file address signals
	//---------------------------------------------------------------------------
	output wire	[3:0]	RF_RD_ADDR,
	output wire	[3:0]	RF_RN_ADDR,
	output wire	[3:0]	RF_RM_ADDR,

	//---------------------------------------------------------------------------
	//	output control signals(for fetch datapath)
	//---------------------------------------------------------------------------
	output wire			PC_REL_SEL,
	//---------------------------------------------------------------------------
	//	output control signals(for Decode datapath)
	//---------------------------------------------------------------------------
	output wire	[2:0]	RN_SEL_CP,
	output wire	[2:0]	RM_SEL_CP,
	output wire	[6:0]	IMM_SEL_CP,
	output wire			SIGN_EXT_SEL_CP,
	output wire	[4:0]	SHT_SEL_CP,

	output wire	[6:0]	OPERATION_CP, 

	//---------------------------------------------------------------------------
	//	output control signals(for execution)
	//---------------------------------------------------------------------------
	output wire	[4:0]	OPTYPE,
	output wire			XY_SEL,

	//---------------------------------------------------------------------------
	//	output control signals(for hazard detection)
	//---------------------------------------------------------------------------
	output wire VALID_X,
	output wire VALID_Y,
	output wire VALID_Z,

	//---------------------------------------------------------------------------
	//	output control signals(for memory write)
	//---------------------------------------------------------------------------
	output wire			MEM_W_EN,
	output wire	[1:0]	MEM_W_SEL,
	output wire			MEM_W_LD_nST
);

//-------------------------------------------------------------------------------
//	internal signals
//-------------------------------------------------------------------------------
wire	[2:0]	opidx0;
wire	[6:0]	opidx1a;
wire	[6:0]	opidx1b;
wire	[6:0]	opidx1c;
wire	[6:0]	opidx1d;
wire	[6:0]	opidx2;

wire	[6:0]	operation;

wire	[4:0]	rn_addr;
wire	[4:0]	rm_addr;
wire	[4:0]	rd_addr;
wire	[4:0]	rs_addr;

wire	[7:0]	opkind;
wire			pc_op;
wire		 	sp_op;
wire		 	br_al_op;
wire		 	br_con_op;
wire		 	rd_op;
wire		 	ld_op;	
wire		 	st_op;	
wire		 	ld_st_op; 

wire			br_cond_true;

//-------------------------------------------------------------------------------
//	opcode decode
//-------------------------------------------------------------------------------
assign opidx0 = INST[15:13];

assign opidx1a = (opidx0==3'd0)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd1)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd2)? INST[12:6]	 : 7'd0;
assign opidx1a = (opidx0==3'd3)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd4)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd5)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd6)? INST[12:11] : 7'd0;
assign opidx1a = (opidx0==3'd7)? INST[12:11] : 7'd0;

assign opidx1b = (opidx0==3'd0)? INST[12:9] : 7'd0;
assign opidx1b = (opidx0==3'd2)? INST[12:8] : 7'd0;
assign opidx1b = (opidx0==3'd5)? INST[12:7] : 7'd0;
assign opidx1b = (opidx0==3'd6)? INST[12] : 7'd0;

assign opidx1c = (opidx0==3'd2)? INST[12:11] : 7'd0;
assign opidx1c = (opidx0==3'd5)? INST[12:9] : 7'd0;

assign opidx1d = (opidx0==3'd2)? INST[12:9] : 7'd0;

assign opidx2 = (opidx0==3'd0)? INST[8:6] : 7'd0;

assign operation = ( (opidx0==3'd0) && (opidx1a==7'h0) )?					 `LSL1 : 
				   ( (opidx0==3'd0) && (opidx1a==7'h1) )?					 `LSR1 : 
				   ( (opidx0==3'd0) && (opidx1a==7'h2) )?					 `ASR1 : 
				   ( (opidx0==3'd0) && (opidx1b==7'hc) )?					 `ADD3 : 
				   ( (opidx0==3'd0) && (opidx1b==7'hd) )?					 `SUB3 : 
				   ( (opidx0==3'd0) && (opidx1b==7'he) && (opidx2==7'd0) )?  `MOV2 : 
				   ( (opidx0==3'd0) && (opidx1b==7'he) && !(opidx2==7'd0) )? `ADD1 : 
				   ( (opidx0==3'd0) && (opidx1b==7'hf) )?					 `SUB1 : 

				   ( (opidx0==3'd1) && (opidx1a==7'h0) )?					 `MOV1 : 
				   ( (opidx0==3'd1) && (opidx1a==7'h1) )?					 `CMP1 : 
				   ( (opidx0==3'd1) && (opidx1a==7'h2) )?					 `ADD2 : 
				   ( (opidx0==3'd1) && (opidx1a==7'h3) )?					 `SUB2 : 

				   ( (opidx0==3'd2) && (opidx1a==7'h0) )?					 `AND  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h1) )?					 `EOR  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h2) )?					 `LSL2 : 
				   ( (opidx0==3'd2) && (opidx1a==7'h3) )?					 `LSR2 : 
				   ( (opidx0==3'd2) && (opidx1a==7'h4) )?					 `ASR2 : 
				   ( (opidx0==3'd2) && (opidx1a==7'h5) )?					 `ADC  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h6) )?					 `SBC  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h7) )?					 `ROR  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h8) )?					 `TST  : 
				   ( (opidx0==3'd2) && (opidx1a==7'h9) )?					 `NEG  : 
				   ( (opidx0==3'd2) && (opidx1a==7'ha) )?					 `CMP2 : 
				   ( (opidx0==3'd2) && (opidx1a==7'hb) )?					 `CMN  : 
				   ( (opidx0==3'd2) && (opidx1a==7'hc) )?					 `ORR  : 
				   ( (opidx0==3'd2) && (opidx1a==7'hd) )?					 `MUL  : 
				   ( (opidx0==3'd2) && (opidx1a==7'he) )?					 `BIC  : 
				   ( (opidx0==3'd2) && (opidx1a==7'hf) )?					 `MVN  : 
				   ( (opidx0==3'd2) && (opidx1b==7'h4) )?					 `ADD4 : 
				   ( (opidx0==3'd2) && (opidx1b==7'h5) )?					 `CMP3 : 
				   ( (opidx0==3'd2) && (opidx1b==7'h6) )?					 `MOV3 : 
				   ( (opidx0==3'd2) && (opidx1c==7'h1) )?					 `LDR3 : 
				   ( (opidx0==3'd2) && (opidx1d==7'h8) )?					 `STR2 : 
				   ( (opidx0==3'd2) && (opidx1d==7'h9) )?					 `STRH2: 
				   ( (opidx0==3'd2) && (opidx1d==7'ha) )?					 `STRB2: 
				   ( (opidx0==3'd2) && (opidx1d==7'hb) )?					 `LDRSB: 
				   ( (opidx0==3'd2) && (opidx1d==7'hc) )?					 `LDR2 : 
				   ( (opidx0==3'd2) && (opidx1d==7'hd) )?					 `LDRH2: 
				   ( (opidx0==3'd2) && (opidx1d==7'he) )?					 `LDRB2: 
				   ( (opidx0==3'd2) && (opidx1d==7'hf) )?					 `LDRSH: 

				   ( (opidx0==3'd3) && (opidx1a==7'h0) )?					 `STR1 : 
				   ( (opidx0==3'd3) && (opidx1a==7'h1) )?					 `LDR1 : 
				   ( (opidx0==3'd3) && (opidx1a==7'h2) )?					 `STRB1: 
				   ( (opidx0==3'd3) && (opidx1a==7'h3) )?					 `LDRB1: 

				   ( (opidx0==3'd4) && (opidx1a==7'h0) )?					 `STRH1: 
				   ( (opidx0==3'd4) && (opidx1a==7'h1) )?					 `LDRH1: 
				   ( (opidx0==3'd4) && (opidx1a==7'h2) )?					 `STR3 : 
				   ( (opidx0==3'd4) && (opidx1a==7'h3) )?					 `LDR4 :

				   ( (opidx0==3'd5) && (opidx1a==7'h0) )?  					 `ADD5 :
				   ( (opidx0==3'd5) && (opidx1a==7'h1) )?  					 `ADD6 :
				   ( (opidx0==3'd5) && (opidx1b==7'h20) )? 					 `ADD7 :
				   ( (opidx0==3'd5) && (opidx1b==7'h21) )? 					 `SUB4 :
				   ( (opidx0==3'd5) && (opidx1c==7'ha) )?  					 `PUSH :
				   ( (opidx0==3'd5) && (opidx1c==7'he) )?  					 `POP  :
				   ( (opidx0==3'd5) && (opidx1c==7'hf) )?  					 `BKPT :

				   ( (opidx0==3'd6) && (opidx1a==7'h0) )?  					 `STMIA :
				   ( (opidx0==3'd6) && (opidx1a==7'h1) )?  					 `LDMIA :
				   ( (opidx0==3'd6) && (opidx1b==7'h1) )?  					 `B1	:

				   ( (opidx0==3'd7) && (opidx1a==7'h0) )?  					 `B2	:
				   ( (opidx0==3'd7) && (opidx1a==7'h1) )?  					 `BLX   :
				   ( (opidx0==3'd7) && (opidx1a==7'h2) )?  					 `BL_H2 :
				   ( (opidx0==3'd7) && (opidx1a==7'h3) )?  					 `BL_H3 :	`NOP;

//-------------------------------------------------------------------------------
//	to Register File
//-------------------------------------------------------------------------------
assign rn_addr = ( (operation==`ADD3) || (operation==`SUB3) )?							INST[5:3]	:
				 ( (operation==`MOV2) )?												INST[5:3]	:
				 ( (operation==`SUB1) )?												INST[5:3]	:
				 ( (operation==`CMP1) )?												INST[10:8]	:
				 ( (operation==`TST) )?													INST[2:0]	:
				 ( (operation==`CMP3) )?							  		 			{INST[7], INST[2:0]}	:
				 ( (operation==`STR2) || (operation==`STRH2)|| (operation==`STRB2) ||
				   (operation==`LDRSB)|| (operation==`LDR2) || (operation==`LDRH2) ||
				   (operation==`LDRB2)|| (operation==`LDRSH)|| (operation==`STR1)  ||
				   (operation==`LDR1) || (operation==`STRB1)|| (operation==`LDRB1) ||
				   (operation==`STRH1)|| (operation==`LDRH1) )?							INST[5:3]	:
				 ( (operation==`LDMIA)|| (operation==`STMIA) )?							INST[10:8]	: `ADDR_NONE;
				 //( (operation==`STR3) || (operation==`LDR4) || (operation==`ADD6) ||
				  // (operation==`ADD7) || (operation==`SUB4) )?							5'd14		: `ADDR_NONE;

assign rm_addr = ( (operation==`LSL1) || (operation==`LSR1) || (operation==`ASR1) ||
				   (operation==`ADD1) || (operation==`AND)  || (operation==`EOR)  ||
				   (operation==`ADC)  || (operation==`SBC)  || (operation==`TST)  ||
				   (operation==`NEG)  || (operation==`CMP2) || (operation==`CMN)  ||
				   (operation==`ORR)  || (operation==`MUL)  || (operation==`BIC)  ||
				   (operation==`MVN) )?													INST[5:3]	:
				 ( (operation==`CMP3) || (operation==`MOV3) || (operation==`ADD4) )? 	{INST[6], INST[5:3]}	:
				 ( (operation==`LDR3) )?		 					 					INST[10:8]	:
				 ( (operation==`STR2) || (operation==`STRH2) || (operation==`STRB2) || 
				   (operation==`LDRSB) || (operation==`LDR2) || (operation==`LDRH2) || 
				   (operation==`LDRB2) || (operation==`LDRSH) )? 						INST[8:6]	: `ADDR_NONE;

assign rs_addr = ( (operation==`LSL2) || (operation==`LSR2) || (operation==`ASR2) ||
				   (operation==`ROR) )? 												INST[5:3]	: `ADDR_NONE;

assign rd_addr = ( (operation==`LSL1) || (operation==`LSR1) || (operation==`ASR1) ||
				   (operation==`ADD3) || (operation==`SUB3) || (operation==`MOV2) ||
				   (operation==`ADD1) || (operation==`SUB1) )?							INST[2:0]	:
				 ( (operation==`MOV1) || (operation==`ADD2) || (operation==`SUB2) )? 	INST[10:8]	:
				 ( (operation==`AND)  || (operation==`EOR)  || (operation==`LSL2) ||
				   (operation==`LSR2) || (operation==`ASR2) || (operation==`ADC)  ||
				   (operation==`SBC)  || (operation==`ROR)  || (operation==`NEG)  ||
				   (operation==`CMP2) || (operation==`CMN)  || (operation==`ORR)  ||
				   (operation==`MUL)  || (operation==`BIC)  || (operation==`MVN) )? 	INST[10:8]	:
				 ( (operation==`MOV3) || (operation==`ADD4) || (operation==`STR2) || 
				   (operation==`STRH2)|| (operation==`STRB2)|| (operation==`LDRSB)|| 
				   (operation==`LDR2) || (operation==`LDRH2)|| (operation==`LDRB2)|| 
				   (operation==`LDRSH)|| (operation==`STR1) || (operation==`LDR1) || 
				   (operation==`STRB1)|| (operation==`LDRB1)|| (operation==`STRH1)|| 
				   (operation==`LDRH1) )?												INST[2:0]	:
				 ( (operation==`STR3) || (operation==`LDR4) || (operation==`ADD5) || 
				   (operation==`ADD6) )?												INST[10:8]	: `ADDR_NONE;

assign pc_op	= ( (operation==`LDR3) || (operation==`ADD5) )? 1'b1 : 1'b0;
assign sp_op	= ( (operation==`STR3) || (operation==`LDR4) || (operation==`ADD6) ||
					(operation==`ADD7) || (operation==`SUB4) )?							1'b1 : 1'b0;
assign br_al_op	= ( (operation==`B2) || (operation==`BLX) || (operation==`BL_H2) ||
					(operation==`BL_H3) )?											    1'b1 : 1'b0;
assign br_con_op= ( (operation==`B1) )? 												1'b1 : 1'b0;
assign rd_op	= ( (operation==`ADD2) || (operation==`SUB2) || (operation==`AND) ||
					(operation==`EOR)  || (operation==`LSL2) || (operation==`ASR2) ||
				   	(operation==`ADC)  || (operation==`SBC)  || (operation==`ROR) )? 	1'b1 : 1'b0;

assign ld_op	= ( (operation==`LDRB1) || (operation==`LDRB2) || (operation==`LDRSB) ||
					(operation==`LDRH1) || (operation==`LDRH2) || (operation==`LDRSH) ||
					(operation==`LDR1)  || (operation==`LDR2)  || (operation==`LDR3)  ||
					(operation==`LDR4)  )?											1'b1: 1'b0;

assign st_op	= ( (operation==`STRB1) || (operation==`STRB2) || (operation==`STRH1) ||
					(operation==`STRH2) || (operation==`STR1)  || (operation==`STR2)  ||
					(operation==`STR3) )? 						                        1'b1: 1'b0;

assign ld_st_op = (ld_op || st_op);

assign opkind = {pc_op, sp_op, br_al_op, br_con_op, rd_op, ld_op, st_op, ld_st_op};

//assign RF_RD_ADDR = (rd_addr != `ADDR_NONE)? rd_addr[3:0] : 4'd0;
//assign RF_RN_ADDR = (rn_addr != `ADDR_NONE)? rn_addr[3:0] : 4'd0;
//assign RF_RM_ADDR = ( (rs_addr != `ADDR_NONE) && (rn_addr==`ADDR_NONE) && (rm_addr==`ADDR_NONE) )? rs_addr[3:0] : rm_addr[3:0];

assign RF_RD_ADDR = (rd_addr != `ADDR_NONE)? rd_addr[3:0] : 4'd0;
assign RF_RN_ADDR = ( (rn_addr != `ADDR_NONE) && sp_op )? 4'd13 : rn_addr[3:0];
assign RF_RM_ADDR = ( (rs_addr != `ADDR_NONE) && (rn_addr==`ADDR_NONE) && (rm_addr==`ADDR_NONE) )? rs_addr[3:0] : rm_addr[3:0];

//-------------------------------------------------------------------------------
//	make selection signals
//-------------------------------------------------------------------------------
// X operand for Execution
assign RN_SEL_CP = (pc_op)? 3'b001 :
				   (rd_op)? 3'b010 : 3'b100;

// Y operand for Execution
assign RM_SEL_CP = (IMM_SEL_CP != 7'h0)? 3'b001 : 3'b010;

// shift amount selection
assign SHT_SEL_CP = ( (operation==`LSL1) || (operation==`LSR1) || (operation==`ASR1) )?						5'b00001 :
				 ( (operation==`LSL2) || (operation==`LSR2) || (operation==`ASR2) || (operation==`ROR) )?	5'b00010 :
				 ( (operation==`BL_H2) )?																	5'b00100 :
				 ( (operation==`ADD5) || (operation==`ADD6) || (operation==`LDR1) || (operation==`LDR3) ||
				   (operation==`LDR4) || (operation==`STR1) || (operation==`STR3) || (operation==`SUB4) )?	5'b01000 :
				 ( (operation==`B1)	  || (operation==`B2)   || (operation==`LDRH1)|| (operation==`STRH1) )? 5'b10000 : 5'b00000;

// immediate selection bit 0: imm3, 1: imm5, 2: imm7, 3: imm8, 4: imm8s,
//						   5: imm11, 6: imm11s
assign IMM_SEL_CP = ( (operation==`ADD1) || (operation==`SUB1) )?							7'b0000001 :
				 ( (operation==`LSL1) || (operation==`LSR1) || (operation==`ASR1)  ||
				   (operation==`STR1) || (operation==`LDR1) || (operation==`STRB1) ||
				   (operation==`LDRB1)|| (operation==`STRH1)|| (operation==`LDRH1) )?	7'b0000010 :
				 ( (operation==`ADD7) || (operation==`SUB4) )?					 		7'b0000100 :
				 ( (operation==`MOV1) || (operation==`CMP1) || (operation==`ADD2) ||
				   (operation==`SUB2) || (operation==`LDR3) || (operation==`STR3) ||
				   (operation==`LDR4) || (operation==`ADD5) || (operation==`ADD6) ||
				   (operation==`BKPT) )?										 		7'b0001000 :
				 ( (operation==`B1) )?										 	 		7'b0010000 :
				 ( (operation==`BLX) || (operation==`BL_H2) || (operation==`BL_H3) )? 	7'b0100000 :
				 ( (operation==`B2) )?										 	 		7'b1000000 : 7'b0000000;

assign SIGN_EXT_SEL_CP = ( (operation==`LDRSB) || (operation==`LDRSH) || (operation==`B1) || (operation==`B2) || (operation==`BL_H2) )? 1'b1 : 1'b0;

assign MEM_W_EN = (ld_st_op)? 1'b1: 1'b0;

assign MEM_W_LD_nST = (ld_op)? 1'b1: 1'b0;

// memory read, write width  1 : 1byte 2: 2byte 3 : 4byte 0: none
assign MEM_W_SEL = ( (operation==`LDRB1) || (operation==`LDRB2) || (operation==`LDRSB) || (operation==`STRB1) || (operation==`STRB2) )? 2'd1 :
			   	   ( (operation==`LDRH1) || (operation==`LDRH2) || (operation==`LDRSH) || (operation==`STRH1) || (operation==`STRH2) )? 2'd2 : 2'd3;

assign OPTYPE = ( (operation==`LSL1) || (operation==`LSR1) || (operation==`ASR1) || (operation==`BL_H2)||
				  (operation==`ADD5) || (operation==`ADD6) || (operation==`LDR1) || (operation==`LDR3) ||
				  (operation==`LDR4) || (operation==`STR1) || (operation==`STR3) || (operation==`SUB4) ||
				  (operation==`B1)	 || (operation==`B2)   || (operation==`LDRH1)|| (operation==`STRH1) )?	`TYPE_LSL :
				( (operation==`LSL2) || (operation==`LSR2) || (operation==`ASR2) || (operation==`ROR) )?	`TYPE_LSR :
				( (operation==`ROR) )?																		`TYPE_ROR :
				( (operation==`ASR1) || (operation==`ASR2) )?												`TYPE_ASR :
				( (operation==`AND)  || (operation==`TST) )?												`TYPE_AND :
				( (operation==`ORR) )?																		`TYPE_OR  :
				( (operation==`EOR) )?																		`TYPE_EOR :
				( (operation==`NEG) )?																		`TYPE_NEG :
				( (operation==`NEG) )?																		`TYPE_NEG :
				( (operation==`ADC)  || (operation==`ADD1) || (operation==`ADD2) || (operation==`ADD3) || 
				  (operation==`ADD4) || (operation==`ADD5) || (operation==`ADD6) || (operation==`ADD7) || 
				  (operation==`CMN)	 || (operation==`LDRB1)|| (operation==`LDRB2)|| (operation==`LDRSB)|| 
				  (operation==`STRB1)|| (operation==`STRB2)|| (operation==`LDRH1)|| (operation==`LDRH2)|| 
				  (operation==`LDRSH)|| (operation==`STRH1)|| (operation==`STRH2)|| (operation==`LDR1) || 
				  (operation==`LDR2) || (operation==`LDR3) || (operation==`LDR4) || (operation==`STR1) || 
				  (operation==`STR2) || (operation==`STR3) )?													`TYPE_ADD : 
				( (operation==`CMP1) || (operation==`CMP3) || (operation==`SBC)  || (operation==`SUB1) || 
				  (operation==`SUB2) || (operation==`SUB3) || (operation==`SUB4) )?							`TYPE_SUB :
				( (operation==`MUL) )?																		`TYPE_MUL :
				( (operation==`B1)   || (operation==`B2) )? 												`TYPE_BR  :
				( (operation==`BLX)  || (operation==`BL_H2)|| (operation==`BL_H3) )?						`TYPE_BL  :
				( (operation==`MOV1) || (operation==`MOV2) || (operation==`MOV3) )?							`TYPE_MOV :
				( (operation==`MVN) )?																		`TYPE_NOT : `TYPE_NOP;

//-------------------------------------------------------------------------------
//	branch condition check
//-------------------------------------------------------------------------------
COND BR_COND(
	.IR			(INST),
	.CPSR		(CPSR),

	.COND_TRUE	(br_cond_true)
);


assign OPERATION_CP = operation;
assign PC_REL_SEL = ( (br_cond_true && br_con_op) || br_al_op );

assign XY_SEL = (operation==`MOV1 || operation==`MOV3 || operation==`LSL1 || operation==`LSR1 || operation==`ASR1 )? 1'b1 :
				(operation==`MOV2 || operation==`LSL2 || operation==`LSR2 || operation==`ASR2 || operation==`ROR )? 1'b0 : 1'b0; 

assign VALID_X = (RN_SEL_CP==3'b001)? 1'b0 : 1'b1;
assign VALID_Y = (RM_SEL_CP==3'b001)? 1'b0 : 1'b1;

assign VALID_Z = (st_op || br_al_op || (br_cond_true && br_con_op) ||
   			     (operation==`TST) || (operation==`CMP1) || (operation==`CMP2) ||
   			     (operation==`CMP3) || (operation==`CMN) )? 1'b0 : 1'b1;
				

endmodule
