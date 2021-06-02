`timescale 1ps / 1ps
module tb_syn_task1();

// Your testbench goes here.
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0,  HEX1,  HEX2, HEX3, HEX4, HEX5;

task1 dut(.*);

initial begin
    CLOCK_50 = 0;
    forever #5 CLOCK_50 = ~CLOCK_50;
end

initial begin
    KEY[3] = 1;
    #10;
    KEY[3] = 0;
    #10;
    KEY[3] = 1;
    #6000;
    $stop;
end
endmodule: tb_syn_task1
