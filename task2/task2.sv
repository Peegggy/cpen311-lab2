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

logic en;
logic rdy;
logic wren;

logic [7:0] wrdataInit, wrdataKSA;
logic [7:0] addr, addrInit, addrKSA;
assign addrInit = 8'b0;
assign addrKSA = 8'b0;

logic [7:0] read_valueInit, read_valueKSA;

always_comb begin
    if(rdy) en = 1;
    else en = 0;
end

//logic [2:0] currentstate, nextstate;

    init i( .clk(CLOCK_50),
            .rst_n(rst_n),
            .en(en),
            .rdy(rdy),
            .addr(addrInit),
            .wrdata(wrdataInit),
            .wren(wren));

    s_mem s1(.address(addrInit),
            .clock(CLOCK_50),
            .data(wrdataInit),
            .wren(wren),
            .q(read_valueInit));

    ksa k(.clk(CLOCK_50),
          .rst_n(rst_n),
          .en(en),
          .rdy(rdy),
          .key(key),
          .addr(addrKSA), //j
          .rddata(wrdataInit),  //s[i]
          .wrdata(wrdataKSA), //s[j]
          .wren(wren));

    s_mem s2(.address(addrInit),
            .clock(CLOCK_50),
            .data(wrdataKSA), //s[j]
            .wren(wren),
            .q(read_valueInit));

    s_mem s(.address(addrKSA),
            .clock(CLOCK_50),
            .data(wrdataInit), //s[i]
            .wren(wren),
            .q(read_valueKSA));

/*always_comb begin
    case(currentstate)
    `RESET:    nextstate = rdy == 1 ? `enableInit : `RESET;
    `enableInit:   nextstate = `waitInit;
    `waitInit: nextstate = (rdy == 1 && rdy == 1) ? `enableKSA : `waitInit;
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
    `RESET: {en, en, wren, wren} <= 4'b0000;
    `enableInit: {en, en, wren, wren} <= 4'b1000;
    `waitInit: {en, en, wren, wren} <= 4'b0010;
    `enableKSA: {en, en, wren, wren} <= 4'b0100;
    `waitKSA: {en, en, wren, wren} <= 4'b0001;
    default: {en, en, wren, wren} <= 4'b0000;
    endcase
end

always_comb begin
    if(currentstate === `enableInit || currentstate === `waitInit) begin
        addr <= addrInit;
    end
    else begin
        addr <= addrKSA;
    end  
end*/



    // your code here

endmodule: task2
