`timescale 1ps / 1ps
module tb_syn_crack();

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
    #20020;
    assert(key_valid === 1)//check if key valid goes to 1 at the right time
    else $error ("key is at 18, key should be valid");
    $stop;
end

endmodule: tb_syn_crack
