module HAZD (
	// destination RA, operand RB,RC
	//from ID
	input wire [3:0] D_RB,
	input wire [3:0] D_RC,
	input wire 		 D_VALID_B,
	input wire		 D_VALID_C,
	//from EX
	input wire [3:0] E_RA1,
	input wire [3:0] E_RA2,
	input wire 		 E_VALID1,
	input wire 		 E_VALID2,
	//from MEM
 	input wire [3:0] M_RA,
	input wire 		 M_VALID,

	//forward request to EX/MEM 
	//output wire 	  FWD_REQ_E,
	output wire       FWD_REQ_M,
	//select forwqrded data
	output wire [3:0] FWD_SEL_X,
	output wire [3:0] FWD_SEL_Y
		
);

	wire FWDB_REQ_E1;
	wire FWDB_REQ_E2;
	wire FWDB_REQ_M;
	wire FWDC_REQ_E1;
	wire FWDC_REQ_E2;
	wire FWDC_REQ_M;

	//hazard occurs RB 
	assign FWDB_REQ_E1 = (D_RB == E_RA1) & (D_VALID_B & E_VALID1);
	assign FWDB_REQ_E2 = (D_RB == E_RA2) & (D_VALID_B & E_VALID2);
	assign FWDB_REQ_M = (D_RB == M_RA) & (D_VALID_B & M_VALID);
	//hazard occurs RC
	assign FWDC_REQ_E1 = (D_RC == E_RA1) & (D_VALID_C & E_VALID1);
	assign FWDC_REQ_E2 = (D_RC == E_RA2) & (D_VALID_C & E_VALID2);
	assign FWDC_REQ_M = (D_RC == M_RA) & (D_VALID_C & M_VALID);

	// DATA fowarded to ID
	//assign FWD_REQ_E = FWDB_REQ_E || FWDC_REQ_E;
	assign FWD_REQ_M = FWDB_REQ_M || FWDC_REQ_M; 

	/*001 : DATA from EX
	  010 : DATA fron MEM
	  100 : no hazard    */
	assign FWD_SEL_X[0] =  FWDB_REQ_E1;  
	assign FWD_SEL_X[1] = ~FWDB_REQ_E1 & FWDB_REQ_E2;
	assign FWD_SEL_X[2] = ~FWDB_REQ_E1 & ~FWDB_REQ_E2 & FWDB_REQ_M;
	assign FWD_SEL_X[3] = ~FWDB_REQ_E1 & ~FWDB_REQ_E2 &~ FWDB_REQ_M;
 
	/*001 : DATA from EX
	  010 : DATA fron MEM
	  100 : no hazard    */
	assign FWD_SEL_Y[0] =  FWDC_REQ_E1;  
	assign FWD_SEL_Y[1] = ~FWDC_REQ_E1 & FWDC_REQ_E2;
	assign FWD_SEL_Y[2] = ~FWDC_REQ_E1 & ~FWDC_REQ_E2 & FWDC_REQ_M;
	assign FWD_SEL_Y[3] = ~FWDC_REQ_E1 & ~FWDC_REQ_E2 &~ FWDC_REQ_M;

endmodule

