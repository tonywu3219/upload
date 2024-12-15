// Code your design here
module fir4csa_u #(parameter w=16)(
	input                      clk, 
                             reset,
  input         [w-1:0] a,
  output logic  [w+1:0] s);
// delay pipeline for input a
  logic         [w-1:0] ar, br, cr, dr;

// RIPPLE CARRY ADDER LOGIC 

  logic         [w-1:0] rca1_s,  rca2_s; 
  logic         [w  :0] rca1_co, rca2_co;
  logic c1,c2;

  logic         [w+1:0] sum;

//   always_comb begin
//     rca1_co[0] = 0;
//     for(int i=0; i<w; i++)
//       {rca1_co[i+1],rca1_s[i]} = ar[i]+br[i]+rca1_co[i];
//   end
  
  CSkipA16 csa_1(.sum(rca1_s), .cout(c1), .a(ar), .b(br));
  CSkipA16 csa_2(.sum(rca2_s), .cout(c2), .a(cr), .b(dr));
//   always_comb begin
//     rca2_co[0] = 0;
//     for(int i=0; i<w; i++)
//       {rca2_co[i+1],rca2_s[i]} = cr[i]+dr[i]+rca2_co[i];
//   end
  always_comb
    sum = {c1,rca1_s} + {c2,rca2_s};
 
// END OF RIPPLE CARRY ADDER

// sequential logic -- standardized for everyone
  always_ff @(posedge clk)			// or just always -- always_ff tells tools you intend D flip flops
    if(reset) begin					// reset forces all registers to 0 for clean start of test
	  ar <= 'b0;
	  br <= 'b0;
	  cr <= 'b0;
	  dr <= 'b0;
	  s  <= 'b0;
    end
    else begin					    // normal operation -- Dffs update on posedge clk
	  ar <= a;						// the chain will always hold the four most recent incoming data samples
	  br <= ar;
	  cr <= br;
	  dr <= cr;
	  s  <= sum; 
	end

endmodule

// Full Adder
module FA(output sum, cout, input a, b, cin);
  wire w0, w1, w2;
  
  xor (w0, a, b);
  xor (sum, w0, cin);
  
  and (w1, w0, cin);
  and (w2, a, b);
  or (cout, w1, w2);
endmodule

// Ripple Carry Adder - 4 bits
module RCA4(output [3:0] sum, output cout, input [3:0] a, b, input cin);
  
  wire [3:1] c;
  
  FA fa0(sum[0], c[1], a[0], b[0], cin);
  FA fa[2:1](sum[2:1], c[3:2], a[2:1], b[2:1], c[2:1]);
  FA fa31(sum[3], cout, a[3], b[3], c[3]);
  
endmodule

module SkipLogic(output cin_next,
  input [3:0] a, b, input cin, cout);
  
  wire p0, p1, p2, p3, P, e;
  
  or (p0, a[0], b[0]);
  or (p1, a[1], b[1]);
  or (p2, a[2], b[2]);
  or (p3, a[3], b[3]);
  
  and (P, p0, p1, p2, p3);
  and (e, P, cin);
  
  or (cin_next, e, cout);

endmodule


// Carry Skip Adder - 16 bits
module CSkipA16(output [15:0] sum, output cout, input [15:0] a, b);
  
  wire [3:0] couts;
  wire [2:0] e; 
  
  RCA4 rca0(sum[3:0], couts[0], a[3:0], b[3:0], 0);
  RCA4 rca[3:1](sum[15:4], couts[3:1], a[15:4], b[15:4], e[2:0]);
  
  SkipLogic skip0(e[0], a[3:0], b[3:0], 0, couts[0]);
  SkipLogic skip[2:1](e[2:1], a[11:4], b[11:4], e[1:0], couts[2:1]);
  SkipLogic skip3(cout, a[15:12], b[15:12], e[2], couts[3]);

endmodule
