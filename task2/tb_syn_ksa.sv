module tb_syn_ksa();

// Your testbench goes here.
logic clk, rst_n, en, rdy;
logic [23:0] key;
logic [7:0] addr, rddata, wrdata;
logic wren;

ksa dut(.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    key = 24'h00033C;
    en = 1;
    rst_n = 1;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    #20600;
    $stop;
end
endmodule: tb_syn_ksa
