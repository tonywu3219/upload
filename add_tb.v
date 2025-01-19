// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module add_tb;

parameter bw = 4;
parameter psum_bw = 4+2;

reg clk = 0;

reg  [bw-1:0] x;
reg  [bw-1:0] y;
reg  [bw:0] z;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;


integer x_file ; // file handler
integer x_scan_file ; // file handler

integer y_file ; // file handler
integer y_scan_file ; // file handler

integer z_file ; // file handler
integer z_scan_file ; // file handler

integer x_dec;
integer y_dec;
integer z_dec;
integer i; 
integer u; 
integer error = 0;

function [4:0] dec2bin ;
  input integer  weight ;
  begin

    if (weight>15) begin
     dec2bin[4] = 1;
     weight = weight - 16;
    end
    else 
     dec2bin[4] = 0;

    if (weight>7) begin
     dec2bin[3] = 1;
     weight = weight - 8;
    end
    else 
     dec2bin[3] = 0;

    if (weight>3) begin
     dec2bin[2] = 1;
     weight = weight - 4;
    end
    else 
     dec2bin[2] = 0;

    if (weight>1) begin
     dec2bin[1] = 1;
     weight = weight - 2;
    end
    else 
     dec2bin[1] = 0;

    if (weight>0) 
     dec2bin[0] = 1;
    else 
     dec2bin[0] = 0;

  end
endfunction




// Below function is for verification
function [psum_bw-1:0] add_predicted;
  
  input [bw-1:0] a, b;
  input [bw:0] c;
  reg [psum_bw-1:0] psum;
 
  begin 

    add_predicted =  a + b + c;
  end 
endfunction



add  add_instance (
	.clk(clk), 
        .x(x), 
        .y(y),
        .z(z),
	.out(out)
); 
 

initial begin 



  $dumpfile("add_tb.vcd");
  $dumpvars(0,add_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<50; i=i+1) begin  // Data lenghh is 10 in the data files

     #1 clk = 1'b0;

     x_dec = $urandom_range(0,15);
     y_dec = $urandom_range(0,15);
     z_dec = $urandom_range(0,31);

     x = dec2bin(x_dec); 
     y = dec2bin(y_dec); 
     z = dec2bin(z_dec); 

     y = {y[3], 1'b0, y[1],1'b0};

     if (i>0) begin // this if condition is needed as the output is available at the next cycle

       if (out == expected_out) 
          $display("Computed data matched :D, %2d vs. %2d",   out, expected_out);
       else begin
          $display("Computed data ERROR (>.<), %2d vs. %2d",  out, expected_out);
          error = error+1;
       end
       $display("Total ERROR: %3d",  error);
     end


     #1 clk = 1'b1;
       expected_out = add_predicted(x, y, z);
  end


  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




