`timescale 1ns/1ps

module alu_tb();
    reg signed [3:0] a=4'b1101, b=4'b0111;
    reg [3:0] aluop=4'b0000;
    reg clk=1'b0;
    wire signed [3:0] res;
    wire cout, ov, zero;

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

    ALU dut(.A(a), .B(b), .ALU_cont(aluop), .Cin(aluop[3]|aluop[2]), .X(res), .Cout(cout), .Zero(zero), .Overflow(ov));

    always @(posedge clk) begin
        a <= $random()%16;
        b <= $random()%16;
        if(aluop == 4'b0111) $display("op: %b\ta: %b,\tb: %b,\ta<b: %b,\t\tcout = %b,\tov=%b\tzero = %b", aluop, a, b, res[0], cout, ov, zero);
        else if(aluop == 4'b1011) $display("op: %b\ta: %b,\tb: %b,\tb<a: %b,\t\tcout = %b,\tov=%b\tzero = %b", aluop, a, b, res[0], cout, ov, zero);
        else if(aluop[1:0]==2'b10) $display("op: %b\ta: %d,\t\tb: %d,\t\tres: %d,\tcout = %b,\tov=%b\tzero = %b", aluop, a, b, res, cout, ov, zero);
        else $display("op: %b\ta: %b,\tb: %b,\tres: %b,\tcout = %b,\tov=%b\tzero = %b", aluop, a, b, res, cout, ov, zero);
    end
    initial begin
        #64
        // wait(~|{a,b});
        $finish;
    end
endmodule