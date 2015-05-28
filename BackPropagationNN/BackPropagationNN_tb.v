`timescale 1 ps/ 1 ps

module BackPropagationNN_tb;
	reg signed [8:0] x0, x1, x2, x3 ;
	reg signed [8:0] desired_y0, desired_y1 ;
	wire y0, y1;
   reg RST, CLK;
	integer file, i, code;
	parameter CYCLE = 100;
	
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
	
	initial begin : file_block
		#100 RST = 1 ;
		#101 RST = 0 ;
		file = $fopen("dataset.txt","r" );
		for (i = 0; i < 200; i=i+1) begin
			code = $fscanf(file, "%d\t%d\t%d\t%d\t%d\t%d\n", x0, x1, x2, x3, desired_y0, desired_y1);
			#4800;
			
		end // for
		$fclose(file); $stop;
	end // initial
	always #(CYCLE) CLK = ~CLK; // Clock generator
endmodule  

