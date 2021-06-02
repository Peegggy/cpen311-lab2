`timescale 1ps / 1ps
module tb_rtl_task2();

// Your testbench goes here.
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0,  HEX1,  HEX2, HEX3, HEX4, HEX5;


task2 dut(.*);

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
    #5130;
    assert(dut.wrdata_final === 255) //checking to see if init ends properly
    else $error ("init did not end at 255");
    #30;
    assert(dut.state === 3'b010) //check to see if it goes to processKSA state after init is done
    else $error ("processKSA did not state");
    #25000;

    $stop;
end
endmodule: tb_rtl_task2
