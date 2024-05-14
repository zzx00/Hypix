//两种配置方案，外部配置与spi接口配置，其中spi能配置每个像素点的信息，外部配置时每一行的配置内容相同
//外部配置为备选方案，spi能够正常工作的时候不要使用外部配置
module mux2_1_opera(
	clk_40MHz,
	shutter_output,
	shutter_output_spi,
	mode_output,
	mode_output_spi,
	push_clk_spi,
	push_clk_in,
	config_info_spi_0,
	config_info_in,
	
	push_clk,
	shutter,
	mode,
	config_info_0
);

	input clk_40MHz;
	input shutter_output;
	input [1:0] shutter_output_spi;
	input mode_output;
	input [1:0] mode_output_spi;
	input [1:0] push_clk_spi;
	input push_clk_in;
	
	//可以看到无论是spi的配置信息config_info_spi_0~3还是外部配置信息config_info_0~3都是192bit
	//计算方法32双列×6bit配置信息位(4bit DAC(外部配置时置0)、Dpusle、Mask)
	input [23:0] config_info_spi_0;
	input [1:0] config_info_in;//外部配置信息仅配置Dpulse和Mask，因为配置时每行的配置内容相同，所以局部DAC的配置信息没意义


	output [1:0] push_clk;
	output [1:0] shutter;
	output [1:0] mode;
	
	output [23:0] config_info_0;
	assign shutter = shutter_output_spi | {2{shutter_output}};
	assign mode = mode_output_spi | {2{mode_output}};
	assign push_clk = push_clk_spi | {2{push_clk_in}};
	//assign shake_hands_col = shake_hands_col_spi | shake_hands_col_in;
	assign config_info_0 = config_info_spi_0 | {4{4'd0, config_info_in}};
	
	
endmodule
