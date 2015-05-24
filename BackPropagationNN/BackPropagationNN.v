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
module BackPropagationNN(
		/* x inputs are in range 0-255 => 8 bits wide */
		/* for x's to be signed we need 9 bits! */
		input wire signed [8:0] x0, x1,
		input wire signed [8:0] x2,
		input wire signed [8:0] x3,
		input wire signed [8:0] desired_y0, desired_y1,
		input RST, CLK,
		output wire y0, y1   
	);
   /* WWIDTH = Width of one weight */
	parameter WWIDTH = 8;
	
	reg [3:0] addr;
	reg [255:0] write_data;
	reg [255:0] selected_data;
	reg we;
	wire [255:0] read_data;
	reg [5:0] state;
	wire reset;
	reg [3:0] counter;
	
	reg signed [16:0] a0_x, a1_x, a2_x, a3_x, a4_x, a5_x;
	wire signed [8:0] a0_y, a1_y, a2_y, a3_y, a4_y, a5_y;
	
	reg signed [16:0] ad0_x, ad1_x, ad2_x, ad3_x, ad4_x, ad5_x;
	wire signed [8:0] ad0_y, ad1_y, ad2_y, ad3_y, ad4_y, ad5_y;
	
	
	/* TEMPORARY registers to save results of dot product of inputs and weights at 1st layer */
	/* 16-bit wide because we multiply 8-bit input to 8-bit weight */
	/* for z's to be signed we need 17 bits!*/
	reg signed [16:0] z0, z1, z2, z3, z4, z5;
	reg signed [16:0] u0, u1;
	
	/* Storing activation function output */
	reg signed [8:0] v0, v1, v2, v3, v4, v5 ; 
	
	/* Storing activation function output */
	reg signed [8:0] delta_30, delta_31, delta_20, delta_21, delta_22, delta_23, delta_24, delta_25; 
	
	/* Storing activation function's derivative's output */
	reg signed [8:0] t0, t1, t2, t3, t4, t5 ; 
	
	
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
	
	activation_derivative ad0(ad0_x, ad0_y, mem_clk);
	activation_derivative ad1(ad1_x, ad1_y, mem_clk);
	activation_derivative ad2(ad2_x, ad2_y, mem_clk);
	activation_derivative ad3(ad3_x, ad3_y, mem_clk);
	activation_derivative ad4(ad4_x, ad4_y, mem_clk);
	activation_derivative ad5(ad5_x, ad5_y, mem_clk);
	
	always @ (negedge mem_clk)
	begin
		if(reset) begin
			state <= 4'd0;
		end
		else begin
			case(state)
				6'd0: begin
					// now set up read
					we <= 0 ;
					/* weights for first layer are at address=0 */
					addr <= 0 ; 
					
					state <= 6'd1 ;
				end
				6'd1: begin
					// ready one cycle later
					selected_data <= read_data ;
					
					state <= 6'd2 ;
				end
				6'd2: begin
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
					
					state <= 6'd3 ;
				end
				6'd3: begin
					// set up activation func.
					a0_x <= z0 ;
					a1_x <= z1 ;
					a2_x <= z2 ;
					a3_x <= z3 ;
					a4_x <= z4 ;
					a5_x <= z5 ;
					
					state <= 6'd4 ;
				end
				6'd4: begin
					v0 <= a0_y ;
					v1 <= a1_y ;
					v2 <= a2_y ;
					v3 <= a3_y ;
					v4 <= a4_y ;
					v5 <= a5_y ;
					
					state <= 6'd5 ;
				end
				6'd5: begin
					// now set up read for next layer's weights
					we <= 0 ;
					/* weights for second layer are at address=1 */
					addr <= 1 ; 
					
					state <= 6'd6 ;
				end
				6'd6: begin
					// ready one cycle later
					selected_data <= read_data ;
					state <= 6'd7 ;
				end
				6'd7: begin
					// calculating dot products
					u0 <= v0 * $signed(selected_data[1 * WWIDTH - 1: 0 * WWIDTH]) +
							v1 * $signed(selected_data[2 * WWIDTH - 1: 1 * WWIDTH]) +
							v2 * $signed(selected_data[3 * WWIDTH - 1: 2 * WWIDTH]) +
							v3 * $signed(selected_data[4 * WWIDTH - 1: 3 * WWIDTH]) +
							v4 * $signed(selected_data[5 * WWIDTH - 1: 4 * WWIDTH]) +
							v5 * $signed(selected_data[6 * WWIDTH - 1: 5 * WWIDTH]);

					u1 <= v0 * $signed(selected_data[7 * WWIDTH - 1: 6 * WWIDTH]) +
							v1 * $signed(selected_data[8 * WWIDTH - 1: 7 * WWIDTH]) +
							v2 * $signed(selected_data[9 * WWIDTH - 1: 8 * WWIDTH]) +
							v3 * $signed(selected_data[10 * WWIDTH - 1: 9 * WWIDTH]) +
							v4 * $signed(selected_data[11 * WWIDTH - 1: 10 * WWIDTH]) +
							v5 * $signed(selected_data[12 * WWIDTH - 1: 11 * WWIDTH]);
							
					state <= 6'd8 ;
				end
				6'd8: begin
					/* difference potentially can be 16 bits... */
					delta_30 = 2 * (u0 - desired_y0) ;
					delta_31 = 2 * (u1 - desired_y1) ;
					
					state <= 6'd9 ;
				end
				6'd9: begin
					// set up activation function's derivative
					ad0_x <= z0 ;
					ad1_x <= z1 ;
					ad2_x <= z2 ;
					ad3_x <= z3 ;
					ad4_x <= z4 ;
					ad5_x <= z5 ;
										
					state <= 6'd10 ;
				end
				6'd10: begin
					t0 <= ad0_y ;
					t1 <= ad1_y ;
					t2 <= ad2_y ;					
					t3 <= ad3_y ;
					t4 <= ad4_y ;
					t5 <= ad5_y ;
					
					state <= 6'd11 ;
				end
				6'd11: begin
					delta_20 = t0 * ( 
						$signed(selected_data[1 * WWIDTH - 1: 0 * WWIDTH]) * delta_30 +
						$signed(selected_data[2 * WWIDTH - 1: 1 * WWIDTH]) * delta_31
					);
					delta_21 = t1 * (
						$signed(selected_data[3 * WWIDTH - 1: 2 * WWIDTH]) * delta_30 +
						$signed(selected_data[4 * WWIDTH - 1: 3 * WWIDTH]) * delta_31
					);
					delta_22 = t2 * (
						$signed(selected_data[5 * WWIDTH - 1: 4 * WWIDTH]) * delta_30 +
						$signed(selected_data[6 * WWIDTH - 1: 5 * WWIDTH]) * delta_31 
					);
					delta_23 = t3 * (
						$signed(selected_data[7 * WWIDTH - 1: 6 * WWIDTH]) +
						$signed(selected_data[8 * WWIDTH - 1: 7 * WWIDTH])
					);
					delta_24 = t4 * (
						$signed(selected_data[9 * WWIDTH - 1: 8 * WWIDTH]) +
						$signed(selected_data[10 * WWIDTH - 1: 9 * WWIDTH])
					);
					delta_25 = t5 * (
						$signed(selected_data[11 * WWIDTH - 1: 10 * WWIDTH]) +
						$signed(selected_data[12 * WWIDTH - 1: 11 * WWIDTH])
					);
					
					state <= 6'd12 ;
				end
				6'd12: begin
					// reloading back weights for 1st layer
					we <= 0 ;
					
					addr <= 0 ; 
					
					state <= 6'd13 ;
				end
				6'd13: begin
					// ready one cycle later
					selected_data <= read_data ;
					state <= 6'd14 ;
				end
				6'd14: begin
					// setting up activation func. with I_1
					a0_x <= x0 ;
					a1_x <= x1 ;
					a2_x <= x2 ;
					a3_x <= x3 ;
					
					state <= 6'd15 ;
				end
				6'd15: begin
					// g_1[i,j] = A(I_1[i]) * delta_2[j]
               // w_1[i,j] = round(w_1[i,j] - learning_rate * g_1[i,j])
					//
					// potential overflow - 8-bit a0_y multiplied by 8-bit delta_20
					
					/* adjusting weights of 0th layer's 0th neuron's connections to all 6 neurons of 1st layer */
					/* weights in memory are aligned in the following way: 
						bits [0-7] -> weight of connection of 0th layer 0th neuron to 1st layer 0th neuron
						bits [32-39] -> " " " 0th layer 0th neuron to 1st layer 2nd neuron
						bits [64-71] -> " " " 0th layer 0th neuron to 1st layer 3rd neuron
						etc.
						
						See difference between using memory in state=2 and here: in state=2 adjacent weights are used,
						e.g. weights of 0th layer 0th neuron, 1st neuron, 2nd neuron etc. connections to 1st layer 0th neuron
					*/
					selected_data[1 * WWIDTH - 1: 0 * WWIDTH] <= 
						$signed(selected_data[1 * WWIDTH - 1: 0 * WWIDTH]) - ((a0_y >> 3) * delta_20) ; // shifting by 3 positions is dividing by 8, which stands for dividing by 10 or 0.1*x, where 0.1 is learning rate
					
					selected_data[5 * WWIDTH - 1: 4 * WWIDTH] <= 
						$signed(selected_data[5 * WWIDTH - 1: 4 * WWIDTH]) - ((a0_y >> 3) * delta_21) ;
					
					selected_data[9 * WWIDTH - 1: 8 * WWIDTH] <= 
						$signed(selected_data[9 * WWIDTH - 1: 8 * WWIDTH]) - ((a0_y >> 3) * delta_22) ;
					
					selected_data[13 * WWIDTH - 1: 12 * WWIDTH] <=
						$signed(selected_data[13 * WWIDTH - 1: 12 * WWIDTH]) - ((a0_y >> 3) * delta_23) ;
						
					selected_data[17 * WWIDTH - 1: 16 * WWIDTH] <=
						$signed(selected_data[17 * WWIDTH - 1: 16 * WWIDTH]) - ((a0_y >> 3) * delta_24) ;
						
					selected_data[21 * WWIDTH - 1: 20 * WWIDTH] <=
						$signed(selected_data[21 * WWIDTH - 1: 20 * WWIDTH]) - ((a0_y >> 3) * delta_25) ;
						
					/* 0th layer 1st neuron */	
					selected_data[2 * WWIDTH - 1: 1 * WWIDTH] <=
						$signed(selected_data[2 * WWIDTH - 1: 1 * WWIDTH]) - ((a1_y >> 3) * delta_20) ;
					
					selected_data[6 * WWIDTH - 1: 5 * WWIDTH] <= 
						$signed(selected_data[6 * WWIDTH - 1: 5 * WWIDTH]) - ((a1_y >> 3) * delta_21) ;
					
					selected_data[10 * WWIDTH - 1: 9 * WWIDTH] <= 
						$signed(selected_data[10 * WWIDTH - 1: 9 * WWIDTH]) - ((a1_y >> 3) * delta_22) ;
					
					selected_data[14 * WWIDTH - 1: 13 * WWIDTH] <=
						$signed(selected_data[14 * WWIDTH - 1: 13 * WWIDTH]) - ((a1_y >> 3) * delta_23) ;
						
					selected_data[18 * WWIDTH - 1: 17 * WWIDTH] <=
						$signed(selected_data[18 * WWIDTH - 1: 17 * WWIDTH]) - ((a1_y >> 3) * delta_24) ;
						
					selected_data[22 * WWIDTH - 1: 21 * WWIDTH] <=
						$signed(selected_data[22 * WWIDTH - 1: 21 * WWIDTH]) - ((a1_y >> 3) * delta_25) ;
						
					/* 0th layer 2nd neuron */
					selected_data[3 * WWIDTH - 1: 2 * WWIDTH] <=
						$signed(selected_data[3 * WWIDTH - 1: 2 * WWIDTH]) - ((a2_y >> 3) * delta_20) ;
					
					selected_data[7 * WWIDTH - 1: 6 * WWIDTH] <= 
						$signed(selected_data[7 * WWIDTH - 1: 6 * WWIDTH]) - ((a2_y >> 3) * delta_21) ;
					
					selected_data[11 * WWIDTH - 1: 10 * WWIDTH] <= 
						$signed(selected_data[11 * WWIDTH - 1: 10 * WWIDTH]) - ((a2_y >> 3) * delta_22) ;
					
					selected_data[15 * WWIDTH - 1: 14 * WWIDTH] <=
						$signed(selected_data[15 * WWIDTH - 1: 14 * WWIDTH]) - ((a2_y >> 3) * delta_23) ;
						
					selected_data[19 * WWIDTH - 1: 18 * WWIDTH] <=
						$signed(selected_data[19 * WWIDTH - 1: 18 * WWIDTH]) - ((a2_y >> 3) * delta_24) ;
						
					selected_data[23 * WWIDTH - 1: 22 * WWIDTH] <=
						$signed(selected_data[23 * WWIDTH - 1: 22 * WWIDTH]) - ((a2_y >> 3) * delta_25) ;
						
					/* 0th layer 3rd neuron */
					selected_data[4 * WWIDTH - 1: 3 * WWIDTH] <=
						$signed(selected_data[4 * WWIDTH - 1: 3 * WWIDTH]) - ((a3_y >> 3) * delta_20) ;
					
					selected_data[8 * WWIDTH - 1: 7 * WWIDTH] <= 
						$signed(selected_data[8 * WWIDTH - 1: 7 * WWIDTH]) - ((a3_y >> 3) * delta_21) ;
					
					selected_data[12 * WWIDTH - 1: 11 * WWIDTH] <= 
						$signed(selected_data[12 * WWIDTH - 1: 11 * WWIDTH]) - ((a3_y >> 3) * delta_22) ;
					
					selected_data[16 * WWIDTH - 1: 15 * WWIDTH] <=
						$signed(selected_data[16 * WWIDTH - 1: 15 * WWIDTH]) - ((a3_y >> 3) * delta_23) ;
						
					selected_data[20 * WWIDTH - 1: 19 * WWIDTH] <=
						$signed(selected_data[20 * WWIDTH - 1: 19 * WWIDTH]) - ((a3_y >> 3) * delta_24) ;
						
					selected_data[24 * WWIDTH - 1: 23 * WWIDTH] <=
						$signed(selected_data[24 * WWIDTH - 1: 23 * WWIDTH]) - ((a3_y >> 3) * delta_25) ;
					
					state <= 6'd16 ;
				end
				6'd16: begin
					write_data <= selected_data ;
					
					state <= 6'd17 ;
				end
				6'd17: begin
					we <= 1 ;
					
					state <= 6'd18 ;				
				end
				6'd18: begin
					// going to reading mode & setting address for 1st layer's weights
					we <= 0;
					
					addr <= 1 ; 
					
					state <= 6'd19 ;				
				end
				6'd19: begin
					// ready one cycle later
					selected_data <= read_data ;
					state <= 6'd20 ;
				end
				
				6'd20: begin					
					// setting up activation func. with I_2
					a0_x <= z0 ;
					a1_x <= z1 ;
					a2_x <= z2 ;
					a3_x <= z3 ;
					a4_x <= z4 ;
					a5_x <= z5 ;
					state <= 6'd21 ;
				end
				6'd21: begin
					/* 1st layer 0th neuron */
					selected_data[1 * WWIDTH - 1: 0 * WWIDTH] <=
						$signed(selected_data[1 * WWIDTH - 1: 0 * WWIDTH]) - ((a0_y >> 3) * delta_30) ;
					
					selected_data[7 * WWIDTH - 1: 6 * WWIDTH] <=
						$signed(selected_data[7 * WWIDTH - 1: 6 * WWIDTH]) - ((a0_y >> 3) * delta_31) ;
					
					/* 1st layer 1st neuron */
					selected_data[2 * WWIDTH - 1: 1 * WWIDTH] <=
						$signed(selected_data[2 * WWIDTH - 1: 1 * WWIDTH]) - ((a1_y >> 3) * delta_30) ;
					
					selected_data[8 * WWIDTH - 1: 7 * WWIDTH] <=
						$signed(selected_data[8 * WWIDTH - 1: 7 * WWIDTH]) - ((a1_y >> 3) * delta_31) ;
						
					/* 1st layer 2nd neuron */
					selected_data[3 * WWIDTH - 1: 2 * WWIDTH] <=
						$signed(selected_data[3 * WWIDTH - 1: 2 * WWIDTH]) - ((a2_y >> 3) * delta_30) ;
					
					selected_data[9 * WWIDTH - 1: 8 * WWIDTH] <=
						$signed(selected_data[9 * WWIDTH - 1: 8 * WWIDTH]) - ((a2_y >> 3) * delta_31) ;
						
					/* 1st layer 3rd neuron */
					selected_data[4 * WWIDTH - 1: 3 * WWIDTH] <=
						$signed(selected_data[4 * WWIDTH - 1: 3 * WWIDTH]) - ((a3_y >> 3) * delta_30) ;
					
					selected_data[10 * WWIDTH - 1: 9 * WWIDTH] <=
						$signed(selected_data[10 * WWIDTH - 1: 9 * WWIDTH]) - ((a3_y >> 3) * delta_31) ;		
			
					/* 1st layer 4th neuron */
					selected_data[5 * WWIDTH - 1: 4 * WWIDTH] <=
						$signed(selected_data[5 * WWIDTH - 1: 4 * WWIDTH]) - ((a4_y >> 3) * delta_30) ;
					
					selected_data[11 * WWIDTH - 1: 10 * WWIDTH] <=
						$signed(selected_data[11 * WWIDTH - 1: 10 * WWIDTH]) - ((a4_y >> 3) * delta_31) ;
											
					/* 1st layer 5th neuron */
					selected_data[6 * WWIDTH - 1: 5 * WWIDTH] <=
						$signed(selected_data[6 * WWIDTH - 1: 5 * WWIDTH]) - ((a5_y >> 3) * delta_30) ;
					
					selected_data[12 * WWIDTH - 1: 11 * WWIDTH] <=
						$signed(selected_data[12 * WWIDTH - 1: 11 * WWIDTH]) - ((a5_y >> 3) * delta_31) ;
					
					state <= 6'd22 ;
				end
				6'd22: begin
					write_data <= selected_data ;
					
					state <= 6'd23 ;
				end
				6'd23: begin
					we <= 1 ;
					
					state <= 6'd0 ;				
				end
			endcase
		end
	end 
	assign y0 = ~selected_data[0] ;
	assign y1 = selected_data[1] ;
endmodule

/* Activation function module */
/* 
	Here we approximate following function:
	# Linear saturating activation function parameters
	f_min = -1.
	f_max = 1.
	slope = 1./2
	f_r = f_max - f_min

	def A(value):

		if value <= -f_r / (2 * slope):
			return f_min
		elif value >= f_r / (2 * slope):
			return f_max
		else:
			return slope * value + (f_min + f_max) / 2 
*/

module activation_derivative( x , y, clk);
	input wire signed [16:0] x;
	output reg signed [8:0] y;
	input clk;
	
	always @ (posedge clk)
	begin
		if(x <= $signed(-16'd2)) begin
			y = 8'd0 ;
		end else if (x >= $signed(16'd2)) begin
			y = 8'd0 ;
		/* this case should return slope (1/2) */
		/* but in all-integer design - ? */
		/* for now we just return 1 */
		end else begin 
			y = 8'd1 ;
		end
		
	end
endmodule 