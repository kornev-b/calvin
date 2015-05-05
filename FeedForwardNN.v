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
   input wire x0,
	input wire x1,
	input wire x2,
	input wire x3,
   output wire y0,
	output wire y1,
   input RST,
	input CLK
	);
    
	reg [3:0] addr;
	reg [255:0] write_data;
	reg [255:0] selected_data;
	reg we;
	wire [255:0] read_data;
	reg [3:0] state;
	wire reset;
	reg [3:0] counter;
	
	wire mem_clk;
	//mem_PLL u1(CLK, mem_clk);
	assign mem_clk = CLK;
	assign reset = RST;
	
	ram_pos_thru memory(read_data, addr, write_data, we, mem_clk);
	
	always @ (negedge mem_clk)
	begin
		if(reset) begin
			state <= 4'd0;
			counter <= 8'b0;
		end
		else begin
			case(state)
				4'd0: begin
					counter <= counter + 1 ;
					state <= 4'd1 ;
				end
				4'd1: begin
					// now set up read
					we <= 0 ;
					addr <= counter ; 
					state <= 4'd2 ;
				end
				4'd2:	begin
					// ready one cycle later
					selected_data <= read_data ;
					state <= 4'd0 ;
				end
				/*4'd2: begin
					
				end*/
			endcase
		end
	end 
	assign y0 = ~selected_data[0] ;
	assign y1 = selected_data[1] ;
endmodule

module ram_pos_thru (q, a, d, we, clk);
	output [255:0] q;
	reg [255:0] q;
	input [255:0] d;
	input [3:0] a;
	input we, clk;
	reg [255:0] mem [3:0] /* synthesis ram_init_file = "ram.mif" */ ;

	always @ (posedge clk)
	begin
		if(we) mem[a] <= d ;
		q <= mem[a] ;
	end
endmodule