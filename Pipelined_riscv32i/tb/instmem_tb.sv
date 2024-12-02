

module Instmem_tb();
	
reg [3:0] address;
reg clock;
reg reset;
wire [31:0] beValue;
wire [31:0] leValue;

Instmem #( .ENDIANNESS(0) ) beInstmem ( .*, .value(beValue) );
Instmem #( .ENDIANNESS(1) ) leInstmem ( .*, .value(leValue) );

always begin
	#2 clock = ~clock;
end

int errorNo = 1;
initial begin

	// initial values
	clock = 0;
	reset = 1;

	// dump
	$dumplimit(1000*1000*1); // 1mb
	$dumpfile("instmem.vcd");
	$dumpvars();

	for (int i = 0; i<10; i++) begin
		$dumpvars(0, leInstmem.memory[i]);
		$dumpvars(0, beInstmem.memory[i]);
	end

	#1;

	// All memory cells should initially be zero
	for (int i = 0; i<10; i++) begin
		if (leInstmem.memory[i] == 0); else $fatal(errorNo++);
		if (beInstmem.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<10; i++) begin
		address = i[3:0];
		#1;
		if (leValue == 0); else $fatal(errorNo++);
		if (beValue == 0); else $fatal(errorNo++);
	end
	
	// writing and then reading
	for (int i = 0; i<10; i++) begin
		leInstmem.memory[i] = 8'(8'h11 * i);
		beInstmem.memory[i] = 8'(8'h11 * i);
	end

	address = 1;
	#1;
	if (beValue == 32'h11223344); else $fatal(errorNo++);
	if (leValue == 32'h44332211); else $fatal(errorNo++);
	
	address = 9;
	#1;
	if (beValue == 32'h99001122); else $fatal(errorNo++);
	if (leValue == 32'h22110099); else $fatal(errorNo++);	

	$display("No errors");
	$finish();
end


endmodule
