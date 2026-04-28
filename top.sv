module top (input logic clk, reset, 
            output logic [31:0] WriteData, Adr, 
            output logic MemWrite);

	logic [31:0] ReadData;

	riscvmulti riscvmulti(
		.clk(clk),
		.reset(reset),
		.WriteData(WriteData),
		.Adr(Adr),
		.MemWrite(MemWrite),
		.ReadData(ReadData)
		);

	mem mem(
		.clk(clk),
		.WD(WriteData),
		.A(Adr),
		.WE(MemWrite),
		.RD(ReadData)
		);

endmodule