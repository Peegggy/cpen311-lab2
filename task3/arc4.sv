`define reset       3'd0; //to reset the process
`define processInit 3'd1; //to process init module
`define processKSA  3'd2; //to process KSA module
`define processPRGA 3'd3; //to process PRGA module
`define done        3'd4; //done state

module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
logic enInit, enKSA, enPRGA; //needs seperate en signals for each module
logic rdyInit, rdyKSA, rdyPRGA; //seperate rdy signals too
logic wren_final, wrenInit, wrenKSA, wrenPRGA; //and seperate wren 

logic [7:0] wrdata_final, wrdataInit, wrdataKSA, wrdataPRGA; //depending on the state, wrdata_final
logic [7:0] addr_final, addrInit, addrKSA, addrPRGA; //addr_final
logic [7:0] read_value_final, read_value, read_valueKSA, read_valuePRGA; //read_value_final can be different

logic [2:0] state; //indicates what the current state is and what the next state will be

//instantiates the 3 modules
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
    //if it is in the processInit state, and the module is ready to start then en is on
    if(state == 3'd1 && rdyInit && addrInit < 256) begin
        enInit = 1;
        enKSA = 0; //and everything else is off
        enPRGA = 0;
    end
    //if it is in the processKSA state, and the module is ready to start (rdyKSA = 1) then enKSA is 1
    else if(state == 3'd2 && rdyKSA) begin 
        enInit = 0;
        enKSA = 1;
        enPRGA = 0;
    end
    //same for processPRGA state
    else if(state == 3'd3 && rdyPRGA) begin
        enInit = 0;
        enKSA = 0;
        enPRGA = 1;
    end
    else begin //else en signals for all three are off
        enInit = 0;
        enKSA = 0;
        enPRGA = 0;
    end
end

always_ff @(posedge clk) begin
    if(~rst_n) //if reset is pressed
    state = 3'd0; //then go back to reset state
    else begin
        case(state)
        //if rdy and enable are both on, then it means the module is ready to perform
        3'd0 : state <= (rdy && en) ? 3'd1 : 3'd0; 
        //to indicate that init has finished, wrenInit has to be off, rdyInit is on and address is at 255
        3'd1 : state <= (~wrenInit && rdyInit && addrInit == 8'd255) ? 3'd2 : 3'd1;
        //to indicate that KSA has finished, rdyKSA is on, wrenKSA is off and the last rddata should not be 255
        3'd2 : state <= (rdyKSA && ~wrenKSA && read_valueKSA !== 8'd255) ? 3'd3 : 3'd2;
        //to indicate that prga is done, enPRGA, rdyPRGA and pt_wren should all be on
        3'd3 : state <= (enPRGA && rdyPRGA && pt_wren) ? 3'd4 : 3'd3;
        //after PRGA has finished, ARC4 is finished
        default : state <= 3'd4;
        endcase
    end
end

always_comb begin
    //s_mem takes the addr of Init in init state, addr of KSA in KSA and addr of PRGA in PRGA else it's 0
    addr_final = (state == 3'd1) ? addrInit : ((state == 3'd2) ? addrKSA : (state == 3'd3 ? addrPRGA : 0));
    //s_mem takes the wrdata of Init in init, wrdata of KSA in KSA and wrdata of PRGA in PRGA else it's 0
    wrdata_final = (state == 3'd1) ? wrdataInit : ((state == 3'd2) ? wrdataKSA : (state == 3'd3 ? wrdataPRGA : 0));
    //s_mem takes wren signals from init in init, KSA in KSA and PRGA in PRGA else it's 0
    wren_final = (state == 3'd1) ? wrenInit : ((state == 3'd2) ? wrenKSA : (state == 3'd3 ? wrenPRGA : 0));
    //KSA gets q from s_mem in KSA state else it is 0
    read_valueKSA = (state == 3'd2) ? read_value : 0;
    //PRGA gets q from s_mem in PRGA state else it is 0
    read_valuePRGA = (state == 3'd3) ? read_value : 0;
    //rdy signals in ARC4 is 1 in reset and done states
    rdy = (state == 3'd0 || state == 3'd4) ? 1 : 0;
end
    // your code here

endmodule: arc4