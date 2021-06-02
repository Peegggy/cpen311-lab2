module tb_syn_prga();

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
    ct_rddata = 8'd35;//can check the waveform
    rst_n = 1;
    #10000;
    $stop;
end
endmodule: tb_syn_prga
