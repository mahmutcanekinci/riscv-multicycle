module datapath(
    input logic clk, reset,
    input logic [31:0] ReadData,
    output logic [31:0] Instr,
    output logic Zero,
    input logic PCWrite, AdrSrc,IRWrite, RegWrite,
    input logic [1:0] ALUSrcA,ALUSrcB, ResultSrc, ImmSrc,
    input logic [2:0] ALUControl,
    output logic [31:0] Adr,WriteData
);

    logic [31:0] PC,OldPC;
    logic [31:0] Data;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] ALUResult, ALUOut;
    logic [31:0] Result;
    logic [31:0] RD1, RD2;
    logic [31:0] A,B;

    // PC register
    flopenr #(32) pcreg (.clk(clk), .reset(reset), .en(PCWrite), .d(Result), .q(PC));
    
    // Adres Mux
    mux2 #(32) adrmux (.d0(PC), .d1(Result), .s(AdrSrc), .y(Adr));

    // OldPC register
    flopenr #(32) oldpcreg (.clk(clk), .reset(reset), .en(IRWrite), .d(PC), .q(OldPC));
    
    // instruction register
    flopenr #(32) instrreg (.clk(clk), .reset(reset), .en(IRWrite), .d(ReadData), .q(Instr));
    
    // data register
    flopr #(32) datareg (.clk(clk), .reset(reset), .d(ReadData), .q(Data));

    // Register File 
    regfile rf (
        .clk(clk), 
        .we3(RegWrite), 
        .a1(Instr[19:15]), 
        .a2(Instr[24:20]), 
        .a3(Instr[11:7]), 
        .wd3(Result), 
        .rd1(RD1), 
        .rd2(RD2)
    );
    
    extend ext (.instr(Instr[31:7]), .immsrc(ImmSrc), .immext(ImmExt));

    flopr #(32) areg (.clk(clk), .reset(reset), .d(RD1), .q(A));
    flopr #(32) breg (.clk(clk), .reset(reset), .d(RD2), .q(B));
    
    assign WriteData = B;

    // ALUSrcA Mux
    mux3 #(32) srcamux (.d0(PC), .d1(OldPC), .d2(A), .s(ALUSrcA), .y(SrcA));
    
    // ALUSrcB Mux
    mux3 #(32) srcbmux (.d0(B), .d1(ImmExt), .d2(32'd4), .s(ALUSrcB), .y(SrcB));
    
    // ALU block
    alu alu_inst (
        .a(SrcA), 
        .b(SrcB), 
        .alucontrol(ALUControl), 
        .result(ALUResult), 
        .zero(Zero)
    );
    
	 //ALU output register
    flopr #(32) aluoutreg (.clk(clk), .reset(reset), .d(ALUResult), .q(ALUOut));

    // Result Mux
    mux3 #(32) resmux (.d0(ALUOut), .d1(Data), .d2(ALUResult), .s(ResultSrc), .y(Result));

endmodule