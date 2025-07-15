module flip_t (
    clk, t, rst, q
);
    input clk, t, rst;
    output reg q;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 0;
        end else if (t) begin
            q <= ~q;
        end else  begin
            q <= q;
        end
    end
endmodule