`timescale 1ps / 1ps
module tb_syn_task4();

// Your testbench goes here.
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0,  HEX1,  HEX2, HEX3, HEX4, HEX5;

task4 dut(.*);

initial begin
    #10;
    $readmemh("test2.memh", dut.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
end

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
    #800000;
    //---check to see if the right key is displayed---
    assert(HEX0 === 7'b0)
    else $error("last digit should be 8");
    assert(HEX1 === 7'b1111001)
    else $error ("second last digit should be 1");
    assert(HEX2 === 7'b1000000)
    else $error ("third last digit should be 0");
    $stop;    
end
endmodule: tb_syn_task4
