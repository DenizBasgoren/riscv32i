cpu:
	iverilog -g2005-sv src/*.sv tb/riscv_superscalar_tb.sv
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