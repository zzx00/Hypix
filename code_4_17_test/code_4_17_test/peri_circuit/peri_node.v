//拥塞缓解控制节点，包括列尾数据处理模块、FIFO和拥塞缓解处理模块
//拥塞缓解模块设置方式目前是间隔3列的两双列共享存储器，目前由data_route_merge_proc模块合理分配击中信号实现，也可将像素阵列打包成IP与外围电路连线
module peri_node(
		clk_40MHz,
		rst_n,
		rst_n_pixel,
		data_eoc_left,//左侧像素阵列双列输出数据
		data_eoc_right,//间隔三列后的右侧像素阵列双列输出数据
		push_flag,//配置时钟
		addr_config,//阵列双列所在地址
		shakehands_next,//shakehands_next为高时说明选择这部分电路数据传输，对应FIFO可以向外发送数据
	
		TimeStamp_left,//左侧双列的时间戳计数器
		TimeStamp_right,//右侧双列的时间戳计数器
		push_clk_left,//左侧双列配置时钟
		push_clk_right,
		shake_hands_col_left,//左侧双列允许数据传输信号
		shake_hands_col_right,
		fifo_data,//FIFO输出的数据
		//rst_n_out,
		empty//FIFO空标志
	);
	
	input clk_40MHz;
	input rst_n_pixel;
	input rst_n;
	input [25:0] data_eoc_left;
	input [25:0] data_eoc_right;
	input push_flag;
	input  addr_config;
	input shakehands_next;

	output [8:0] TimeStamp_left;
	output [8:0] TimeStamp_right;
	output push_clk_left;
	output push_clk_right;
	output shake_hands_col_left;
	output shake_hands_col_right;
	output [27:0] fifo_data;
	//output rst_n_out;
	output empty;
	wire fifo_full;
	wire [26:0] data_eoc_arbiter;//加了一位判断是左侧双列还是右侧双列
	wire [27:0] col_fifo_data;//
	wire wr_en;
	wire [8:0] TimeStamp;
	wire push_clk;
	wire shake_hands_col;
	//wire rst_n_out;//与运算之后的rst_n，传到像素阵列中
	
	End_of_Col u_End_of_Col(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n),//只需要rst_n复位
		.rst_n_pixel(rst_n_pixel),
		.col_data(data_eoc_arbiter),//26位，加了一位判断左右哪个双列
		.push_flag(push_flag),
		.addr_config(addr_config),
		.fifo_full(fifo_full),
		
		.col_fifo_data(col_fifo_data),
		.TimeStamp(TimeStamp),
		.wr_fifo(wr_en),
		.push_clk(push_clk),
		//.rst_n_out(rst_n_out),
		.shake_hands_col(shake_hands_col)
	);
	
	dealing_with_congestion u_dealing_with_congestion(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n_pixel),//只要有一个不复位就不进行仲裁
		//.rst_n_pixel(rst_n_pixel),
		.data_eoc_left(data_eoc_left),
		.data_eoc_right(data_eoc_right),
		.TimeStamp(TimeStamp),
		.push_clk(push_clk),
		.shake_hands_col(shake_hands_col),
		
		.data_eoc_arbiter(data_eoc_arbiter),
		.TimeStamp_left(TimeStamp_left),
		.TimeStamp_right(TimeStamp_right),
		.push_clk_left(push_clk_left),
		.push_clk_right(push_clk_right),
		.shake_hands_col_left(shake_hands_col_left),
		.shake_hands_col_right(shake_hands_col_right)
	);
	
	fifo_deep_two u_fifo_deep_two( 
		.clk_40MHz(clk_40MHz), 
		.rst_n(rst_n_pixel), 
		.wr_en(wr_en),
		.rd_en(shakehands_next),
		.col_fifo_data(col_fifo_data),
		
		.fifo_data(fifo_data),
		.full(fifo_full),
		.empty(empty)
	);

endmodule