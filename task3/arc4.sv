`define reset       3'd0;
`define processInit 3'd1;
`define processKSA  3'd2;
`define processPRGA 3'd3;
`define done        3'd4;

module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
logic enInit, enKSA, enPRGA;
logic rdyInit, rdyKSA, rdyPRGA;
logic wren_final, wrenInit, wrenKSA, wrenPRGA;

logic [7:0] wrdata_final, wrdataInit, wrdataKSA, wrdataPRGA;
logic [7:0] addr_final, addrInit, addrKSA, addrPRGA;

logic [7:0] read_value_final, read_value, read_valueKSA, read_valuePRGA;

logic [2:0] state;

    s_mem s(.address(addr_final),
            .clock(clk),
            .data(wrdata_final),
            .wren(wren_final),
            .q(read_value));

    init i( .clk(clk),
            .rst_n(rst_n),
            .en(enInit),
            .rdy(rdyInit),
            .addr(addrInit),
            .wrdata(wrdataInit),
            .wren(wrenInit));

    ksa k(.clk(clk),
          .rst_n(rst_n),
          .en(enKSA),
          .rdy(rdyKSA),
          .key(key),
          .addr(addrKSA), //j
          .rddata(read_valueKSA),  //s[i]
          .wrdata(wrdataKSA), //s[j]
          .wren(wrenKSA));

    prga p(.clk(clk),
           .rst_n(rst_n),
           .en(enPRGA),
           .rdy(rdyPRGA),
           .key(key), 
           .s_addr(addrPRGA),
           .s_rddata(read_valuePRGA),
           .s_wrdata(wrdataPRGA),
           .s_wren(wrenPRGA),
           .ct_addr(ct_addr),
           .ct_rddata(ct_rddata),
           .pt_addr(pt_addr),
           .pt_rddata(pt_rddata),
           .pt_wrdata(pt_wrdata),
           .pt_wren(pt_wren));

always_comb begin
    if(state == 3'd1 && rdyInit && addrInit < 256) begin
        enInit = 1;
        enKSA = 0;
        enPRGA = 0;
    end
    else if(state == 3'd2 && rdyKSA) begin
        enInit = 0;
        enKSA = 1;
        enPRGA = 0;
    end
    else if(state == 3'd3 && rdyPRGA) begin
        enInit = 0;
        enKSA = 0;
        enPRGA = 1;
    end
    else begin
        enInit = 0;
        enKSA = 0;
        enPRGA = 0;
    end
end

always_ff @(posedge clk) begin
    if(~rst_n)
    state = 3'd0;
    else begin
        case(state)
        3'd0 : state <= (rdy && en) ? 3'd1 : 3'd0;
        3'd1 : state <= (~wrenInit && rdyInit && addrInit == 8'd255) ? 3'd2 : 3'd1;
        3'd2 : state <= (rdyKSA && ~wrenKSA && read_valueKSA == 8'd255) ? 3'd3 : 3'd2;
        3'd3 : state <= (rdyPRGA && addrPRGA !== 0) ? 3'd4 : 3'd3;
        default : state <= 3'd4;
        endcase
    end
end

always_comb begin
    addr_final = (state == 3'd1) ? addrInit : ((state == 3'd2) ? addrKSA : (state == 3'd3 ? addrPRGA : 0));
    wrdata_final = (state == 3'd1) ? wrdataInit : ((state == 3'd2) ? wrdataKSA : (state == 3'd3 ? wrdataPRGA : 0));
    wren_final = (state == 3'd1) ? wrenInit : ((state == 3'd2) ? wrenKSA : (state == 3'd3 ? wrenPRGA : 0));
    read_valueKSA = (state == 3'd2) ? read_value : 0;
    read_valuePRGA = (state == 3'd3) ? read_value : 0;
    rdy = (state == 3'd0 || state == 3'd4) ? 1 : 0;
end
    // your code here

endmodule: arc4
