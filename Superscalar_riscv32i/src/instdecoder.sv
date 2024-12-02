
module InstDecoder (
	input wire [31:0] inst,
	input wire branchCompOutput,
	output reg [18:0] controlWord
);

reg [2:0] funct3;
reg funct1;

// parts of the controlWord:
reg [3:0] instType;
reg datamemWriteEnable;
reg PCSelect;
reg [1:0] writebackSelect;
reg [1:0] aluArg1Select;
reg aluArg2Select;
reg regfileWriteEnable;
reg [3:0] aluOperation;
reg [2:0] branchType;

always @(inst, branchCompOutput) begin: DECODE_PROCESS
	if (inst[1:0] == 2'b11 && inst[4:2] != 3'b111); else begin
		controlWord = 19'bx;
		disable DECODE_PROCESS;
	end
	if (inst[6:0] == 7'b0001111) begin
		$display("Note: Fences are not supported.");
		controlWord = 19'bx;
		disable DECODE_PROCESS;
	end
	if (inst == 32'h00000073) begin
		$display("Note: Ecall is not supported.");
		controlWord = 19'bx;
		disable DECODE_PROCESS;
	end
	if (inst == 32'h00100073) begin // ebreak
		controlWord = 19'bx;
		disable DECODE_PROCESS;
	end

	case (inst[6:2])
		5'b01101: instType = 4; // lui
		5'b00101: instType = 5; // auipc
		5'b11011: instType = 8; // jal
		5'b11001: instType = 7; // jalr
		5'b11000: instType = 6; // brnch
		5'b00000: instType = 0; // load
		5'b01000: instType = 2; // store
		5'b00100: instType = 1; // imm
		5'b01100: instType = 3; // reg
		default: begin
			controlWord = 19'bx;
			disable DECODE_PROCESS;
		end
	endcase
    

    funct3 = inst[14:12];
    funct1 = inst[30];

	datamemWriteEnable = instType == 2;

	PCSelect = (instType==6 && branchCompOutput) || instType==8 || instType==7;

	if (instType==0) begin
		writebackSelect = 0;
	end
	else if (instType==8 || instType==7) begin
		writebackSelect = 2;
	end
	else begin
		writebackSelect = 1;
	end

	if (instType==5 || instType==8 || instType==6) begin
		aluArg1Select = 1;
	end
	else if (instType==4) begin
		aluArg1Select = 2;
	end
	else begin
		aluArg1Select = 0;
	end

	aluArg2Select = instType != 3;

	regfileWriteEnable = !(instType==6 || instType==2);

	if (instType==1) begin // addi, slti ...
		casez ({funct1, funct3})
			4'bz000: aluOperation = 0;
			4'bz010: aluOperation = 8;
			4'bz011: aluOperation = 9;
			4'bz100: aluOperation = 4;
			4'bz110: aluOperation = 2;
			4'bz111: aluOperation = 3;
			4'b0001: aluOperation = 5;
			4'b0101: aluOperation = 6;
			4'b1101: aluOperation = 7;
			default: aluOperation = 4'bx;
		endcase
	end
	else if (instType==3) begin // add, slt ...
		case ({funct1, funct3})
			4'b0000: aluOperation = 0;
			4'b0010: aluOperation = 8;
			4'b0011: aluOperation = 9;
			4'b0100: aluOperation = 4;
			4'b0110: aluOperation = 2;
			4'b0111: aluOperation = 3;
			4'b0001: aluOperation = 5;
			4'b0101: aluOperation = 6;
			4'b1101: aluOperation = 7;
			4'b1000: aluOperation = 1;
			default: aluOperation = 4'bx;
		endcase
	end
	else begin
		aluOperation = 0;
	end

	branchType = funct3;

	// to the output
	controlWord[18:15] = instType;  // 0:load 1:imm 2:store 3:reg 4:lui 5:auipc 6:brnch 7:jalr 8:jal
	controlWord[14] = datamemWriteEnable;
	controlWord[13] = PCSelect; // 0:pc+pcDelta 1:alu
	controlWord[12:11] = writebackSelect; // 0:mem 1:alu 2:pc+4
	controlWord[10:9] = aluArg1Select; // 0:reg1, 1:pc, 2:const 0
	controlWord[8] = aluArg2Select; // 1:immed 0:reg2
	controlWord[7] = regfileWriteEnable;
	controlWord[6:3] = aluOperation; //0:add 1:sub 2:or 3:and 4:xor 5:sll 6:srl 7:sra 8:slt 9:sltu
	controlWord[2:0] = branchType;  // 0:beq, 1:bne, 4:blt, 5:bge, 6:bltu, 7:bgeu
end

endmodule
