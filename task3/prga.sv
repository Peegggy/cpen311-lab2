`define reset       5'd1;
`define readCT      5'd2;
`define loadCT      5'd3;
`define PTmsgLen    5'd4;
`define readi       5'd5;
`define loadi       5'd6;
`define readj       5'd7;
`define loadj       5'd8;
`define swapij      5'd9;
`define swapji      5'd10;
`define readS       5'd11;
`define loadS       5'd12;
`define assignPAD   5'd13;
`define readK       5'd14;
`define loadK       5'd15;
`define assignPT    5'd16;
`define Kincr       5'd17;
`define done        5'd18;



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
    5'd1 : nextstate = (rdy && en) ? 5'd2 : 5'd1;
    5'd2 : nextstate = 5'd3;
    5'd3 : nextstate = 5'd4;
    5'd4 : nextstate = 5'd5;
    5'd5 : nextstate = 5'd6;
    5'd6 : nextstate = k == (msg_len + 1'b1) ? 5'd18 : 5'd7;
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
    5'd17 : nextstate = 5'd5;
    5'd18 : nextstate = 5'd18;
    default : nextstate = 5'd18;
    endcase
end

always_ff @(posedge clk) begin
    if(~rst_n)
    state = 5'd1;
    else
    state = nextstate;
end

always_ff @(posedge clk) begin
    case(state)
    5'd1 : begin
        i = 0;
        j = 0;
        k = 1;
        s_addr = 0;
        ct_addr = 0;
        pt_addr = 0;
        s_wrdata = 0;
        pt_wrdata = 0;
        s_wren = 0;
        pt_wren = 0;
        rdy = 1;
        msg_len = 0;
    end
    5'd2 : begin
        rdy = 0;
    end
    5'd3 : begin
        msg_len = ct_rddata;
    end
    5'd4 : begin
        pt_wren = 1;
        pt_wrdata = msg_len;
    end
    5'd5 : begin
        s_addr = (i+1) % 256;
        s_wren = 0;
    end
    5'd6 : begin
        //readi = s_rddata;
        i = s_addr;
    end
    5'd7 : begin
        readi = s_rddata;
        s_addr = (j+s_rddata) % 256;
        s_wren = 0;
    end
    5'd8 : begin
        j = s_addr;
    end
    5'd9 : begin
        readj = s_rddata;
        s_addr = i;
        s_wrdata = s_rddata;
        s_wren = 1;
    end
    5'd10 : begin
        s_addr = j;
        s_wrdata = readi;
        s_wren = 1;
    end
    5'd11 : begin
        s_addr = (readi + readj) % 256;
        s_wren = 0;
    end
    5'd12 : begin
        
    end
    5'd13 : begin
        padK = s_rddata;
    end
    5'd14 : begin
        ct_addr = k;
    end
    5'd15 : begin
        
    end
    5'd16 : begin
        pt_addr = k;
        pt_wren = 1;
        pt_wrdata = ct_rddata ^ padK;
    end
    5'd17 : begin
        k += 1;
        pt_wren = 0;
    end
    5'd18 : begin
        i = 0;
        j = 0;
        s_addr = 0;
        ct_addr = 0;
        pt_addr = 0;
        s_wrdata = 0;
        pt_wrdata = 0;
        s_wren = 0;
        pt_wren = 0;
        rdy = 1;
        k = 1;
        
    end
    endcase

end
endmodule: prga
