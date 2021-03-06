
`timescale 1ns / 10ps

module ARM_Thumb (
			CLK,
			RESET_N,		// reset when negative
			
			// For instruction memory
			IREQ,
			IADDR,
			IRW,
			INSTR,

			// For data memory
			DREQ,
			DADDR,
			DRW,
			DSIZE,
			DIN,
			DOUT
			);

	input		CLK;
	input		RESET_N;

	output	reg 	IREQ;
	output	reg     [31:0]	IADDR;
	output	reg 	IRW;
	input	wire     [31:0]	INSTR;

	output	reg 	DREQ;
	output	reg     [31:0]	DADDR;
	output	reg 	DRW;
	output	reg     [1:0]	DSIZE;
	input	wire     [31:0]	DIN;
	output	reg     [31:0]	DOUT;

    reg     [31:0]  instr;
    reg     [31:0]  data;
    reg             WE;
    reg             WAIT;

//---------------------------------------------------------------------------
//	internal signals
//---------------------------------------------------------------------------
// pipeline register enable signals

// before fetch 
wire			global_pc_en;
wire			global_inst_en;
wire			global_cpsr_en;

// after fetch
wire			pc2_fd_en;
wire			ir2_fd_en;

// after decode
wire			fwd_req_m_de_en;
wire			fwd_sel_x_de_en;
wire			fwd_sel_y_de_en;
wire			rf_ra_a_de_en;
wire			mem_w_en_de_en;
wire			mem_w_sel_de_en;
wire			mem_w_ld_nst_de_en;
wire			grf_z_de_en;
wire			grf_z_de_1d_en;
wire			op_x_de_en;
wire			op_y_de_en;
wire			shamt_de_en;
wire			optype_de_en;
wire			xy_sel_de_en;
wire			valid_z_de_en;

// after decode
wire			z_result_em_en;
wire			z_result_em_1d_en;
wire			validrd_out_em_en;
wire			validrd_out_em_1d_en;
wire			rd_out_em_en;
wire			rd_out_em_1d_en;
wire			mem_w_en_em_en;
wire			mem_w_sel_em_en;
wire			mem_w_ld_nst_em_en;
wire			fwd_req_m_em_en;

// after mem
wire			wb_din_mw_en;
wire			wb_a_mw_en;
wire			w_valid_mw_en;
wire			exe_d_mw_en;


// pipeline register data out signals
// before fetch 
wire 	[31:0]	global_pc;
wire 	[15:0]	global_inst;
wire 	[31:0]	global_cpsr;

// after fetch
wire 	[31:0] 	pc2_fd;
wire 	[15:0]	ir2_fd;

// after decode
wire			fwd_req_m_de;
wire 	[3:0]	fwd_sel_x_de;
wire 	[3:0]	fwd_sel_y_de;
wire 	[3:0]	rf_ra_a_de;
wire			mem_w_en_de;
wire 	[1:0]	mem_w_sel_de;
wire			mem_w_ld_nst_de;
wire 	[31:0]	grf_z_de;
wire 	[31:0] 	grf_z_de_1d;	
wire 	[31:0]	op_x_de;
wire 	[31:0]	op_y_de;
wire 	[7:0]	shamt_de;
wire 	[4:0]	optype_de;
wire			xy_sel_de;
wire			valid_z_de;

// after decode
wire 	[31:0] 	z_result_em;
wire 	[31:0] 	z_result_em_1d;
wire			validrd_out_em;
wire			validrd_out_em_1d;
wire 	[3:0] 	rd_out_em;	
wire 	[3:0] 	rd_out_em_1d;	
wire			mem_w_en_em;
wire 	[1:0] 	mem_w_sel_em;	
wire			mem_w_ld_nst_em;
wire			fwd_req_m_em;

// after mem
wire 	[31:0]	wb_din_mw;
wire 	[3:0]	wb_a_mw;
wire			w_valid_mw;
wire 	[31:0]	exe_d_mw;

// ///////

// IF_DP module signals
wire 	[31:0] 	pc1;
wire 	[15:0]	ir1;

// ID_CP module signals
wire 	[3:0] 	rf_ra_a;
wire 	[3:0] 	rf_ra_b;
wire 	[3:0] 	rf_ra_c;
wire 	   		pc_rel_sel;
wire 	[2:0]	rn_sel_cp;	
wire 	[2:0]	rm_sel_cp;
wire 	[6:0]	imm_sel_cp;
wire 	   		sign_ext_sel_cp;
wire 	[4:0]	sht_sel_cp;
wire 	[6:0]	operation_cp;
wire 	[4:0]	optype;
wire 			xy_sel;
wire 	   		valid_x;
wire 	   		valid_y;
wire 	   		valid_z;
wire 	  		mem_w_en;
wire 	[1:0]	mem_w_sel;
wire 	   		mem_w_ld_nst;

// ID_DP module signals
wire 	[31:0]	op_x;	
wire 	[31:0]	op_y;
wire 	[7:0]	sht_amount;
wire	[31:0]	pc_offset;

// HAZD module signals
wire 			fwd_req_m;	// need 1 stall
wire 	[3:0] 	fwd_sel_x;	
wire 	[3:0] 	fwd_sel_y;	

// EXEv2 module signals
wire 	[31:0] 	z_result;	
wire 	[3:0]	rd_out;
wire 	[3:0]	nzcvupdate;
wire 	   		validrd_out;

// MEM module signals
wire 			dreq_inv;	
wire			drnw;
wire 	[31:0] 	daddr;	
wire 	[1:0] 	dsize;	
wire 	[31:0] 	wdata;	
wire 	[3:0] 	wb_a;	
wire 			w_valid;	
wire 	[31:0] 	din;
wire 	[31:0]	exe_d;

// WB module signals
wire 	   		rf_wb_we;
wire 	[3:0]	rf_wb_addr;
wire 	[31:0]	rf_wb_data;

// regfile signals
wire 	[31:0]	grf_x;	
wire 	[31:0]	grf_y;
wire 	[31:0]	grf_z;

// IM, DM interface
reg				im_req_flag;
wire 	[15:0] 	pipe_inst;
wire 	[31:0]	nzcv_updated;
wire			dreq;

//---------------------------------------------------------------------------
//	IF stage
//---------------------------------------------------------------------------
PipeReg #(32) GLOBAL_PC(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (global_pc_en),
	.D   (pc1),
	.Q   (global_pc)
);

assign pipe_inst = (!im_req_flag)? instr[15:0] : instr[31:16];

PipeReg # (16) GLOBAL_INST(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (global_inst_en),
	//.D   (instr),
	.D   (pipe_inst),
	.Q   (global_inst)
);

PipeReg #(32) GLOBAL_CPSR(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (global_cpsr_en),
	.D   (nzcv_updated),
	.Q   (global_cpsr)
);


assign nzcv_updated = {nzcvupdate[3:0], global_cpsr[27:0]};

IF_DP if_dp(
	 .PC			(global_pc),
	 .INST			(global_inst), 

	 .PC_REL_SEL	(pc_rel_sel),
	 .PC_REL_OFFSET	(pc_offset),

	 .IF_PC			(pc1),
	 .FINST			(ir1)
);


//---------------------------------------------------------------------------
//	ID stage
//---------------------------------------------------------------------------
PipeReg #(32) PC2_FD(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (pc2_fd_en),
	.D   (pc1),
	.Q   (pc2_fd)
);


PipeReg #(16) IR2_FD(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (ir2_fd_en),
	.D   (ir1),
	.Q   (ir2_fd)
);


ID_CP id_cp(
	.INST			(ir2_fd),

	.CPSR			(global_cpsr),
	
	.RF_RD_ADDR		(rf_ra_a),
	.RF_RN_ADDR		(rf_ra_b),
	.RF_RM_ADDR		(rf_ra_c),

	.PC_REL_SEL		(pc_rel_sel),

	.RN_SEL_CP		(rn_sel_cp),
	.RM_SEL_CP		(rm_sel_cp),
	.IMM_SEL_CP		(imm_sel_cp),
	.SIGN_EXT_SEL_CP (sign_ext_sel_cp),
	.SHT_SEL_CP		(sht_sel_cp),

	.OPERATION_CP	(operation_cp),

	.OPTYPE			(optype),
	.XY_SEL			(xy_sel),

	.VALID_X		(valid_x),
	.VALID_Y		(valid_y),
	.VALID_Z		(valid_z),

	.MEM_W_EN		(mem_w_en),
	.MEM_W_SEL		(mem_w_sel),
	.MEM_W_LD_nST	(mem_w_ld_nst)
);

ID_DP id_dp(
	.INST			(ir2_fd),	
	.IF_PC			(pc2_fd),	

	.RF_RN			(grf_x),	
	.RF_RM			(grf_y),
	.RF_RD			(grf_z),

	.RN_SEL_DP		(rn_sel_cp),	
	.RM_SEL_DP		(rm_sel_cp),
	.IMM_SEL_DP		(imm_sel_cp),
	.SIGN_EXT_SEL_DP (sign_ext_sel_cp),
	.SHT_SEL_DP		(sht_sel_cp),

	.OPERATION_DP	(operation_cp),

	.OP_X			(op_x),	
	.OP_Y			(op_y),
	.SHT_AMONUT		(sht_amount),

	.PC_OFFSET		(pc_offset)
);

HAZD hazd(
	.D_RB		(rf_ra_b),	
	.D_RC		(rf_ra_c),	
	.D_VALID_B	(valid_x),	
	.D_VALID_C	(valid_y),	
	
	.E_RA1		(rd_out),	
	.E_RA2		(rd_out_em_1d),	
	.E_VALID1	(validrd_out),	
	.E_VALID2	(validrd_out_em_1d),	
	
 	.M_RA		(wb_a),	
	.M_VALID	(w_valid),	

	//.FWD_REQ_E	( ),	
	.FWD_REQ_M	(fwd_req_m),	// need 1 stall
	.FWD_SEL_X	(fwd_sel_x),	
	.FWD_SEL_Y	(fwd_sel_y)	
);

// make stall because harzard is detected


//---------------------------------------------------------------------------
//	EX stage
//---------------------------------------------------------------------------
PipeReg #(1) FWD_REQ_M_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (fwd_req_m_de_en),
	.D   (fwd_req_m),
	.Q   (fwd_req_m_de)
);


PipeReg #(4) FWD_SEL_X_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (fwd_sel_x_de_en),
	.D   (fwd_sel_x),
	.Q   (fwd_sel_x_de)
);


PipeReg #(4) FWD_SEL_Y_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (fwd_sel_y_de_en),
	.D   (fwd_sel_y),
	.Q   (fwd_sel_y_de)
);


PipeReg #(4) RF_RA_A_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (rf_ra_a_de_en),
	.D   (rf_ra_a),
	.Q   (rf_ra_a_de)
);


PipeReg #(1) MEM_W_EN_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_en_de_en),
	.D   (mem_w_en),
	.Q   (mem_w_en_de)
);


PipeReg #(2) MEM_W_SEL_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_sel_de_en),
	.D   (mem_w_sel),
	.Q   (mem_w_sel_de)
);


PipeReg #(1) MEM_W_LD_NST_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_ld_nst_de_en),
	.D   (mem_w_ld_nst),
	.Q   (mem_w_ld_nst_de)
);


PipeReg #(32) GRF_Z_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (grf_z_de_en),
	.D   (grf_z),
	.Q   (grf_z_de)
);


PipeReg #(32) GRF_Z_DE_1D(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (grf_z_de_1d_en),
	.D   (grf_z_de),
	.Q   (grf_z_de_1d)
);



PipeReg #(32) OP_X_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (op_x_de_en),
	.D   (op_x),
	.Q   (op_x_de)
);


PipeReg #(32) OP_Y_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (op_y_de_en),
	.D   (op_y),
	.Q   (op_y_de)
);


PipeReg #(8) SHAMT_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (shamt_de_en),
	.D   (sht_amount),
	.Q   (shamt_de)
);


PipeReg #(5) OPTYPE_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (optype_de_en),
	.D   (optype),
	.Q   (optype_de)
);

PipeReg #(1) XY_SEL_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (xy_sel_de_en),
	.D   (xy_sel),
	.Q   (xy_sel_de)
);

PipeReg #(1) VALID_Z_DE(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (valid_z_de_en),
	.D   (valid_z),
	.Q   (valid_z_de)
);

EXEv2 exev2(
	.X			(op_x_de)		,	//First operend
	.Y			(op_y_de)		,	//Second operend
	.RD_IN		(rf_ra_a_de)	,	//Destination register number
	//.LR_IN		(4'd14)   ,
	.SHAMT		(shamt_de)   ,
	.OPTYPE		(optype_de)   ,
	.XY_SEL		(xy_sel_de)   ,
	.VALIDRD_IN	(valid_z_de)   ,
	.NZCV		(global_cpsr[31:28])	,	//NZCV from CPSR Register[31:28]	
	.EXE_DF1	(z_result_em)	,//Data forwarded from EXE
	.EXE_DF2	(z_result_em_1d)	,//Data forwarded from EXE
	.MEM_DF		(exe_d_mw)	,//Data forwarded from MEM
	.HZ_CTRLX	(fwd_sel_x_de)	,//CS from hazard detection unit
	.HZ_CTRLY	(fwd_sel_y_de) ,
                     
	.Z_RESULT	(z_result)   ,
//	.LR_RESULT	()	 ,//BL instruction
	.RD_OUT		(rd_out)   ,
//	.BR_RESULT	()   ,
	.NZCVUPDATE	(nzcvupdate)   ,
	.VALIDRD_OUT(validrd_out) 
);

//---------------------------------------------------------------------------
//	MEM stage
//---------------------------------------------------------------------------

PipeReg #(32) Z_RESULT_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (z_result_em_en),
	.D   (z_result),
	.Q   (z_result_em)
);


PipeReg #(32) Z_RESULT_EM_1D(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (z_result_em_1d_en),
	.D   (z_result_em),
	.Q   (z_result_em_1d)
);


PipeReg #(1) VALIDRD_OUT_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (validrd_out_em_en),
	.D   (validrd_out),
	.Q   (validrd_out_em)
);


PipeReg #(1) VALIDRD_OUT_EM_1D(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (validrd_out_em_1d_en),
	.D   (validrd_out_em),
	.Q   (validrd_out_em_1d)
);


PipeReg #(4) RD_OUT_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (rd_out_em_en),
	.D   (rd_out),
	.Q   (rd_out_em)
);

PipeReg #(4) RD_OUT_EM_1D(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (rd_out_em_1d_en),
	.D   (rd_out_em),
	.Q   (rd_out_em_1d)
);

PipeReg #(1) MEM_W_EN_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_en_em_en),
	.D   (mem_w_en_de),
	.Q   (mem_w_en_em)
);

PipeReg #(2) MEM_W_SEL_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_sel_em_en),
	.D   (mem_w_sel_de),
	.Q   (mem_w_sel_em)
);

PipeReg #(1) MEM_W_LD_NST_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (mem_w_ld_nst_em_en),
	.D   (mem_w_ld_nst_de),
	.Q   (mem_w_ld_nst_em)
);

PipeReg #(1) FWD_REQ_M_EM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (fwd_req_m_em_en),
	.D   (fwd_req_m_de),
	.Q   (fwd_req_m_em)
);


MEM mem(
//from EXE
	.MEMACC		(mem_w_en_em),	
	.LDST		(mem_w_ld_nst_em),	
	.DATA_SIZE	(mem_w_sel_em),	

	.RESULT		(z_result),	
	.RD_A		(rd_out_em),	
	.RD			(grf_z_de_1d),	

	.FWD_REQ_FROM_HAZD (fwd_req_m_em),

	.DIN		(DOUT),	

	.REQ		(dreq_inv),	
	.DRW		(drnw),	
	.DADDR		(daddr),	
	.DSIZE		(dsize),	
	.DOUT		(wdata),	

	.WB_A		(wb_a),	
	.W_VALID	(w_valid),	
	.WB_D 		(din),

	.EXE_D		(exe_d)
);


assign  dreq = !dreq_inv;
assign  drnw = !drnw;

PipeReg #(32) WB_DIN_MW(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (wb_din_mw_en),
	.D   (din),
	.Q   (wb_din_mw)
);


PipeReg #(4) WB_A_MW(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (wb_a_mw_en),
	.D   (wb_a),
	.Q   (wb_a_mw)
);


PipeReg #(1) W_VALID_MW(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (w_valid_mw_en),
	.D   (w_valid),
	.Q   (w_valid_mw)
);

PipeReg #(32) EXE_D_MW(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (exe_d_mw_en),
	.D   (exe_d),
	.Q   (exe_d_mw)
);

//---------------------------------------------------------------------------
//	WB stage
//---------------------------------------------------------------------------
WB wb(
	.WB_DIN			(wb_din_mw),
	.WB_WE			(w_valid_mw),
	.WB_RADDR		(wb_a_mw),

	.RF_WB_WE		(rf_wb_we),
	.RF_WB_ADDR		(rf_wb_addr),
	.RF_WB_DATA		(rf_wb_data)
);

//---------------------------------------------------------------------------
//	IM, DM Memory access
//---------------------------------------------------------------------------

// Read from Instruction Memory
always @ (posedge CLK)  begin
    if(~RESET_N)    begin
        instr <= 32'b0;
        IREQ <= 1'b0;
        IADDR <= 32'b0;
        WAIT <= 1'b0;
        WE <= 1'b0;
		im_req_flag <= 1'b0;
    end 
    else    begin
        if(~IREQ)    begin
			if(im_req_flag) begin
				IREQ <= 1'b1;
				//IADDR <= IADDR + {29'b0, 3'b100};
				IADDR <= global_pc;
				WAIT <= 1'b1;
			end

			im_req_flag <= !im_req_flag;
        end
        else if(IREQ && WAIT)   begin
            WAIT <= 1'b0;
        end
        else    begin
            instr <= INSTR;
            IREQ <= 1'b0;
            WE <= 1'b1;
            #1;
        end
    end

end

//Write to Data Memory
always @ (posedge CLK)  begin

    if(~RESET_N)    begin
        data <= 32'b0;
        DADDR <= 32'b0;
        DRW <= 1'b0;
        DSIZE <= 2'b0;
        DOUT <= 32'b0;
    end
    else    begin
        if(WE && ~DREQ)  begin
            //DREQ <= 1'b1;
            DREQ <= dreq;
            DADDR <= DADDR + {29'b0, 3'b100};
            //DRW <= 1'b1;
            DRW <= drnw;
            DSIZE <= 2'b10;
            DOUT <= instr;
        end
        else    begin
            DREQ <= 1'b0;
        end
    end

end

RegFile16x32 regfile(
	.CLK	(CLK),	 
	.WEN_A	(rf_wb_we),
	//.WEN_B	( ),	
	.W_DA	(rf_wb_data),	
	//.W_DB	( ),	

	.RA_A	(rf_ra_a),	
	.RA_B	(rf_ra_b),	
	.RA_C	(rf_ra_c),	

	.WA_A	(rf_wb_addr),	
	//.WA_B	( ),	
	.GRF_X	(grf_x),	
	.GRF_Y	(grf_y),	
	.GRF_Z	(grf_z)
);

endmodule
