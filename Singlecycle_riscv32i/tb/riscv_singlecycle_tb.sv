
module RiscvSingleCycle_tb ();

	reg clk_i = 0;
	reg rst_ni = 1;
	wire [31:0] rf_data_hex;

	always begin
		#1 clk_i = !clk_i;
	end

	initial begin
		// dump
		$dumplimit(1000*1000*10); // 10mb
		$dumpfile("riscv_singlecycle.vcd");
		$dumpvars();

		for (int i = 0; i<=31; i++) begin
			$dumpvars(0, cpu.regfile.memory[i]);
		end
		for (int i = 0; i<=99; i++) begin
			$dumpvars(0, cpu.datamem.memory[i]);
		end
		for (int i = 0; i<=199; i++) begin
			$dumpvars(0, cpu.instmem.memory[i]);
		end

		#100000;
		$finish;
	end

	riscv_singlecycle cpu ( .* );
endmodule