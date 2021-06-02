`timescale 1ps / 1ps
//the purpose of this module runs the whole decryption process

module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [23:0] key;
    
    logic enC, rdyC, key_valid;
    
    logic [7:0] ct_rddata, ct_addr;

    always_comb begin
        if(rdyC)
        enC = 1;
        else enC = 0;
    end

    ct_mem ct(.address(ct_addr),
              .clock(CLOCK_50),
              .data(8'b0),
              .wren(1'b0),
              .q(ct_rddata));
    //instantiates crack to crack the code and get the final key
    crack c(.clk(CLOCK_50),
            .rst_n(KEY[3]),
            .en(enC),
            .rdy(rdyC),
            .key(key),
            .key_valid(key_valid),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata));

    //instantiates the display HEX module for HEX0-5 to display the final key
    hex_display h5 (.value(key[23:20]), .HEX(HEX5), .key_valid(key_valid));
    hex_display h4 (.value(key[19:16]), .HEX(HEX4), .key_valid(key_valid));
    hex_display h3 (.value(key[15:12]), .HEX(HEX3), .key_valid(key_valid));
    hex_display h2 (.value(key[11:8]), .HEX(HEX2), .key_valid(key_valid));
    hex_display h1 (.value(key[7:4]), .HEX(HEX1), .key_valid(key_valid));
    hex_display h0 (.value(key[3:0]), .HEX(HEX0), .key_valid(key_valid));
endmodule: task4
    // your code here
 module hex_display(input logic [3:0] value, output logic [6:0] HEX, input logic key_valid);
		//this module displays the key on the board
  always_comb begin
   HEX = 7'b1;
   if(key_valid) begin
        if (value == 4'd0)//0
        HEX = 7'b1000000;
        if (value == 4'd1)//1
        HEX = 7'b1111001; 
        if (value == 4'd2)//2
        HEX = 7'b0100100;
        if (value == 4'd3)//3
        HEX = 7'b0110000;
        if (value == 4'd4)//4
        HEX = 7'b0011001;
        if (value == 4'd5)//5
        HEX = 7'b0010010;
        if (value == 4'd6)//6
        HEX = 7'b0000010;
        if (value == 4'd7)//7
        HEX = 7'b1111000;
        if (value == 4'd8)//8
        HEX = 7'b0;
        if (value == 4'd9)//9
        HEX = 7'b0010000;
        if (value == 4'd10)//A
        HEX = 7'b0001000; //display A
        if (value == 4'd11)//B
        HEX = 7'b0000011; //display b
        if (value == 4'd12)//C
        HEX = 7'b1000110;  //display C
        if (value == 4'd13)//D
        HEX = 7'b0100001;  //display d
        if (value == 4'd14)//E
        HEX = 7'b0000110;  //display E
        if (value == 4'd15)//F
        HEX = 7'b0001110;  //display F
   end
  else HEX = 7'b0111111;
  end
	
endmodule


