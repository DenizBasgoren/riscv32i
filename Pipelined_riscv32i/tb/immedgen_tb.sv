module ImmedGen_tb ();
    

	reg [3:0] instType;
    reg [31:0] inst;
    wire [31:0] immed;

    ImmedGen immedGen ( .* );

	int errorNo = 1;

    initial begin
		instType = 0;
		inst = 0;

		// 0:load 1:imm 2:store 3:reg 4:lui 5:auipc 6:brnch 7:jalr 8:jal
		
        #1;
        instType = 4; // lui
        inst = 32'h030391b7; // lui x3, 12345
        #1;
		if (immed == 50565120); else $fatal(errorNo++); // must print immed<<12

        instType = 8; // jal
        inst = 32'h038031ef; // jal x3, 12344
        #1;
		if (immed == 12344); else $fatal(errorNo++);

        instType = 6; // brnch
        inst = 32'h08418063; // beq x3, x4, 128
        #1;
		if (immed == 128); else $fatal(errorNo++);

        instType = 2; // store
        inst = 32'h08320023; // sb x3, 128(x4)
        #1;
		if (immed == 128); else $fatal(errorNo++);

        instType = 0; // load
        inst = 32'h08020183; // lb x3, 128(x4)
        #1;
		if (immed == 128); else $fatal(errorNo++);

        instType = 3; // reg
        inst = 32'h005201b3; // add x3,x4,x5
        #1;
		if (immed === 32'bx); else $fatal(errorNo++);

        instType = 1; // immed
        inst = 32'h07b20193; // addi x3,x4,123
        #1;
		if (immed == 123); else $fatal(errorNo++);

		$display("No errors");
		$finish();

    end
    

endmodule
