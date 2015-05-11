/*
module TOP (
	////////////////////	Clock Input	 	////////////////////	 
	CLOCK_27,						//	27 MHz
	CLOCK_50,						//	50 MHz
	EXT_CLOCK						//	External Clock
	);
	////////////////////////	Clock Input	 	////////////////////////
	input			CLOCK_27;				//	27 MHz
	input			CLOCK_50;				//	50 MHz
	input			EXT_CLOCK;				//	External Clock
	
	reg x0,x1,x2,x3,y0,y1;

	
	FeedForwardNN ff(x0, x1, x2, x3, y0, y1, CLOCK_50) ;
endmodule //end top level DE2_TOP	
*/
module FeedForwardNN(
	/* x inputs are in range 0-255 => 8 bits wide */
	/* for x's to be signed we need 9 bits! */
   input wire signed [8:0] x0, x1,
	input wire signed [8:0] x2,
	input wire signed [8:0] x3,
   output wire y0,
	output wire y1,
   input RST, CLK
	);
   /* WWIDTH = Width of one weight */
	parameter WWIDTH = 8;
	
	reg [3:0] addr;
	reg [255:0] write_data;
	reg [255:0] selected_data;
	reg we;
	wire [255:0] read_data;
	reg [3:0] state;
	wire reset;
	reg [3:0] counter;
	
	reg signed [16:0] a0_x, a1_x, a2_x, a3_x, a4_x, a5_x;
	wire signed [8:0] a0_y, a1_y, a2_y, a3_y, a4_y, a5_y;
	
	/* TEMPORARY registers to save results of dot product of inputs and weights at 1st layer */
	/* 16-bit wide because we multiply 8-bit input to 8-bit weight */
	/* for z's to be signed we need 17 bits!*/
	reg signed [16:0] z0, z1, z2, z3, z4, z5;
	
	/* Storing activation function output */
	reg signed [8:0] v0, v1, v2, v3, v4, v5 ; 
	
	wire mem_clk;
	//mem_PLL u1(CLK, mem_clk);
	assign mem_clk = CLK;
	assign reset = RST;
	
	ram_pos_thru memory(read_data, addr, write_data, we, mem_clk);
	activation a0(a0_x, a0_y, mem_clk);
	activation a1(a1_x, a1_y, mem_clk);
	activation a2(a2_x, a2_y, mem_clk);
	activation a3(a3_x, a3_y, mem_clk);
	activation a4(a4_x, a4_y, mem_clk);
	activation a5(a5_x, a5_y, mem_clk);
	
	always @ (negedge mem_clk)
	begin
		if(reset) begin
			state <= 4'd0;
		end
		else begin
			case(state)
				4'd0: begin
					// now set up read
					we <= 0 ;
					/* weights for first layer are at address=0 */
					addr <= 0 ; 
					
					state <= 4'd1 ;
				end
				4'd1: begin
					// ready one cycle later
					selected_data <= read_data ;
					
					// calculating dot products
					/* each weight is 8-bit wide */
					/* w0 is 0th to 7th bits of selected_data */
					/* w1 is 8th to 15th bits */
					/* to simpify we used WWIDTH parameter */
					/* so Nth weight is in range [N + 1 * WWIDTH - 1: N * WWIDTH] */
					z0 <= x0 * $signed(selected_data[1 * WWIDTH - 1: 0 * WWIDTH]) +
							x1 * $signed(selected_data[2 * WWIDTH - 1: 1 * WWIDTH]) +
							x2 * $signed(selected_data[3 * WWIDTH - 1: 2 * WWIDTH]) +
							x3 * $signed(selected_data[4 * WWIDTH - 1: 3 * WWIDTH]);
					
					z1 <= x0 * $signed(selected_data[5 * WWIDTH - 1: 4 * WWIDTH]) +
							x1 * $signed(selected_data[6 * WWIDTH - 1: 5 * WWIDTH]) +
							x2 * $signed(selected_data[7 * WWIDTH - 1: 6 * WWIDTH]) +
							x3 * $signed(selected_data[8 * WWIDTH - 1: 7 * WWIDTH]);
					
					z2 <= x0 * $signed(selected_data[9 * WWIDTH - 1: 8 * WWIDTH]) +
							x1 * $signed(selected_data[10 * WWIDTH - 1: 9 * WWIDTH]) +
							x2 * $signed(selected_data[11 * WWIDTH - 1: 10 * WWIDTH]) +
							x3 * $signed(selected_data[12 * WWIDTH - 1: 11 * WWIDTH]);
							
					z3 <= x0 * $signed(selected_data[13 * WWIDTH - 1: 12 * WWIDTH]) +
							x1 * $signed(selected_data[14 * WWIDTH - 1: 13 * WWIDTH]) +
							x2 * $signed(selected_data[15 * WWIDTH - 1: 14 * WWIDTH]) +
							x3 * $signed(selected_data[16 * WWIDTH - 1: 15 * WWIDTH]);
							
					z4 <= x0 * $signed(selected_data[17 * WWIDTH - 1: 16 * WWIDTH]) +
							x1 * $signed(selected_data[18 * WWIDTH - 1: 17 * WWIDTH]) +
							x2 * $signed(selected_data[19 * WWIDTH - 1: 18 * WWIDTH]) +
							x3 * $signed(selected_data[20 * WWIDTH - 1: 19 * WWIDTH]);
					
					z5 <= x0 * $signed(selected_data[21 * WWIDTH - 1: 20 * WWIDTH]) +
							x1 * $signed(selected_data[22 * WWIDTH - 1: 21 * WWIDTH]) +
							x2 * $signed(selected_data[23 * WWIDTH - 1: 22 * WWIDTH]) +
							x3 * $signed(selected_data[24 * WWIDTH - 1: 23 * WWIDTH]);
					
					state <= 4'd2 ;
				end
				4'd2: begin
					// set up activation func.
					a0_x <= z0 ;
					a1_x <= z1 ;
					a2_x <= z2 ;
					a3_x <= z3 ;
					a4_x <= z4 ;
					a5_x <= z5 ;
					
					state <= 4'd3 ;
				end
				4'd3: begin
					v0 <= a0_y ;
					v1 <= a1_y ;
					v2 <= a2_y ;
					v3 <= a3_y ;
					v4 <= a4_y ;
					v5 <= a5_y ;
					
					state <= 4'd0 ;
				end
			endcase
		end
	end 
	assign y0 = ~selected_data[0] ;
	assign y1 = selected_data[1] ;
endmodule

module activation( x , y, clk);
	input wire signed [16:0] x;
	output reg signed [8:0] y;
	input clk;
	
	always @ (posedge clk)
	begin
		if(x < -16'd1) y = -8'd1 ;
		else if (x > 16'd1) y = 8'd1 ;
		else y = 8'd0 ;
	end
endmodule

module ram_pos_thru (q, a, d, we, clk);
	output [255:0] q;
	reg [255:0] q;
	input [255:0] d;
	input [3:0] a;
	input we, clk;
	reg [255:0] mem [3:0] /* synthesis ram_init_file = "TestMemFile.hex" */ ;
	
	initial begin
		$readmemh("ram.hex", mem);
	end
	
	always @ (posedge clk)
	begin
		if(we) mem[a] <= d ;
		q <= mem[a] ;
	end
endmodule