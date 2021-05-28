`define restart    4'd1;
`define readi      4'd2;
`define loadi      4'd3;
`define readj      4'd4;
`define loadj      4'd5;
`define switchij   4'd6;
`define switchji   4'd7;
`define finish     4'd8;


/*j = 0
for i = 0 to 255:
    j = (j + s[i] + key[i mod keylength]) mod 256   -- for us, keylength is 3
    swap values of s[i] and s[j]
*/

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, 
           output logic wren);

    // your code here

logic [3:0] currentstate, nextstate;
logic [7:0] index_i, j;
logic [7:0] readi, readj;
logic [7:0] key_index;
logic load_memi, load_memj;


always_comb begin
    case(currentstate)
    4'd1 : nextstate =  (~en && rst_n) ? 4'd2 : 4'd1;
    4'd2 : nextstate =  4'd3;
    4'd3 : nextstate = 4'd4;
    4'd4 : nextstate = 4'd5;
    4'd5 : nextstate = (index_i == 9'd255) ? 4'd8 : 4'd6; //if i is at 255 then go to finish state
    4'd6 : nextstate = 4'd7;
    4'd7 : nextstate =  4'd2;
    4'd8 : nextstate = 4'd8;
    default: nextstate = 4'd1;
    endcase 
end


always_ff @(posedge clk) begin
    if(~rst_n)
    currentstate = 4'd1;
    else 
    currentstate = nextstate;
end

always_comb begin
    readi = load_memi ? rddata : readi;
    readj = load_memj ? rddata : readj;
end

always_ff @(posedge clk) begin
    case(currentstate)
    4'd1 : begin
        rdy = 0;
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        index_i = 8'b0;
        j = 8'b0;
        load_memi = 0;
        load_memj = 0;
    end
    4'd2 : begin
        rdy = 0;
        addr = index_i;
        wren = 0;
        load_memi = 0;
        load_memj = 0;
    end
    4'd3 : begin
        load_memi = 1; //since it takes another cycle for ksa to receive the data from s_mem
                        //so I added another state for loading s[i] to readi
        load_memj = 0;
        rdy = 0;
        wren = 0;

    end
    4'd4 : begin
        key_index = index_i % 8'd3;
        case(key_index)
        8'd0 : j = (j + rddata + key[23:16]) % 256; //flipping the byte order
        8'd1 : j = (j + rddata + key[15:8]) % 256;
        8'd2 : j = (j + rddata + key[7:0]) % 256;
        endcase
        rdy = 0;
        wren = 0;
        addr = j;
        load_memi = 0;
        load_memj = 0;       
    end
    4'd5 : begin
        load_memj = 1; 
        load_memi = 0;
        rdy = 0;
        wren = 0;
    end

    4'd6 : begin
        rdy = 0;
        addr = index_i; //write s[j] to i
        wrdata = readj;
        wren = 1;
        load_memi = 0;
        load_memj = 0;
    end

    4'd7 : begin
        rdy = 0;
        addr = j; //write s[i] to j
        wrdata = readi;
        wren = 1;
        index_i += 1'b1; //increments i
        load_memi = 0;
        load_memj = 0;
    end
    4'd8 : begin
        rdy = 1; //rdy is 1 indicates the module is done
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        index_i = 0;
        j = 0;
        load_memi = 0;
        load_memj = 0;
    end
    default: begin
        load_memi = 0;
        load_memj = 0;       
        rdy = 0; 
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        index_i = 0;
        j = 0;
    end
    endcase
end

endmodule: ksa
