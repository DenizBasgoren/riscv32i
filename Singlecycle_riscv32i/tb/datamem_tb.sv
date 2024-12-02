

module Datamem_tb();
	
reg [31:0] address;
reg [2:0] flagsForReading; // 000:loadByte, 001:loadHalf, 010:loadWord, 100:loadByteUnsigned, 101:loadHalfUnsigned
reg [1:0] flagsForWriting; // 00:storeByte, 01:storeHalf, 10:storeWord
reg [31:0] valueForWriting;
reg clock;
reg reset;
reg writeEnable;
wire [31:0] beValue;
wire [31:0] leValue;

Datamem #( .ENDIANNESS(0) ) beDatamem ( .*, .value(beValue) );
Datamem #( .ENDIANNESS(1) ) leDatamem ( .*, .value(leValue) );

always begin
	#2 clock = ~clock;
end

int errorNo = 1;
initial begin

	// initial values
	clock = 0;
	reset = 1;
	writeEnable = 0;
	flagsForWriting = 0;
	flagsForReading = 0;

	// dump
	$dumplimit(1000*1000*1); // 1mb
	$dumpfile("datamem.vcd");
	$dumpvars();

	for (int i = 0; i<10; i++) begin
		$dumpvars(0, leDatamem.memory[i]);
		$dumpvars(0, beDatamem.memory[i]);
	end

	#1;


	// All memory cells should initially be zero
	for (int i = 0; i<10; i++) begin
		if (leDatamem.memory[i] == 0); else $fatal(errorNo++);
		if (beDatamem.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<10; i++) begin
		address = i[3:0];
		#1;
		if (leValue == 0); else $fatal(errorNo++);
		if (beValue == 0); else $fatal(errorNo++);
	end
	
	// write doesnt work unless writeEnable=1
	for (int i = 0; i<10; i++) begin
		address = i[3:0];
		valueForWriting = i+10;
		@(posedge clock); #1;
	end

	for (int i = 0; i<10; i++) begin
		if (leDatamem.memory[i] == 0); else $fatal(errorNo++);
		if (beDatamem.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<10; i++) begin
		address = i[3:0];
		#1;
		if (leValue == 0); else $fatal(errorNo++);
		if (beValue == 0); else $fatal(errorNo++);
	end

	// write works when writeEnable=1
	writeEnable = 1;
	flagsForWriting = 0; // 00:storeByte, 01:storeHalf, 10:storeWord
	for (int i = 0; i<10; i++) begin
		address = i[3:0];
		valueForWriting = 32'h11;
		@(posedge clock); #1;
	end
	writeEnable = 0;


	for (int i = 0; i<10; i++) begin
		if (leDatamem.memory[i] == 8'h11); else $fatal(errorNo++);
		if (beDatamem.memory[i] == 8'h11); else $fatal(errorNo++);
	end

	// reset resets asynchronously
	@(posedge clock);
	#1;
	reset = 0;
	#1;
	reset = 1;
	#1;

	// all registers are zero
	for (int i = 0; i<10; i++) begin
		if (leDatamem.memory[i] == 0); else $fatal(errorNo++);
		if (beDatamem.memory[i] == 0); else $fatal(errorNo++);
	end

	// writing works again after resetting
	writeEnable = 1;

	address = 1;
	valueForWriting = 32'haabbccdd;
	flagsForWriting = 2;
	@(posedge clock); #1;

	address = 9;
	valueForWriting = 32'h66778899;
	flagsForWriting = 1;
	@(posedge clock); #1;

	address = 5;
	valueForWriting = 32'h112233EE;
	flagsForWriting = 0;
	@(posedge clock); #1;

	writeEnable = 0;

	address = 9;
	flagsForReading = 2;
	#1;
	if (beValue == 32'h8899aabb); else $fatal(errorNo++);
	if (leValue == 32'hccdd8899); else $fatal(errorNo++);

	address = 4;
	flagsForReading = 1;
	#1;
	if (beValue == 32'hffffddee); else $fatal(errorNo++);
	if (leValue == 32'hffffeeaa); else $fatal(errorNo++);

	address = 3;
	flagsForReading = 5;
	#1;
	if (beValue == 32'h0000ccdd); else $fatal(errorNo++);
	if (leValue == 32'h0000aabb); else $fatal(errorNo++);

	address = 0;
	flagsForReading = 0;
	#1;
	if (beValue == 32'hffffff99); else $fatal(errorNo++);
	if (leValue == 32'hffffff88); else $fatal(errorNo++);

	address = 0;
	flagsForReading = 4;
	#1;
	if (beValue == 32'h00000099); else $fatal(errorNo++);
	if (leValue == 32'h00000088); else $fatal(errorNo++);

	$display("No errors");
	$finish();
end


endmodule
