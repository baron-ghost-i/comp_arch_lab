`timescale 1ns / 1ps

module Multiplier #(
    parameter N = 4
)(
    input [N-1:0] A, B,
    output [2*N-1:0] P
);
    genvar i, j;
    wire [N-1:0] prod[0:N-1];
    wire [N-1:0] partial[0:N-1];

    generate
        for(i=0; i<N; i=i+1) begin
            assign prod[i] = {N{B[i]}} & A;
        end
        assign partial[0] = {1'b0, prod[0][N-1:1]};
        assign P[0] = prod[0][0];
        
        for(i=1; i<N; i=i+1) begin
            RCA #(.N(N)) rca1(
                .A(partial[i-1]),
                .B(prod[i]),
                .Cin(1'b0),
                .S({partial[i][N-2:0], P[i]}),
                .Cout(partial[i][N-1])
            );
        end
    endgenerate
    assign P[2*N-1:N] = partial[N-1];
endmodule

module signedMultiplier #(
    parameter N = 4
)(
    input [N-1:0] A, B,
    output [2*N-1:0] P
);
    
    genvar i, j;
    wire [N-1:0] Amag, Bmag;
    wire A_cout, B_cout, P_cout, outsign;
    wire [2*N-1:0] Pmag;
    
    // take 2's complement iff input is signed and sign bit is set
    RCA #(.N(N)) rca_A(.A(A^{N{A[N-1]}}), .B({N{1'b0}}), .Cin(A[N-1]), .S(Amag), .Cout(A_cout));
    RCA #(.N(N)) rca_B(.A(B^{N{B[N-1]}}), .B({N{1'b0}}), .Cin(B[N-1]), .S(Bmag), .Cout(B_cout));
    assign outsign = A[N-1]^B[N-1];
    
    wire [N-1:0] prod[0:N-1];
    wire [N-1:0] partial[0:N-1];

    generate
        for(i=0; i<N; i=i+1) begin
            assign prod[i] = {N{Bmag[i]}} & Amag;
        end
        assign partial[0] = {1'b0, prod[0][N-1:1]};
        assign Pmag[0] = prod[0][0];
        
        for(i=1; i<N; i=i+1) begin
            RCA #(.N(N)) rca1(
                .A(partial[i-1]),
                .B(prod[i]),
                .Cin(1'b0),
                .S({partial[i][N-2:0], Pmag[i]}),
                .Cout(partial[i][N-1])
            );
        end
    endgenerate
    assign Pmag[2*N-1:N] = partial[N-1];
    RCA #(.N(2*N)) rca_out(.A(Pmag^{2*N{outsign}}), .B({2*N{1'b0}}), .Cin(outsign), .S(P), .Cout(P_cout));
endmodule