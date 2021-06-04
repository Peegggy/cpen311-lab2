`define reset       4'd1; 
`define processA4   4'd2; //starts processing arc4
`define readMsgLen  4'd3; //gets the length so k knows when to stop incrementing
`define loadMsgLen  4'd4; //load it as a "local variable"
`define setAddrPT   4'd5; //start at 1 and see if every value in pt is within the ASCII range
`define readPT      4'd6; //read pt
`define loadPT      4'd7; //take a cycle for the value to be read 
`define compare     4'd8; //see if the value is within the readable range
`define addrPTincr  4'd9; //if it is, then check the next value
`define keyIncr     4'd10; //if not use the incremented key to check again
`define done        4'd11; //done

module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             input logic [23:0] starting_point);

    // For Task 5, you may modify the crack port list above,
    // but ONLY by adding new ports. All predefined ports must be identical.
    // your code here
    logic [3:0] state, nextstate;
    logic [7:0] pt_addr, pt_wrdata, pt_rddata;
    //data for arc4 to write into pt
    logic [7:0] a4pt_addr, a4pt_wrdata, a4pt_rddata;
    logic a4pt_wren;
    logic rst_a4, pt_wren, ena4, rdya4;
    logic PTincr;//determines if pt address shoud increment
    logic [7:0] msg_len; //length of the message
    // your code here
    always_comb begin
        if(state == 4'd2 && rdya4) //if arc4 is ready to process then 
        ena4 = 1; //set en for a4 to be 1
        else ena4 = 0; //else set to 0
    end
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr),
              .clock(clk),
              .data(pt_wrdata),
              .wren(pt_wren),
              .q(pt_rddata));

    arc4 a4(.clk(clk),
            .rst_n(rst_a4),
            .en(ena4),
            .rdy(rdya4),
            .key(key),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata),
            .pt_addr(a4pt_addr),
            .pt_rddata(a4pt_rddata),
            .pt_wrdata(a4pt_wrdata),
            .pt_wren(a4pt_wren));
    // your code here
    always_ff @(posedge clk) begin
        if(~rst_n) //if reset is pressed
        state = 4'd1; // crack goes back to reset state
        else
        state = nextstate; //else the nextstate is the current state
    end

    always_comb begin
        case(state)
        //reset state, if rdy and en are 1 then start arc4
        4'd1 : nextstate = (rdy && en) ? 4'd2 : 4'd1;
        //once arc4 is done then procees to read pt[0] which is the message length
        4'd2 : nextstate = (rdya4 && ena4 && a4pt_wren) ? 4'd3 : 4'd2;
        4'd3 : nextstate = 4'd4;
        4'd4 : nextstate = 4'd5;
        4'd5 : nextstate = 4'd6;
        4'd6 : nextstate = 4'd7;
        4'd7 : nextstate = 4'd8;
        4'd8 : nextstate = 4'd9;
        //if the addr for pt is at the end of the message and PTincr is still 1, meaning that all the values have been within the readable range
        //then the next state is done, else if pt_addr has not reached the end and PTincr is 0, that means there is a value that is not within the 
        //readable range, then increment the key by 1, else keep reading the next pt_addr
        4'd9 : nextstate = (pt_addr == msg_len && PTincr) ?  4'd11 : ((pt_addr < msg_len && ~PTincr) ? 4'd10 : 4'd6);
        //increments key by 1 and redo the whole process
        4'd10 : nextstate = (key == 24'hFFFFFF) ? 4'd11 : 4'd2;
        default : nextstate = 4'd11;
        endcase
    end
    always_ff @(posedge clk) begin
        case(state)
        4'd1 : begin //reset state
            rst_a4 = 0;
            rdy = 1; //everything is 0 except ready 
            key_valid = 0;
            key = starting_point;
            pt_wren = 0;
            pt_addr = 0;
            pt_wrdata = 0;
            PTincr = 0;
        end
        4'd2 : begin //processA4
            rdy = 0;
            rst_a4 = 1; //unreset arc4 to start the process
            pt_wrdata = a4pt_wrdata; //pt wires are connected to the pt wires from arc4
            pt_addr = a4pt_addr;
            pt_wren = a4pt_wren;
            a4pt_rddata = pt_rddata;
        end
        4'd3 : begin //readMsgLen
            pt_addr = 0; //the message length is in pt[0]
            pt_wren = 0;
        end
        4'd4 : begin //loadMsgLen
            //wait a cycle to get pt[0]
        end
        4'd5 : begin //setAddrPT
            msg_len = pt_rddata; //the read data from pt is the message length 
            rst_a4 = 0; //arc4 is done so reset arc4 for next use
            pt_addr = 8'd1; //start checking each value starting from address 1
        end
        4'd6 : begin //read PT
            pt_wren = 0; 
        end
        4'd7 : begin //loadPT
            
        end
        4'd8 : begin //compare
        //if pt_rddata is between the readable range in binary then set PTincr to 1 indicating
        //that we can increment pt addr to check the next value
            PTincr = (8'b00011111 < pt_rddata && pt_rddata  < 8'b01111111) ? 1 : 0;
        end
        4'd9 : begin //addrPTincr
            pt_addr ++; //increment pt address
        end
        4'd10 : begin //keyIncr
            key = key + 24'd2 ; //increment key
        end
        4'd11 : begin //done state
            rdy = 1;
            pt_wren = 0;
            pt_addr = 0;
            pt_wrdata = 0;
            key_valid = PTincr ? 1 : 0; //if PTincr remains 1 for the whole process then set key_valid to 1
        end
        endcase


    end
endmodule: crack
