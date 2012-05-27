
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

wire RDOUT_BUFF0_EN;
wire RDOUT_BUFF1_EN;
wire MEM_W_EN_EX_EN;
wire MEM_W_SEL_EX_EN;
wire FWD_REQ_M_EX_EN;
wire WB_DIN_EN;
wire WB_A_DELAYED_EN;
wire WB_VAL_DELAYED_EN;
wire MEM_W_LD_ST_EX_EN;

wire VALID_BUFF1_EN;
wire VALID_BUFF0_EN;
wire EXE_DF_BUFF0_EN;
wire Z_RESULT_EN;
wire VALIDZ_EN;
wire OPTYPE_EX_EN;
wire SHAMT_EN;
wire Y_RESULT_EN;
wire X_RESULT_EN;
wire RD_BUFF1_EN;
wire RD_BUFF0_EN;
wire FWD_SEL_Y_ID_EN;
wire MEM_W_LD_ST_ID_EN;
wire MEM_W_EN_ID_EN;
wire RD_ADDR_EN;
wire MEM_W_SEL_ID_EN;
wire FWD_SEL_X_ID_EN;
wire FWD_REQ_M_ID_EN;
wire IR2_EN;
wire PC2_EN;
wire CPSR_REG_EN;
wire PRE_INST_EN;
wire PRE_PC_EN;

wire rdout_buff0;
wire rdout_buff1;
wire mem_w_ex;
wire wb_din;
wire wb_val_delayed;
wire mem_w_ld_st_ex;
wire validrd_out_temp;
wire exe_df_buff0;
wire validz;
wire [4:0] optype_id;
wire [7:0] sht_amount_id;
wire [31:0] grf_z_id;
wire mem_w_ld_st_id;
wire mem_w_id;
wire rd_addr;
wire [1:0] mem_w_sel_id;
wire fwd_req_m_id;
wire [31:0] pc1;
wire [31:0] pc2;
wire [31:0] cpsr_reg;
wire [15:0] pre_inst;
wire [31:0] pre_pc;




wire [31:0] nzcv_updated;
wire [3:0] nzcvupdate;
wire dreq;
wire drnw;

wire [31:0] exe_d;
wire [31:0] exe_d_mem;


wire [31:0] pc_offset;
wire [15:0] ir1;

wire [15:0]	ir2;
wire [31:0]	cpsr;
wire [3:0] 	rf_ra_a;
wire [3:0] 	rf_ra_b;
wire [3:0] 	rf_ra_c;
wire	pc_rel_sel;
wire 	xy_sel;
wire	valid_x;
wire	valid_y;
wire	valid_z;
wire	mem_w_en;
wire [1:0]	mem_w_sel;
wire	mem_w_ld_nst;

wire [31:0]	grf_x;	
wire [31:0]	grf_y;
wire [31:0]	grf_z;
wire [2:0]	rn_sel_cp;	
wire [2:0]	rm_sel_cp;
wire [6:0]	imm_sel_cp;
wire	sign_ext_sel_cp;
wire [4:0]	sht_sel_cp;
wire [6:0]	operation_cp;
wire [31:0]	op_x;	
wire [31:0]	op_y;
wire [7:0]	sht_amount;

wire [3:0] rn_addr;	
wire [3:0] rm_addr;	
wire [3:0] rd_out_delayed;	
wire validrd_out_delayed;	
wire w_valid;	

wire fwd_req_m;	// need 1 stall
wire [3:0] fwd_sel_x;	
wire [3:0] fwd_sel_y;	


wire [31:0]	op_x_id;
wire [31:0]	op_y_id;
wire [3:0]	rf_ra_a_id;
wire [4:0]	sht_amount_in;
wire [4:0]	optype;
wire	valid_z_id;
wire [31:0] 	z;
wire [31:0]	z_delayed;
wire [3:0]	fwd_sel_x_id;
wire [3:0]	fwd_sel_y_id;
wire [3:0]	rd_out;
wire	validrd_out;


wire mem_w_en_id;	
wire mem_w_en_ex;	
wire mem_w_ld_nst_ex;	
wire [1:0] mem_w_sel_ex;	
wire [31:0] z_result;	
wire [3:0] rd_out_temp;	
wire [31:0] grf_z_delayed;	
wire fwd_req_m_ex;
wire dreq_inv;	
wire [31:0] daddr;	
wire [1:0] dsize;	
wire [31:0] wdata;	
wire [3:0] wb_a;	
wire [31:0] din;

wire [31:0]	din_wb;
wire	w_valid_delayed;
wire [3:0]	wb_a_delayed;
wire	rf_wb_we;
wire [3:0]	rf_wb_addr;
wire [31:0]	rf_wb_data;

reg	im_req_flag;
wire [15:0] pipe_inst;

//---------------------------------------------------------------------------
//	IF stage
//---------------------------------------------------------------------------
PipeReg #(32) PRE_PC(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (PRE_PC_EN),
	.D   (pc1),
	.Q   (pre_pc)
);

assign pipe_inst = (!im_req_flag)? instr[15:0] : instr[31:16];

PipeReg # (16) PRE_INST(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (PRE_INST_EN),
	//.D   (instr),
	.D   (pipe_inst),
	.Q   (pre_inst)
);



PipeReg #(32) CPSR_REG(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (CPSR_REG_EN),
	.D   (nzcv_updated),
	.Q   (cpsr)
);


assign nzcv_updated = {nzcvupdate[3:0], cpsr[27:0]};

IF_DP if_dp(
	 .PC			(pre_pc),
	 .INST			(pre_inst), 

	 .PC_REL_SEL	(pc_rel_sel),
	 .PC_REL_OFFSET	(pc_offset),

	 .IF_PC			(pc1),
	 .FINST			(ir1)
);


//---------------------------------------------------------------------------
//	ID stage
//---------------------------------------------------------------------------
PipeReg #(32) PC2(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (PC2_EN),
	.D   (pc1),
	.Q   (pc2)
);


PipeReg #(16) IR2(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (IR2_EN),
	.D   (ir1),
	.Q   (ir2)
);


ID_CP id_cp(
	.INST			(ir2),

	.CPSR			(cpsr),
	
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
	.INST			(ir2),	
	.IF_PC			(pc2),	

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
	.D_RB		(rn_addr),	
	.D_RC		(rm_addr),	
	.D_VALID_B	(valid_x),	
	.D_VALID_C	(valid_y),	
	
	.E_RA1		(rd_out),	
	.E_RA2		(rd_out_delayed),	
	.E_VALID1	(validrd_out),	
	.E_VALID2	(validrd_out_delayed),	
	
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
PipeReg #(1) FWD_REQ_M_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (FWD_REQ_M_ID_EN),
	.D   (fwd_req_m),
	.Q   (fwd_req_m_id)
);



PipeReg #(4) FWD_SEL_X_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (FWD_SEL_X_ID_EN),
	.D   (fwd_sel_x),
	.Q   (fwd_sel_x_id)
);


PipeReg #(4) FWD_SEL_Y_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (FWD_SEL_Y_ID_EN),
	.D   (fwd_sel_y),
	.Q   (fwd_sel_y_id)
);



PipeReg #(4) RD_ADDR(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (RD_ADDR_EN),
	.D   (rf_ra_a),
	.Q   (rf_ra_a_id)
);



PipeReg #(1) MEM_W_EN_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_EN_ID_EN),
	.D   (mem_w_en),
	.Q   (mem_w_en_id)
);


PipeReg #(2) MEM_W_SEL_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_SEL_ID_EN),
	.D   (mem_w_sel),
	.Q   (mem_w_sel_id)
);


PipeReg #(1) MEM_W_LD_ST_ID(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_LD_ST_ID_EN),
	.D   (mem_w_ld_nst),
	.Q   (mem_w_ld_nst_id)
);


PipeReg #(	 32) RD_BUFF0(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (RD_BUFF0_EN),
	.D   (grf_z),
	.Q   (grf_z_id)
);


PipeReg #(	 32) RD_BUFF1(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (RD_BUFF1_EN),
	.D   (grf_z_id),
	.Q   (grf_z_delayed)
);



PipeReg #(	 32) X_RESULT(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (X_RESULT_EN),
	.D   (op_x),
	.Q   (op_x_id)
);


PipeReg #(	 32) Y_RESULT(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (Y_RESULT_EN),
	.D   (op_y),
	.Q   (op_y_id)
);


PipeReg #(8) SHAMT(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (SHAMT_EN),
	.D   (sht_amount),
	.Q   (sht_amount_id)
);


PipeReg #(5) OPTYPE_EX(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (OPTYPE_EX_EN),
	.D   (optype),
	.Q   (optype_id)
);



PipeReg #(1) VALIDZ(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (VALIDZ_EN),
	.D   (valid_z),
	.Q   (valid_z_id)
);



EXEv2 exev2(
	.X			(op_x_id)		,	//First operend
	.Y			(op_y_id)		,	//Second operend
	.RD_IN		(rf_ra_a_id)	,	//Destination register number
	//.LR_IN		(4'd14)   ,
	.SHAMT		(sht_amount_in)   ,
	.OPTYPE		(optype)   ,
	.XY_SEL		(xy_sel)   ,
	.VALIDRD_IN	(valid_z_id)   ,
	.NZCV		(cpsr[31:28])	,	//NZCV from CPSR[31:28]	
	.EXE_DF1	(z)	,//Data forwarded from EXE
	.EXE_DF2	(z_delayed)	,//Data forwarded from EXE
	.MEM_DF		(exe_d_mem)	,//Data forwarded from MEM
	.HZ_CTRLX	(fwd_sel_x_id)	,//CS from hazard detection unit
	.HZ_CTRLY	(fwd_sel_y_id) ,
                     
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

PipeReg #(32) Z_RESULT(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (Z_RESULT_EN),
	.D   (z_result),
	.Q   (z)
);


PipeReg #(32) EXE_DF_BUFF0(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (EXE_DF_BUFF0_EN),
	.D   (z),
	.Q   (z_delayed)
);


PipeReg #(1) VALID_BUFF0(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (VALID_BUFF0_EN),
	.D   (validrd_out),
	.Q   (validrd_out_temp)
);


PipeReg #(1) VALID_BUFF1(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (VALID_BUFF1_EN),
	.D   (validrd_out_temp),
	.Q   (validrd_out_delayed)
);


PipeReg #(4) RDOUT_BUFF0(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (RDOUT_BUFF0_EN),
	.D   (rd_out),
	.Q   (rd_out_temp)
);

PipeReg #(4) RDOUT_BUFF1(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (RDOUT_BUFF1_EN),
	.D   (rd_out_temp),
	.Q   (rd_out_delayed)
);

PipeReg #(1) MEM_W_EN_EX(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_EN_EX_EN),
	.D   (mem_w_en_id),
	.Q   (mem_w_en_ex)
);

PipeReg #(2) MEM_W_SEL_EX(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_SEL_EX_EN),
	.D   (mem_w_sel_id),
	.Q   (mem_w_sel_ex)
);

PipeReg #(1) MEM_W_LD_ST_EX(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (MEM_W_LD_ST_EX_EN),
	.D   (mem_w_ld_nst_id),
	.Q   (mem_w_ld_nst_ex)
);

PipeReg #(1) FWD_REQ_M_EX(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (FWD_REQ_M_EX_EN),
	.D   (fwd_req_m_id),
	.Q   (fwd_req_m_ex)
);


MEM mem(
//from EXE
	.MEMACC		(mem_w_en_ex),	
	.LDST		(mem_w_ld_nst_ex),	
	.DATA_SIZE	(mem_w_sel_ex),	

	.RESULT		(z_result),	
	.RD_A		(rd_out_temp),	
	.RD			(grf_z_delayed),	

	.FWD_REQ_FROM_HAZD (fwd_req_m_ex),

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

PipeReg #(32) WB_DIN(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (WB_DIN_EN),
	.D   (din),
	.Q   (din_wb)
);


PipeReg #(4) WB_A_DELAYED(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (WB_A_DELAYED_EN),
	.D   (wb_a),
	.Q   (wb_a_delayed)
);


PipeReg #(1) WB_VAL_DELAYED(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (WB_VAL_DELAYED_EN),
	.D   (w_valid),
	.Q   (w_valid_delayed)
);

PipeReg #(32) EXE_D_MEM(
	.CLK (CLK),
	.RST (~RESET_N),
	.EN  (EXE_D_MEM_EN),
	.D   (exe_d),
	.Q   (exe_d_mem)
);


//---------------------------------------------------------------------------
//	WB stage
//---------------------------------------------------------------------------
WB wb(
	.WB_DIN			(din_wb),
	.WB_WE			(w_valid_delayed),
	.WB_RADDR		(wb_a_delayed),

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
				IADDR <= pre_pc;
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
