`timescale 1ps / 1ps
module tb_rtl_task3();

// Your testbench goes here.
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0,  HEX1,  HEX2, HEX3, HEX4, HEX5;
logic [23:0] key;

task3 dut(.*);
initial $readmemh("test2.memh", tb_rtl_task3.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
initial begin
    CLOCK_50 = 0;
    forever #5 CLOCK_50 = ~CLOCK_50;
end

initial begin
    
    SW[9:0] = 10'b0000011000;
    KEY[3] = 1;
    #10;
    KEY[3] = 0;
    #10;
    KEY[3] = 1;
    #31000;
   //#27665;
    $stop;    
end
endmodule: tb_rtl_task3
