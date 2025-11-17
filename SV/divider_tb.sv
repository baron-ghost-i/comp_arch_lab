`timescale 1ns/1ps

module divider_tb();

    reg [3:0] dividend = 4'd15;
    reg [3:0] divisor = 4'd7;
    wire [3:0] quotient;
    wire [7:0] remainder;
    wire [3:0] dbg;
    reg clk = 1'b0;
    reg rst = 1'b1;
    wire done, error;

    initial begin
        forever begin
            #0.5 clk = ~clk;
        end
    end

    divider #(.N(4)) dut (.clk(clk), .rst(rst), .dividend(dividend), .divisor(divisor), .quotient(quotient), .remainder(remainder), .done(done), .error(error));

    initial begin
        for(integer i=0; i<16; i=i+1) begin
            for(integer j=0; j<16; j=j+1) begin
                divisor = i;
                dividend = j;
                @(posedge clk); rst = 1'b0;
                @(posedge clk);	rst = 1'b1;
                wait(done);
                $display("Divisor: %d\tDividend: %d\tQuotient: %d\tRemainder: %d\tError: %b\tDone: %b", divisor, dividend, quotient, remainder, error, done);
            end
        end
        $finish;
    end

endmodule