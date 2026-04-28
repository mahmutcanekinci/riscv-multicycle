module mainfsm (
    input logic clk, reset,
    input logic [6:0] op,
    output logic [1:0] aluop,
    output logic branch, pcupdate,
    output logic regwrite, memwrite, irwrite,
    output logic [1:0] resultsrc,
    output logic [1:0] alusrca, alusrcb,
    output logic adrsrc
);

    // Definition of States
    typedef enum logic [3:0] {
        FETCH = 4'd0,  // S0
        DECODE = 4'd1,  // S1
        MEMADR = 4'd2,  // S2
        MEMREAD = 4'd3,  // S3
        MEMWB = 4'd4,  // S4
        MEMWRITE = 4'd5,  // S5
        EXECUTER = 4'd6,  // S6
        ALUWB = 4'd7,  // S7
        EXECUTEI = 4'd8,  // S8
        JAL = 4'd9,  // S9
        BEQ = 4'd10  // S10
    } statetype;

    statetype state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) 
		  state <= FETCH;       
        else       
		  state <= next_state;  
    end

	 // It only decides on the next state.
    always_comb begin
        next_state = state; 
        
        case (state)
            FETCH:    next_state = DECODE;
            
            DECODE: begin
                case (op)
                    7'b0000011, 7'b0100011: next_state = MEMADR; // (lw, sw)
                    7'b0110011: next_state = EXECUTER; // R-type
                    7'b0010011: next_state = EXECUTEI; // I-type
                    7'b1101111: next_state = JAL; // jal
                    7'b1100011: next_state = BEQ; // beq
                    default: next_state = FETCH;    
                 endcase
             end
            
            MEMADR: begin
                if (op == 7'b0000011)      
					 next_state = MEMREAD;
                else if (op == 7'b0100011) 
					 next_state = MEMWRITE;
                else                       
					 next_state = FETCH;
            end
            
            MEMREAD: next_state = MEMWB;
            MEMWB: next_state = FETCH;
            MEMWRITE: next_state = FETCH;
            EXECUTER: next_state = ALUWB;
            EXECUTEI: next_state = ALUWB;
            JAL: next_state = ALUWB; 
            ALUWB: next_state = FETCH;
            BEQ: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

// It only controls the output signals.
    always_comb begin
        aluop = 2'b00;
        branch = 1'b0;
        pcupdate = 1'b0;
        regwrite = 1'b0;
        memwrite = 1'b0;
        irwrite = 1'b0;
        resultsrc = 2'b00;
        alusrca = 2'b00;
        alusrcb = 2'b00;
        adrsrc = 1'b0;

        case (state)
            FETCH: begin
                adrsrc = 1'b0;
                irwrite = 1'b1;
                alusrca = 2'b00;
                alusrcb = 2'b10;
                aluop = 2'b00;
                resultsrc = 2'b10;
                pcupdate = 1'b1;
            end
            DECODE: begin
                alusrca = 2'b01;
                alusrcb = 2'b01;
                aluop = 2'b00;
            end
            MEMADR: begin
                alusrca = 2'b10;
                alusrcb = 2'b01;
                aluop = 2'b00;
            end
            MEMREAD: begin
                resultsrc = 2'b00; 
                adrsrc = 1'b1;
            end
            MEMWB: begin
                resultsrc = 2'b01;
                regwrite = 1'b1;
            end
            MEMWRITE: begin
                resultsrc = 2'b00;
                adrsrc = 1'b1;
                memwrite = 1'b1;
            end
            EXECUTER: begin
                alusrca = 2'b10;
                alusrcb = 2'b00;
                aluop = 2'b10;
            end
            ALUWB: begin
                resultsrc = 2'b00;
                regwrite = 1'b1;
            end
            EXECUTEI: begin
                alusrca = 2'b10;
                alusrcb = 2'b01;
                aluop = 2'b10;
            end
            JAL: begin
                alusrca = 2'b01;
                alusrcb = 2'b10;
                aluop = 2'b00;
                resultsrc = 2'b00;
                pcupdate = 1'b1;
            end
            BEQ: begin
                alusrca = 2'b10;
                alusrcb = 2'b00;
                aluop = 2'b01;
                resultsrc = 2'b00;
                branch = 1'b1;
            end
        endcase
    end

endmodule