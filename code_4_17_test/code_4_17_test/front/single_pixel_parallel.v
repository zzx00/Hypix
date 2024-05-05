module single_pixel_parallel(  
	clk_gating_single_pixel_40MHz,
    clk_gating_single_pixel_640MHz,
	hit_pixel,
	out_flag,
	shutter,
	TimeStamp,
	hit_pixel_edge,
	hit_or,

	hit_over,
	ToT_data,
	timestamp_hit,
    FTOA
);

	input clk_gating_single_pixel_40MHz;
    input clk_gating_single_pixel_640MHz;
	input hit_pixel;
	input out_flag;
	input shutter;
	input [8:0] TimeStamp;
	input hit_pixel_edge;
	input hit_or;
	
	output hit_over;
	output [7:0] ToT_data;
	output [8:0] timestamp_hit;
    output [4:0] FTOA;//5位FTOA
	
	reg hit_over;
	reg flag_clear;
	reg [7:0] ToT_data;
	reg [8:0] timestamp_hit;
    reg [4:0] FTOA;
	reg [4:0] FTOA_photon;
	reg [4:0] FTOA_particle;


	always @(hit_pixel or flag_clear or shutter)
		begin
			if(flag_clear)
				begin
					hit_over = 1'b0;
				end
			else if(!hit_pixel & !shutter)
				begin
					hit_over = 1'b1;
				end
			else
				begin

					hit_over = 1'b0;
				end
		end
	
    always @(posedge clk_gating_single_pixel_640MHz or posedge out_flag) 
        begin
			if(out_flag)
                begin
                    FTOA_particle <= 5'd0;
                end
			else
			if(hit_or) begin
				FTOA_particle<={FTOA_particle[3:0],~(FTOA_particle[4]^FTOA_particle[2])};//5位LFSR抽3、5位
			end
                
        end

	always @(posedge clk_gating_single_pixel_40MHz or posedge out_flag)
		begin
			if(out_flag)
				begin
					ToT_data <= 8'd0;
					timestamp_hit <= 9'd0;
					flag_clear <= 1'b1;
					FTOA_photon <= 5'd0;
				end
			else if(shutter)
				begin
					flag_clear <= 1'b0;
					timestamp_hit[8] <= 1'b0;
					FTOA_photon[4]<=1'b0;//FTOA最高位没有使用
					{timestamp_hit[1:0],FTOA_photon[3:0], ToT_data} <= {timestamp_hit[0],FTOA_photon[3:0], ToT_data, ~(timestamp_hit[1] ^ ToT_data[4] ^ ToT_data[2] ^ ToT_data[0])};
					if(hit_pixel_edge)
						begin
							{timestamp_hit[7:2]} <= {timestamp_hit[6:2], ~(timestamp_hit[7] ^ timestamp_hit[6])};
						end
					else
						begin
							{timestamp_hit[7:2]} <= {timestamp_hit[7:2]};
						end
				end
			else
				begin
					flag_clear <= 1'b0;
					ToT_data <= {ToT_data[6:0], ~(ToT_data[7] ^ ToT_data[5] ^ ToT_data[4] ^ ToT_data[3])};
					if(hit_pixel_edge ) begin
						timestamp_hit <= TimeStamp;
					end
					
				end
		end
    

	always @( out_flag or shutter or FTOA_particle or FTOA_photon)
	    begin
			if(out_flag)
			    FTOA = 5'd0;
		    else if(shutter)
			    FTOA = FTOA_photon;
			else
			    FTOA = FTOA_particle;
	    end


endmodule
