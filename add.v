// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module add (clk, out, x, y, z);

parameter bw = 4;
parameter psum_bw = 4+2;

output reg [psum_bw-1:0] out;
input [bw-1:0] x;
input [bw-1:0] y;
input [bw:0] z;
input clk;


wire [psum_bw-1:0] out_wire;
wire s0, s1, s2, s3, s4, s5, s6, s7;
wire c0, c1, c2, c3, c4, c5, c6, c7;


csa2_2  csa2_2_instance0 (.x(x[0]), .y(z[0]), .s(s0), .c(c0));
csa3_2  csa3_2_instance1 (.x(x[1]), .y(y[1]), .z(z[1]), .s(s1), .c(c1));
csa2_2  csa2_2_instance2 (.x(c0), .y(s1), .s(s2), .c(c2));
csa3_2  csa3_2_instance3 (.x(x[2]), .y(z[2]), .z(c1), .s(s3), .c(c3));
csa2_2  csa2_2_instance4 (.x(s3), .y(c2), .s(s4), .c(c4));
csa3_2  csa3_2_instance5 (.x(x[3]), .y(y[3]), .z(z[3]), .s(s5), .c(c5));
csa3_2  csa3_2_instance6 (.x(c3), .y(c4), .z(s5), .s(s6), .c(c6));
csa3_2  csa3_2_instance7 (.x(c5), .y(c6), .z(z[4]), .s(s7), .c(c7));


assign out_wire[0] = s0;
assign out_wire[1] = s2;
assign out_wire[2] = s4;
assign out_wire[3] = s6;
assign out_wire[4] = s7;
assign out_wire[5] = c7;

always @ (posedge clk) begin
        out  <= out_wire;
end

endmodule
