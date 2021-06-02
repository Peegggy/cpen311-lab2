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
    #40;
    assert(dut.a4.state === 4'd1) //check to see if init state started
    else $error ("not in init state");
    #5140;
    assert(dut.a4.state === 4'd2) //check to see if ksa state started
    else $error ("not in KSA state");
    #18000;
    assert(dut.a4.state === 4'd3) //check to see if prga state started
    else $error ("not in prga state");
    #6900;
    assert(dut.a4.state === 4'd4) //check to see if task 3 is done
    else $error ("not in done state");
    #20;
    $stop;    
end
endmodule: tb_rtl_task3
