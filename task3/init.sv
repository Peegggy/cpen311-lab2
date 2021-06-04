`define reset     3'd1; //reset state
`define writeAddr 3'd2; //write the value to address
`define increAddr 3'd3; //increment address
`define done      3'd4; //finished

// this module initializes the s_mem file by writing 0-255 in the corresponding address

module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here
logic [2:0] state;

always_ff @(posedge clk) begin
    if(~rst_n) //this means reset is pressed
    state <= 3'd1; //go to reset state
    else begin
        case(state)
        3'd1 : state <= (en && rdy) ? 3'd2 : 3'd1; //see if the module is ready and enabled
        3'd2 : state <= (addr === 8'd255) ? 3'd4 : 3'd3; //writes the value to the address
        3'd3 : state <= 3'd2; //repeats until address is at 255
        default : state <= 3'd4; //does nothing state
        endcase
    end
end

always_ff @(posedge clk) begin
    case(state)
    3'd1 : begin //reset state
        wren <= 1; 
        rdy <= 1; //the module is ready to proceed
        addr <= 0; //starts at address 0
    end
    3'd2 : begin //writeAddr state
        wren <= 1; //writes to address 0
        rdy <= 0; //rdy is 0 because the module is processing
    end
    3'd3 : begin //increAddr state
        wren <= 0; //wren is 0 because we do not want to write to the memory
        rdy <= 0; //rdy = 0 because the module is still processing
        addr <= addr + 8'd1; //address get incremented by 1
    end
    3'd4 : begin //done state
        wren <= 0; //wren is 0 because we do not want to write to the memory
        rdy <= 1; //rdy is 1 because the module is done processing
    end
    endcase
end


assign wrdata = addr; //we are writing the same value as the address

endmodule: init