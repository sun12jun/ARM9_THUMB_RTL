module NZCVupdater (
	input wire [31:0] X,
	input wire [31:0] Y,
	input wire [31:0] result,
	input wire [1:0]  updatetype,
	input wire [3:0]  NZCV,	

	output wire [3:0] NZCV_new
);

	wire	N_new;
	wire 	Z_new;
	wire	C_new;
	wire	V_new;
	
	assign NZCV_new[3] = N_new;
	assign NZCV_new[2] = Z_new;
	assign NZCV_new[1] = C_new;
	assign NZCV_new[0] = V_new;

	wire	N;
	wire	Z;
	wire	C;
	wire	V;
	
	assign N = NZCV[3];
	assign Z = NZCV[2];
	assign C = NZCV[1];
	assign V = NZCV[0];

	wire N_temp;
	wire Z_temp;
	wire C_temp_add;
	wire C_temp_sub;
	wire V_temp_add;
	wire V_temp_sub;

	assign N_temp = ($signed(result) < 0) ? 1 : 0;
	assign N_new = (updatetype == 2'b00) ? (N) : (N_temp);
	
	assign Z_temp = (result == 0) ? 1: 0;
	assign Z_new = (updatetype == 2'b00) ? (Z) : (Z_temp);
	
	//C update for ADD case
	assign C_temp_add = ((X[31] & Y[31] == 1) ||
					    ((((X[31] | Y[31]) == 1) && (result[31])) == 0)) ? 1 : 0; 

	//C update for SUB case
	assign C_temp_sub = ((X[31] == 1 && Y[31] == 0) ||
					    ((((X[31] | ~Y[31]) == 1) && (result[31])) == 0)) ? 1 : 0; 

	//V update for ADD case
	assign V_temp_add = ((X[31] == Y[31]) && (result[31] != X[31])) ? 1 : 0;

	//V update for SUB case
	assign V_temp_sub = ((X[31] != Y[31]) && (result[31] != X[31])) ? 1 : 0;

	assign C_new = (updatetype == 2'b10) ? C_temp_add	:	
				  ((updatetype == 2'b11) ? C_temp_sub	:
					C);
	
	assign V_new = (updatetype == 2'b10) ? V_temp_add	:
				  ((updatetype == 2'b11) ? V_temp_sub	:
					V);
	

endmodule
