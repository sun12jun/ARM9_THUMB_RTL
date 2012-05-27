module MEM (
//from EXE
	input wire MEMACC, 
	input wire LDST, // 1:LD 0:ST
	input wire [1:0] DATA_SIZE, // 01 : 8bit(B), 10 : 16bit(H), 11 : 32bit, 00 : error

	input wire [31:0] RESULT,
	input wire [3:0]  RD_A,
	input wire [31:0] RD,

//from HAZD
	input wire FWD_REQ_FROM_HAZD,

//from DM 
	input wire [31:0] DIN,

//to DMEM
	output wire REQ,
	output wire DRW,
	output wire [31:0]DADDR,
	output wire [1:0]DSIZE,
	output wire [31:0]DOUT,
//to WB or to HAZD
	output wire [3:0]WB_A,
	output wire W_VALID,
	output wire [31:0]WB_D,

	output wire [31:0] EXE_D	
);


wire [31:0]  addr_b = {24'b0, RESULT[7:0]} ;
wire [31:0]  addr_h = {16'b0, RESULT[15:0]};
wire [31:0]  addr   = RESULT[31:0];

wire [31:0] rdData_b = {24'b0,RD[7:0]} ;
wire [31:0] rdData_h = {16'b0,RD[15:0]};
wire [31:0] rdData   = RD[31:0];

assign REQ   = (MEMACC == 1)? 1 : 0; 
assign DRW	 = (LDST == 1)?	  1 : 0; // 1: READ, 0: WRITE
assign DADDR = (DATA_SIZE == 2'b01)? addr_b : ((DATA_SIZE == 2'b10)? addr_h : addr);
assign DOUT  = (DATA_SIZE == 2'b01)? rdData_b : ((DATA_SIZE == 2'b10)? rdData_h : rdData); 
assign DSIZE = DATA_SIZE;

assign WB_A 	= (LDST == 1)? RD_A : 4'b1111;
assign W_VALID  = (LDST == 1)? 1	: 0;
assign WB_D 	= (LDST == 1)? DIN 	: 31'b0;

assign EXE_D	= (FWD_REQ_FROM_HAZD)? DIN 	: 31'b0;



endmodule 
