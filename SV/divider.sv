`timescale 1ns/1ps

module divider #(
	// lengths of all registers
	parameter integer ldvn = 8,
	parameter integer ldvr = 8,
	parameter integer lqtn = 4,
	parameter integer lrem = 8
) (
	input clk,
	input rst,		// active low rst
	
	input [ldvn-1:0] dividend,
	input [ldvr-1:0] divisor,
	
	output reg [ldvr-1:0] quotient,
	output reg [ldvr-1:0] remainder,
	
	output done,
	output error		// only triggered when divisor is 0
);

	localparam integer	counter_size = $clog2(ldvr);

	reg	[counter_size-1:0]	counter = 'b0;
	reg				en = 1'b1;

	reg	[ldvr-1:0]		dvsr = divisor;
	wire	[lrem-1:0]		temp;
	wire				temp_bit;

	assign 				done = ~en;
	assign				error = ~(|divisor);

	// Logic for enable and counter
	always @(posedge clk or negedge rst) begin
		if(~rst) begin
			en	<= 1'b1;
			counter	<= {counter_size{1'b0}};
		end
		
		else if(error) begin
			en	<= 1'b0;
			counter	<= {counter_size{1'b0}};
		end

		else if(en) begin
			if(counter == ldvr-1) begin
				counter	<= {counter_size{1'b0}};
				en	<= 1'b0;
			end
			else
				counter	<= counter+1;
		end
	end

	// division logic
	RCA_SUB #(.N(lrem)) subtractor (.A(remainder), .B(divisor), .Bin(1'b0), .D(temp), .Bout(temp_bit));
	always @(posedge clk or negedge rst) begin
		if(~rst) begin
			quotient  <= {lqtn{1'b0}};
			remainder <= {lrem{1'b0}};
		end
		else if(en) begin
			if(counter == {counter_size{1'b0}})
				remainder <= dividend;
			else begin
				quotient <= {quotient[lqtn-2:0], ~temp};
				remainder <= temp[lrem-1]?remainder:temp;
			end
			dvsr <= {1'b0, dvsr[ldvr-1:1]};
		end
	end

endmodule