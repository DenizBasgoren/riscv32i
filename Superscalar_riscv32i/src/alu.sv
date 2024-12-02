


module Alu (
	input wire [31:0] arg1,
	input wire [31:0] arg2,
	input wire [3:0] operation,
	output reg [31:0] result
);

always @(arg1, arg2, operation) begin
	case (operation)
		0: result = arg1 + arg2; // add
		1: result = arg1 - arg2; // sub
		2: result = arg1 | arg2; // or
		3: result = arg1 & arg2; // and
		4: result = arg1 ^ arg2; // xor
		5: result = arg1 << arg2[4:0]; // sll
		6: result = arg1 >> arg2[4:0]; // srl
		7: result = $signed(arg1) >> arg2[4:0]; //sra
		8: result = $signed(arg1) < $signed(arg2); // slt
		9: result = arg1 < arg2; // sltu
		default: begin
			result = 32'bx;
		end
	endcase
end


endmodule