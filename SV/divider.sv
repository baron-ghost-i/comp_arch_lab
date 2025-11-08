`timescale 1ns/1ps

// module divider #(
// 	// lengths of all registers
// 	parameter integer ldvn = 8,
// 	parameter integer ldvr = 8,
// 	parameter integer lqtn = 8,
// 	parameter integer lrem = 8
// ) (
// 	input clk,
// 	input rst,		// active low rst
	
// 	input [ldvn-1:0] dividend,
// 	input [ldvr-1:0] divisor,
	
// 	output reg [lqtn-1:0] quotient,
// 	output reg [lrem-1:0] remainder,

// 	output [ldvn-1:0] dvsr_debug,
	
// 	output done,
// 	output error		// only triggered when divisor is 0
// );

// 	localparam integer	counter_size = $clog2(ldvr);

// 	reg	[counter_size-1:0]	counter;
// 	reg				en = 1'b1;

// 	reg	[ldvr-1:0]		dvsr;
// 	wire	[lrem-1:0]		temp;
// 	wire				temp_bit;

// 	assign 				done = ~en;
// 	assign				error = ~(|divisor);
// 	assign				dvsr_debug = dvsr;

// 	// Logic for enable and counter
// 	always @(posedge clk or negedge rst) begin
// 		if(~rst) begin
// 			en		<= 1'b1;
// 			counter		<= {counter_size{1'b0}};
// 			quotient	<= {lqtn{1'b0}};
// 			remainder	<= dividend;
// 			dvsr		<= divisor;
// 		end
		
// 		else if(error) begin
// 			en	<= 1'b0;
// 			counter	<= {counter_size{1'b0}};
// 		end

// 		else if(en) begin
// 			if(counter == lqtn+1) begin
// 				counter	<= {counter_size{1'b0}};
// 				en	<= 1'b0;
// 			end
// 			else
// 				counter	<= counter+1;
// 		end
// 	end
// 	// division logic
// 	RCA_SUB #(.N(lrem)) subtractor (.A(remainder), .B(dvsr), .Bin(1'b0), .D(temp), .Bout(temp_bit));
// 	always @(posedge clk or negedge rst) begin
// 		if(en) begin
// 			quotient <= {quotient[lqtn-2:0], ~temp_bit};
// 			remainder <= (temp_bit)?(remainder):(temp);
// 			dvsr <= {1'b0, dvsr[ldvr-1:1]};
// 		end
// 	end

// endmodule

`timescale 1ns/1ps

module divider #(
	parameter N = 4
) (
	input		clk, rst,
	input		[N-1:0]	divisor,  dividend,
	output	reg	[N-1:0]	quotient,
	output	reg	[N-1:0]	remainder,
	output 		done, error
);
	reg [N-1:0] rem;

	reg en = 1'b1;
	assign done = ~en;
	assign error = ~(|divisor);

	wire [N-1:0] q_in, r_in;
	wire q_cout, r_bout;

	RCA #(.N(N)) adder(.A(quotient), .B({N{1'b0}}), .Cin(1'b1), .S(q_in), .Cout(q_cout));
	RCA_SUB #(.N(N)) subtractor(.A(remainder), .B(divisor), .Bin(1'b0), .D(r_in), .Bout(r_bout));

	always @(posedge clk or negedge rst) begin
		if(~rst) begin
			en <= 1'b1;
			quotient <= {N{1'b0}};
			remainder <= dividend;
		end
		else if (error) begin
			en <= 1'b0;
			quotient <= {N{1'b0}};
			remainder <= {N{1'b0}};
		end
		else if(en) begin
			if(r_bout) en <= 1'b0;
			else begin
				quotient <= q_in;
				remainder <= r_in;
			end
		end
	end
endmodule