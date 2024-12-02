
// verilator lint_off WIDTHTRUNC

module Regfile_tb();
	
reg [4:0] addressForReading1;
reg [4:0] addressForReading2;
reg [4:0] addressForWriting;
reg [31:0] valueForWriting;
reg clock;
reg reset;
reg writeEnable;
wire [31:0] value1;
wire [31:0] value2;

Regfile regfile ( .* );

always begin
	#2 clock = ~clock;
end

int errorNo = 1;
initial begin

	// initial values
	clock = 0;
	reset = 1;
	writeEnable = 0;

	// dump
	$dumplimit(1000*1000*1); // 1mb
	$dumpfile("regfile.vcd");

	$dumpvars();

	for (int i = 0; i<=31; i++) begin
		$dumpvars(0, regfile.memory[i]);
	end

	#1;

	// All registers should initially be zero
	for (int i = 0; i<=31; i++) begin
		if (regfile.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<=31; i++) begin
		addressForReading1 = i;
		addressForReading2 = 31-i;
		#1;
		if (value1 == 0); else $fatal(errorNo++);
		if (value2 == 0); else $fatal(errorNo++);
	end
	
	// write doesnt work unless writeEnable=1
	for (int i = 0; i<=31; i++) begin
		addressForWriting = i;
		valueForWriting = i+10;
		#1;
	end

	for (int i = 0; i<=31; i++) begin
		if (regfile.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<=31; i++) begin
		addressForReading1 = i;
		addressForReading2 = 31-i;
		#1;
		if (value1 == 0); else $fatal(errorNo++);
		if (value2 == 0); else $fatal(errorNo++);
	end

	// write works when writeEnable=1
	writeEnable = 1;
	for (int i = 0; i<=31; i++) begin
		addressForWriting = i;
		valueForWriting = i+10;
		@(posedge clock); #1;
	end
	writeEnable = 0;

	if (regfile.memory[0] == 0); else $fatal(errorNo++);
	for (int i = 1; i<=31; i++) begin
		if (regfile.memory[i] == i+10); else $fatal(errorNo++);
	end
	for (int i = 0; i<=31; i++) begin
		addressForReading1 = i;
		addressForReading2 = 31-i;
		#1;
		if (addressForReading1 == 0) begin
			if (value1 == 0); else $fatal(errorNo++);
		end
		else begin
			if (value1 == i+10); else $fatal(errorNo++);
		end
		if (addressForReading2 == 0) begin
			if (value2 == 0); else $fatal(errorNo++);
		end
		else begin
			if (value2 == (31-i)+10); else $fatal(errorNo++);
		end
	end

	// reset resets asynchronously
	@(posedge clock);
	#1;
	reset = 0;
	#1;
	reset = 1;
	#1;

	// all registers are zero
	for (int i = 0; i<=31; i++) begin
		if (regfile.memory[i] == 0); else $fatal(errorNo++);
	end
	for (int i = 0; i<=31; i++) begin
		addressForReading1 = i;
		addressForReading2 = 31-i;
		if (value1 == 0); else $fatal(errorNo++);
		if (value2 == 0); else $fatal(errorNo++);
	end

	// writing works again after resetting
	writeEnable = 1;
	for (int i = 0; i<=31; i++) begin
		addressForWriting = i;
		valueForWriting = i+10;
		@(posedge clock); #1;
	end
	writeEnable = 0;

	if (regfile.memory[0] == 0); else $fatal(errorNo++);	
	for (int i = 1; i<=31; i++) begin
		if (regfile.memory[i] == i+10); else $fatal(errorNo++);
	end
	for (int i = 0; i<=31; i++) begin
		addressForReading1 = i;
		addressForReading2 = 31-i;
		#1;
		if (addressForReading1 == 0) begin
			if (value1 == 0); else $fatal(errorNo++);
		end
		else begin
			if (value1 == i+10); else $fatal(errorNo++);
		end
		if (addressForReading2 == 0) begin
			if (value2 == 0); else $fatal(errorNo++);
		end
		else begin
			if (value2 == (31-i)+10); else $fatal(errorNo++);
		end
	end

	$display("No errors");
	$finish();
end

endmodule

// verilator lint_on WIDTHTRUNC