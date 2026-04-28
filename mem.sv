module mem (
    input logic clk, 
    input logic WE,
    input logic [31:0] A, 
    input logic [31:0] WD,
    output logic [31:0] RD
);

    logic [31:0] RAM[63:0];

    initial begin
        $readmemh("riscvtest.txt", RAM);
    end

    assign RD = RAM[A[31:2]]; 

    always_ff @(posedge clk) begin
        if (WE) begin
            RAM[A[31:2]] <= WD;
    end
    end

endmodule