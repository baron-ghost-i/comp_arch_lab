`timescale 1ns/1ps

module alu_tb();
    reg signed [3:0] a=4'b1101, b=4'b0111;
    reg [1:0] ctrl=2'b00;
    reg clk=1'b0;
    wire signed [7:0] res;
    wire cout, ov, zero;

    initial begin
        forever begin
            #0.5 clk = ~clk;
        end
    end

    initial begin
        forever begin
            #4 ctrl = ctrl+1;
        end
    end

    control_unit dut(.Ctrl1(ctrl[1]), .Ctrl0(ctrl[0]), .A(a), .B(b), .ResH(res[7:4]), .ResL(res[3:0]), .Zero(zero), .Overflow(ov), .Cout(cout));

    always @(posedge clk) begin
        a <= $random()%256;
        b <= $random()%256;
        $display("ctrl: %b\ta: %b,\tb: %b,\tres: %b,\tcout = %b,\tov=%b\tzero = %b", ctrl, a, b, res, cout, ov, zero);
    end
    initial begin
        #16
        $finish;
    end
endmodule