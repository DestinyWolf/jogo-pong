module flip_d (
    clk, d, rst, q
);
    input clk, d, rst;
    output reg q;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule