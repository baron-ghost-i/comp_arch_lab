`timescale 1ns/1ps

module alu_tb();
	reg signed [7:0] a=8'b1101, b=8'b0111;
	reg [3:0] aluop=4'b0000;
	reg clk=1'b0;
	wire signed [7:0] res;
	wire cout;
	wire zero;

	initial begin	
		forever begin
			#0.5 clk = ~clk;
		end
	end

	initial begin	
		forever begin
			#4 aluop = aluop+1;
		end
	end

	ALU_8bit dut(.A(a), .B(b), .ALU_cont(aluop), .Cin(aluop[3]|aluop[2]), .X(res), .Cout(cout), .Zero(zero));

	always @(posedge clk) begin
		a <= $random()%256;
		b <= $random()%256;
		if(aluop == 4'b0111) $display("op: %b\ta: %d,\tb: %d,\ta<b: %b,\t\tcout = %b,\tzero = %b", aluop, a, b, res[0], cout, zero);
		else if(aluop == 4'b1011) $display("op: %b\ta: %d,\tb: %d,\tb<a: %b,\t\tcout = %b,\tzero = %b", aluop, a, b, res[0], cout, zero);
		else if(aluop[1:0]==2'b10) $display("op: %b\ta: %d,\tb: %d,\tres: %d,\tcout = %b,\tzero = %b", aluop, a, b, res, cout, zero);
		else $display("op: %b\ta: %b,\tb: %b,\tres: %b,\tcout = %b,\tzero = %b", aluop, a, b, res, cout, zero);
	end
	initial begin
		#64
		// wait(~|{a,b});
		$finish;
	end
endmodule