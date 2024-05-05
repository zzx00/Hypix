module super_pixel_parallel(  
	clk_40MHz,
	//clk_640MHz,//外部接入的640MHz时钟
	push_clk,//配置时钟，配置config_info
	rst_n,
	rst_n_pixel,
	Dpulse,
	hit,//模拟前端传来的击中信号
	hit_over,//像素单元数据记录结束信号
	shutter,//光子记录模式数据记录使能
	mode,//粒子径迹追踪/光子计数模式切换开关
	config_info,//配置信息，目前包括数字激励Dpulse，掩码mask以及4bit dac输入
	//TimeStamp,
	ToT_data_0,//像素单元TOT信息
	ToT_data_1,
	ToT_data_2,
	ToT_data_3,
	ToT_data_4,
	ToT_data_5,
	ToT_data_6,
	ToT_data_7,
	timestamp_hit_0,//像素单元TOA信息
	timestamp_hit_1,
	timestamp_hit_2,
	timestamp_hit_3,
	timestamp_hit_4,
	timestamp_hit_5,
	timestamp_hit_6,
	timestamp_hit_7,
	FTOA_0,
	FTOA_1,
	FTOA_2,
	FTOA_3,
	FTOA_4,
	FTOA_5,
	FTOA_6,
	FTOA_7,
	
	addr_col,//超级像素所在列地址，该地址为固定值   8*8一个双列2个超级像素
	last_data,//上一超级像素仲裁数据(所有超级像素共享一条数据总线)
	shake_hands_next,//握手协议，由下一级超级像素仲裁器的发出，告知总线已选择本超级像素数据传输，可改变仲裁数据
	
	hit_pixel,//同步后的击中信号，用于开启门控时钟，数据记录等
	hit_or_super_pixel,
	next_config_info,//向下传输的配置信息
	arbiter_data,//8个单像素点数据冲突时的仲裁数据
	clk_gating_single_pixel_40MHz,//输送给各个单像素的门控时钟
    //clk_gating_single_pixel_640MHz,//640MHz输送给各个单像素的门控时钟
	shake_hands_last,//告知上一级超级像素总线已选择上一级超级像素数据传输，可改变仲裁数据
	out_flag,//计数结束后的数据被取走，告知单像素将ToT清零
	shutter_temp,//同步后的shutter信号
	config_DAC_0,//8个单像素点DAC配置信息
	config_DAC_1,
	config_DAC_2,
	config_DAC_3,
	config_DAC_4,
	config_DAC_5,
	config_DAC_6,
	config_DAC_7,
	hit_or,
	hit_pixel_edge//击中信号上升沿
);

	input clk_40MHz;
	//input clk_640MHz;
	input push_clk;
	input rst_n;
	input rst_n_pixel;
	input Dpulse;
	input [7:0] hit;
	input [7:0] hit_over;
	input shutter;
	input mode;
	input [5:0] config_info;
	//input [8:0] TimeStamp;
	input [7:0] ToT_data_0;
	input [7:0] ToT_data_1;
	input [7:0] ToT_data_2;
	input [7:0] ToT_data_3;
	input [7:0] ToT_data_4;
	input [7:0] ToT_data_5;
	input [7:0] ToT_data_6;
	input [7:0] ToT_data_7;
	input [8:0] timestamp_hit_0;
	input [8:0] timestamp_hit_1;
	input [8:0] timestamp_hit_2;
	input [8:0] timestamp_hit_3;
	input [8:0] timestamp_hit_4;
	input [8:0] timestamp_hit_5;
	input [8:0] timestamp_hit_6;
	input [8:0] timestamp_hit_7;

		//FTOA
	input [4:0] FTOA_0;
	input [4:0] FTOA_1;
	input [4:0] FTOA_2;
	input [4:0] FTOA_3;
	input [4:0] FTOA_4;
	input [4:0] FTOA_5;
	input [4:0] FTOA_6;
	input [4:0] FTOA_7;

	//FTOA
	wire [4:0] FTOA_0;
	wire [4:0] FTOA_1;
	wire [4:0] FTOA_2;
	wire [4:0] FTOA_3;
	wire [4:0] FTOA_4;
	wire [4:0] FTOA_5;
	wire [4:0] FTOA_6;
	wire [4:0] FTOA_7;

	input  addr_col;//列级地址  两个超级像素 ，只需要1位
	input [25:0] last_data;//由于只需要两个超级像素，只需要26位，加了FTOA,FTOA5位
    input shake_hands_next;

	output [7:0] hit_pixel;
	output hit_or_super_pixel;
	output [5:0] next_config_info;//1位Dpulse，1位Mask，4位DAC
    output [25:0] arbiter_data;
	output shake_hands_last;
	output [7:0] clk_gating_single_pixel_40MHz;
    //output [7:0] clk_gating_single_pixel_640MHz;
	output [7:0] out_flag;
	output [7:0] hit_pixel_edge;
	output [3:0] config_DAC_0;
	output [3:0] config_DAC_1;
	output [3:0] config_DAC_2;
	output [3:0] config_DAC_3;
	output [3:0] config_DAC_4;
	output [3:0] config_DAC_5;
	output [3:0] config_DAC_6;
	output [3:0] config_DAC_7;

	output [7:0] hit_or;

	output shutter_temp;
	
	wire [7:0] clk_gating_single_pixel_40MHz;
    //wire [7:0] clk_gating_single_pixel_640MHz;
	//25位仲裁信息
	reg [25:0] arbiter_data;
	reg [25:0] arbiter_data_temp;
	reg [7:0] out_flag;
	reg [7:0] out_flag_temp;
	reg shake_hands_last;
	
	reg [7:0] hit_pixel;
	reg [7:0] hit_pixel_temp;
	reg [7:0] hit_pixel_negedge;
	wire [7:0] hit_pixel_edge;
	//reg [7:0] hit_pixel_640MHz_temp;
	//wire [7:0] hit_pixel_640MHz_edge;
	reg shutter_temp;
	wire [8:0] timestamp_hit_0;
	wire [8:0] timestamp_hit_1;
	wire [8:0] timestamp_hit_2;
	wire [8:0] timestamp_hit_3;
	wire [8:0] timestamp_hit_4;
	wire [8:0] timestamp_hit_5;
	wire [8:0] timestamp_hit_6;
	wire [8:0] timestamp_hit_7;
	reg [47:0] config_info_temp;
	wire [5:0] next_config_info;
	wire [7:0] hit_or;
	//wire rst_and;
	//assign rst_and=rst_n & rst_n_pixel;
	assign hit_or_super_pixel=|hit_or;
	//wire [7:0] clk_gating_en;
	// wire [7:0] TE_temp;
	// wire [7:0] E_temp;
	
	assign next_config_info = config_info_temp[47:42];
	assign config_DAC_0 = config_info_temp[5:2];
	assign config_DAC_1 = config_info_temp[11:8];
	assign config_DAC_2 = config_info_temp[17:14];
	assign config_DAC_3 = config_info_temp[23:20];
	assign config_DAC_4 = config_info_temp[29:26];
	assign config_DAC_5 = config_info_temp[35:32];
	assign config_DAC_6 = config_info_temp[41:38];
	assign config_DAC_7 = config_info_temp[47:44];
	
	//击中信号上升沿检测
	assign hit_pixel_edge[0] = hit_pixel[0] & !hit_pixel_temp[0];
	assign hit_pixel_edge[1] = hit_pixel[1] & !hit_pixel_temp[1];
	assign hit_pixel_edge[2] = hit_pixel[2] & !hit_pixel_temp[2];
	assign hit_pixel_edge[3] = hit_pixel[3] & !hit_pixel_temp[3];
	assign hit_pixel_edge[4] = hit_pixel[4] & !hit_pixel_temp[4];
	assign hit_pixel_edge[5] = hit_pixel[5] & !hit_pixel_temp[5];
	assign hit_pixel_edge[6] = hit_pixel[6] & !hit_pixel_temp[6];
	assign hit_pixel_edge[7] = hit_pixel[7] & !hit_pixel_temp[7];


    	//配置信息逐周期推送至每个像素点
	always @(posedge push_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					config_info_temp <= 48'd0;
				end
			else
				begin
					config_info_temp <= {config_info_temp[41:0], config_info};
				end
		end

    //同步，包括击中信号hit两级同步（config_info_temp[1]等为Mask，该信号有效时关闭像素，config_info_temp[0]等为Dpulse，该信号可代替hit信号工作，用于测试像素点功能）
	//shutter同步了一次，shutter信号由外围电路传至超级像素延时很长，本次同步用于更新时序信息
	//下降沿同步一次
	always @( negedge clk_40MHz or negedge rst_n_pixel )
		begin
			if(!rst_n_pixel)
				begin
					hit_pixel_negedge <= 8'd0;
				end
			else
				begin
					//40MHz同步后的hit_pixel信号
					hit_pixel_negedge[0] <= !config_info_temp[1] & (hit[0] | (Dpulse & config_info_temp[0]));
					hit_pixel_negedge[1] <= !config_info_temp[7] & (hit[1] | (Dpulse & config_info_temp[6]));
					hit_pixel_negedge[2] <= !config_info_temp[13] & (hit[2] | (Dpulse & config_info_temp[12]));
					hit_pixel_negedge[3] <= !config_info_temp[19] & (hit[3] | (Dpulse & config_info_temp[18]));
					hit_pixel_negedge[4] <= !config_info_temp[25] & (hit[4] | (Dpulse & config_info_temp[24]));
					hit_pixel_negedge[5] <= !config_info_temp[31] & (hit[5] | (Dpulse & config_info_temp[30]));
					hit_pixel_negedge[6] <= !config_info_temp[37] & (hit[6] | (Dpulse & config_info_temp[36]));
					hit_pixel_negedge[7] <= !config_info_temp[43] & (hit[7] | (Dpulse & config_info_temp[42]));
				end
		end

//上升沿同步一次
	always @( posedge clk_40MHz or negedge rst_n_pixel )
		begin
			if(!rst_n_pixel)
				begin
					hit_pixel <= 8'd0;
					hit_pixel_temp <= 8'd0;
					shutter_temp <= 1'b0;
				end
			else
				begin
					//40MHz同步后的hit_pixel信号
					hit_pixel[0] <= hit_pixel_negedge[0];
					hit_pixel[1] <= hit_pixel_negedge[1];
					hit_pixel[2] <= hit_pixel_negedge[2];
					hit_pixel[3] <= hit_pixel_negedge[3];
					hit_pixel[4] <= hit_pixel_negedge[4];
					hit_pixel[5] <= hit_pixel_negedge[5];
					hit_pixel[6] <= hit_pixel_negedge[6];
					hit_pixel[7] <= hit_pixel_negedge[7];
					hit_pixel_temp <= hit_pixel;
					shutter_temp <= shutter;
				end
		end


    
	// //生成单像素门控时钟
	// assign clk_gating_en[0] =  shutter_temp ? shutter_temp : hit_pixel[0];
	// assign clk_gating_en[1] =  shutter_temp ? shutter_temp : hit_pixel[1];
	// assign clk_gating_en[2] =  shutter_temp ? shutter_temp : hit_pixel[2];
	// assign clk_gating_en[3] =  shutter_temp ? shutter_temp : hit_pixel[3];
	// assign clk_gating_en[4] =  shutter_temp ? shutter_temp : hit_pixel[4];
	// assign clk_gating_en[5] =  shutter_temp ? shutter_temp : hit_pixel[5];
	// assign clk_gating_en[6] =  shutter_temp ? shutter_temp : hit_pixel[6];
	// assign clk_gating_en[7] =  shutter_temp ? shutter_temp : hit_pixel[7];

	// assign TE_temp[0] = !mode & !shutter & hit_pixel[0];
	// assign TE_temp[1] = !mode & !shutter & hit_pixel[1];
	// assign TE_temp[2] = !mode & !shutter & hit_pixel[2];
	// assign TE_temp[3] = !mode & !shutter & hit_pixel[3];
	// assign TE_temp[4] = !mode & !shutter & hit_pixel[4];
	// assign TE_temp[5] = !mode & !shutter & hit_pixel[5];
	// assign TE_temp[6] = !mode & !shutter & hit_pixel[6];
	// assign TE_temp[7] = !mode & !shutter & hit_pixel[7];

	// assign E_temp[0] = (shutter & hit_pixel[0])|(!shutter & shutter_temp);
	// assign E_temp[1] = (shutter & hit_pixel[1])|(!shutter & shutter_temp);
	// assign E_temp[2] = (shutter & hit_pixel[2])|(!shutter & shutter_temp);
	// assign E_temp[3] = (shutter & hit_pixel[3])|(!shutter & shutter_temp);
	// assign E_temp[4] = (shutter & hit_pixel[4])|(!shutter & shutter_temp);
	// assign E_temp[5] = (shutter & hit_pixel[5])|(!shutter & shutter_temp);
	// assign E_temp[6] = (shutter & hit_pixel[6])|(!shutter & shutter_temp);
	// assign E_temp[7] = (shutter & hit_pixel[7])|(!shutter & shutter_temp);
	
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_0
	(
		.TE(~(mode^shutter) & hit_pixel[0]),
		.E((shutter & hit_pixel[0])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[0])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_1
	(
		.TE(~(mode^shutter) & hit_pixel[1]),
		.E((shutter & hit_pixel[1])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[1])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_2
	(
		.TE(~(mode^shutter) & hit_pixel[2]),
		.E((shutter & hit_pixel[2])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[2])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_3
	(
		.TE(~(mode^shutter) & hit_pixel[3]),
		.E((shutter & hit_pixel[3])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[3])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_4
	(
		.TE(~(mode^shutter) & hit_pixel[4]),
		.E((shutter & hit_pixel[4])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[4])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_5
	(
		.TE(~(mode^shutter) & hit_pixel[5]),
		.E((shutter & hit_pixel[5])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[5])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_6
	(
		.TE(~(mode^shutter) & hit_pixel[6]),
		.E((shutter & hit_pixel[6])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[6])
	);
	
	CKLNQD8BWP7T u_CKLNQD8BWP7T_7
	(
		.TE(~(mode^shutter) & hit_pixel[7]),
		.E((shutter & hit_pixel[7])|(!shutter & shutter_temp)),
		.CP(clk_40MHz),
		.Q(clk_gating_single_pixel_40MHz[7])
	);


	assign hit_or[0] = !config_info_temp[1] & (hit[0] | (Dpulse & config_info_temp[0])) & !hit_pixel[0] & !mode & !shutter;
    assign hit_or[1] = !config_info_temp[7] & (hit[1] | (Dpulse & config_info_temp[6])) & !hit_pixel[1] & !mode & !shutter;
    assign hit_or[2] = !config_info_temp[13] & (hit[2] | (Dpulse & config_info_temp[12])) & !hit_pixel[2] & !mode & !shutter;
    assign hit_or[3] = !config_info_temp[19] & (hit[3] | (Dpulse & config_info_temp[18])) & !hit_pixel[3] & !mode & !shutter;
    assign hit_or[4] = !config_info_temp[25] & (hit[4] | (Dpulse & config_info_temp[24])) & !hit_pixel[4] & !mode & !shutter;
    assign hit_or[5] = !config_info_temp[31] & (hit[5] | (Dpulse & config_info_temp[30])) & !hit_pixel[5] & !mode & !shutter;
    assign hit_or[6] = !config_info_temp[37] & (hit[6] | (Dpulse & config_info_temp[36])) & !hit_pixel[6] & !mode & !shutter;
    assign hit_or[7] = !config_info_temp[43] & (hit[7] | (Dpulse & config_info_temp[42])) & !hit_pixel[7] & !mode & !shutter;


    // assign clk_gating_single_pixel_640MHz[0] = hit_or[0] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[1] = hit_or[1] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[2] = hit_or[2] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[3] = hit_or[3] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[4] = hit_or[4] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[5] = hit_or[5] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[6] = hit_or[6] & clk_640MHz;
    // assign clk_gating_single_pixel_640MHz[7] = hit_or[7] & clk_640MHz;


//感觉仲裁这里不需要改
	//shake_hands_next有效时更换仲裁数据，其余时间保持
	//out_flag延时了一拍，不然会立刻触发单像素复位，导致hit_over信号出错
	//仲裁26位
	always @(posedge clk_40MHz or negedge rst_n_pixel )
		begin
			if(!rst_n_pixel)
				begin
					out_flag <= 8'b11111111;//复位值得是1，由out_flag再复位单像素TOT、TOA信息
					arbiter_data <= 26'd0;
				end
			else
				begin
					out_flag <= out_flag_temp;
					if(shake_hands_next)
						arbiter_data <= arbiter_data_temp;//打一拍更新时序信息，数据从最顶层超级像素两两比较至底层超级像素无法在一周期内完成
					else
						arbiter_data <= arbiter_data;
				end
		end
		
	//状态机相关，两个状态，本级数据和上一级数据任有其一，直接输出，保证数据最快速度输出
	reg current_state;
	reg next_state;
	parameter OUT_current = 1'b1;
	parameter OUT_last =1'b0;
	
	//状态机
	always @(posedge clk_40MHz or negedge rst_n_pixel)
		begin
			if(!rst_n_pixel)
				begin
					current_state <= OUT_last;
				end
			else
				begin
					current_state <= next_state;
				end
		end
	
	//hit_over 8bit数据表示八个像素点是否有数据击中
	//超级像素管理模块选择上一超级像素数据(OUT_last)，或者本级超级像素数据(OUT_current)传输
	always @(current_state or rst_n_pixel or last_data or hit_over)
		begin
			if(!rst_n_pixel)
				begin
					next_state = OUT_last;
				end
			else
				case(current_state)
					OUT_last : 
						begin
							if(last_data == 26'd0 & hit_over != 8'd0)
								next_state = OUT_current;
							else
								next_state = OUT_last;
						end
					OUT_current : 
						begin
							if(hit_over == 8'd0)
								next_state = OUT_last;
							else
								next_state = OUT_current;
						end
					default : 
						begin
							next_state = OUT_current;
						end
				endcase
		end
	
	always @(current_state  or rst_n_pixel or shake_hands_next or last_data or hit_over or addr_col or timestamp_hit_7 or timestamp_hit_6 or timestamp_hit_5 or timestamp_hit_4 or timestamp_hit_3 or timestamp_hit_2 or timestamp_hit_1 or timestamp_hit_0 or ToT_data_7 or ToT_data_6 or ToT_data_5 or ToT_data_4 or ToT_data_3 or ToT_data_2 or ToT_data_1 or ToT_data_0 or FTOA_0 or FTOA_1 or FTOA_2 or FTOA_3 or FTOA_4 or FTOA_5 or FTOA_6 or FTOA_7)
		begin
			if(!rst_n_pixel)
				begin
					out_flag_temp = 8'b00000000;
					arbiter_data_temp = 26'd0;
					shake_hands_last = 1'b0;
				end
			else
				case(current_state)
					OUT_last : 
						begin
							out_flag_temp = 8'b00000000;
							arbiter_data_temp = last_data;
							if(shake_hands_next)
								begin
									shake_hands_last = 1'b1;
								end
							else
								begin
									shake_hands_last = 1'b0;
								end
						end
					OUT_current :
						begin
							shake_hands_last = 1'b0;
							if(shake_hands_next == 1'b1)
								begin
									if(hit_over[7] == 1'b1)
										begin
											arbiter_data_temp = {timestamp_hit_7, FTOA_7, ToT_data_7, addr_col, 3'b111};
											out_flag_temp = 8'b10000000;
										end
									else if(hit_over[6] == 1'b1)
										begin                      
											arbiter_data_temp = {timestamp_hit_6, FTOA_6, ToT_data_6, addr_col, 3'b110};
											out_flag_temp = 8'b01000000;       
										end
									else if(hit_over[5] == 1'b1)
										begin                                  
											arbiter_data_temp = {timestamp_hit_5, FTOA_5, ToT_data_5, addr_col, 3'b101};
											out_flag_temp = 8'b00100000;    
										end
									else if(hit_over[4] == 1'b1)
										begin                                   
											arbiter_data_temp = {timestamp_hit_4, FTOA_4, ToT_data_4, addr_col, 3'b100};
											out_flag_temp = 8'b00010000;     
										end
									else if(hit_over[3] == 1'b1)
										begin                                    
											arbiter_data_temp = {timestamp_hit_3, FTOA_3, ToT_data_3, addr_col, 3'b011};
											out_flag_temp = 8'b00001000;    
										end
									else if(hit_over[2] == 1'b1)
										begin                                  
											arbiter_data_temp = {timestamp_hit_2, FTOA_2, ToT_data_2, addr_col, 3'b010};
											out_flag_temp = 8'b00000100;   
										end
									else if(hit_over[1] == 1'b1)
										begin                                    
											arbiter_data_temp = {timestamp_hit_1, FTOA_1, ToT_data_1, addr_col, 3'b001};
											out_flag_temp = 8'b00000010; 
										end
									else if(hit_over[0] == 1'b1)
										begin                                         
											arbiter_data_temp = {timestamp_hit_0, FTOA_0, ToT_data_0, addr_col, 3'b000};
											out_flag_temp = 8'b00000001;   
										end
									else
										begin
											arbiter_data_temp = 26'd0;
											out_flag_temp = 8'd0;    
										end
								end
							else
								begin
									arbiter_data_temp = 26'd0;
									out_flag_temp = 8'd0;
								end
						end
					default : 
						begin
							shake_hands_last = 1'b0;
							arbiter_data_temp = 26'b0;
							out_flag_temp = 8'b0;
						end
				endcase
		end
endmodule

