/*******************************************************/
/********************Multiplier module********************/
/*****************************************************/
// add additional modules as needs, such as full adder, and others

// multiplier module
module mult
(
	input [7:0] x,
	input [7:0] y,
	output [15:0] out,   // Result of the multiplication
	output [15:0] pp [9] // for automarker to check partial products of a multiplication
);
	// Declare a 9-high, 16-deep array of signals holding sums of the partial products.
	// They represent the _input_ partial sums for that row, coming from above.
	// The input for the "ninth row" is actually the final multiplier output.
	// The first row is tied to 0.
    assign pp[0] = '0;

	// Make another array to hold the carry signals
	logic [16:0] cin[9];
	assign cin[0] = '0;

	// Cin signals for the final (fast adder) row
	logic [16:7] cin_final;
	assign cin_final[7] = '0;

	// TODO: complete the following digital logic design of a carry save multiplier (unsigned)
	// Note: generate_hw tutorial can help you describe duplicated modules efficiently

	// Note: partial product of each row is the result coming out from a full adder at the end of that row

	// Note: a "Fast adder" operates on columns 8 through 15 of final row.

	// Initial first row pp
	for (genvar k=0; k<8; k=k+1) begin: init_pp
	   assign pp[1][k] = x[k] & y[0];
	end

	assign pp[1][8] = 0;

	// Initial first row cin
	for(genvar z=1; z<9; z=z+1) begin: init_cin
	    assign cin[1][z] = x[z-1] & y[1];
	end

	//till end
    genvar i;
    genvar j;
    genvar u;

    for(i=1; i<7; i++) begin: large_for_loop
        //pass the pp
        for (j=0; j<i; j++) begin: init
            assign pp[i+1][j]=pp[i][j];
        end
        //the first adder always use 0 bit
        full_adder first_add(
            .a(pp[i][i]),
            .b(1'b0),
            .cin(cin[i][i]),
            .cout(cin[i+1][i+1]),
            .s(pp[i+1][i])
        );

        for (u=0; u<6; u=u+1) begin: multing_stuff
            full_adder fa_inst(
                .a(pp[i][u+i+1]),
                .b(x[u]&y[i+1]),
                .cin(cin[i][u+i+1]),
                .cout(cin[i+1][u+i+2]),
                .s(pp[i+1][u+i+1])
            );
        end

        //the final adder
        if(i==1)
            full_adder final_add(
                .a(1'b0),
                .b(x[6]&y[i+1]),
                .cin(cin[i][7+i]),
                .cout(cin[i+1][7+i+1]),
                .s(pp[i+1][7+i])
            );
        else
            full_adder final_add_two(
                .a(x[7]&y[i]),
                .b(x[6]&y[i+1]),
                .cin(cin[i][7+i]),
                .cout(cin[i+1][7+i+1]),
                .s(pp[i+1][7+i])
            );
    end

    //final layers
    //transport
    for (j=0; j<7; j++) begin: final_init
        assign pp[8][j]=pp[7][j];
    end

    //final layer adders
    for (j=0; j<7; j++) begin: final_middle
        full_adder final_layer_middle(
            .a(pp[7][j+7]),
            .b(cin[7][j+7]),
            .cin(cin_final[j+7]),
            .cout(cin_final[j+7+1]),
            .s(pp[8][j+7])
        );
    end

    //final adders
    full_adder final_layer_middle(
        .a(x[7]&y[7]),
        .b(cin[7][7+7]),
        .cin(cin_final[7+7]),
        .cout(pp[8][7+7+1]),
        .s(pp[8][7+7])
    );

    assign out[15:0] = pp[8][15:0];
		  
endmodule


// The following code is provided for you to use in your design

module full_adder(
    input a,
    input b,
    input cin,
    output cout,
    output s
);

assign s = a ^ b ^ cin;
assign cout = a & b | (cin & (a ^ b));

endmodule