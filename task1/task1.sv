`timescale 1ps / 1ps

module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic rst_n;
    assign rst_n = KEY[3];// KEY has reverse logic, therefore when KEY[3] is 0 it is actually 1 for rst_n
    logic en, rdy;
    logic [7:0] addr;
    logic [7:0] wrdata;
    logic [7:0] read_value;
    logic wren;

    always_comb begin
        if(rdy)
        en = 1'b1;
        else en = 0;
    end
    init i(.clk(CLOCK_50),
            .rst_n(rst_n),
            .en(en),
            .rdy(rdy),
            .addr(addr),
            .wrdata(wrdata),
            .wren(wren));

   
    s_mem s(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata),
            .wren(wren),
            .q(read_value));
  


    // your code here

endmodule: task1
