module matriz(
	clk, rst, linha0, linha1, linha2, linha3, linha4, linha_out, colunas
);
	input clk, rst;
	input [7:0] linha0, linha1, linha2, linha3, linha4;
	output reg [7:0] linha_out;
	output reg [4:0] colunas;
	wire [2:0] ff_in;
	wire [2:0] count;
	wire rst_ff;
	
	//reg [2:0] count;
	assign ff_in[0] = 1'b1;
	assign ff_in[1] = count[0];
	assign ff_in[2] = count[0] & count[1];
	
	flip_t ff0(clk, ff_in[0], rst_ff, count[0]);
	flip_t ff1(clk, ff_in[1], rst_ff, count[1]);
	flip_t ff2(clk, ff_in[2], rst_ff, count[2]);
	
	assign rst_ff = (count[2] & !count[1] & count[0]) | rst;
	
	always @(posedge clk) begin
		case (count) 
			3'b000: begin
				linha_out <= linha0;
				colunas <= 5'b11110;
	//			count <= 3'b001;
			end
			3'b001: begin
				linha_out <= linha1;
				colunas <= 5'b11101;
		//		count <= 3'b010;
			end
			3'b010: begin
				linha_out <= linha2;
				colunas <= 5'b11011;
			//	count <= 3'b011;
			end
			3'b011: begin
				linha_out <= linha3;
				colunas <= 5'b10111;
				//count <=3'b100;
			end
			3'b100: begin
				linha_out <= linha4;
				colunas <= 5'b01111;
				//count <= 3'b000;
			end
			default: begin
				linha_out <= linha_out;
				colunas <= colunas;
				//count <= count;
			end
		endcase
	end
	
endmodule