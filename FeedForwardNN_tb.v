`timescale 1 ps/ 1 ps

module FeedForwardNN_tb;
	reg x0, x1, x2, x3 ;
	wire y0, y1;
   reg RST, CLK;
   FeedForwardNN FF0 (
		.x0(x0),
		.x1(x1),
		.x2(x2),
		.x3(x3),
		.y0(y0),
		.y1(y1),
		.RST(RST),
		.CLK(CLK)
	);
	
	initial 
	begin 
		CLK = 0 ; 
		RST = 0 ;
	end 
	
	always
	begin
		#10 CLK = ~CLK ;
	end
	
	initial
	begin
		#20 RST = 1 ;
		#30 RST = 0 ;
	end
endmodule 