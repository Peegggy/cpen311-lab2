`timescale 1ps / 1ps
module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [23:0] key;
    assign key = {14'b0, SW[9:0]};

    logic ena4, rdya4;
    logic pt_wren;
    logic [7:0] ct_rddata, ct_addr;
    logic [7:0] pt_addr, pt_wrdata, pt_rddata;

    logic [2:0] state;

    always_comb begin
        if(rdya4)
        ena4 = 1;
        else ena4 = 0;
    end

    ct_mem ct(.address(ct_addr),
              .clock(CLOCK_50),
              .data(8'b0),
              .wren(1'b0),
              .q(ct_rddata));

    pt_mem pt(.address(pt_addr),
              .clock(CLOCK_50),
              .data(pt_wrdata),
              .wren(pt_wren),
              .q(pt_rddata));

    arc4 a4(.clk(CLOCK_50),
            .rst_n(KEY[3]),
            .en(ena4),
            .rdy(rdya4),
            .key(key),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata),
            .pt_addr(pt_addr),
            .pt_rddata(pt_rddata),
            .pt_wrdata(pt_wrdata),
            .pt_wren(pt_wren));

    // your code here

endmodule: task3
