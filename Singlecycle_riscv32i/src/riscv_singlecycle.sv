
module riscv_singlecycle #(
	DMemInitFile = "samples/prime.c.elf.dmem",
	IMemInitFile = "samples/prime.c.elf.imem",
	logFile = "log.log",
	DATAMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	DATAMEM_LENGTH = 5000,
	INSTMEM_ENDIANNESS = 1, // 0:big endian, 1:little endian
	INSTMEM_LENGTH = 5000,
	INITIAL_PC_ADDRESS = 36 // 112 for bubblesort
) (
	input wire clk_i,
	input wire rst_ni,
	output wire [31:0] rf_data_hex
);

	wire [31:0] imemOut;
	wire [31:0] immedGenOut;
	wire [31:0] reg1Out;
	wire [31:0] reg2Out;
	reg [31:0] regWritingIn;
	reg [31:0] aluArg1In;
	reg [31:0] aluArg2In;
	wire [31:0] aluOut;
	wire [31:0] datamemOut;
	wire willBranch;
	wire [18:0] controlWord;

	reg [31:0] pc; // program counter

	Alu alu ( .arg1(aluArg1In), .arg2(aluArg2In), .operation(controlWord[6:3]), .result(aluOut));
	Regfile #(.LOG_FILE(logFile)) regfile ( .addressForReading1(imemOut[19:15]), .addressForReading2(imemOut[24:20]), .addressForWriting(imemOut[11:7]), .valueForWriting(regWritingIn), .clock(clk_i), .reset(rst_ni), .writeEnable(controlWord[7]), .value1(reg1Out), .value2(reg2Out));
	BranchComparator branchComparator ( .value1(reg1Out), .value2(reg2Out), .branchType(controlWord[2:0]), .willBranch(willBranch));
	Datamem #(.LENGTH(DATAMEM_LENGTH), .ENDIANNESS(DATAMEM_ENDIANNESS), .INIT_FILE(DMemInitFile), .LOG_FILE(logFile)) datamem ( .address(aluOut), .flagsForReading(controlWord[2:0]), .flagsForWriting(controlWord[1:0]), .valueForWriting(reg2Out), .clock(clk_i), .reset(rst_ni), .writeEnable(controlWord[14]), .value(datamemOut));
	Instmem #(.LENGTH(INSTMEM_LENGTH), .ENDIANNESS(INSTMEM_ENDIANNESS), .INIT_FILE(IMemInitFile)) instmem ( .address(pc[$clog2(INSTMEM_LENGTH)-1:0]), .value(imemOut));
	ImmedGen immedGen (.instType(controlWord[18:15]), .inst(imemOut), .immed(immedGenOut));
	InstDecoder instDecoder( .inst(imemOut), .willBranch(willBranch), .controlWord(controlWord));

	initial begin
		pc = INITIAL_PC_ADDRESS;
	end

	int logFileDescriptor;
	initial begin
		logFileDescriptor = $fopen(logFile, "a");
	end

	always @(posedge clk_i) begin
		if (controlWord[13]==1) begin
			pc <= aluOut;
			$fwrite(logFileDescriptor, "t=%0d:\tpc <- %0h\h\n", $time, aluOut);
			$fflush(logFileDescriptor);
		end
		else begin
			pc <= pc+4;
		end
	end

	always @(pc, reg1Out, controlWord) begin
		if (controlWord[10:9] == 2) begin
			aluArg1In = 32'b0;
		end
		else if (controlWord[10:9] == 0) begin
			aluArg1In = reg1Out;
		end
		else if (controlWord[10:9] == 1) begin
			aluArg1In = pc;
		end
		else begin
			aluArg1In = 32'bx;
		end
	end

	always @(reg2Out, immedGenOut, controlWord) begin
		if (controlWord[8] == 1) begin
			aluArg2In = immedGenOut;
		end
		else begin
			aluArg2In = reg2Out;
		end
	end

	always @(datamemOut, aluOut, pc, controlWord) begin
		if (controlWord[12:11] == 0) begin
			regWritingIn = datamemOut;
		end
		else if (controlWord[12:11] == 1) begin
			regWritingIn = aluOut;
		end
		else if (controlWord[12:11] == 2) begin
			regWritingIn = pc+4;
		end
	end



endmodule