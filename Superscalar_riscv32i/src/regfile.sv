
// verilator lint_off MULTIDRIVEN

module Regfile #(
	LOG_FILE = ""
)(
	input wire [4:0] addressForReading1,
	input wire [4:0] addressForReading2,
	input wire [4:0] addressForReading3,
	input wire [4:0] addressForReading4,
	input wire [4:0] addressForWriting1,
	input wire [4:0] addressForWriting2,
	input wire [31:0] valueForWriting1,
	input wire [31:0] valueForWriting2,
	input wire clock,
	input wire reset,
	input wire writeEnable1,
	input wire writeEnable2,
	output reg [31:0] value1,
	output reg [31:0] value2,
	output reg [31:0] value3,
	output reg [31:0] value4
);

reg [31:0] memory [0:31];

initial begin
	for (int i = 0; i<=31; i++) begin
		memory[i] = 0;
	end
	value1 = 0;
	value2 = 0;
	value3 = 0;
	value4 = 0;
end


always @(negedge clock, negedge reset) begin
	if (!reset) begin
		for (int i = 0; i<=31; i++) begin
			memory[i] <= 0;
		end
		value1 <= 0;
		value2 <= 0;
		value3 <= 0;
		value4 <= 0;
	end
	else begin
		// write
		if (addressForWriting1 != 0 && writeEnable1) begin
			memory[addressForWriting1] <= valueForWriting1;
			$fwrite(logFileDescriptor, "t=%0d:\treg[%0d] <- %0h\h\n", $time, addressForWriting1, valueForWriting1);
			$fflush(logFileDescriptor);
		end
		if (addressForWriting2 != 0 && writeEnable2) begin
			memory[addressForWriting2] <= valueForWriting2;
			$fwrite(logFileDescriptor, "t=%0d:\treg[%0d] <- %0h\h\n", $time, addressForWriting2, valueForWriting2);
			$fflush(logFileDescriptor);
		end
	end

end

always @(addressForReading1, addressForReading2, addressForReading3, addressForReading4, memory[addressForReading1], memory[addressForReading2], memory[addressForReading3], memory[addressForReading4]) begin
	if (addressForReading1 == 0) begin
		value1 = 0;
	end
	else begin
		value1 = memory[addressForReading1];
	end

	if (addressForReading2 == 0) begin
		value2 = 0;
	end
	else begin
		value2 = memory[addressForReading2];
	end

	if (addressForReading3 == 0) begin
		value3 = 0;
	end
	else begin
		value3 = memory[addressForReading3];
	end

	if (addressForReading4 == 0) begin
		value4 = 0;
	end
	else begin
		value4 = memory[addressForReading4];
	end
end


int logFileDescriptor;
initial begin
	logFileDescriptor = $fopen(LOG_FILE, "a");
end



endmodule

// verilator lint_on MULTIDRIVEN
