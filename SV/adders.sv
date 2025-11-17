`timescale 1ns / 1ps

module HA (
    input A, B,
    output S, Cout
);
    assign S = A^B;
    assign Cout = A&B;
endmodule

module FA (
    input A, B, Cin,
    output S, Cout
);
    assign S = A^B^Cin;
    assign Cout = (A&B) | (B&Cin) | (Cin&A);
endmodule

module RCA #(
    parameter N = 4
)(
    input [N-1:0] A, B,
    input Cin,
    output [N-1:0] S,
    output Cout
);
    genvar i;
    wire [N-1:0] C;
    assign Cout = C[N-1];
    FA fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(C[0]));
    generate
    for(i=1; i<N; i=i+1) begin
        FA fa(.A(A[i]), .B(B[i]), .Cin(C[i-1]), .S(S[i]), .Cout(C[i]));
    end
    endgenerate
endmodule

/*
    D = A^B^Bin
    Bout = (A.B' + B'.Bin' + A.Bin')'
*/
module RCA_SUB #(
    parameter N = 4
)(
    input [N-1:0] A, B,
    input Bin,
    output [N-1:0] D,
    output Bout
);
    wire [N-1:0] B_comp = ~B;
    wire temp;
    assign Bout = ~temp;
    RCA #(.N(N)) rca(.A(A), .B(B_comp), .Cin(~Bin), .S(D), .Cout(temp));
endmodule

/* Additional overflow flag introduced */
module adder_2s_comp #(
    parameter N = 4
)(
    input [N-1:0] A, B,
    input Cin,
    output [N-1:0] S,
    output Ov, Cout
);
    genvar i;
    wire [N-1:0] C;

    FA fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(C[0]));
    generate
    for(i=1; i<N; i=i+1) begin: fa
        FA fa(.A(A[i]), .B(B[i]), .Cin(C[i-1]), .S(S[i]), .Cout(C[i]));
    end
    endgenerate

    assign Cout = C[N-1];
    assign Ov = C[N-2]^C[N-1];

endmodule