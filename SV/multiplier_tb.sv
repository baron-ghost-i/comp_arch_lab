`timescale 1ns/1ps


module multiplier_tb(
);
    reg [3:0] A = 4'b0000;
    reg [3:0] B = 4'b0000;
    reg signed [3:0] sA = 4'b0000;
    reg signed [3:0] sB = 4'b0000;

    wire [7:0] P;
    wire signed [7:0] sP;
    Multiplier #(.N(4)) DUT(.A(A), .B(B), .P(P));
    signedMultiplier #(.N(4)) sDUT(.A(A), .B(B), .P(sP));

    initial begin
        $monitor("A: %d (%d), B: %d (%d), P: %d (%d)", A, sA, B, sB, P, sP);
        for(integer i=0; i<16; i=i+1) begin
            for(integer j=0; j<16; j=j+1) begin
                #1 A <= i; B <= j; sA <= i; sB <= j;
            end
        end
    #1 $finish;
    end
endmodule
