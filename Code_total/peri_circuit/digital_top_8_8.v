module digital_top_8_8(
		clk_40MHz,
		clk_640MHz,
		//rst_n_pixel,//像素阵列复位信号，低电平有效
		rst_n,//复位信号，低电平有效
		Dpulse,
		shutter_in,//光子计数使能
		mode_in,//光子计数、轨迹追踪模式开关
		//mode_e_in,//轨迹追踪模式能量信息开关
		spi_sdi,//MOSI
		spi_cs,//40MHz
		hit_0_left,//像素阵列输入信号，由模拟前端输送
		hit_0_right,
		hit_1_left,
		hit_1_right,
		push_clk_in,//配置时钟（这里是由外部直接给，正常使用是通过spi配置，防止spi出问题这里加上了这种配置方式，外部/spi两种配置方式）
		config_info_in,//配置信息（同上）
		shake_hands_col_in,//握手信号（当握手信号有效时阵列存储的数据才能输出出去）
	
		spi_sdo,//MISO,40MHz
		config_DAC_0,//DAC配置位
		config_DAC_1,
		config_DAC_2,
		config_DAC_3,
		valid_out,
		route_data_proc
		
	);

	input clk_40MHz;
	input clk_640MHz;
	//input rst_n_pixel;
	input rst_n;
	input Dpulse;
	input shutter_in;
	input mode_in;
	//input mode_e_in;
	input spi_sdi;
	input spi_cs;
	input [15:0] hit_0_left;
	input [15:0] hit_0_right;
	input [15:0] hit_1_left;
	input [15:0] hit_1_right;
	input push_clk_in;
	input [1:0] config_info_in;
	input shake_hands_col_in;
	output spi_sdo;
	output [63:0] config_DAC_0;
	output [63:0] config_DAC_1;
	output [63:0] config_DAC_2;
	output [63:0] config_DAC_3;
	
	output route_data_proc;//一根线
	output valid_out;
	wire [1:0] push_clk;//最终送到像素电路的配置时钟，是spi写入的配置时钟和片外直接给的时钟做或运算的值
	wire shake_hands_col;//握手信息，同样是spi（shake_hands_col_spi）/片外（shake_hands_col_in）或运算结果
	wire shake_hands_col_spi;//握手信息，由spi配置
	
	wire [27:0] route_data_proc_in;//像素阵列输出数据信息，需要送到in_out_clear模块缓存一个周期，目的清除组合逻辑的延时，让芯片管脚经测试板到fpga有一个周期的时间可以传输（80MHz为12.5ns）。
	//wire clk_out;//clk_out由clk_40MHz加上一个门控信号（由spi配置）实现的，目的是用push_clk配置config_info时不让像素阵列工作
	wire [5:0] cfig_data;//每个双列像素都需要一个config_info信息，这个信息由spi配置，传入pixel_config进行移位操作
	wire [1:0] push_flag;//config_info信息移位完成后由这个信号通过像素阵列一级一级往上推
	wire [23:0] config_info_0;//最终送往像素阵列的config_info信息，由外围和spi的信号或运算得到，每个双列2bit，64列，共32双列，64bit
	wire [1:0] rst_n_out;//只是把复位信号复制了16遍
	wire [1:0] Dpulse_out;
	wire Apulse_en;
	wire [1:0] Apulse_en_out;
	wire [23:0] config_info_spi_0;//spi配置的配置信息
	
	wire config_do;//记录配置信息最后一位
	wire config_en;//pixel_config进行移位操作时的控制信号，spi一次配置8位config信息，spi一次配置后这个信号有效，把8位输出传入pixel_config
	wire push_en;//可以理解为spi产生的push_clk，和push_clk_in与运算之后复制16份送入像素阵列，即push_clk

	wire spi_sdi_output;
	wire spi_cs_output;
	wire push_clk_in_output;
	wire [1:0] config_info_in_output;
	wire shake_hands_col_in_output;
	wire shutter_output;
	wire mode_output;
	wire [1:0] shutter;
	wire [1:0] mode;
	wire shutter_spi_in;
	wire mode_spi_in;
	wire rst_n_pixel_spi_in;
	wire [1:0] shutter_output_spi;
	wire [1:0] mode_output_spi;
	wire [1:0] rst_n_pixel_output_spi;
	wire single_free;
	
	//输入输出时序清理模块，数据由FPGA经由pcb版传入芯片中需要一定时间，如果这个时间太长会导致芯片内部时序混乱，将信号进行一次同步操作保证信号输入至片内时有一个周期的处理时间，传至片外同理
	in_out_clear u_in_out_clear(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n),
		//input
		.spi_sdi_input(spi_sdi),
		.spi_cs_input(spi_cs),
		.shutter_input(shutter_in),
		.mode_input(mode_in),
		.push_clk_in_input(push_clk_in),
		.config_info_in_input(config_info_in),
		.shake_hands_col_in_input(shake_hands_col_in),
		
		.spi_sdi_output(spi_sdi_output),
		.spi_cs_output(spi_cs_output),
		.shutter_output(shutter_output),
		.mode_output(mode_output),
		.push_clk_in_output(push_clk_in_output),
		.config_info_in_output(config_info_in_output),
		.shake_hands_col_in_output(shake_hands_col_in_output)

		
	);
	
	//像素阵列+外围逻辑数据路由
	data_route_merge_proc u_data_route_merge_proc(
		.clk_40MHz(clk_40MHz), 
		.clk_640MHz(clk_640MHz),
		.rst_n(rst_n_out),
		.Dpulse(Dpulse_out),
		.Apulse_en(Apulse_en_out),
		.shutter(shutter),
		.mode(mode),
		.rst_n_pixel(rst_n_pixel_output_spi),
		.hit_0_left(hit_0_left),
		.hit_0_right(hit_0_right),
		.hit_1_left(hit_1_left),
		.hit_1_right(hit_1_right),
		.push_flag(push_clk),
		.addr_config_0(1'b0),
		.addr_config_1(1'b1),
		.shakehands_proc(shake_hands_col),
		.config_info_0(config_info_0),
		.config_DAC_0(config_DAC_0),
		.config_DAC_1(config_DAC_1),
		.config_DAC_2(config_DAC_2),
		.config_DAC_3(config_DAC_3),
		//route_data_proc这个数据应该要根据三种工作模式重新组织一下输出的数据以匹配LVDS传输时的串并转化
		//把不需要输出的信息比如光子计数应用中的地址信息置零类似的，后续需要改一下
		//最开始只弄了携带能量的粒子径迹检测模式，这部分还没来得及改
		.route_data_proc(route_data_proc_in)
	);

	PIS u_pis(
		.clk_40MHz(clk_40MHz),
		.rst_n(rst_n),
		.shake_hands_col_spi(shake_hands_col_spi),
		.shake_hands_col_in_output(shake_hands_col_in_output),
		.shake_hands_col(shake_hands_col),
		.route_data_proc_in(route_data_proc_in),
		.valid_out(valid_out),
		.route_data_proc_out_single(route_data_proc)
	);

	
	
	//两种配置方案，一种从片外直接给，一种由SPI进行配置，二者进行或运算对像素数字激励、掩码、输出开关等信息进行配置
	mux2_1_opera u_mux2_1_opera(
		.clk_40MHz(clk_40MHz),
		.shutter_output(shutter_output),
		.shutter_output_spi(shutter_output_spi),
		.mode_output(mode_output),
		.mode_output_spi(mode_output_spi),
		.push_clk_spi(push_flag),
		.push_clk_in(push_clk_in_output),
		
		.config_info_spi_0(config_info_spi_0),
		.config_info_in(config_info_in_output),
		
		.push_clk(push_clk),
		.shutter(shutter),
		.mode(mode),
		
		.config_info_0(config_info_0)
		
	);
	
	//SPI接口+寄存器堆，寄存器堆中存放smode、ctm等信息
	spi_data_trans u_spi_data_trans(
		.rst_n(rst_n),
		.spi_clk(clk_40MHz),
		.spi_sdi(spi_sdi_output),//这里改了，sdi和cs由in_out_clear输出
		.spi_cs(spi_cs_output),
		.config_do(config_do),
		.route_data_proc(route_data_proc_in),
		
		.spi_sdo(spi_sdo),
		.config_en(config_en),
		.push_clk(push_en),
		.shutter(shutter_spi_in),
		.mode(mode_spi_in),
		.rst_n_pixel(rst_n_pixel_spi_in),
		.Apulse_en(Apulse_en),
		.cfig_data(cfig_data),
		
		.shake_hands_col(shake_hands_col_spi)
	);

	//像素配置模块，整合配置信息，传入像素阵列
	pixel_config u_pixel_config(
		//.clk_40MHz(clk_40MHz),
		.rst_n(rst_n),
		.Dpulse(Dpulse),
		.shutter(shutter_spi_in),
		.mode(mode_spi_in),
		.Apulse_en(Apulse_en),
		.rst_n_pixel(rst_n_pixel_spi_in),
		.config_data(cfig_data),
		.config_clk(clk_40MHz),
		.config_en(config_en),
		.push_en(push_en),
		
		.config_do(config_do),
		.push_clk_out(push_flag),
		.config_data_0(config_info_spi_0),
		.shutter_out(shutter_output_spi),
		.mode_out(mode_output_spi),
		.rst_n_pixel_out(rst_n_pixel_output_spi),
		.Dpulse_out(Dpulse_out),
		.Apulse_en_out(Apulse_en_out),
		.rst_n_out(rst_n_out)
	);
	
	
endmodule