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
		/*
		159	205	81	76	0	1	
		168	218	37	36	0	1	
		111	216	3	89	0	1	
		238	216	9	8	0	1	
		78	101	214	226	0	0	
		*/
		#0 x0 = 8'd159; x1 = 8'd205; x2 = 8'd81; x3 = 8'd76; desired_y0 = 8'd0; desired_y1 = 8'd1;
		#4800 x0 = 8'd168; x1 = 8'd218; x2 = 8'd37; x3 = 8'd36; desired_y0 = 8'd0; desired_y1 = 8'd1;
		#4800 x0 = 8'd111; x1 = 8'd216; x2 = 8'd3; x3 = 8'd89; desired_y0 = 8'd0; desired_y1 = 8'd1;
		#4800 x0 = 8'd238; x1 = 8'd216; x2 = 8'd9; x3 = 8'd8; desired_y0 = 8'd0; desired_y1 = 8'd1;
		#4800 x0 = 8'd78; x1 = 8'd101; x2 = 8'd214; x3 = 8'd226; desired_y0 = 8'd0; desired_y1 = 8'd0;
		
	end
endmodule  

