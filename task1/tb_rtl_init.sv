`timescale 1ps / 1ps
module tb_rtl_init();

// Your testbench goes here.
logic clk, rst_n, en, rdy, wren;
logic [7:0] addr, wrdata;

init dut(.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 1;
    en = 1;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    #10;
    //---check to see if addr is starting correctly----
    assert(addr === 0)
    else $error ("address should be 0");
    assert(wrdata === 0)
    else $error ("wrdata should be 0");
    #20;
    //--check to see if addr is incremented correctly---
    assert(addr === 1)
    else $error ("address should be 1");
    assert(wrdata === 1)
    else $error ("wrdata should be 1");
    #20;
    assert(addr === 2)
    else $error ("address should be 2");
    assert(wrdata === 2)
    else $error ("wrdata should be 2");    
    #20;
    assert(addr === 3)
    else $error ("address should be 3");
    assert(wrdata === 3)
    else $error ("wrdata should be 3");
    #20;
    assert(addr === 4)
    else $error ("address should be 4");
    assert(wrdata === 4)
    else $error ("wrdata should be 4");
    #20;
    assert(addr === 5)
    else $error ("address should be 5");
    assert(wrdata === 5)
    else $error ("wrdata should be 5");
    #20;
    assert(addr === 6)
    else $error ("address should be 6");
    assert(wrdata === 6)
    else $error ("wrdata should be 6");    
    #5000;    
    assert(addr === 255)
    else $error ("address should be at 255");
    assert(dut.state === 3'b100)
    else $error ("should be in finish state");
    #20;        
    $stop;
end
endmodule: tb_rtl_init
