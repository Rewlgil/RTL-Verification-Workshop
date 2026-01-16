To obtain coverage info using Verilator

1. Modify fpmul_stim1_new.v to output test patterns
   iverilog -o gen_pattern fpmul_stim1_new.v -y.

2. vvp gen_pattern > patterns.txt

3. Edit patterns.txt to remove non-pattern lines

4. Modify fpmul.v to comment out define PIPELINED (as test bench 2 is combinational only)

5. Run verilator to compile verilog to create an executable
   verilator --binary --timing --coverage fpmul_stim2.v fpmul.v

6. Run verilator-generated executable which will also create coverage.dat
   ./obj_dir/Vfpmul_stim2

7. Annotate coverage info into source verilog
   verilator_coverage --annotate obj_dir coverage.dat
   Output:
     Total coverage (65/95) 68.00%
     See lines with '%00' in obj_dir

8. Check ./obj_dir/*.v for annotation
