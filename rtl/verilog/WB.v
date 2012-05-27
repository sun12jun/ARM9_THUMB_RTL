
`timescale 1ns / 10ps

module WB(
	input wire [31:0] WB_DIN,
	input wire  WB_WE,
	input wire [3:0] WB_RADDR,

	output wire RF_WB_WE,
	output wire [3:0] RF_WB_ADDR,
	output wire [31:0] RF_WB_DATA
);

assign RF_WB_WE = WB_WE;
assign RF_WB_ADDR = WB_RADDR;
assign RF_WB_DATA = WB_DIN;

endmodule
