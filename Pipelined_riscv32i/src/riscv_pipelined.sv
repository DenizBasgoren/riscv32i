
module riscv_pipelined #(
	DMemInitFile = "samples/prime.c.elf.dmem",
	IMemInitFile = "samples/prime.c.elf.imem",
	logFile = "prime.log",
	DATAMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	DATAMEM_LENGTH = 5000,
	INSTMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	INSTMEM_LENGTH = 5000,
	INITIAL_PC_ADDRESS = 36
) (
	input wire clock,
	input wire reset,
	output wire [31:0] dummyOutput
);


	wire [31:0] imemOut;
	wire [31:0] immedGenOutXstage;
	wire [31:0] reg1Out;
	wire [31:0] reg2Out;
	reg [31:0] regWritingIn;
	reg [31:0] aluArg1In;
	reg [31:0] aluArg2In;
	reg [31:0] branchComparatorArg1In;
	reg [31:0] branchComparatorArg2In;
	wire [31:0] aluOutXstage;
	wire [31:0] datamemOut;
	wire willBranch;
	wire [18:0] controlWordXstage;
	wire [18:0] controlWordMstage;
	wire [18:0] controlWordWstage;

	reg [31:0] pcFstage;
	reg [31:0] pcDstage;
	reg [31:0] pcXstage;
	reg [31:0] pcMstage;
	reg [31:0] instDstage;
	reg [31:0] instXstage;
	reg [31:0] instMstage;
	reg [31:0] instWstage;
	reg [31:0] reg1OutXstage;
	reg [31:0] reg2OutXstage;
	reg [31:0] reg2OutMstage;
	reg [31:0] aluOutMstage;

	
	


	Alu alu ( .arg1(aluArg1In), .arg2(aluArg2In), .operation(controlWordXstage[6:3]), .result(aluOutXstage));
	Regfile #(.LOG_FILE(logFile)) regfile ( .addressForReading1(instDstage[19:15]), .addressForReading2(instDstage[24:20]), .addressForWriting(instWstage[11:7]), .valueForWriting(regWritingIn), .clock(clock), .reset(reset), .writeEnable(controlWordWstage[7]), .value1(reg1Out), .value2(reg2Out));
	BranchComparator branchComparator ( .value1(branchComparatorArg1In), .value2(branchComparatorArg2In), .branchType(controlWordXstage[2:0]), .willBranch(willBranch));
	Datamem #(.LENGTH(DATAMEM_LENGTH), .ENDIANNESS(DATAMEM_ENDIANNESS), .INIT_FILE(DMemInitFile), .LOG_FILE(logFile)) datamem ( .address(aluOutMstage), .flagsForReading(controlWordMstage[2:0]), .flagsForWriting(controlWordMstage[1:0]), .valueForWriting(reg2OutMstage), .clock(clock), .reset(reset), .writeEnable(controlWordMstage[14]), .value(datamemOut));
	Instmem #(.LENGTH(INSTMEM_LENGTH), .ENDIANNESS(INSTMEM_ENDIANNESS), .INIT_FILE(IMemInitFile)) instmem ( .address(pcFstage[$clog2(INSTMEM_LENGTH)-1:0]), .value(imemOut));
	ImmedGen immedGen (.instType(controlWordXstage[18:15]), .inst(instXstage), .immed(immedGenOutXstage));
	InstDecoder instDecoderXstage( .inst(instXstage), .willBranch(willBranch), .controlWord(controlWordXstage));
	InstDecoder instDecoderMstage( .inst(instMstage), .willBranch(0), .controlWord(controlWordMstage));
	InstDecoder instDecoderWstage( .inst(instWstage), .willBranch(0), .controlWord(controlWordWstage));

	initial begin
		pcFstage = INITIAL_PC_ADDRESS;
	end

	int logFileDescriptor;
	initial begin
		logFileDescriptor = $fopen(logFile, "a");
	end

	always @(posedge clock) begin
		if (!stallPipeline) begin
			if (controlWordXstage[13]==1) begin
				pcFstage <= aluOutXstage;
				$fwrite(logFileDescriptor, "t=%0d:\tpc <- %0h\h\n", $time, aluOutXstage);
				$fflush(logFileDescriptor);
			end
			else begin
				pcFstage <= pcFstage+4;
			end
		end
	end

	always @(posedge clock) begin
		if (!stallPipeline) begin
			pcDstage <= pcFstage;
		end
		pcXstage <= pcDstage;
		pcMstage <= pcXstage;
		// flushes for jumps, branches
		if (controlWordXstage[13]) begin
			instDstage <= 16'h00000013;
		end
		// load-use hazard handling
		else if (!stallPipeline) begin
			instDstage <= imemOut;
		end
		if (stallPipeline || controlWordXstage[13]) begin
			instXstage <= 16'h00000013;
		end
		else begin
			instXstage <= instDstage;
		end
		instMstage <= instXstage;
		instWstage <= instMstage;
		if (forwardArg2==2) begin // memory copy hazard handling
			reg2OutMstage <= regWritingIn;
		end
		else if (forwardArg2==1) begin
			reg2OutMstage <= aluOutMstage;
		end
		else begin
			reg2OutMstage <= reg2OutXstage;
		end
		reg1OutXstage <= reg1Out;
		reg2OutXstage <= reg2Out;
		aluOutMstage <= aluOutXstage;
	end


	// forward logic (for RAW hazards)
	reg [1:0] forwardArg1;
	reg [1:0] forwardArg2;
	
	always @(*) begin
		//cw[7] is regwrite
		// inst[19:15] rs1
		// inst[11:7] rd
		// inst[24:20] rs2
		if ( controlWordMstage[7] && instMstage[11:7] && instMstage[11:7]==instXstage[19:15]) begin
			forwardArg1 = 1;
		end
		else if (controlWordWstage[7] && instWstage[11:7] && instWstage[11:7]==instXstage[19:15] && instMstage[11:7]!=instXstage[19:15]) begin
			forwardArg1 = 2;
		end
		else begin
			forwardArg1 = 0;
		end

		if ( controlWordMstage[7] && instMstage[11:7] && instMstage[11:7]==instXstage[24:20]) begin
			forwardArg2 = 1;
		end
		else if (controlWordWstage[7] && instWstage[11:7] && instWstage[11:7]==instXstage[24:20] && instMstage[11:7]!=instXstage[24:20]) begin
			forwardArg2 = 2;
		end
		else begin
			forwardArg2 = 0;
		end
	end

	always @(*) begin
		if (controlWordXstage[10:9] == 2) begin
			aluArg1In = 32'b0;
		end
		else if (controlWordXstage[10:9] == 0) begin
			if (forwardArg1==0) begin
				aluArg1In = reg1OutXstage;
			end
			else if (forwardArg1==1) begin
				aluArg1In = aluOutMstage;
			end
			else if (forwardArg1==2) begin
				aluArg1In = regWritingIn;
			end
			else begin
				aluArg1In = 32'bx;
			end
		end
		else if (controlWordXstage[10:9] == 1) begin
			aluArg1In = pcXstage;
		end
		else begin
			aluArg1In = 32'bx;
		end
	end

	always @(*) begin
		if (controlWordXstage[8] == 1) begin
			aluArg2In = immedGenOutXstage;
		end
		else begin
			if (forwardArg2==0) begin
				aluArg2In = reg2OutXstage;
			end
			else if (forwardArg2==1) begin
				aluArg2In = aluOutMstage;
			end
			else if (forwardArg2==2) begin
				aluArg2In = regWritingIn;
			end
			else begin
				aluArg2In = 32'bx;
			end
		end
	end

	always @(*) begin
		if (forwardArg1==0) begin
			branchComparatorArg1In = reg1OutXstage;
		end
		else if (forwardArg1==1) begin
			branchComparatorArg1In = aluOutMstage;
		end
		else if (forwardArg1==2) begin
			branchComparatorArg1In = regWritingIn;
		end
		else begin
			branchComparatorArg1In = 32'bx;
		end

		if (forwardArg2==0) begin
			branchComparatorArg2In = reg2OutXstage;
		end
		else if (forwardArg2==1) begin
			branchComparatorArg2In = aluOutMstage;
		end
		else if (forwardArg2==2) begin
			branchComparatorArg2In = regWritingIn;
		end
		else begin
			branchComparatorArg2In = 32'bx;
		end
	end

	always @(posedge clock) begin
		if (controlWordMstage[12:11] == 0) begin
			regWritingIn <= datamemOut;
		end
		else if (controlWordMstage[12:11] == 1) begin
			regWritingIn <= aluOutMstage;
		end
		else if (controlWordMstage[12:11] == 2) begin
			regWritingIn <= pcMstage+4;
		end
	end

	// load use hazard
	reg stallPipeline = 0;
	always @(*) begin
		// cw[18:15] instType
		// instType==0 <-> load
		// inst[19:15] rs1
		// inst[11:7] rd
		// inst[24:20] rs2
		if (controlWordXstage[18:15]==0 && ( instXstage[11:7]==instDstage[19:15] || instXstage[11:7]==instDstage[24:20])) begin
			stallPipeline = 1;
		end
		else begin
			stallPipeline = 0;
		end
	end



endmodule