

`timescale 1ns / 10ps

module SRAM (
			CLK, 
			CSN, 
			ADDR, 
			WE, 
			BE,
			DI, 
			DO
		);

	input			CLK; 
	input			CSN; 
	input	[11:0]		ADDR; 
	input			WE; 
	input	[3:0]		BE;
	input	[31:0]		DI; 
	output	[31:0]		DO;

	
	reg	[31:0]		outline;
	reg	[31:0]		ram[0 : 4095];
	reg	[31:0]		tmp_rd;
	reg	[31:0]		tmp_wd;

	parameter ROMDATA = "mem.hex";

	initial	begin
		$readmemh(ROMDATA, ram);
	end
	
	//assign #1 DO = outline;
	assign DO = outline;

	always @ (posedge CLK) begin
		if (~CSN) begin			// chip select at negative
			if (~WE) begin		// read operation
				tmp_rd = ram[ADDR];
				if (BE[0]) outline[ 7: 0] = tmp_rd[7:0];
				if (BE[1]) outline[15: 8] = tmp_rd[15:8];
				if (BE[2]) outline[23:16] = tmp_rd[23:16];
				if (BE[3]) outline[31:24] = tmp_rd[31:24];
			end
			else begin		// write operation
				if (BE[0]) tmp_wd[7:0] = DI[7:0];
				if (BE[1]) tmp_wd[15:8] = DI[15:8];
				if (BE[2]) tmp_wd[23:16] = DI[23:16];
				if (BE[3]) tmp_wd[31:24] = DI[31:24];

				ram[ADDR] = tmp_wd;
			end
		end
	end
endmodule
