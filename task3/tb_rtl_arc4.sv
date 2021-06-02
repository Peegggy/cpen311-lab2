`timescale 1ps / 1ps

module tb_rtl_arc4();
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
    #20;
    assert(dut.state === 3'b001) //check if init started
    else $error ("init did not start");
    #5140;
    assert(dut.state === 3'b010) //check if ksa started
    else $error ("KSA did not start");
    #17950;
    assert(dut.state === 3'b011) //check if prga started
    else $error ("PRGA did not start");
    $stop;
end

endmodule: tb_rtl_arc4
