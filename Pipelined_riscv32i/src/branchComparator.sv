
module BranchComparator(
	input wire [31:0] value1,
	input wire [31:0] value2,
	input wire [2:0] branchType, // 0:beq, 1:bne, 4:blt, 5:bge, 6:bltu, 7:bgeu
	output reg willBranch
);

	always @(value1, value2, branchType) begin
		case (branchType)
			0: willBranch = value1 === value2;
			1: willBranch = value1 !== value2;
			4: willBranch = $signed(value1) < $signed(value2);
			5: willBranch = $signed(value1) >= $signed(value2);
			6: willBranch = value1 < value2;
			7: willBranch = value1 >= value2;
			default: willBranch = 1'bx;
		endcase
	end

endmodule