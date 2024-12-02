
// verilator lint_off MULTIDRIVEN

module Instmem #(
	LENGTH = 10, // length in bytes
	ENDIANNESS = 0, // 0:big endian, 1:little endian
	INIT_FILE = ""
) (
	input wire [$clog2(LENGTH)-1:0] address,
	output reg [31:0] value1,
	output reg [31:0] value2
);

reg [7:0] memory [0:LENGTH-1];

initial begin
	for (int i = 0; i<=LENGTH-1; i++) begin
		memory[i] = 0;
	end
	value1 = 0;
	value2 = 0;
	$readmemh(INIT_FILE, memory);
end



always @(address) begin
	doLoadStuff;
end


task doLoadStuff();

	if (ENDIANNESS==0) begin // big endian
		value1 = {
			memory[(address+0)%LENGTH],
			memory[(address+1)%LENGTH],
			memory[(address+2)%LENGTH],
			memory[(address+3)%LENGTH]
		};
		value2 = {
			memory[(address+4)%LENGTH],
			memory[(address+5)%LENGTH],
			memory[(address+6)%LENGTH],
			memory[(address+7)%LENGTH]
		};
	end
	else if (ENDIANNESS==1) begin // little endian
		value1 = {
			memory[(address+3)%LENGTH],
			memory[(address+2)%LENGTH],
			memory[(address+1)%LENGTH],
			memory[(address+0)%LENGTH]
		};
		value2 = {
			memory[(address+7)%LENGTH],
			memory[(address+6)%LENGTH],
			memory[(address+5)%LENGTH],
			memory[(address+4)%LENGTH]
		};
	end
	else begin
		$display("Error: Instmem ENDIANNESS should be 0 (big) or 1 (little).");
		$finish(1);
	end

endtask


endmodule

// verilator lint_on MULTIDRIVEN