module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here



always_ff @(posedge clk) begin
    if(~en && ~rst_n)begin
         rdy = 1; //ready to write to RAM
         wren = 1; //to write to RAM
         addr = 8'b0; //starting from addr 0

    end
    else if(~en && addr <= 9'd255)begin 
            rdy = 1; //ready to write to RAM
            wren = 1; 
            addr = addr + 1; //increment by one spot
        end

    else begin
        rdy = 0; //else not ready to write to RAM
        wren = 0;
        addr = addr;
    end
end

assign wrdata = addr;

endmodule: init