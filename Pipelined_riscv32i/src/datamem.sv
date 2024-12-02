
// verilator lint_off MULTIDRIVEN

module Datamem #(
	LENGTH = 10, // length in bytes
	ENDIANNESS = 0, // 0:big endian, 1:little endian
	INIT_FILE = "",
	LOG_FILE = ""
) (
	input wire [31:0] address,
	input wire [2:0] flagsForReading, // 000:loadByte, 001:loadHalf, 010:loadWord, 100:loadByteUnsigned, 101:loadHalfUnsigned
	input wire [1:0] flagsForWriting, // 00:storeByte, 01:storeHalf, 10:storeWord
	input wire [31:0] valueForWriting,
	input wire clock,
	input wire reset,
	input wire writeEnable,
	output reg [31:0] value
);

reg [7:0] memory [0:LENGTH-1];

initial begin
	for (int i = 0; i<=LENGTH-1; i++) begin
		memory[i] = 0;
	end
	value = 0;

	$readmemh(INIT_FILE, memory);
end


always @(posedge clock, negedge reset) begin
	if (!reset) begin
		for (int i = 0; i<=LENGTH-1; i++) begin
			memory[i] <= 0;
		end
		value <= 0;
	end
	else begin
		if (writeEnable) begin
			doStoreStuff;
			doLoadStuff;
		end
	end

end

always @(address, flagsForReading) begin
	doLoadStuff;
end



task doLoadStuff();

	if (ENDIANNESS==0) begin // big endian
		if (flagsForReading==0) begin // byte
			value = {
				{24{memory[roundToRange(address)][7]}},
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==1) begin // half
			value = {
				{16{memory[roundToRange(address)][7]}},
				memory[roundToRange(address)],
				memory[roundToRange(address+1)]
			};
		end
		else if (flagsForReading==2) begin // word
			value = {
				memory[roundToRange(address)],
				memory[roundToRange(address+1)],
				memory[roundToRange(address+2)],
				memory[roundToRange(address+3)]
			};
		end
		else if (flagsForReading==4) begin // byte unsigned
			value = {
				{24{1'b0}},
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==5) begin // half unsigned
			value = {
				{16{1'b0}},
				memory[roundToRange(address)],
				memory[roundToRange(address+1)]
			};
		end
		else begin
			value = 32'bx;
		end
	end
	else if (ENDIANNESS==1) begin // little endian
		if (flagsForReading==0) begin // byte
			value = {
				{24{memory[roundToRange(address)][7]}},
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==1) begin // half
			value = {
				{16{memory[roundToRange(address)][7]}},
				memory[roundToRange(address+1)],
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==2) begin // word
			value = {
				memory[roundToRange(address+3)],
				memory[roundToRange(address+2)],
				memory[roundToRange(address+1)],
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==4) begin // byte unsigned
			value = {
				{24{1'b0}},
				memory[roundToRange(address)]
			};
		end
		else if (flagsForReading==5) begin // half unsigned
			value = {
				{16{1'b0}},
				memory[roundToRange(address+1)],
				memory[roundToRange(address)]
			};
		end
		else begin
			value = 32'bx;
		end
	end
	else begin
		$display("Error: Datamem ENDIANNESS should be 0 (big) or 1 (little).");
		$finish(1);
	end

endtask

task doStoreStuff();

	if (ENDIANNESS==0) begin // big endian
		if (flagsForWriting==0) begin // byte
			store(address, valueForWriting[7:0]);
		end
		else if (flagsForWriting==1) begin // half
			store(address, valueForWriting[15:8]);
			store(address+1, valueForWriting[7:0]);
		end
		else if (flagsForWriting==2) begin // word
			store(address, valueForWriting[31:24]);
			store(address+1, valueForWriting[23:16]);
			store(address+2, valueForWriting[15:8]);
			store(address+3, valueForWriting[7:0]);
		end
	end
	else if (ENDIANNESS==1) begin // little endian
		if (flagsForWriting==0) begin // byte
			store(address, valueForWriting[7:0]);
		end
		else if (flagsForWriting==1) begin // half
			store(address, valueForWriting[7:0]);
			store(address+1, valueForWriting[15:8]);
		end
		else if (flagsForWriting==2) begin // word
			store(address, valueForWriting[7:0]);
			store(address+1, valueForWriting[15:8]);
			store(address+2, valueForWriting[23:16]);
			store(address+3, valueForWriting[31:24]);
		end
	end
	else begin
		$display("Error: Datamem ENDIANNESS should be 0 (big) or 1 (little).");
		$finish(1);
	end


endtask

int logFileDescriptor;
initial begin
	logFileDescriptor = $fopen(LOG_FILE, "a");
end

task store(
	input reg [31:0] address,
	input reg [7:0] valueForWriting
);
	memory[roundToRange(address)] = valueForWriting;
	$fwrite(logFileDescriptor, "t=%0d:\tmem[%0h\h] <- %0h\h\n", $time, roundToRange(address), valueForWriting);
	$fflush(logFileDescriptor);
endtask

function [31:0] roundToRange (input signed [31:0] value);
	if (value >= 0)
		roundToRange = value % LENGTH;
	else
		roundToRange = ((value % LENGTH) + LENGTH) % LENGTH;
endfunction

endmodule

// verilator lint_on MULTIDRIVEN
