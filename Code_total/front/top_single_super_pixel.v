//一个超级像素由八个单像素single_pixel_parallel u0~u8，和一个超级像素管理模块u_super_pixel_parallel组成
module top_single_super_pixel(
		clk_40MHz,
		clk_640MHz,
		rst_n,
		rst_n_pixel,
		Dpulse,
		Apulse_en,
		shutter,
		mode,
		TimeStamp,
		hit,
		push_clk,
		//push_data_in,
		//mask_pulse_DAC_config,
		config_info,
		addr_col,
		last_data,
		shake_hands_next,
		
		//push_data_out,
		next_config_info,
		shake_hands_last,
		config_DAC_0,
		config_DAC_1,
		config_DAC_2,
		config_DAC_3,
		config_DAC_4,
		config_DAC_5,
		config_DAC_6,
		config_DAC_7,
		Apulse_en_super_pixel,
		arbiter_data
	);

	input clk_40MHz;
	input clk_640MHz;
	input rst_n;
	input rst_n_pixel;
	input Dpulse;
	input Apulse_en;
	input shutter;
	input mode;
	input [8:0] TimeStamp;
	input [7:0] hit;
	input push_clk;
	//input push_data_in;
	input [5:0] config_info;//输入的配置信息
	//input [2:0] mask_pulse_DAC_config;
	input  addr_col;
	input [25:0] last_data;//26位
    input shake_hands_next;
	
	//output push_data_out;
	output [5:0] next_config_info;
	output shake_hands_last;
	output [3:0] config_DAC_0;
	output [3:0] config_DAC_1;
	output [3:0] config_DAC_2;
	output [3:0] config_DAC_3;
	output [3:0] config_DAC_4;
	output [3:0] config_DAC_5;
	output [3:0] config_DAC_6;
	output [3:0] config_DAC_7;
	output [7:0] Apulse_en_super_pixel;
    output [25:0] arbiter_data; 
	
	wire [7:0] hit_pixel;
	wire [7:0] hit_over;
	wire [7:0] ToT_data_0;
	wire [7:0] ToT_data_1;
	wire [7:0] ToT_data_2;
	wire [7:0] ToT_data_3;
	wire [7:0] ToT_data_4;
	wire [7:0] ToT_data_5;
	wire [7:0] ToT_data_6;
	wire [7:0] ToT_data_7;
	wire [8:0] timestamp_hit_0;
	wire [8:0] timestamp_hit_1;
	wire [8:0] timestamp_hit_2;
	wire [8:0] timestamp_hit_3;
	wire [8:0] timestamp_hit_4;
	wire [8:0] timestamp_hit_5;
	wire [8:0] timestamp_hit_6;
	wire [8:0] timestamp_hit_7;
	//FTOA
	wire [4:0] FTOA_0;
	wire [4:0] FTOA_1;
	wire [4:0] FTOA_2;
	wire [4:0] FTOA_3;
	wire [4:0] FTOA_4;
	wire [4:0] FTOA_5;
	wire [4:0] FTOA_6;
	wire [4:0] FTOA_7;

	wire  addr_col;//一个双列两个超级像素，只需要1位
	wire [7:0] clk_gating_single_pixel_40MHz;
	//wire [7:0] clk_gating_single_pixel_640MHz;
	wire [7:0] out_flag;
	wire [7:0] hit_pixel_edge;
	wire shutter_temp;
	wire hit_or_super_pixel;//将来连vco
	wire [7:0] hit_or;
	wire [7:0] Apulse_en_super_pixel;
	assign Apulse_en_super_pixel={8{Apulse_en}};



//超级像素管理模块
	super_pixel_parallel u_super_pixel_parallel(  
		.clk_40MHz(clk_40MHz),
		//.clk_640MHz(clk_640MHz),
		.push_clk(push_clk),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.Dpulse(Dpulse),
		.hit(hit),
		.hit_over(hit_over),
		.shutter(shutter),
		.mode(mode),
		.config_info(config_info),
		//.TimeStamp(TimeStamp),
		.ToT_data_0(ToT_data_0),
		.ToT_data_1(ToT_data_1),
		.ToT_data_2(ToT_data_2),
		.ToT_data_3(ToT_data_3),
		.ToT_data_4(ToT_data_4),
		.ToT_data_5(ToT_data_5),
		.ToT_data_6(ToT_data_6),
		.ToT_data_7(ToT_data_7),
		.timestamp_hit_0(timestamp_hit_0),
		.timestamp_hit_1(timestamp_hit_1),
		.timestamp_hit_2(timestamp_hit_2),
		.timestamp_hit_3(timestamp_hit_3),
		.timestamp_hit_4(timestamp_hit_4),
		.timestamp_hit_5(timestamp_hit_5),
		.timestamp_hit_6(timestamp_hit_6),
		.timestamp_hit_7(timestamp_hit_7),
		.FTOA_0(FTOA_0),
		.FTOA_1(FTOA_1),
		.FTOA_2(FTOA_2),
		.FTOA_3(FTOA_3),
		.FTOA_4(FTOA_4),
		.FTOA_5(FTOA_5),
		.FTOA_6(FTOA_6),
		.FTOA_7(FTOA_7),
		.addr_col(addr_col),
		.last_data(last_data),
		.shake_hands_next(shake_hands_next),
		
		.hit_pixel(hit_pixel),
		.hit_or_super_pixel(hit_or_super_pixel),
		.next_config_info(next_config_info),
		.arbiter_data(arbiter_data),
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz),
		//.clk_gating_single_pixel_640MHz(clk_gating_single_pixel_640MHz),
		.out_flag(out_flag),
		.hit_pixel_edge(hit_pixel_edge),
		.shutter_temp(shutter_temp),
		.config_DAC_0(config_DAC_0),
		.config_DAC_1(config_DAC_1),
		.config_DAC_2(config_DAC_2),
		.config_DAC_3(config_DAC_3),
		.config_DAC_4(config_DAC_4),
		.config_DAC_5(config_DAC_5),
		.config_DAC_6(config_DAC_6),
		.config_DAC_7(config_DAC_7),
		.hit_or(hit_or),
		.shake_hands_last(shake_hands_last)
	);

//每个超级像素中8个单像素
	
	single_pixel_parallel u0(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[0]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[0]),
		.out_flag(out_flag[0]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[0]),
		.hit_or(hit_or[0]),
		
		.hit_over(hit_over[0]),
		.timestamp_hit(timestamp_hit_0),
		.ToT_data(ToT_data_0),
		.FTOA(FTOA_0)
	);
	
	single_pixel_parallel u1(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[1]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[1]),
		.out_flag(out_flag[1]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[1]),
		.hit_or(hit_or[1]),
		
		.hit_over(hit_over[1]),
		.timestamp_hit(timestamp_hit_1),
		.ToT_data(ToT_data_1),
		.FTOA(FTOA_1)
	);
	
	single_pixel_parallel u2(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[2]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[2]),
		.out_flag(out_flag[2]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[2]),
		.hit_or(hit_or[2]),
		
		.hit_over(hit_over[2]),
		.timestamp_hit(timestamp_hit_2),
		.ToT_data(ToT_data_2),
		.FTOA(FTOA_2)
	);
	
	single_pixel_parallel u3(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[3]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[3]),
		.out_flag(out_flag[3]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[3]),
		.hit_or(hit_or[3]),
		
		.hit_over(hit_over[3]),
		.timestamp_hit(timestamp_hit_3),
		.ToT_data(ToT_data_3),
		.FTOA(FTOA_3)
	);
	
	single_pixel_parallel u4(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[4]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[4]),
		.out_flag(out_flag[4]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[4]),
		.hit_or(hit_or[4]),
		
		.hit_over(hit_over[4]),
		.timestamp_hit(timestamp_hit_4),
		.ToT_data(ToT_data_4),
		.FTOA(FTOA_4)
	);
	
	single_pixel_parallel u5(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[5]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[5]),
		.out_flag(out_flag[5]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[5]),
		.hit_or(hit_or[5]),
		
		.hit_over(hit_over[5]),
		.timestamp_hit(timestamp_hit_5),
		.ToT_data(ToT_data_5),
		.FTOA(FTOA_5)
	);
	
	single_pixel_parallel u6(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[6]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[6]),
		.out_flag(out_flag[6]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[6]),
		.hit_or(hit_or[6]),
		
		.hit_over(hit_over[6]),
		.timestamp_hit(timestamp_hit_6),
		.ToT_data(ToT_data_6),
		.FTOA(FTOA_6)
	);
	
	single_pixel_parallel u7(  
		.clk_gating_single_pixel_40MHz(clk_gating_single_pixel_40MHz[7]),
		.clk_gating_single_pixel_640MHz(clk_640MHz),
		.hit_pixel(hit_pixel[7]),
		.out_flag(out_flag[7]),
		.shutter(shutter_temp),
		.TimeStamp(TimeStamp),
		.hit_pixel_edge(hit_pixel_edge[7]),
		.hit_or(hit_or[7]),
		
		.hit_over(hit_over[7]),
		.timestamp_hit(timestamp_hit_7),
		.ToT_data(ToT_data_7),
		.FTOA(FTOA_7)
	);


endmodule