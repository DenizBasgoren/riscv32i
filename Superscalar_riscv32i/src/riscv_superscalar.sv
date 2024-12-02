
module RiscvSuperscalar #(
	DMemInitFile = "samples/strlen.c.elf.dmem",
	IMemInitFile = "samples/strlen.c.elf.imem",
	logFile = "strlen.log",
	DATAMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	DATAMEM_LENGTH = 5000,
	INSTMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	INSTMEM_LENGTH = 5000,
	INITIAL_PC_ADDRESS = 36 // 112 for bubblesort, 36 for others
) (
	input wire clock,
	input wire reset,
	output wire [31:0] dummyOutput
);


	wire [31:0] imemOut1;
	wire [31:0] imemOut2;
	wire [31:0] immedGen1OutXstage;
	wire [31:0] immedGen2OutXstage;
	wire [31:0] reg1Out;
	wire [31:0] reg2Out;
	wire [31:0] reg3Out;
	wire [31:0] reg4Out;
	reg [31:0] writeBack1X;
	reg [31:0] writeBack1W;
	reg [31:0] writeBack2X;
	reg [31:0] writeBack2W;
	reg [31:0] alu1Arg1In;
	reg [31:0] alu1Arg2In;
	reg [31:0] alu2Arg1In;
	reg [31:0] alu2Arg2In;
	wire [31:0] alu1OutXstage;
	wire [31:0] alu2OutXstage;
	wire [31:0] datamemOut;
	wire branchCompOutput;
	wire [18:0] controlWord1Dstage;
	wire [18:0] controlWord1Xstage;
	wire [18:0] controlWord1Wstage;
	wire [18:0] controlWord2Dstage;
	wire [18:0] controlWord2Xstage;
	wire [18:0] controlWord2Wstage;

	reg [31:0] pcFstage;
	reg [31:0] pcDstage;
	reg [31:0] pcXstage;
	reg [31:0] inst1Dstage;
	reg [31:0] inst1Istage;
	reg [31:0] inst1Xstage;
	reg [31:0] inst1Wstage;
	reg [31:0] inst2Dstage;
	reg [31:0] inst2Istage;
	reg [31:0] inst2Xstage;
	reg [31:0] inst2Wstage;
	reg [31:0] reg1OutXstage;
	reg [31:0] reg2OutXstage;
	reg [31:0] reg3OutXstage;
	reg [31:0] reg4OutXstage;
	reg [31:0] reg1AfterForwarding;
	reg [31:0] reg2AfterForwarding;
	reg [31:0] reg3AfterForwarding;
	reg [31:0] reg4AfterForwarding;

	wire [2:0] forwardReg1From; // 0:no forward, 1-4: forward from 1-4
	wire [2:0] forwardReg2From;
	wire [2:0] forwardReg3From;
	wire [2:0] forwardReg4From;

	wire [1:0] pcDelta;
	reg willJumpBranch;

	Alu alu1 ( .arg1(alu1Arg1In), .arg2(alu1Arg2In), .operation(controlWord1Xstage[6:3]), .result(alu1OutXstage));
	Alu alu2 ( .arg1(alu2Arg1In), .arg2(alu2Arg2In), .operation(controlWord2Xstage[6:3]), .result(alu2OutXstage));
	Regfile #(.LOG_FILE(logFile)) regfile ( .addressForReading1(inst1Istage[19:15]), .addressForReading2(inst1Istage[24:20]), .addressForReading3(inst2Istage[19:15]), .addressForReading4(inst2Istage[24:20]), .addressForWriting1(inst1Wstage[11:7]), .valueForWriting1(writeBack1W), .addressForWriting2(inst2Wstage[11:7]), .valueForWriting2(writeBack2W), .clock(clock), .reset(reset), .writeEnable1(controlWord1Wstage[7]), .writeEnable2(controlWord2Wstage[7]), .value1(reg1Out), .value2(reg2Out), .value3(reg3Out), .value4(reg4Out));
	BranchComparator branchComparator ( .value1(reg1AfterForwarding), .value2(reg2AfterForwarding), .branchType(controlWord1Xstage[2:0]), .branchCompOutput(branchCompOutput));
	Datamem #(.LENGTH(DATAMEM_LENGTH), .ENDIANNESS(DATAMEM_ENDIANNESS), .INIT_FILE(DMemInitFile), .LOG_FILE(logFile)) datamem ( .address(alu2OutXstage), .flagsForReading(controlWord2Xstage[2:0]), .flagsForWriting(controlWord2Xstage[1:0]), .valueForWriting(reg4AfterForwarding), .clock(clock), .reset(reset), .writeEnable(controlWord2Xstage[14] && !controlWord1Xstage[13] /* if top:branch and will branch and bottom:store, don't let datamem work. */), .value(datamemOut));
	Instmem #(.LENGTH(INSTMEM_LENGTH), .ENDIANNESS(INSTMEM_ENDIANNESS), .INIT_FILE(IMemInitFile)) instmem ( .address(pcFstage[$clog2(INSTMEM_LENGTH)-1:0]), .value1(imemOut1), .value2(imemOut2));
	ImmedGen immedGen1 (.instType(controlWord1Xstage[18:15]), .inst(inst1Xstage), .immed(immedGen1OutXstage));
	ImmedGen immedGen2 (.instType(controlWord2Xstage[18:15]), .inst(inst2Xstage), .immed(immedGen2OutXstage));
	InstDecoder instDecoder1Dstage( .inst(inst1Dstage), .branchCompOutput(1'b0), .controlWord(controlWord1Dstage));
	InstDecoder instDecoder1Xstage( .inst(inst1Xstage), .branchCompOutput(branchCompOutput), .controlWord(controlWord1Xstage));
	InstDecoder instDecoder1Wstage( .inst(inst1Wstage), .branchCompOutput(1'b0), .controlWord(controlWord1Wstage));
	InstDecoder instDecoder2Dstage( .inst(inst2Dstage), .branchCompOutput(1'b0), .controlWord(controlWord2Dstage));
	InstDecoder instDecoder2Xstage( .inst(inst2Xstage), .branchCompOutput(branchCompOutput), .controlWord(controlWord2Xstage));
	InstDecoder instDecoder2Wstage( .inst(inst2Wstage), .branchCompOutput(1'b0), .controlWord(controlWord2Wstage));
	IssueUnit issueUnit( .inst1(inst1Dstage), .inst2(inst2Dstage), .controlWord1(controlWord1Dstage), .controlWord2(controlWord2Dstage), .outInst1(inst1Istage), .outInst2(inst2Istage), .pcDelta(pcDelta) );
	ForwardingUnit forwardingUnit( .controlWord1Xstage(controlWord1Xstage), .controlWord1Wstage(controlWord1Wstage), .controlWord2Xstage(controlWord2Xstage), .controlWord2Wstage(controlWord2Wstage), .inst1(inst1Xstage), .inst2(inst1Wstage), .inst3(inst2Xstage), .inst4(inst2Wstage), .forwardReg1From(forwardReg1From), .forwardReg2From(forwardReg2From), .forwardReg3From(forwardReg3From), .forwardReg4From(forwardReg4From)); 
	
	initial begin
		pcFstage = INITIAL_PC_ADDRESS;
	end

	int logFileDescriptor;
	initial begin
		logFileDescriptor = $fopen(logFile, "a");
	end

	
	

	always @(posedge clock) begin

		if (controlWord1Xstage[13]) begin
			pcFstage <= alu1OutXstage;
			$fwrite(logFileDescriptor, "t=%0d:\tpc <- %0h\h\n", $time, alu1OutXstage);
			$fflush(logFileDescriptor);
		end
		else if (controlWord2Xstage[13]) begin
			pcFstage <= alu2OutXstage;
			$fwrite(logFileDescriptor, "t=%0d:\tpc <- %0h\h\n", $time, alu2OutXstage);
			$fflush(logFileDescriptor);
		end
		else if (pcDelta==0) begin
			pcFstage <= pcFstage+0;
		end
		else if (pcDelta==1) begin
			pcFstage <= pcFstage-4;
		end
		else if (pcDelta==2) begin
			pcFstage <= pcFstage+8;
		end
		else begin
			pcFstage <= 32'bx;
		end

		pcDstage <= pcFstage;
		pcXstage <= pcDstage;

		if (willJumpBranch) begin
			inst1Dstage <= 32'h00000013;
			inst2Dstage <= 32'h00000013;
			inst1Xstage <= 32'h00000013;
			inst2Xstage <= 32'h00000013;
		end
		else begin
			if (pcDelta==1) begin
				inst1Dstage <= 32'h00000013;
			end
			else begin
				inst1Dstage <= imemOut1;
			end
			inst1Xstage <= inst1Istage;

			if (pcDelta==1) begin
				inst2Dstage <= 32'h00000013;
			end
			else begin
				inst2Dstage <= imemOut2;
			end
			inst2Xstage <= inst2Istage;
			
		end

		// the following code prevents bugs of type top:branch (branches), bottom: any inst. the bottom inst should be prevented from updating regfile
		if ( controlWord1Xstage[13] ) begin
			inst2Wstage <= 32'h00000013;
		end
		else begin
			inst2Wstage <= inst2Xstage;
		end

		inst1Wstage <= inst1Xstage;

		reg1OutXstage <= reg1Out;
		reg2OutXstage <= reg2Out;
		reg3OutXstage <= reg3Out;
		reg4OutXstage <= reg4Out;
	end


	// to the output
	// controlWord[18:15] = instType;  // 0:load 1:imm 2:store 3:reg 4:lui 5:auipc 6:brnch 7:jalr 8:jal
	// controlWord[14] = datamemWriteEnable;
	// controlWord[13] = PCSelect; // 0:pc+4 1:alu
	// controlWord[12:11] = writebackSelect; // 0:mem 1:alu 2:pc+4
	// controlWord[10:9] = aluArg1Select; // 0:reg1, 1:pc, 2:const 0
	// controlWord[8] = aluArg2Select; // 1:immed 0:reg2
	// controlWord[7] = regfileWriteEnable;
	// controlWord[6:3] = aluOperation; //0:add 1:sub 2:or 3:and 4:xor 5:sll 6:srl 7:sra 8:slt 9:sltu
	// controlWord[2:0] = branchType;  // 0:beq, 1:bne, 4:blt, 5:bge, 6:bltu, 7:bgeu

	always @(*) begin
		willJumpBranch = controlWord1Xstage[13] || controlWord2Xstage[13];
	end

	always @(*) begin
		if (controlWord1Xstage[8] == 1) begin
			alu1Arg2In = immedGen1OutXstage;
		end
		else begin
			alu1Arg2In = reg2AfterForwarding;
		end
	end

	always @(*) begin
		if (controlWord2Xstage[8] == 1) begin
			alu2Arg2In = immedGen2OutXstage;
		end
		else begin
			alu2Arg2In = reg4AfterForwarding;
		end
	end

	always @(*) begin
		if (controlWord1Xstage[10:9] == 2) begin
			alu1Arg1In = 32'b0;
		end
		else if (controlWord1Xstage[10:9] == 0) begin
			alu1Arg1In = reg1AfterForwarding;
		end
		else if (controlWord1Xstage[10:9] == 1) begin
			alu1Arg1In = pcXstage;
		end
		else begin
			alu1Arg1In = 32'bx;
		end
	end

	always @(*) begin
		if (controlWord2Xstage[10:9] == 2) begin
			alu2Arg1In = 32'b0;
		end
		else if (controlWord2Xstage[10:9] == 0) begin
			alu2Arg1In = reg3AfterForwarding;
		end
		else if (controlWord2Xstage[10:9] == 1) begin
			alu2Arg1In = pcXstage+4;
		end
		else begin
			alu2Arg1In = 32'bx;
		end
	end


	always @(*) begin
		if (controlWord1Xstage[12:11] == 1) begin
			writeBack1X = alu1OutXstage;
		end
		else if (controlWord1Xstage[12:11] == 2) begin
			writeBack1X = pcXstage+4;
		end
		else begin
			writeBack1X = 32'bx;
		end
	end

	always @(*) begin
		if (controlWord2Xstage[12:11] == 0) begin
			writeBack2X = datamemOut;
		end
		else if (controlWord2Xstage[12:11] == 1) begin
			writeBack2X = alu2OutXstage;
		end
		else if (controlWord2Xstage[12:11] == 2) begin
			writeBack2X = pcXstage+8;
		end
		else begin
			writeBack2X = 32'bx;
		end
	end

	always @(posedge clock) begin
		writeBack1W <= writeBack1X;
		writeBack2W <= writeBack2X;
	end

	// forwarding stuff
	always @(*) begin
		// reg1
		if (forwardReg1From==0) begin
			reg1AfterForwarding = reg1OutXstage;
		end
		else if (forwardReg1From==1) begin
			reg1AfterForwarding = writeBack1X;
		end
		else if (forwardReg1From==2) begin
			reg1AfterForwarding = writeBack1W;
		end
		else if (forwardReg1From==3) begin
			reg1AfterForwarding = writeBack2X;
		end
		else if (forwardReg1From==4) begin
			reg1AfterForwarding = writeBack2W;
		end
		else begin
			reg1AfterForwarding = 32'bx;
		end

		// reg2
		if (forwardReg2From==0) begin
			reg2AfterForwarding = reg2OutXstage;
		end
		else if (forwardReg2From==1) begin
			reg2AfterForwarding = writeBack1X;
		end
		else if (forwardReg2From==2) begin
			reg2AfterForwarding = writeBack1W;
		end
		else if (forwardReg2From==3) begin
			reg2AfterForwarding = writeBack2X;
		end
		else if (forwardReg2From==4) begin
			reg2AfterForwarding = writeBack2W;
		end
		else begin
			reg2AfterForwarding = 32'bx;
		end

		// reg3
		if (forwardReg3From==0) begin
			reg3AfterForwarding = reg3OutXstage;
		end
		else if (forwardReg3From==1) begin
			reg3AfterForwarding = writeBack1X;
		end
		else if (forwardReg3From==2) begin
			reg3AfterForwarding = writeBack1W;
		end
		else if (forwardReg3From==3) begin
			reg3AfterForwarding = writeBack2X;
		end
		else if (forwardReg3From==4) begin
			reg3AfterForwarding = writeBack2W;
		end
		else begin
			reg3AfterForwarding = 32'bx;
		end

		// reg4
		if (forwardReg4From==0) begin
			reg4AfterForwarding = reg4OutXstage;
		end
		else if (forwardReg4From==1) begin
			reg4AfterForwarding = writeBack1X;
		end
		else if (forwardReg4From==2) begin
			reg4AfterForwarding = writeBack1W;
		end
		else if (forwardReg4From==3) begin
			reg4AfterForwarding = writeBack2X;
		end
		else if (forwardReg4From==4) begin
			reg4AfterForwarding = writeBack2W;
		end
		else begin
			reg4AfterForwarding = 32'bx;
		end
	end

	always @(*) begin
		if (inst1Wstage==32'h00100073 || inst2Wstage==32'h00100073) begin
			$display("Note: ebreak encountered at t=%0d. Halting when the pipeline is done", $time);
			#2;
			$finish;
		end
	end




endmodule