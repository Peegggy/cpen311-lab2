`timescale 1ps / 1ps
module tb_rtl_crack();

// Your testbench goes here.
logic clk, rst_n, en, rdy;
logic [23:0] key;
logic key_valid;
logic [7:0] ct_addr, ct_rddata;

crack dut(.*);

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
    #20;
    assert(dut.state === 4'd2) //check to see if arc4 starts
    else $error ("not processing arc4");
    #20000;
    $stop;
end
endmodule: tb_rtl_crack
