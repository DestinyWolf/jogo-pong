module count_3b (
    inc, dec, clk, rst, out
);
    input inc, dec, clk, rst;
    output reg [2:0] out;

	always @(posedge clk) begin
		if (rst) begin
			out <= 3'b0;
		end
		if (inc) begin
			out <= out +1;
		end else if (dec) begin
			out <= out -1;
		end else begin
			out <= out;
		end	
			
	end
	 

endmodule