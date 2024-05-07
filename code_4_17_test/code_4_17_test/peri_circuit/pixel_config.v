//像素配置模块
//config_do怎么解释？
//clk_out说是要用门控时钟替换一下，我替换了，但是有点问题，翻下去看看
module pixel_config(
		//clk_40MHz					,
		rst_n						,
		Dpulse						,
		Apulse_en					,
		shutter						,//光子计数模式数据记录使能
		mode						,//光子计数模式/粒子径迹检测模式切换开关
		rst_n_pixel					,
		config_data					,//串行输入配置数据
		config_clk					,//串行输入时钟，用spi_clk
		config_en					,//001号寄存器，即像素配置数据寄存器配置结束后的一个标志信号
		push_en						,//并行时钟输入使能，掩码配置结束后手动开启
		
		config_do					,//串行输出使能，即配置像素时的sdo输出
		push_clk_out				,//并行输出时钟，给到32双列对应的mask_pulse_DAC_config
		config_data_0				,//串行输入，包括mask、apulse、dpulse、dac0的配置
		mode_out					,
		rst_n_pixel_out				,
		shutter_out                 ,
		Dpulse_out					,
		Apulse_en_out				,
		rst_n_out					//并行复位输入
	);

	//input clk_40MHz;
	input rst_n;
	input Dpulse;
	//input smode;
	input shutter;
	input mode;
	input rst_n_pixel;
	input [5:0] config_data;//应该是6bit吧，感觉像是之前的没改过来
	input config_clk;
	input config_en;
	input push_en;
	input Apulse_en;
	
	output config_do;
	output [1:0] rst_n_pixel_out;
	output [1:0] push_clk_out;
	output [23:0] config_data_0;
	output [1:0] shutter_out;
	output [1:0] mode_out;
	output [1:0] rst_n_out;
	output [1:0] Dpulse_out;
	output [1:0] Apulse_en_out;
	
	wire config_do;
	wire [1:0] push_clk_out;
	reg [23:0] config_data_0;
	wire [1:0] rst_n_out;
	wire [1:0] Dpulse_out;
	wire [1:0] Apulse_en_out;
	assign Apulse_en_out={2{Apulse_en}};
	assign Dpulse_out={2{Dpulse}};
	
	assign rst_n_pixel_out={2{rst_n_pixel}};
	//assign clk_out = {clk_40MHz & mask_pulse_en_temp};//这部分应该用门控时钟单元替换一下
	assign rst_n_out = {2{rst_n}};
	//assign push_clk_out = {32{push_en & config_clk}};
	assign config_do = config_data_0[23];
	//assign smode_out = {16{smode}};
	assign shutter_out = {2{shutter}};
	assign mode_out = {2{mode}};
	assign push_clk_out = {2{push_en}};
		
	always @(negedge config_clk or negedge rst_n)
		begin
			if (!rst_n)
				begin
					config_data_0 <= 24'd0;
				end
			else
				begin
					//要将数据推至每个双列列尾，共192bit数据，每次spi配置6bit，要使用移位寄存器配置32次才能将数据推送至对应双列，
					//再令push_clk拉高将数据推送至第一行像素，随后更换这192bit数据，再次使用push_clk推送，反复配置128次完成。

					//4次
					if(config_en)
						begin
							{config_data_0} <= {config_data_0[17:0], config_data};
						end
					else
						begin
							config_data_0 <= config_data_0;
						end
				end
		end
	
endmodule
