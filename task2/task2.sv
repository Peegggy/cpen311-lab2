`timescale 1ps / 1ps

`define RESET        3'b000;
`define enableInit   3'b001;
`define waitInit     3'b010;
`define enableKSA    3'b011;
`define waitKSA      3'b100;

module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

logic [23:0] key;
//assign key = {14'b0, SW};
assign key = 24'hC33000;
logic rst_n;
assign rst_n = KEY[3];

logic enInit, enKSA;
logic rdyInit, rdyKSA;
logic wrenInit, wrenKSA;

logic [7:0] wrdataInit, wrdataKSA;
logic [7:0] addr, addrInit, addrKSA;
assign addrInit = 8'b0;
assign addrKSA = 8'b0;

logic [7:0] read_valueInit, read_valueKSA;

logic [2:0] currentstate, nextstate;

    init i( .clk(CLOCK_50),
            .rst_n(rst_n),
            .en(enInit),
            .rdy(rdyInit),
            .addr(addrInit),
            .wrdata(wrdataInit),
            .wren(wrenInit));

    s_mem s1(.address(addr),
            .clock(CLOCK_50),
            .data(wrdataInit),
            .wren(wrenInit),
            .q(read_valueInit));

    ksa k(.clk(CLOCK_50),
          .rst_n(rst_n),
          .en(enKSA),
          .rdy(rdyKSA),
          .key(key),
          .addr(addrKSA), //j
          .rddata(wrdataInti),  //s[i]
          .wrdata(wrdataKSA), //s[j]
          .wren(wrenKSA));

    s_mem s2(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata_bufferKSA), //s[j]
            .wren(wrenKSA),
            .q(read_valueInit));

    s_mem s(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata_bufferInit), //s[i]
            .wren(wrenInit),
            .q(read_valueKSA));

always_comb begin
    case(currentstate)
    `RESET:    nextstate = rdyInit ? `enableInit : `RESET;
    `enableInit:   nextstate = `waitInit;
    `waitInit: nextstate = (rdyInit && rdyKSA) ? `enableKSA : `waitInit;
    `enableKSA:    nextstate = `waitKSA;
    `waitKSA:  nextstate = `waitKSA;
    default:   nextstate = `RESET;
    endcase
end

always_ff @(posedge CLOCK_50) begin
    if(rst_n)
    currentstate <= nextstate;
    else
    currentstate <= `RESET;
end

always_comb begin
    case(currentstate)
    `RESET: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b0000;
    `enableInit: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b1000;
    `waitInit: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b0010;
    `enableKSA: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b0100;
    `waitKSA: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b0001;
    default: {enInit, enKSA, wrenInit, wrenKSA} <= 4'b0000;
    endcase
end

always_comb begin
    if(currentstate === `enableInit || currentstate === `waitInit) begin
        addr <= addrInit;
    end
    else begin
        addr <= addrKSA;
    end  
end



    // your code here

endmodule: task2
