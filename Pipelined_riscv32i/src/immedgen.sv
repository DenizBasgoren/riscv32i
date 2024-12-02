


module ImmedGen (
	input wire [3:0] instType,
	input wire [31:0] inst,
	output reg [31:0] immed
);

// 0:load 1:imm 2:store 3:reg 4:lui 5:auipc 6:brnch 7:jalr 8:jal

always @(instType, inst) begin
    case (instType)

        // lui, auipc
        4, 5: immed = {inst[31:12], {12{1'b0}}};
        // jal
        8: immed = {{12{inst[31]}},  inst[19:12], inst[20], inst[30:21], 1'b0};
        // brnch
        6: immed = {{20{inst[31]}},  inst[7], inst[30:25], inst[11:8], 1'b0};
        // store
        2: immed = {{21{inst[31]}},  inst[30:25], inst[11:7]};
        // load, immed, jalr
        0, 1, 7: immed = {{21{inst[31]}},  inst[30:20]};
		// reg
        default: immed = 32'bx;
    endcase
end

endmodule