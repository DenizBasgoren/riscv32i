
module IssueUnit (
	input wire [31:0] inst1,
	input wire [31:0] inst2,
	input wire [18:0] controlWord1,
	input wire [18:0] controlWord2,
	output reg [31:0] outInst1,
	output reg [31:0] outInst2,
	output reg [1:0] pcDelta // 0:pc+=0, 1:pc-=4, 2:pc+=8
);


	// to the output
	// controlWord[18:15] = instType;  // 0:load 1:imm 2:store 3:reg 4:lui 5:auipc 6:brnch 7:jalr 8:jal
	// controlWord[14] = datamemWriteEnable;
	// controlWord[13] = PCSelect; // 0:pc+pcDelta 1:alu
	// controlWord[12:11] = writebackSelect; // 0:mem 1:alu 2:pc+4
	// controlWord[10:9] = aluArg1Select; // 0:reg1, 1:pc, 2:const 0
	// controlWord[8] = aluArg2Select; // 1:immed 0:reg2
	// controlWord[7] = regfileWriteEnable;
	// controlWord[6:3] = aluOperation; //0:add 1:sub 2:or 3:and 4:xor 5:sll 6:srl 7:sra 8:slt 9:sltu
	// controlWord[2:0] = branchType;  // 0:beq, 1:bne, 4:blt, 5:bge, 6:bltu, 7:bgeu

initial begin
	pcDelta = 2;
end

always @(*) begin
	// this case is just for the first cycle to work
	if (inst1[0]==1'b0 || inst2[0]==1'b0 ) begin
		outInst1 = 32'h00000013;
		outInst2 = 32'h00000013;
		pcDelta = 0;
	end
	// if the top one is jal/jalr, do (jal/jalr, nop)
	else if (controlWord1[18:15]==7 || controlWord1[18:15]==8 ) begin
		outInst1 = inst1;
		outInst2 = 32'h00000013;
		pcDelta = 2;
	end
	// if the top one is ld/st, do (nop, ld/st)
	else if (controlWord1[18:15]==0 || controlWord1[18:15]==2) begin
		outInst1 = 32'h00000013;
		outInst2 = inst1;
		pcDelta = 1;
	end
	// if the bottom one is branch, do (top, nop)
	else if (controlWord2[18:15]==6) begin
		outInst1 = inst1;
		outInst2 = 32'h00000013;
		pcDelta = 1;
	end
	// otherwise dont change anything
	else begin
		outInst1 = inst1;
		outInst2 = inst2;
		pcDelta = 2;
	end
	
	
end

endmodule