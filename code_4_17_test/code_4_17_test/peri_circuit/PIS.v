module PIS (
    clk_40MHz,
    rst_n,
    shake_hands_col_in_output,
    shake_hands_col_spi,
    route_data_proc_in,

    shake_hands_col,
    valid_out,
    route_data_proc_out_single
    
    

);
    input rst_n;
    input clk_40MHz;
    input [27:0] route_data_proc_in;
    input shake_hands_col_in_output;
    input shake_hands_col_spi;
    output shake_hands_col;
    reg shake_hands_col;
    
    output valid_out;
	output route_data_proc_out_single;
	reg [4:0] counter;//计数
	reg valid;
    reg [27:0] route_data_proc_out;
	
always@(posedge clk_40MHz or negedge rst_n)  //or negedge rst
	begin 
		if(!rst_n)               //引脚复位不用，通过其他方式复位
			begin
				counter<=5'd27;
				route_data_proc_out<=0;
				valid<=0;
                shake_hands_col<=shake_hands_col_spi|shake_hands_col_in_output;
			end
		else begin
			if(counter==27) begin
				if(route_data_proc_in==0) begin
					route_data_proc_out<=28'd0;
					counter<=5'd27;
					valid<=0;
					
                    shake_hands_col<=shake_hands_col_spi|shake_hands_col_in_output;
				end else if(route_data_proc_in!=0) begin
					route_data_proc_out<=route_data_proc_in;
					counter<=5'd0;
					valid<=1;
					
                    shake_hands_col<=1'b0;
				end
			end else begin
				counter<=counter+1;
				valid<=0;
				route_data_proc_out<={route_data_proc_out[26:0],route_data_proc_out[27]};
				
                shake_hands_col<=1'b0;
			end
		end
 
	end
	assign route_data_proc_out_single=route_data_proc_out[27];
	assign valid_out=valid;
endmodule
