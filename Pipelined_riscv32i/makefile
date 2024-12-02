regfile:
	iverilog -g2005-sv src/regfile.sv tb/regfile_tb.sv
	./a.out
datamem:
	iverilog -g2005-sv src/datamem.sv tb/datamem_tb.sv
	./a.out
instmem:
	iverilog -g2005-sv src/instmem.sv tb/instmem_tb.sv
	./a.out
immedgen:
	iverilog -g2005-sv src/immedgen.sv tb/immedgen_tb.sv
	./a.out
cpu:
	iverilog -g2005-sv src/*.sv tb/riscv_pipelined_tb.sv
	rm ./*.log || true
	./a.out
prepare_c:
	riscv64-linux-gnu-gcc -march=rv32i -mabi=ilp32 -nostartfiles -nostdlib -static -Wl,-Tcompilation.ld $(SRC) -o $(SRC).elf
	riscv64-linux-gnu-objdump --disassemble-all --disassemble-zeroes -M numeric,no-aliases $(SRC).elf > $(SRC).dump
	node utils/prepareInstructions.js $(SRC).elf
prepare_asm:
	riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 $(SRC) -o $(SRC).elf
	riscv64-linux-gnu-objdump --disassemble-all --disassemble-zeroes -M numeric,no-aliases $(SRC).elf > $(SRC).dump
	node utils/prepareInstructions.js $(SRC).elf