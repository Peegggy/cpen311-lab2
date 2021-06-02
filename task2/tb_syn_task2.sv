`timescale 1ps / 1ps

module tb_syn_task2();

// Your testbench goes here.
logic CLOCK_50, a, b, c, d;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0,  HEX1,  HEX2, HEX3, HEX4, HEX5;


task2 dut(
    .altera_reserved_tms(s),
    .altera_reserved_tck(b),
    .altera_reserved_tdi(c),
    .altera_reserved_tdo(d),
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .LEDR(LEDR)
);

initial begin
    CLOCK_50 = 0;
    forever #5 CLOCK_50 = ~CLOCK_50;
end

initial begin
    dut.key = 24'h00033C;
    KEY[3] = 1;
    #10;
    KEY[3] = 0;
    #10;
    KEY[3] = 1;
    #20500;
    /* somehow, I am not able to read the mem fileusing this line of code for post synthesis, but 
    i am able to read the file in rtl*/
   // assert(dut.s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[0] == 8'hb4)
   // else $error ("first mem value should be b4");
    $stop;
end
endmodule: tb_syn_task2
