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

`timescale 1ns/1ns

`include "fpmath_defs.v"

module fpmul_stim1_v_tf();

// Clock
    reg clk;

// Inputs
    reg [31:0] a, b;

// Outputs
    wire [31:0] r;
    wire omu;

// Instantiate the UUT
    fpmul uut (
        .clk(clk),
        .a(a), 
        .b(b), 
        .c(r),
        .over_mul_under(omu) 

        );

// clock generator

    initial begin
        clk = 1;
        forever begin
            #50
            clk = ~clk;
        end
    end

task delay;
    input [20:0] m;
    repeat (m)
        @(posedge clk);
endtask

// implements infinity

function real inf;

    input nop;

    real v;
    integer i;

    begin
        v = 1e40;
        for (i=0; i<3; i=i+1) v = v*v;
        
        inf = v;
    end
endfunction

// 32-bit random number

function [31:0] random32;
    input nop;

    reg [31:0] r;

    begin
    r = $random;
    random32 = r;
    end
endfunction

//  drive inputs

integer input_file;
integer output_file;
integer fd;

initial begin
    $dumpfile("fpmul_stim1_new.vcd");
    $dumpvars(0, fpmul_stim1_v_tf);

    input_file  = $fopen("test_case.csv",   "r");
    output_file = $fopen("test_result.csv", "w");

    // ******** drive begins here ************

    fd = $fscanf(input_file, "%b,%b", a, b);
    delay(1);

    while (fd == 2) begin
        $fdisplay(output_file, "%b,%b,%b,%b", a, b, r, omu);
        $display(output_file, "\t%b %b %b %b", a, b, r, omu);
        fd = $fscanf(input_file, "%b,%b", a, b);
        delay(1);
    end

    $display("\t\t------ TEST ENDED ------");

    $fclose(input_file);
    $fclose(output_file);
    $finish;

end
endmodule
