//一个column_pixel_peri连接两个双列做拥塞缓解处理
//这部分把640MHz删了，包括top_single和top_column里的也删了，640MHz的只进入超级像素管理单元应用
module column_pixel_peri(
		clk_40MHz, 
		clk_640MHz,
		rst_n,
		rst_n_pixel,
		Dpulse,
		Apulse_en,
		shutter,
		mode,
		hit_left,//column_pixel_peri连接左侧双列的击中信号(与模拟前端电路连接)
		hit_right,//column_pixel_peri连接右侧双列的击中信号(与模拟前端电路连接)
		push_flag,
		addr_config,//配置地址(定值)
		shakehands_next,//shakehands_next为高时说明选择这部分电路数据传输，对应FIFO可以向外发送数据
		//mask_pulse_DAC_config,
		config_info_left,//column_pixel_peri连接左侧双列的配置信息
		config_info_right,

		empty,//column_pixel_peri中的拥塞缓解模块对应FIFO空信号
		fifo_data,//继续向外围电路持续/循环仲裁模块传输的fifo数据
		config_DAC_left,//左侧双列传给模拟前端电路dac的输入信号
		config_DAC_right
	);

	input clk_40MHz;
	input clk_640MHz;
	input rst_n;
	input rst_n_pixel;
	input Dpulse;
	input Apulse_en;
	input shutter;
	input mode;
	//input smode;
	//不需要，忘删了
	input [15:0] hit_left;
	input [15:0] hit_right;
	//input push_data;
	input push_flag;
	input addr_config;
	//应该是一位吧，在dealing with congestion中判断了是左边双列还是右边双列，只需要判断双列中哪个就行，一个双列两个超级像素，只需要一位

	input shakehands_next;
	//input [2:0] mask_pulse_DAC_config;
	input [5:0] config_info_left;
	input [5:0] config_info_right;
	
	output empty;
	output [27:0] fifo_data;//加了一位判断左右
	output [63:0] config_DAC_left;
	output [63:0] config_DAC_right;
	
	//output shake_hands_col;
	
	wire [8:0] TimeStamp_left;
	wire [8:0] TimeStamp_right;
	wire push_clk_left;
	wire push_clk_right;
	wire shake_hands_col_left;//该信号由拥塞缓解模块发出，说明当前拥塞缓解模块选择的左右哪个双列的数据存储
	wire shake_hands_col_right;//正常工作时shake_hands_col_left和shake_hands_col_right不可同时为1
	wire [25:0] data_eoc_left;//左侧双列最后一个超级像素输出的数据
	wire [25:0] data_eoc_right;

	//shutter和mode连接至双列每一个像素点，连接前打一拍更新时序信息
	reg shutter_temp;
	reg mode_temp;
	//wire rst_n_out;


	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					shutter_temp <= 1'b0;
					mode_temp <= 1'b0;
				end
			else
				begin
					shutter_temp <= shutter;
					mode_temp <= mode;
				end
		end

	peri_node u_peri_node(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.data_eoc_left(data_eoc_left),
		.data_eoc_right(data_eoc_right),
		.push_flag(push_flag),
		.addr_config(addr_config),
		.shakehands_next(shakehands_next),
		
		.TimeStamp_left(TimeStamp_left),
		.TimeStamp_right(TimeStamp_right),
		.push_clk_left(push_clk_left),
		.push_clk_right(push_clk_right),
		.shake_hands_col_left(shake_hands_col_left),
		.shake_hands_col_right(shake_hands_col_right),
		.fifo_data(fifo_data),
		//.rst_n_out(rst_n_out),
		.empty(empty)
	);

	top_column_super_pixel u_top_column_super_pixel_left(
		.clk_40MHz(clk_40MHz), 
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.Dpulse(Dpulse),
		.Apulse_en(Apulse_en),
		.shutter(shutter_temp),
		.mode(mode_temp),
		.hit(hit_left),
		.TimeStamp(TimeStamp_left),
		.push_clk(push_clk_left),
		.shake_hands_col(shake_hands_col_left),
		.config_info(config_info_left),

		.config_DAC(config_DAC_left),
		.col_data(data_eoc_left)
	);
	
	top_column_super_pixel u_top_column_super_pixel_right(
		.clk_40MHz(clk_40MHz), 
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n),
		.rst_n_pixel(rst_n_pixel),
		.Dpulse(Dpulse),
		.Apulse_en(Apulse_en),
		.shutter(shutter_temp),
		.mode(mode_temp),
		.hit(hit_right),
		.TimeStamp(TimeStamp_right),
		.push_clk(push_clk_right),
		.shake_hands_col(shake_hands_col_right),
		.config_info(config_info_right),
		
		.config_DAC(config_DAC_right),
		.col_data(data_eoc_right)
	);
	
endmodule