`timescale 1ps / 1ps
module tb_syn_arc4();

// Your testbench goes here.
logic clk, rst_n, en, rdy;
logic [23:0] key;
logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
logic pt_wren;

// Your testbench goes here.
arc4 dut(.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    key = 24'h000018;
    rst_n = 1;
    en = 1;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    #23000;
    $stop;
end
endmodule: tb_syn_arc4
