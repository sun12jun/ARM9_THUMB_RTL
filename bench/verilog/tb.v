
`define NCVERILOG 1

module arm_thumb_test();


	// --------------------------------------------
	// For Dump variables
	// --------------------------------------------
	parameter DUMP_FILE = "arm_thumb_test.vcd";

	`ifdef WAVES
		`ifdef NCVERILOG	// ncverilog user
		initial begin
			$display("Dump variables..");
			`ifdef VCD
				$dumpvars("AC");
				$dumpfile(DUMP_FILE);
			`else
				$shm_open("waves");
				$shm_probe("AC");
			`endif
		
		end
		`else			// icarus verilog user
		initial begin
			$display("Dump variables..");
			$dumpfile(DUMP_FILE);
			$dumpvars;
		end
		`endif
	`endif

	// --------------------------------------------
	// Simulation end condition
	// --------------------------------------------
	parameter CLK_PER = 10;
	parameter NUM_CLK = 1000;

	initial begin
		#(CLK_PER * NUM_CLK); $finish;
	end



	// --------------------------------------------
	// Wires and Regs
	// --------------------------------------------
	
	reg			CLK;
	reg			RESET_N;

	wire			IREQ;
	wire	[31:0]		IADDR;
	wire			IWE;
	wire	[31:0]		INSTR;

	wire			DREQ;
	wire	[31:0]		DADDR;
	wire			DWE;
	wire	[1:0]		DSIZE;
	wire	[31:0]		DIN;
	wire	[31:0]		DOUT;

	reg	[3:0]		DBE;
	
	// --------------------------------------------
	// Clock and Initialize
	// --------------------------------------------
	
	always #(CLK_PER/2) CLK = ~CLK;


	initial begin
		CLK = 1'b0;
		RESET_N = 1'b0;

		#(CLK_PER/4);
		
		#(CLK_PER*4);
			RESET_N = 1;
	end

	
	always @*
	begin
		casex( {DSIZE, DADDR[1:0]} )
			{2'b00, 2'b00}	:	DBE = 4'b0001;
			{2'b00, 2'b01}	:	DBE = 4'b0010;
			{2'b00, 2'b10}	:	DBE = 4'b0100;
			{2'b00, 2'b11}	:	DBE = 4'b1000;
			{2'b01, 2'b00}	:	DBE = 4'b0011;
			{2'b01, 2'b10}	:	DBE = 4'b1100;
			{2'b10, 2'b00}	:	DBE = 4'b1111;
		endcase
	end

	
	// --------------------------------------------
	// Instance modules
	// --------------------------------------------
	ARM_Thumb arm_thumb_processor (
					.CLK(CLK),
					.RESET_N(RESET_N),
					
					// For instruction memory
					.IREQ(IREQ),
					.IADDR(IADDR),
					.IRW(IWE),		// read/write
					.INSTR(INSTR),

					// For data memory
					.DREQ(DREQ),
					.DADDR(DADDR),
					.DRW(DWE),		// read/write
					.DSIZE(DSIZE),		// Data memory access size 
					.DIN(DIN),
					.DOUT(DOUT)
					);


	SRAM inst_mem (
					.CLK (CLK),
					.CSN (1'b0),		// always chip select
					.ADDR (IADDR[13:2]),
					.WE (1'b0),		// only read operation
					.BE (4'b1111),		// word access
					.DI (),			// not used
					.DO (INSTR)		// read data
					);

	SRAM data_mem (
					.CLK (CLK),
					.CSN (1'b0),		// always chip select
					.ADDR (DADDR[13:2]),
					.WE (DREQ && DRW),
					.BE (DBE),	
					.DI (DIN),
					.DO (DOUT)
					);


	// --------------------------------------------
	// Load test vector to inst and data memory
	// --------------------------------------------
	// Caution : Assumption : input file has hex data like below. 
	//			 input file : M[0x03]M[0x02]M[0x01]M[0x00]
	//                        M[0x07]M[0x06]M[0x05]M[0x04]
	//									... 
	//           If the first 4 bytes in input file is 1234_5678
	//           then, the loaded value is mem[0x0000] = 0x1234_5678 (LSB)

	defparam arm_thumb_test.inst_mem.ROMDATA = "data_proc.hex";
	defparam arm_thumb_test.data_mem.ROMDATA = "data.hex";

endmodule

