module riscvmulti(input logic clk, reset,
                  input logic [31:0] ReadData,
                  output logic [31:0] Adr, WriteData,
                  output logic MemWrite);

	logic PCWrite, AdrSrc,IRWrite, RegWrite, Zero;
	logic [1:0] ResultSrc, ALUSrcA,ALUSrcB, ImmSrc;
	logic [2:0] ALUControl;
	logic [31:0] Instr;

	controller main_ctrl (
		.clk(clk),
		.reset(reset),
		.op(Instr[6:0]),         
		.funct3(Instr[14:12]),
		.funct7b5(Instr[30]),
		.zero(Zero),             
		.immsrc(ImmSrc),
		.alusrca(ALUSrcA),
		.alusrcb(ALUSrcB),
		.resultsrc(ResultSrc),
		.adrsrc(AdrSrc),
		.irwrite(IRWrite),
		.pcwrite(PCWrite),
		.regwrite(RegWrite),
		.memwrite(MemWrite),    
		.alucontrol(ALUControl)
	   );
	datapath dp (
		.clk(clk),
		.reset(reset),
		.ReadData(ReadData),     
		.Instr(Instr),           
		.Zero(Zero),
		.PCWrite(PCWrite),
		.AdrSrc(AdrSrc),
		.IRWrite(IRWrite),
		.RegWrite(RegWrite),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.ImmSrc(ImmSrc),
		.ALUControl(ALUControl),
		.Adr(Adr),              
		.WriteData(WriteData)  
	   );

endmodule