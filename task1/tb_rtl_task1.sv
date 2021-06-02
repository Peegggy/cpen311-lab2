`timescale 1ps / 1ps

module tb_rtl_task1();

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
    #10;
    //---check to see if addr is starting correctly----
    assert(dut.addr === 0)
    else $error ("address should be 0");
    assert(dut.wrdata === 0)
    else $error ("wrdata should be 0");
    #20;
    //--check to see if addr is incremented correctly---
    assert(dut.addr === 1)
    else $error ("address should be 1");
    assert(dut.wrdata === 1)
    else $error ("wrdata should be 1");
    #20;
    assert(dut.addr === 2)
    else $error ("address should be 2");
    assert(dut.wrdata === 2)
    else $error ("wrdata should be 2");    
    #20;
    assert(dut.addr === 3)
    else $error ("address should be 3");
    assert(dut.wrdata === 3)
    else $error ("wrdata should be 3");
    #20;
    assert(dut.addr === 4)
    else $error ("address should be 4");
    assert(dut.wrdata === 4)
    else $error ("wrdata should be 4");
    #20;
    assert(dut.addr === 5)
    else $error ("address should be 5");
    assert(dut.wrdata === 5)
    else $error ("wrdata should be 5");
    #20;
    assert(dut.addr === 6)
    else $error ("address should be 6");
    assert(dut.wrdata === 6)
    else $error ("wrdata should be 6");    
    #5000;    
    assert(dut.addr === 255)
    else $error ("address should be at 255");
    #20;        
    $stop;
end
endmodule: tb_rtl_task1
