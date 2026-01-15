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

    assign c = 0;
    assign over_mul_under = 0;

endmodule
