module tb_rtl_prga();

// Your testbench goes here.
logic clk, rst_n, en, rdy;
logic [23:0] key;
logic [7:0] s_addr, s_rddata, s_wrdata;
logic s_wren;
logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata; 
logic pt_wren;

prga dut(.*);

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
    ct_rddata = 8'd35;
    rst_n = 1;
    #30;
    assert(dut.msg_len === 8'd35) //check if message length is correct
    else $error ("message length wrong");
    #4550;
    assert(dut.k === 8'd35) //check if k stops at the message length
    else $error ("k did not increment till the message length");
    #5000;
    $stop;
end
endmodule: tb_rtl_prga
