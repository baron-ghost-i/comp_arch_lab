`timescale 1ns/1ps

module divider #(
    // lengths of all registers
    parameter integer N = 4
) (
    input clk, rst,
    input [N-1:0] divisor, dividend,
    output reg [N-1:0] quotient = 0,
    output reg [2*N-1:0] remainder = 0,
    output done, error
);
    localparam integer counter_size = $clog2(N)+1;

    reg	[counter_size-1:0]	counter = {counter_size{1'b0}};
    reg				en = 1'b1;

    reg	[2*N-1:0]		dvsr;
    wire	[2*N-1:0]		temp;
    wire				temp_bit;

    assign 				done = ~en;
    assign				error = ~(|divisor);

    // Logic for enable and counter
    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            en		<= 1'b1;
            counter		<= {counter_size{1'b0}};
            quotient	<= {N{1'b0}};
            remainder	<= {{N{1'b0}}, dividend};
            dvsr		<= {divisor, {N{1'b0}}};
        end
        
        else if(error) begin
            en	<= 1'b0;
            counter	<= {counter_size{1'b0}};
            quotient <= {N{1'b0}};
            remainder <= {2*N{1'b0}};
        end

        else if(en) begin
            if(counter == N) en <= 1'b0;
            counter	<= counter+1;
        end
    end

    // division logic
    RCA_SUB #(.N(2*N)) subtractor (.A(remainder), .B(dvsr), .Bin(1'b0), .D(temp), .Bout(temp_bit));
    always @(posedge clk or negedge rst) begin
        if(en) begin
            quotient <= {quotient[N-2:0], ~temp_bit};
            remainder <= (temp_bit)?(remainder):(temp);
            dvsr <= {1'b0, dvsr[2*N-1:1]};
        end
    end

endmodule