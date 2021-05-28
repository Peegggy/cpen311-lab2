`timescale 1ps / 1ps

`define reset        3'b000;
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

/*always_comb begin
    if(rdyInit) begin
        enInit = 1;
    end 
    else begin 
        enInit = 0;
    end
end

always_comb begin
    if(rdyKSA) enKSA = 1;
    else enKSA = 0;
end
*/

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
    if(state === 3'b001 && rdyInit === 1 && addrInit < 9'd256) begin
        enInit <= 1;
        //enKSA <= 0;
    end
    else if(state === 3'b010 && rdyKSA === 1 && addrKSA === 8'b0)begin
        enInit <= 0;
       // enKSA <= 1;
    end
    else if(state === 3'b000) begin
        if(rdyInit === 1)
        enInit <= 1;
      /*  else if(rdyKSA === 1)
        enKSA <= 1;*/
        else begin
           // enKSA <= 0;
            enInit <= 0;
        end
    end
    else begin
        enInit <= 0;
        //enKSA <= 0;
    end
end

always_ff @(posedge CLOCK_50) begin
    if(~rst_n)
    state <= 3'b000;
    else begin
        case(state)
        3'b000 : state <= rdyInit ? 3'b001 : 3'b000;
        3'b001 : state <= (~wrenInit && rdyInit ) ? 3'b010 : 3'b001;
        3'b010 : state <= (~wrenKSA && rdyKSA) ? 3'b100 : 3'b010;
        default : state <= 3'b100;
        endcase
    end
end

always_ff @(posedge CLOCK_50) begin
    case(state)
    3'b000 : begin
        addr_final <= 8'b0;
        wrdata_final <= 8'b0;
        wren_final <= 1'b0;
    end
    3'b001 : begin
        addr_final <= addrInit;
        wrdata_final <= wrdataInit;
        wren_final <= wrenInit;

        enKSA <= 1;
    end
    3'b010 : begin
        addr_final <= addrKSA;
        wrdata_final <= wrdataKSA;
        wren_final <= wrenKSA;
        read_valueKSA <= read_value;
        enKSA <= 0;
    end
    3'b100 : begin
        addr_final <= 8'b0;
        wrdata_final <= 8'b0;
        wren_final <= 0;
    end
    default : begin
        addr_final <= addr_final;
        wrdata_final <= wrdata_final;
        wren_final <= 0;
        read_valueKSA <= read_valueKSA;
        enKSA <= 1;
        
    end
    endcase
end
    // your code here



endmodule: task2