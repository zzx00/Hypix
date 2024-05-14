//各信号含义其他模块都有，这里不作注释
//这个模块设置的目的主要是信号从由PCB传输过来以及经由PCB传输至FPGA等其他器件时存在一段延时
//对外部输入的信号以及将输出至外部的信号缓存一拍，更新时序信息，满足传输时间
module in_out_clear(
	clk_40MHz,
	rst_n,
	//input由片外输入
	spi_sdi_input,
	spi_cs_input,
	shutter_input,
	mode_input,
	push_clk_in_input,
	config_info_in_input,
	shake_hands_col_in_input,
	
	spi_sdi_output,
	spi_cs_output,
	shutter_output,
	mode_output,
	push_clk_in_output,
	config_info_in_output,
	shake_hands_col_in_output

);

	input clk_40MHz;
	input rst_n;
	input spi_sdi_input;
	input spi_cs_input;
	input shutter_input;
	input mode_input;
	input push_clk_in_input;
	input [1:0] config_info_in_input;
	input shake_hands_col_in_input;
	
	output spi_sdi_output;
	output spi_cs_output;
	output shutter_output;
	output mode_output;
	output push_clk_in_output;
	output [1:0] config_info_in_output;
	output shake_hands_col_in_output;
	
	reg spi_sdi_output;
	reg spi_cs_output;
	reg shutter_output;
	reg mode_output;
	reg push_clk_in_output;
	reg [1:0] config_info_in_output;
	reg shake_hands_col_in_output;

	
	
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					spi_sdi_output <= 1'b0;
					spi_cs_output <= 1'b0;
					push_clk_in_output <= 1'b0;
					config_info_in_output <= 1'b0;
					shake_hands_col_in_output <= 1'b0;
					shutter_output <= 1'b0;
					mode_output <= 1'b0;
				end
			else
				begin
					spi_sdi_output <= spi_sdi_input;
					spi_cs_output <= spi_cs_input;
					push_clk_in_output <= push_clk_in_input;
					config_info_in_output <= config_info_in_input;
					shake_hands_col_in_output<=shake_hands_col_in_input;
					shutter_output <= shutter_input;
					mode_output <= mode_input;
				end
		end
	


	// always @(posedge clk_40MHz or negedge rst_n)
	// 	begin
	// 		if(!rst_n)
	// 			begin
	// 				route_data_proc_out <= 27'd0;
	// 			end
	// 		else
	// 			begin
	// 				route_data_proc_out <= route_data_proc_in;
	// 			end
	// 	end
		
endmodule