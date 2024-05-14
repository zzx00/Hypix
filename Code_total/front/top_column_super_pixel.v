//8*8阵列，需要4个双列，每个双列两个超级像素
module top_column_super_pixel(
	clk_40MHz, 
	clk_640MHz,
	rst_n,
	rst_n_pixel,
	Dpulse,
	Apulse_en,
	hit,
	push_clk,
	TimeStamp,
	shutter,
	mode,
	//push_data,
	//mask_pulse_DAC_config,
	config_info,
	shake_hands_col,
	config_DAC,
	col_data
);


	input clk_40MHz;
	input clk_640MHz;
	input rst_n;
	input rst_n_pixel;
	input Dpulse;
	input Apulse_en;
	input [15:0] hit;//一个双列两个超级像素，只需要16个
	//input push_data;
	input push_clk;
	input [8:0] TimeStamp;
	input shutter;
	input mode;
	//input [2:0] mask_pulse_DAC_config;
	input [5:0] config_info;
	input shake_hands_col;
	output [63:0] config_DAC;
	output [25:0] col_data;
	
	//wire [14:0] push_data_temp;
 	wire  shake_hands;
	
	wire [25:0] arbiter_1;
	
	wire [5:0] config_info_temp_1;

	//最下面的超级像素
	top_single_super_pixel u_top_0(
		.clk_40MHz(clk_40MHz),
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.Dpulse(Dpulse),
		.Apulse_en(Apulse_en),
		.shutter(shutter),
		.mode(mode),
		.TimeStamp(TimeStamp),
		.hit(hit[7:0]),
		.push_clk(push_clk),
		//.mask_pulse_DAC_config(mask_pulse_DAC_config),
		//.push_data_in(push_data),
		.config_info(config_info),
		.addr_col(1'b0),
		.last_data(arbiter_1),
		.shake_hands_next(shake_hands_col),
		
		//.push_data_out(push_data_temp[0]),
		.shake_hands_last(shake_hands),
		.arbiter_data(col_data),
		.config_DAC_0(config_DAC[3:0]),
		.config_DAC_1(config_DAC[7:4]),
		.config_DAC_2(config_DAC[11:8]),
		.config_DAC_3(config_DAC[15:12]),
		.config_DAC_4(config_DAC[19:16]),
		.config_DAC_5(config_DAC[23:20]),
		.config_DAC_6(config_DAC[27:24]),
		.config_DAC_7(config_DAC[31:28]),
		.next_config_info(config_info_temp_1)
	);
	
	//最上面那个超级像素
	top_single_super_pixel u_top_1(
		.clk_40MHz(clk_40MHz),
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.Dpulse(Dpulse),
		.Apulse_en(Apulse_en),
		.shutter(shutter),
		.mode(mode),
		.TimeStamp(TimeStamp),
		.hit(hit[15:8]),
		.push_clk(push_clk),
		//.push_data_in(push_data_temp[0]),
		//.mask_pulse_DAC_config(mask_pulse_DAC_config),
		.config_info(config_info_temp_1),
		.addr_col(1'b1),
		.last_data(26'd0),
		//表示在这一列里在这个超级像素下面的像素
		.shake_hands_next(shake_hands),
		
		//.push_data_out(push_data_temp[1]),
		.shake_hands_last(),
		.arbiter_data(arbiter_1),
		.config_DAC_0(config_DAC[35:32]),
		.config_DAC_1(config_DAC[39:36]),
		.config_DAC_2(config_DAC[43:40]),
		.config_DAC_3(config_DAC[47:44]),
		.config_DAC_4(config_DAC[51:48]),
		.config_DAC_5(config_DAC[55:52]),
		.config_DAC_6(config_DAC[59:56]),
		.config_DAC_7(config_DAC[63:60]),
		.next_config_info()
	);
endmodule