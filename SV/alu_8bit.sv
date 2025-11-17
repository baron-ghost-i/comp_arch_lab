`timescale 1ns/1ps

module ALU_8bit (
    /*
    * ALU Control Ops:
        0000 - A&B      0001 - A|B      0010 - A+B      0011 - ignored
        0100 - A&(~B)   0101 - A|~B     0110 - A-B      0111 - A<B
        1000 - (~A)&B   1001 - ~A|B     1010 - B-A      1011 - A>B
        1100 - ~(A|B)   1101 - ~(A&B)   1110 - 2-(B+A)  1111 - ignored
    */
    input [3:0] ALU_cont,
    input [7:0] A, B,
    input Cin,
    output [7:0] X,
    output Zero, Overflow, Cout
);

    wire z0, z1, carry, slt;
    wire [7:0] X_pre;
    wire ov[1:0];

    assign Zero = z0 & z1;
    assign overflow = (A[7]^B[7])&(A[7]^X_pre[7]);
    
    // hard-coding ALU_cont so that alu operation xx11 leads to xx10, where it will be processed further.
    ALU lsb(.ALU_cont({ALU_cont[3:1], (~ALU_cont[1])&ALU_cont[0]}), .A(A[3:0]), .B(B[3:0]), .Cin(Cin^(ALU_cont[3]|ALU_cont[2])), .X(X_pre[3:0]), .Zero(z0), .Cout(carry), .Overflow(ov[0])); 
    ALU msb(.ALU_cont({ALU_cont[3:1], (~ALU_cont[1])&ALU_cont[0]}), .A(A[7:4]), .B(B[7:4]), .Cin(carry), .X(X_pre[7:4]), .Zero(z1), .Cout(Cout), .Overflow(ov[1]));

    assign slt = A[7]^B[7] ?
            (ALU_cont[2] & A[7]) | (ALU_cont[3] & B[7]) :
            X_pre[7];
    assign Overflow = ov[1];
    assign X = (ALU_cont[1]&ALU_cont[0]) ? {7'b0, slt} : X_pre;
endmodule