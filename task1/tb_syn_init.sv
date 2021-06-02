`timescale 1ps / 1ps
module tb_syn_init();

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
    #5090;
    //check to see if address ends at the riht value
    assert(addr === 255)
    else $error ("address should be 255");
    //check to see if the right value is written
    assert(wrdata === 255)
    else $error ("wrdata should be 255");
    //check to see if wren is on
    assert(wren === 1)
    else $error("wren should be 1, should write to memory");
    #10;
    $stop;
end
endmodule: tb_syn_init
