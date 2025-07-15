module amux (
    s, a, b, out
);
    input s;
    input [2:0] a;
    input [2:0] b;
    output [2:0] out;

    assign out = s ? a : b;
endmodule