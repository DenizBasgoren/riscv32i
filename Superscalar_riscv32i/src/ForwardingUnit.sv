
module ForwardingUnit (
	input wire [18:0] controlWord1Xstage,
	input wire [18:0] controlWord1Wstage,
	input wire [18:0] controlWord2Xstage,
	input wire [18:0] controlWord2Wstage,
	input wire [31:0] inst1,
	input wire [31:0] inst2,
	input wire [31:0] inst3,
	input wire [31:0] inst4,
	output reg [2:0]  forwardReg1From, // 0:no forward, 1-4: forward from 1-4
	output reg [2:0]  forwardReg2From,
	output reg [2:0]  forwardReg3From,
	output reg [2:0]  forwardReg4From
);

	//cw[7] is regwrite
	// inst[19:15] rs1
	// inst[11:7] rd
	// inst[24:20] rs2
	
always @(*) begin

	`define rs1 [19:15]
	`define rd [11:7]
	`define rs2 [24:20]

	// forwarding logic of reg1
	if (controlWord2Wstage[7] && inst4`rd && inst4`rd==inst1`rs1) begin
		forwardReg1From = 4;
	end
	else if (controlWord1Wstage[7] && inst2`rd && inst2`rd==inst1`rs1 ) begin
		forwardReg1From = 2;
	end
	else begin
		forwardReg1From = 0;
	end

	// of reg2
	if (controlWord2Wstage[7] && inst4`rd && inst4`rd==inst1`rs2) begin
		forwardReg2From = 4;
	end
	else if (controlWord1Wstage[7] && inst2`rd && inst2`rd==inst1`rs2 ) begin
		forwardReg2From = 2;
	end
	else begin
		forwardReg2From = 0;
	end

	// of reg3
	if (controlWord1Xstage[7] && inst1`rd && inst1`rd==inst3`rs1) begin
		forwardReg3From = 1;
	end
	else if (controlWord2Wstage[7] && inst4`rd && inst4`rd==inst3`rs1) begin
		forwardReg3From = 4;
	end
	else if (controlWord1Wstage[7] && inst2`rd && inst2`rd==inst3`rs1) begin
		forwardReg3From = 2;
	end
	else begin
		forwardReg3From = 0;
	end

	// of reg4
	if (controlWord1Xstage[7] && inst1`rd && inst1`rd==inst3`rs2) begin
		forwardReg4From = 1;
	end
	else if (controlWord2Wstage[7] && inst4`rd && inst4`rd==inst3`rs2) begin
		forwardReg4From = 4;
	end
	else if (controlWord1Wstage[7] && inst2`rd && inst2`rd==inst3`rs2) begin
		forwardReg4From = 2;
	end
	else begin
		forwardReg4From = 0;
	end

	



	`undef rs1
	`undef rd
	`undef rs2
	
end

endmodule