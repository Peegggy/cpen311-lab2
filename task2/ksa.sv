`define restart    4'd1;
`define readi      4'd2;
`define loadi      4'd3;
`define readj      4'd4;
`define loadj      4'd5;
`define switchji   4'd6;
`define switchij   4'd7;
`define finish     4'd8;
`define buffer     4'd9;


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
logic [8:0] i, j;
logic [7:0] readi, readj;



always_comb begin
    case(currentstate)
    4'd1 : nextstate =  (en && rdy) ? 4'd2 : 4'd1;
    4'd2 : nextstate =  (i == 9'd256) ? 4'd8 : 4'd3;
    4'd3 : nextstate = 4'd4;
    4'd4 : nextstate = 4'd9;
    4'd9 : nextstate = 4'd5;
    4'd5 : nextstate = 4'd6; //if i is at 255 then go to finish state
    4'd6 : nextstate = 4'd7;
    4'd7 : nextstate =  4'd2;
    4'd8 : nextstate = 4'd8;
    default: nextstate = 4'd8;
    endcase 
end

always_ff @(posedge clk) begin
    if(~rst_n)
    currentstate = 4'd1;
    else begin
    currentstate = nextstate;
    end
end

always_ff @(posedge clk) begin
    case(currentstate)
    4'd1 : begin
        rdy = 1;
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        i = 0;
        j = 0;
    end
    4'd2 : begin
        rdy = 0;
        addr = i;
        wren = 0;
    end
    4'd3 : begin
        //readi = rddata;
    end
    4'd4 : begin
        readi = rddata;
        case(i%3)
        0 : j = (j + rddata + key[23:16]) % 256; //flipping the byte order
        1 : j = (j + rddata + key[15:8]) % 256;
        2 : j = (j + rddata + key[7:0]) % 256;
        default : j = 8'bx;
        endcase
      
    end
    4'd9 : begin

        addr = j;
        wren = 0;
    end
    4'd5 : begin
      //  readj = rddata;
    end

    4'd6 : begin
        rdy = 0;
        addr = i; //write s[j] to i
        wrdata = rddata;
        wren = 1;

    end

    4'd7 : begin
        rdy = 0;
        addr = j; //write s[i] to j
        wrdata = readi;
        wren = 1;
        i += 1'b1; //increments i
    end
    4'd8 : begin
        rdy = 1; //rdy is 1 indicates the module is done
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        j = 0;
    end
    default: begin  
        rdy = 0; 
        addr = 8'b0;
        wrdata = 8'b0;
        wren = 0;
        j = 0;
    end
    endcase
end

endmodule: ksa