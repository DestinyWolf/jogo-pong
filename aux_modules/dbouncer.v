module dbouncer (
    key_in, clk, key_out, rst
);
    input key_in, clk, rst;
    output key_out;

    wire reset;
    wire delay_key;
    assign reset = rst;
	 
	 wire[1:0] clk_aux;
	 
	 //flip_t flipt1(clk, 1'b1, reset, clk_aux[0]);  
	
    flip_d flip1(clk, key_in, reset, delay_key);

    assign key_out = !delay_key & key_in;

    //flip_d flip2(clk_aux[0], delay_key, reset, key_out);

endmodule