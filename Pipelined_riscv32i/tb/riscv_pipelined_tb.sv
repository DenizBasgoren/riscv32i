
module RiscvPipelined_tb ();

	reg clock = 0;
	reg reset = 1;
	wire [31:0] dummyOutput;

	always begin
		#1 clock = !clock;
	end

	time t = 0;
	always begin
		#1 t = $time;
	end

	initial begin
		// dump
		$dumplimit(1000*1000*10); // 10mb
		$dumpfile("riscv_pipelined.vcd");
		$dumpvars();

		for (int i = 0; i<=31; i++) begin
			$dumpvars(0, cpu.regfile.memory[i]);
		end

		#100000;
		$finish;
	end

	riscv_pipelined cpu ( .* );
endmodule