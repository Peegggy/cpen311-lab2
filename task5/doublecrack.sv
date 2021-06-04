
module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr),
              .clock(clk),
              .data(pt_wrdata),
              .wren(pt_wren),
              .q(pt_rddata));

    // for this task only, you may ADD ports to crack
    crack c1(.clk(clk),
            .rst_n(rst_n),
            .en(en),
            .rdy(rdy),
            .key(key),
            .key_valid(key_valid),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata),
            .starting_point(24'd0),
            .pt_addr(pt_addr),
            .pt_wrdata(pt_wrdata),
            .pt_rddata(pt_rddata),
            .pt_wren(pt_wren));

    crack c2(.clk(clk),
            .rst_n(rst_n),
            .en(en),
            .rdy(rdy),
            .key(key),
            .key_valid(key_valid),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata),
            .starting_point(24'd1),
            .pt_addr(pt_addr),
            .pt_wrdata(pt_wrdata),
            .pt_rddata(pt_rddata),
            .pt_wren(pt_wren));
    
    // your code here

endmodule: doublecrack
