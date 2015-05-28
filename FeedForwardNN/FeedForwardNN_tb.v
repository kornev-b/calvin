`timescale 1 ps/ 1 ps

module FeedForwardNN_tb;
	reg signed [8:0] x0, x1, x2, x3 ;
	wire signed [16:0] y0, y1;
   reg RST, CLK;
	integer file, i, code;
	parameter CYCLE = 100;
	
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
	
	initial begin : file_block
		#100 RST = 1 ;
		#101 RST = 0 ;
		file = $fopen("testset.txt","r" );
		for (i = 0; i < 100; i=i+1) begin
			code = $fscanf(file, "%d\t%d\t%d\t%d\t%d\t%d\n", x0, x1, x2, x3, 0, 0);
			#4800;
			$display("%d: x0=%d, x1=%d, x2=%d, x3=%d, y0=%d y1=%d", i, x0, x1, x2, x3, y0, y1);
		end // for
		$fclose(file); $stop;
	end // initial
	always #(CYCLE) CLK = ~CLK; // Clock generator
endmodule  
