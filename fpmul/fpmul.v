/*
 * Copyright (C) 2006-2026 <YOUR NAME>
 *
 * This design is licensed under the GNU Affero General Public License v3.0.
 *
 * YOU MUST READ THIS:
 * This design is strictly copyleft. If you include this module (or any
 * modified version of it) in a hardware design, simulation, or FPGA
 * bitstream that is accessible to users (physically or over a network),
 * you MUST make the full source code of your ENTIRE design available
 * under this same license.
 *
 * Commercial licenses without these restrictions are available by
 * contacting: <YOUR EMAIL>
 */

`timescale 1ns / 1ns

module fpmul(clk, a, b, c, over_mul_under);

    input clk;
    input [31:0] a, b;
    output [31:0] c;
    output over_mul_under;

/***********************************************/
    wire a_sign;
    wire [7:0]  a_exp;
    wire [22:0] a_frac;

    wire b_sign;
    wire [7:0]  b_exp;
    wire [22:0] b_frac;

    wire c_sign;
    reg [8:0]  c_exp;
    reg [47:0] c_frac;

    assign a_sign = a[31];
    assign a_exp  = a[30:23];
    assign a_frac = a[22:0];

    assign b_sign = b[31];
    assign b_exp  = b[30:23];
    assign b_frac = b[22:0];

    assign c_sign = a_sign ^ b_sign;

/***********************************************/
    /* status
    * 00 - zero
    * 01 - underflow
    * 10 - overflow
    * 11 - normal 
    */
    reg [1:0] a_sts;
    reg [1:0] b_sts;
    reg [1:0] c_sts;
    reg over_mul_under;

    always @(a_exp, a_frac) begin
        if (a_exp == 8'h0) begin
            if (a_frac == 23'h0) begin
                a_sts <= 2'b00;
            end
            else begin
                a_sts <= 2'b01;
            end
        end
        else if (a_exp == 8'hff) begin
            a_sts <= 2'b10;
        end
        else begin
            a_sts <= 2'b11;
        end
    end

    always @(b_exp, b_frac) begin
        if (b_exp == 8'h0) begin
            if (b_frac == 23'h0) begin
                b_sts <= 2'b00;
            end
            else begin
                b_sts <= 2'b01;
            end
        end
        else if (b_exp == 8'hff) begin
            b_sts <= 2'b10;
        end
        else begin
            b_sts <= 2'b11;
        end
    end

// | a   | b   | c    | over_mul_under |
// | O   | O   | O    | 0              |
// | O   | N   | O    | 0              |
// | O   | U   | X    | 1              |
// | N   | O   | O    | 0              |
// | N   | U   | U    | 0              |
// | U   | O   | X    | 1              |
// | U   | N   | U    | 0              |
// | U   | U   | U    | 0              |
// | N   | N   | N    | 0              |
    always @(a_sts, b_sts) begin
        case ( {a_sts, b_sts} )
            4'b1010: begin c_sts <= 2'b10; over_mul_under <= 1'b0; end
            4'b1000: begin c_sts <= 2'b10; over_mul_under <= 1'b0; end
            4'b1011: begin c_sts <= 2'b10; over_mul_under <= 1'b0; end
            4'b1001: begin c_sts <= 2'b00; over_mul_under <= 1'b1; end
            4'b1110: begin c_sts <= 2'b10; over_mul_under <= 1'b0; end
            4'b0010: begin c_sts <= 2'b10; over_mul_under <= 1'b0; end
            4'b1101: begin c_sts <= 2'b01; over_mul_under <= 1'b0; end
            4'b0001: begin c_sts <= 2'b01; over_mul_under <= 1'b0; end
            4'b0110: begin c_sts <= 2'b00; over_mul_under <= 1'b1; end
            4'b0111: begin c_sts <= 2'b01; over_mul_under <= 1'b0; end
            4'b0100: begin c_sts <= 2'b01; over_mul_under <= 1'b0; end
            4'b0101: begin c_sts <= 2'b01; over_mul_under <= 1'b0; end
            4'b0000: begin c_sts <= 2'b00; over_mul_under <= 1'b0; end
            4'b0011: begin c_sts <= 2'b00; over_mul_under <= 1'b0; end
            4'b1100: begin c_sts <= 2'b00; over_mul_under <= 1'b0; end
            4'b1111: begin c_sts <= 2'b11; over_mul_under <= 1'b0; end
        endcase
    end

/***********************************************/

    always @(c_sts) begin
        case (c_sts)
            2'b00: begin c_exp <= 9'h00; c_frac <= 48'h0; end 
            2'b01: begin c_exp <= 9'h00; c_frac <= 48'h0; end 
            2'b10: begin c_exp <= 9'hff; c_frac <= 48'h0; end 
            2'b11: begin
                c_exp  <= a_exp + b_exp;
                if (c_exp > 127) begin
                    c_exp <= c_exp - 127;
                    c_frac <= {1'b1, a_frac} * {1'b1, b_frac};
                end
                else if (c_exp > 255) begin
                    c_exp  <= 9'hff;
                    c_frac <= 48'h0;
                end
                else begin
                    c_exp  <= 9'h00;
                    c_frac <= 48'h0;
                end
            end 
        endcase
    end

    assign c = {c_sign, c_exp[7:0], c_frac[46:24]};

endmodule
