`define reset       5'd1;
`define readCT      5'd2; //read the data from ct_mem
`define loadCT      5'd3; //a cycle to load ct_mem into prga
`define PTmsgLen    5'd4; //get the message length from ct[0] and load it into pt[0]
`define readi       5'd5; //read s[i]
`define loadi       5'd6; //load s[i]
`define readj       5'd7; //read s[j]
`define loadj       5'd8; //load s[j]
`define swapij      5'd9; //s[i] goes into s[j]
`define swapji      5'd10; //s[j] goes into s[i]
`define readS       5'd11; //read s[(s[i]+s[j])%256]
`define loadS       5'd12; //load the value
`define assignPAD   5'd13; //pad[k] is the value of s[(s[i]+s[j])%256]
`define readK       5'd14; //read ct[k]
`define loadK       5'd15; //load ct[k]
`define assignPT    5'd16; //pt[k] = pad[k] xor ct[k]
`define Kincr       5'd17; // k++
`define done        5'd18; //done state

// this modules implements the following pseudo code:
/*i = 0, j = 0
message_length = ciphertext[0]
for k = 1 to message_length:
    i = (i+1) mod 256
    j = (j+s[i]) mod 256
    swap values of s[i] and s[j]
    pad[k] = s[(s[i]+s[j]) mod 256]

plaintext[0] = message_length
for k = 1 to message_length:
    plaintext[k] = pad[k] xor ciphertext[k]  -- xor each byte */
// instead of having 2 for loops that count up k, I combined the loops into one big one and 
//declared a wire for storing pad[k]. 


module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
logic [8:0] i, j, k, readi, readj, padK;
logic [7:0] msg_len;
logic [4:0] state, nextstate;


always_comb begin
    case(state)
    5'd1 : nextstate = (rdy && en) ? 5'd2 : 5'd1; //if both rdy and en are 1 then prga is ready to perform
    5'd2 : nextstate = 5'd3;
    5'd3 : nextstate = 5'd4;
    5'd4 : nextstate = 5'd5;
    5'd5 : nextstate = 5'd6;
    5'd6 : nextstate = k == (msg_len + 1'b1) ? 5'd18 : 5'd7; //if k exceeds the message length then prga is done
    5'd7 : nextstate = 5'd8;
    5'd8 : nextstate = 5'd9;
    5'd9 : nextstate = 5'd10;
    5'd10 : nextstate = 5'd11;
    5'd11 : nextstate = 5'd12;
    5'd12 : nextstate = 5'd13;
    5'd13 : nextstate = 5'd14;
    5'd14 : nextstate = 5'd15;
    5'd15 : nextstate = 5'd16;
    5'd16 : nextstate = 5'd17;
    5'd17 : nextstate = 5'd5;//After K increments, the nextstate is readi to restart the process with a different k
    5'd18 : nextstate = 5'd18;
    default : nextstate = 5'd18;
    endcase
end

always_ff @(posedge clk) begin
    if(~rst_n) //if reset is pressed then it goes to reset state
    state = 5'd1;
    else
    state = nextstate; //else next state becomes the current state
end

always_ff @(posedge clk) begin
    case(state)
    5'd1 : begin //in reset state
        i = 0;
        j = 0;
        k = 1;
        s_addr = 0;
        ct_addr = 0; //ct_addr = 0 and ct_wren is always 0 so it is actually reading ct[0]
        pt_addr = 0;
        s_wrdata = 0;
        pt_wrdata = 0;
        s_wren = 0;
        pt_wren = 0;
        rdy = 1; //rdy is 1 then to indicate that prga is ready to go
        msg_len = 0;
    end
    5'd2 : begin //readCT
        rdy = 0; //this state loads the data from ct_addr = 0 that was previously set in the reset state
    end
    5'd3 : begin //loadCT
        msg_len = ct_rddata; //ct[0] = message length
    end
    5'd4 : begin //PTmsgLen
        pt_wren = 1; //writing the message length to pt[0] which pt_addr was set in the reset state
        pt_wrdata = msg_len;
    end
    5'd5 : begin //readi, this state calculates the index i for s_mem
        s_addr = (i+1) % 256; 
        s_wren = 0; 
    end
    5'd6 : begin //loadi
        //readi = s_rddata;
        i = s_addr; // i becomes the newly calculated address
    end
    5'd7 : begin //readj
        readi = s_rddata; //the s_rddata is the read value at address i
        s_addr = (j+s_rddata) % 256; //calculating the index j for s_mem
        s_wren = 0;
    end
    5'd8 : begin //loadj
        j = s_addr; //j becomes the newly calculated address
    end
    5'd9 : begin //swapij
        readj = s_rddata; //the s_rddata is the read value at address j
        s_addr = i; //the new address is i
        s_wrdata = s_rddata; //s_rddata is still s[j] in this cycle 
        s_wren = 1;
    end
    5'd10 : begin //swapji
        s_addr = j; //set address to j
        s_wrdata = readi; //then write s[i] to s[j]
        s_wren = 1;
    end
    5'd11 : begin //readS
        //the address it is setting to read in s_mem is at (s[i]+s[j])%256
        s_addr = (readi + readj) % 256; 
        s_wren = 0;
    end
    5'd12 : begin //loadS
        //the purpose of this state is the extra clock cycle for s_mem to load the value at
        //(s[i]+s[j])%256 back into PRGA  
    end
    5'd13 : begin //assignPAD
        padK = s_rddata; //a "local variable" for storing pad[k]
    end
    5'd14 : begin //readk
        ct_addr = k; //now we are reading ct[k] but first, we need to assign the new ct_addr
    end
    5'd15 : begin //loadK
        //an empty state for the extra clock cycle to load ct[k] into PRGA
        //nothing else needs to be set in this state
    end
    5'd16 : begin //assignPT
        pt_addr = k; //for storing pad[k]^ct[k] into plaintext[k]
        pt_wren = 1;
        pt_wrdata = ct_rddata ^ padK;
    end
    5'd17 : begin //Kincr
        k += 1; //k increments by 1
        pt_wren = 0;
    end
    5'd18 : begin //done
        i = 0; 
        j = 0;
        s_addr = 0;
        ct_addr = 0;
        pt_addr = 0;
        s_wrdata = 0;
        pt_wrdata = msg_len;
        s_wren = 0;
        pt_wren = 1;
        rdy = 1;
        k = 1;
        
    end
    endcase

end
endmodule: prga