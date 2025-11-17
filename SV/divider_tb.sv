`timescale 1ns/1ps

module divider_tb();

    reg [7:0] dividend = 8'd225;
    reg [7:0] divisor = (8'd0);
    wire [7:0] quotient;
    wire [7:0] remainder;
    reg clk = 1'b1;
    reg rst = 1'b1;
    wire done, error;

    initial begin
        $monitor("%d %d %d %d\tError: %b", divisor, dividend, quotient, remainder, error);
    end

    initial begin
        forever begin
            #0.5 clk = ~clk;
        end
    end

    // divider #(.ldvn(8), .ldvr(8), .lqtn(8), .lrem(8)) dut (.clk(clk), .rst(rst), .dividend(dividend), .divisor(divisor), .quotient(quotient), .remainder(remainder), .done(done), .error(error), .dvsr_debug(dvsr_debug));

    divider #(.N(8)) dut(.clk(clk), .rst(rst), .divisor(divisor), .dividend(dividend), .quotient(quotient), .remainder(remainder), .done(done), .error(error));

    initial begin
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        #1 rst = 1'b1;
        #1000 $finish;
    end

endmodule