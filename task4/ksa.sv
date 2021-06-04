`define restart    4'd1; //restart state
`define readi      4'd2; //to read s[i] state
`define loadi      4'd3; //load s[i] back to KSA state (buffer state)
`define getj      4'd4; //set address j state
`define loadj      4'd5; //load s[j] back to KSA state
`define switchji   4'd6; //load s[j] into s[i] state
`define switchij   4'd7; //load s[i] into s[j] state
`define finish     4'd8; //finish
`define readj     4'd9; //read s[j] state (buffer state)


/*j = 0
for i = 0 to 255:
    j = (j + s[i] + key[i mod keylength]) mod 256   -- for us, keylength is 3
    swap values of s[i] and s[j]
*/
//purpose of this module is to swap s[i] and s[j], while i is incremented by 1 each time
//j is calculated from (j + s[i] + key[i%3]) % 256
 
module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, 
           output logic wren);

    // your code here

logic [3:0] currentstate, nextstate; 
logic [8:0] i, j; // index i and index j
logic [7:0] readi; // for storing the value of s[i]



always_comb begin
    case(currentstate)
    4'd1 : nextstate =  (en && rdy) ? 4'd2 : 4'd1; //starts the process if ready and en are on
    4'd2 : nextstate =  (i == 9'd256) ? 4'd8 : 4'd3; //reads s[i] and checks to see if i exceeds 255
    4'd3 : nextstate = 4'd4; //wait a cycle for the data to be loaded back into KSA
    4'd4 : nextstate = 4'd9; //sets index j and also stores the read data into readi
    4'd9 : nextstate = 4'd5; //wait a cycle for the data to be loaded back into KSA
    4'd5 : nextstate = 4'd6; //if i is at 255 then go to finish state
    4'd6 : nextstate = 4'd7; //take the read data s[j] and load it into s[i]
    4'd7 : nextstate =  4'd2; //s[i] into s[j]
    4'd8 : nextstate = 4'd8; //done state
    default: nextstate = 4'd8; 
    endcase 
end

always_ff @(posedge clk) begin
    if(~rst_n) //if reset is pressed
    currentstate <= 4'd1; //then go back to restart state
    else begin
    currentstate <= nextstate; //else nextstate becomes the current state
    end
end

always_ff @(posedge clk) begin
    case(currentstate)
    4'd1 : begin //`restart
        rdy <= 1; //KSA is ready to perform
        addr <= 8'b0; 
        wrdata <= 8'b0; 
        wren <= 0; //not writing anything
        i <= 0; 
        j <= 0;
    end
    4'd2 : begin //`readi
        rdy <= 0; //rdy is 0 to indicate that the process has begun
        addr <= i; //addr = i to get s[i]
        wren <= 0; //reading s[i]
    end
    4'd3 : begin //`loadi
        //readi = rddata, wait a cycle for the rddata for s[i] to be loaded back
    end
    4'd4 : begin //`getj
        readi = rddata; //readi is s[i]
        case(i%3) //since key is big endian so we need to flip the order
        0 : j <= (j + rddata + key[23:16]) % 256; //flipping the byte order
        1 : j <= (j + rddata + key[15:8]) % 256;
        2 : j <= (j + rddata + key[7:0]) % 256;
        default : j = 8'bx;
        endcase
      
    end
    4'd9 : begin //`readj
        addr <= j; //needs another cycle to assign j to address or else address would get the old j
        wren <= 0; //read from j
    end
    4'd5 : begin //loadj
      //  readj = rddata, takes another cycle for rddata to be read to KSA
    end

    4'd6 : begin //`switchij
        rdy <= 0; 
        addr <= i; //write s[j] to i
        wrdata <= rddata; //since nothing else is read between the loadj state and switchij state
        wren <= 1; // so rddata still holds the last read value which is s[j]

    end

    4'd7 : begin //switchji
        rdy <= 0;
        addr <= j; //write s[i] to j
        wrdata <= readi; 
        wren <= 1;
        i += 1'b1; //increments i
    end
    4'd8 : begin //`done
        rdy <= 1; //rdy is 1 indicates the module is done
        addr <= 8'b0; //everything gets set back to 0
        wrdata <= 8'b0;
        wren <= 0;
        j <= 0;
    end
    default: begin  
        rdy <= 0; 
        addr <= 8'b0;
        wrdata <= 8'b0;
        wren <= 0;
        j <= 0;
    end
    endcase
end

endmodule: ksa