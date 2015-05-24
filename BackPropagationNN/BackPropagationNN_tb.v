`timescale 1 ps/ 1 ps

module BackPropagationNN_tb;
	reg signed [8:0] x0, x1, x2, x3 ;
	reg signed [8:0] desired_y0, desired_y1 ;
	wire y0, y1;
   reg RST, CLK;
   BackPropagationNN BP0 (
		.x0(x0),
		.x1(x1),
		.x2(x2),
		.x3(x3),
		.desired_y0(desired_y0),
		.desired_y1(desired_y1),
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
		#100 CLK = ~CLK ;
	end
	
	initial
	begin
		#100 RST = 1 ;
		#101 RST = 0 ;
		
		#0 x0 = 8'd196; x1 = 8'd243; x2 = 8'd106; x3 = 8'd149; desired_y0 = 8'd0; desired_y1 = 8'd0;
		#1800 x0 = 8'd13; x1 = 8'd37; x2 = 8'd128; x3 = 8'd160; desired_y0 = 8'd1; desired_y1 = 8'd0;

	end
endmodule  
