/*
* Module describing a 32-bit ripple carry adder, with no carry output or input.
*
* You can and should modify this file but do NOT change the interface.
*/
module adder32 import calculator_pkg::*; (
    // DO NOT MODIFY THE PORTs
    input  logic [DATA_W - 1 : 0]    a_i,  // First operand
    input  logic [DATA_W - 1 : 0]    b_i,  // Second operand
    input  logic                     c_i,  // Carry input
    output logic                     c_o,  // Carry output
    output logic [DATA_W - 1 : 0]    sum_o // Sum output
);
    logic carry [DATA_W : 0];
    assign carry[0] = c_i;

    assign c_o = carry[DATA_W];
    generate
        genvar i;
        for (i = 0; i < DATA_W; i = i + 1) begin
            full_adder fa (
                .a(a_i[i]),
                .b(b_i[i]),
                .cin(carry[i]),
                .cout(carry[i + 1]),
                .s(sum_o[i])
            );
        end
    endgenerate
endmodule