//直接使用这个模块进行循环仲裁，将data_route_proc改为二选一选择器并修改状态机，进行循环仲裁
//此时column_pixel_peri有两个双列，这里只需要例化两个column即可
//从data_route_proc出来的路由数据就是80MHz传出去的最终数据
//需要将这两部分合二为一

//这部分持续/循环仲裁模块，依据论文状态转换图很好理解，也比较简单，不作详述
module data_route_merge_proc(
		clk_40MHz, 
		clk_640MHz,
		//rst_n_pixel,
		rst_n,
		Dpulse,
		Apulse_en,
		shutter,
		mode,
		rst_n_pixel,
		hit_0_left,
		hit_0_right,
		hit_1_left,
		hit_1_right,
		
		push_flag,
		
		addr_config_0,
		addr_config_1,//为每列像素固定地址
		
		shakehands_proc,//数据传输开关
		config_info_0,
		
		config_DAC_0,
		config_DAC_1,
		config_DAC_2,
		config_DAC_3,
		route_data_proc
	);

	input clk_40MHz;
	input clk_640MHz;
	//只需要两个
	//input rst_n_pixel;
	input [1:0] rst_n;
	input [1:0] Dpulse;
	input [1:0] Apulse_en;
	//两个
	input [1:0] shutter;
	input [1:0] mode;
	input [1:0] rst_n_pixel;
	//input [1:0] smode;
	//两个两个双列
	input [15:0] hit_0_left;
	input [15:0] hit_0_right;
	input [15:0] hit_1_left;
	input [15:0] hit_1_right;


	input  [1:0] push_flag;
	input  addr_config_0;
	input  addr_config_1;
	input shakehands_proc;
	//一个双列6bit，4个双列24bit
	input [23:0] config_info_0;
	
	//只需要4个
	output [63:0] config_DAC_0;
	output [63:0] config_DAC_1;
	output [63:0] config_DAC_2;
	output [63:0] config_DAC_3;
	output [27:0] route_data_proc;

	wire [27:0] route_data_0;//双列过来的数据
	wire [27:0] route_data_1;

	wire [1:0] empty_merge;//空满信息，用于状态机状态转换
	wire [1:0] shake_hands_merge;//状态机控制信号，比如shake_hands_merge = 4'b0001表示现在选取u_data_merge_0传输过来的数据，其他部分停止传输
	//要加shakehands，因为我们这里没有data_merge，只调用了两个双列的，所以声明一个正常的两个双列，声明一个列尾的两个双列
	data_route_proc u_data_route_proc(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n_pixel[0]),//有一个rst都不会仲裁
		.route_data_0(route_data_0),
		.route_data_1(route_data_1),

		.empty_merge(empty_merge),
		.shakehands_proc(shakehands_proc),
	
		.route_data_proc(route_data_proc),
		.shake_hands_merge(shake_hands_merge)
	);


	column_pixel_peri column_pixel_peri_u0(
		.clk_40MHz(clk_40MHz), 
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n[0]),
		.rst_n_pixel(rst_n_pixel[0]),
		.Dpulse(Dpulse[0]),
		.Apulse_en(Apulse_en[0]),
		.shutter(shutter[0]),
		.mode(mode[0]),
		//.smode(smode[0]),
		.hit_left(hit_0_left),
		.hit_right(hit_0_right),
		.push_flag(push_flag[0]),
		//.push_data(push_data[0]),
		.addr_config(addr_config_0),
		.shakehands_next(shake_hands_merge[0]),
		//每个双列6位
		.config_info_left(config_info_0[5:0]),
		.config_info_right(config_info_0[11:6]),
		.empty(empty_merge[0]),//列尾fifo空满信息
		.fifo_data(route_data_0),
		.config_DAC_left(config_DAC_0),
		.config_DAC_right(config_DAC_1)
		//.shake_hands_col(shake_hands_col[0])
	);

//最后列尾元素只是在列尾加了oct模块，其他无差别，要是我们不需要oct模块，感觉不用加，也不需要shake_hands_col_left/right
	column_pixel_peri column_pixel_peri_u1(
		.clk_40MHz(clk_40MHz), 
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n[1]),
		.rst_n_pixel(rst_n_pixel[1]),
		.Dpulse(Dpulse[1]),
		.Apulse_en(Apulse_en[0]),
		.shutter(shutter[1]),
		.mode(mode[1]),
		.hit_left(hit_1_left),
		.hit_right(hit_1_right),
		.push_flag(push_flag[1]),
		.addr_config(addr_config_1),
		.shakehands_next(shake_hands_merge[1]),
		//每个双列6位
		.config_info_left(config_info_0[17:12]),
		.config_info_right(config_info_0[23:18]),
		.empty(empty_merge[1]),
		.fifo_data(route_data_1),
		.config_DAC_left(config_DAC_2),
		.config_DAC_right(config_DAC_3)
	);

	
endmodule