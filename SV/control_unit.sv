`timescale 1ns/1ps

module control_unit (
	input 			Ctrl1, Ctrl0,
	input		[3:0]	A, B,
	output logic	[3:0]	ResL, ResH,
	output logic		Zero, Overflow, Cout
);
	/*
		CU operations:
		00 - A+B	01 - A-B
		10 - A*B	11 - A&B
	*/
	wire [7:0] res_mult;
	wire [3:0] res_alu;
	ALU alu(
		/* We will use ALU for AND and add/sub ops.
		   - For all cases, A is not inverted, thus ALU_cont[3] = 0
		   - If we do subtraction, ALU_cont[2] = 1, else 0. Thus we want it to be set IF Ctrl1=0 and Ctrl0=1
		   - Add/sub is to be used only when Ctrl1 = 0, thus ALU_cont[1] = ~Ctrl1.
		   - ALU_cont[0]=1 corresponds to OR/comparator branches; it is thus always set to 0.
		*/
		.ALU_cont({1'b0, Ctrl0&(~Ctrl1), (~Ctrl1), 1'b0}),
		.A(A), .B(B), .Cin(Ctrl0&(~Ctrl1)),
		.X(res_alu), .Zero(Zero), .Overflow(Overflow), .Cout(Cout)
	);
	signedMultiplier mult(.A(A), .B(B), .P(res_mult));
	assign ResL = Ctrl1&(~Ctrl0) ? res_mult[3:0] : res_alu;
	MUX_4_1 mux(.I0({4{Cout}}), .I1({4{Cout}}), .I2(res_mult[7:4]), .I3(4'b0), .S({Ctrl1, Ctrl0}), .Y(ResH));
endmodule