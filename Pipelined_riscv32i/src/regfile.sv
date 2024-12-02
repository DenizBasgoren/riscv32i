
// verilator lint_off MULTIDRIVEN

module Regfile #(
	LOG_FILE = ""
)(
	input wire [4:0] addressForReading1,
	input wire [4:0] addressForReading2,
	input wire [4:0] addressForWriting,
	input wire [31:0] valueForWriting,
	input wire clock,
	input wire reset,
	input wire writeEnable,
	output reg [31:0] value1,
	output reg [31:0] value2
);

reg [31:0] memory [0:31];

initial begin
	for (int i = 0; i<=31; i++) begin
		memory[i] = 0;
	end
	value1 = 0;
	value2 = 0;
end


always @(negedge clock, negedge reset) begin
	if (!reset) begin
		for (int i = 0; i<=31; i++) begin
			memory[i] <= 0;
		end
		value1 <= 0;
		value2 <= 0;
	end
	else begin
		// write
		if (addressForWriting != 0 && writeEnable) begin
			memory[addressForWriting] <= valueForWriting;
			$fwrite(logFileDescriptor, "t=%0d:\treg[%0d] <- %0h\h\n", $time, addressForWriting, valueForWriting);
			$fflush(logFileDescriptor);
		end
	end

end

always @(addressForReading1, addressForReading2, memory[addressForReading1], memory[addressForReading2]) begin
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
end


int logFileDescriptor;
initial begin
	logFileDescriptor = $fopen(LOG_FILE, "a");
end



endmodule

// verilator lint_on MULTIDRIVEN
