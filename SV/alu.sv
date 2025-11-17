`timescale 1ns/1ps

module MUX_4_1(
    input [3:0] I0, I1, I2, I3,
    input [1:0] S,
    output logic [3:0] Y
);
    always_comb begin : mux
        case(S)
            2'b00: Y = I0;
            2'b01: Y = I1; 
            2'b10: Y = I2; 
            2'b11: Y = I3;
            default: Y = 4'b0;
        endcase
    end		
endmodule

module ALU(
    /*
    * ALU Control Ops:
        0000 - A&B	0001 - A|B	0010 - A+B	0011 - ignored
        0100 - A&(~B)	0101 - A|~B	0110 - A-B	0111 - A<B
        1000 - (~A)&B	1001 - ~A|B	1010 - B-A	1011 - A>B
        1100 - ~(A|B)	1101 - ~(A&B)	1110 - ignored	1111 - ignored
    */
    input	[3:0]	ALU_cont,
    input	[3:0]	A, B,
    input		Cin,	// acts as dual for B_in when subtracting
    output	[3:0] 	X,
    output		Zero, Overflow,
    output		Cout	// acts as dual for B_out when subtracting
);
    /* Arithmetic result wires */
    wire		carry_borrow_out;
    wire		slt;

    /* Check if A or B needs to be inverted */
    wire		invA = ALU_cont[3],
            invB = ALU_cont[2];

    /* Check ALU operation to be performed */
    wire	[1:0]	ALUOp = ALU_cont[1:0];

    /* MUX to select ALU output based on operation */
    wire	[3:0]	mux_in 	  [0:3];
    MUX_4_1 mux(.I0(mux_in[0]), .I1(mux_in[1]), .I2(mux_in[2]), .I3(mux_in[3]), .S(ALUOp), .Y(X));

    /* Invert A and/or B as needed */
    wire	[3:0]	A_in = A^{4{invA}},
            B_in = B^{4{invB}}; 

    /* Op00: AND */
    assign mux_in[0] = A_in & B_in;
    /* Op01: OR */
    assign mux_in[1] = A_in | B_in;
    /* Op10: Adder/Subtractor */
    adder_2s_comp	add_sub(.A(A_in), .B(B_in), .Cin(Cin), .S(mux_in[2]), .Cout(carry_borrow_out), .Ov(Overflow));
    /* Op11: Comparator */
    assign slt = Overflow ?
            (invB & A[3]) | (invA & B[3]) : // if invA, B-A is being performed so sign of B matters, and vice-versa. Op1111 is invalid
            mux_in[2][3];			// sign of difference
    assign mux_in[3] = {3'b0, slt};

    assign		Cout = carry_borrow_out;
    assign		Zero = ~|X;

endmodule