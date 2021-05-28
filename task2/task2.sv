`timescale 1ps / 1ps

//`define reset        3'b000;
`define processInit  3'b001;
`define processKSA   3'b010;
`define done         3'b100;

module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

logic [23:0] key;
//assign key = {14'b0, SW};
assign key = 24'h00033C;
logic rst_n;
assign rst_n = KEY[3];

logic enInit, enKSA;
logic rdyInit, rdyKSA;
logic wren_final, wrenInit, wrenKSA;

logic [7:0] wrdata_final, wrdataInit, wrdataKSA;
logic [7:0] addr_final, addrInit, addrKSA;

logic [7:0] read_value_final, read_value, read_valueKSA;

logic [2:0] state;



    init i( .clk(CLOCK_50),
            .rst_n(rst_n),
            .en(enInit),
            .rdy(rdyInit),
            .addr(addrInit),
            .wrdata(wrdataInit),
            .wren(wrenInit));

    ksa k(.clk(CLOCK_50),
          .rst_n(rst_n),
          .en(enKSA),
          .rdy(rdyKSA),
          .key(key),
          .addr(addrKSA), //j
          .rddata(read_valueKSA),  //s[i]
          .wrdata(wrdataKSA), //s[j]
          .wren(wrenKSA));

    s_mem s(.address(addr_final),
            .clock(CLOCK_50),
            .data(wrdata_final),
            .wren(wren_final),
            .q(read_value));


always_comb begin
    if(state == 3'b001 && rdyInit && addrInit < 256) begin
        enInit = 1;
        enKSA = 0;
    end
    else if(state == 3'b010 && rdyKSA) begin
        enInit = 0;
        enKSA = 1;
    end
    else begin
        enInit = 0;
        enKSA = 0;
    end
end

always_ff @(posedge CLOCK_50) begin
    if(~rst_n)
    state <= 3'b001;
    else begin
        case(state)
        3'b001 : state <= (~wrenInit && rdyInit && addrInit == 8'd255 ) ? 3'b010 : 3'b001;
        3'b010 : state <= (rdyKSA && addrKSA == 8'd255) ? 3'b100 : 3'b010;
        default : state <= 3'b100;
        endcase
    end
end

always_comb begin
    addr_final = (state == 3'b001) ? addrInit : ((state == 3'b010) ? addrKSA : 8'b0);
    wrdata_final = (state == 3'b001) ? wrdataInit : ((state == 3'b010) ? wrdataKSA : 8'b0);
    wren_final = (state == 3'b001) ? wrenInit : ((state == 3'b010) ? wrenKSA : 0);
    read_valueKSA = read_value;
end


endmodule: task2