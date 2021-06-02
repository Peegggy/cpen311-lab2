module tb_rtl_ksa();

// Your testbench goes here.
logic clk, rst_n, en, rdy;
logic [23:0] key;
logic [7:0] addr, rddata, wrdata;
logic wren;
//this testbench mainly checks if i is incrementing correctly and j is being calculated correctly
//with manually inputed rddata.
ksa dut(.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    key = 24'h00033C;
    en = 1;
    rst_n = 1;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    assert(dut.currentstate === 4'd1)
    else $error ("not in the restart state");
    #5;
    rddata = 0; //setting rddata to be 0, readi should have this value as well and j should be 0
    #10;
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    #15;
    assert(dut.readi === 0) //checking if readi is rddata
    else $error ("readi should be 0");
    assert(dut.j === 0)
    else $error ("j should be 0");
    #50;
    assert(dut.i === 9'd1) //i should increment
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    //--------------case1-----------------
    rddata = 1; //setting rddata to be 1
    #20;
    assert(dut.readi === 1) //readi should be 1
    else $error ("readi should be 1");
    assert(dut.j === 4) //j = (j(which is 0) + readi + key[15:8])%256 
    else $error ("j should be 4"); //which is 4
    #50;
    assert(dut.i === 9'd2) //i should finish incrementing in readi state
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2) 
    else $error ("not in readi state");
    //--------------case2------------
    rddata = 2; //setting rddata to be 2
    #20;
    assert(dut.readi === 2) 
    else $error ("readi should be 2"); //i%3 = 2
    assert(dut.j === 66) //j = (4 + 2 + key[7:0])%256
    else $error ("j should be 66"); //which is 66
    #50;
    assert(dut.i === 9'd3)
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    //----------------case3------------
    rddata = 3;
    #20;
    assert(dut.readi === 3)
    else $error ("readi should be 3"); //i%3 = 0
    assert(dut.j === 69) //j = (66 + 3 + 0)%256
    else $error ("j should be 69"); //which is 69
    #50;
    assert(dut.i === 9'd4)
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    //---------case4-----------------
    rddata = 4;
    #20;
    assert(dut.readi === 4)
    else $error ("readi should be 4"); //i%3 = 1
    assert(dut.j === 76) //j = (69+4+3) %256
    else $error ("j should be 76"); //which is 76
    #50;
    assert(dut.i === 9'd5)
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    //------------case5--------------
    rddata = 5;
    #20;
    assert(dut.readi === 5)
    else $error ("readi should be 5"); //i%3 = 2
    assert(dut.j === 141) //j = (76+5+60) % 256
    else $error ("j should be 141"); //which is 141
    #50;
    assert(dut.i === 9'd6)
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    //-----------case6----------
    rddata = 6;
    #20;
    assert(dut.readi === 6)
    else $error ("readi should be 5"); //i%3 = 0
    assert(dut.j === 147) //j = (141+6+0)%256
    else $error ("j should be 147"); //which is 147
    #50;
    assert(dut.i === 9'd7)
    else $error ("i did not count up");
    assert(dut.currentstate === 4'd2)
    else $error ("not in readi state");
    #20000;
    $stop;
end
endmodule: tb_rtl_ksa
