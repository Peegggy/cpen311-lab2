module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, 
           output logic wren);

    // your code here

logic [7:0] i;

always_ff @(posedge clk) begin
    if(~en && ~rst_n)begin
        rdy = 1;
        wren = 1;
        addr = 8'b0;
        i = 8'b0;
    end 
    else if(~en && i <= 8'd255) begin
        rdy = 1;
        wren = 1;
        addr = (addr + rddata + key[(i % 8'd3)]) % 9'd256; //j
        i++;
    end
    else begin 
        rdy = 0;
        wren = 0;
        addr = addr;
    end
end
assign wrdata = addr;
endmodule: ksa
