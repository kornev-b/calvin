`timescale 1 ps/ 1 ps

module FeedForwardNN_Activation_tb;
	reg signed [16:0] x;
	wire signed [8:0] y;
   reg CLK;
   activation a0 (
		.x(x),
		.y(y),
		.clk(CLK)
	);
	
	initial 
	begin 
		CLK = 0 ; 
	end 
	
	always
	begin
		#100 CLK = ~CLK ;
	end
	
	initial
	begin
		#100 x = -10 ;
		#200 x = -2 ;
		#300 x = -1 ;
		#400 x = 0 ;
		#500 x = 1 ;
		#600 x = 2 ;
		#700 x = 10 ;
	end
endmodule 