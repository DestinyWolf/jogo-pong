module shift_register_7b (
    side, clk, rst, data, dataout
);
    input side, clk, rst, data;
    output [7:0] dataout;
    wire [7:0] ff_data_out;
	 wire [7:0] data_in;
	 
    assign data_in[0] = side ? data:ff_data_out[1];
    assign data_in[1] = side ? ff_data_out[0]:ff_data_out[2];
    assign data_in[2] = side ? ff_data_out[1]:ff_data_out[3];
    assign data_in[3] = side ? ff_data_out[2]:ff_data_out[4];
    assign data_in[4] = side ? ff_data_out[3]:ff_data_out[5];
    assign data_in[5] = side ? ff_data_out[4]:ff_data_out[6];
	 assign data_in[6] = side ? ff_data_out[5]:ff_data_out[7];
    assign data_in[7] = side ? ff_data_out[6]:data;

	 

    flip_d f0(.clk(clk), .d(data_in[0]), .rst(rst), .q(ff_data_out[0]));
    flip_d f1(.clk(clk), .d(data_in[1]), .rst(rst), .q(ff_data_out[1]));
    flip_d f2(.clk(clk), .d(data_in[2]), .rst(rst), .q(ff_data_out[2]));
    flip_d f3(.clk(clk), .d(data_in[3]), .rst(rst), .q(ff_data_out[3]));
    flip_d f4(.clk(clk), .d(data_in[4]), .rst(rst), .q(ff_data_out[4]));
    flip_d f5(.clk(clk), .d(data_in[5]), .rst(rst), .q(ff_data_out[5]));
    flip_d f6(.clk(clk), .d(data_in[6]), .rst(rst), .q(ff_data_out[6]));
	 flip_d f7(.clk(clk), .d(data_in[7]), .rst(rst), .q(ff_data_out[7]));

    assign dataout = ~ff_data_out;
    
endmodule