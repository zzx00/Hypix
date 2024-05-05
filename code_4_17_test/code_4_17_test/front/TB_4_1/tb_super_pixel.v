`timescale 1ns/10fs

module super_ctrl_tb();

reg clk_40MHz,clk_640MHz,push_clk,rst_n;
reg mode,shutter;
reg [7:0] hit;
reg [7:0] hit_over;
reg [5:0] config_info;
reg [7:0] ToT_data_0,ToT_data_1,ToT_data_2,ToT_data_3,ToT_data_4,ToT_data_5,ToT_data_6,ToT_data_7;
reg [8:0]	timestamp_hit_0,timestamp_hit_1,timestamp_hit_2,timestamp_hit_3,timestamp_hit_4,timestamp_hit_5,timestamp_hit_6,timestamp_hit_7;
reg [3:0]	FTOA_0,	FTOA_1,	FTOA_2,	FTOA_3,	FTOA_4,	FTOA_5,FTOA_6,FTOA_7;
reg addr_col,shake_hands_next;
reg [24:0] last_data;


wire [7:0] hit_pixel,hit_pixel_640MHz,hit_pixel_edge;
wire [5:0] next_config_info;
wire [24:0] arbiter_data;
wire shake_hands_last;
wire [7:0] clk_gating_single_pixel_40MHz,clk_gating_single_pixel_640MHz,out_flag;
wire [3:0] config_DAC_0,config_DAC_1,config_DAC_2,config_DAC_3,config_DAC_4,config_DAC_5,config_DAC_6,config_DAC_7;
wire shutter_temp;

super_pixel_parallel inst(clk_40MHz,
	clk_640MHz,//外部接入的640MHz时钟
	push_clk,//配置时钟，配置config_info
	rst_n,
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
	hit_pixel_640MHz,//同步后的640MHz击中信号，用来开启门控，记录FTOA
	next_config_info,//向下传输的配置信息
	arbiter_data,//8个单像素点数据冲突时的仲裁数据
	clk_gating_single_pixel_40MHz,//输送给各个单像素的门控时钟
    clk_gating_single_pixel_640MHz,//640MHz输送给各个单像素的门控时钟
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
	hit_pixel_edge);

    integer i;

    initial begin
        #5
        clk_40MHz<=0;
        clk_640MHz<=0;
        push_clk<=0;
        i<=0;
        rst_n<=0;
        hit_over<=0;
        shutter<=0;
        mode<=0;
        addr_col<=0;
        last_data<=0;
        shake_hands_next<=0;
        hit<=8'd0;
        #10
        rst_n<=1;
        config_info<=6'b01_0100;
        #(25*8)
        #5
        shutter<=0;
        hit_over<=1;
        #5
		#60
		for(i=0;i<8;i=i+1)
		begin
		if(i==0)
		begin
			hit[0]<=1;
			ToT_data_0<=8'd7;
			timestamp_hit_0<=9'd7;
			FTOA_0<=4'd7;
			#50
			hit[0]<=0;
			hit_over[0]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==1)
		begin
			hit[1]<=1;
			ToT_data_1<=8'd6;
			timestamp_hit_1<=9'd6;
			FTOA_1<=4'd6;
			#50
			hit[1]<=0;
			hit_over[1]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==2)
		begin
			hit[2]<=1;
			ToT_data_2<=8'd5;
			timestamp_hit_2<=9'd5;
			FTOA_2<=4'd5;
			#50
			hit[2]<=0;
			hit_over[2]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==3)
		begin
			hit[3]<=1;
			ToT_data_3<=8'd4;
			timestamp_hit_3<=9'd4;
			FTOA_3<=4'd4;
			#50
			hit[3]<=0;
			hit_over[3]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==4)
		begin
			hit[4]<=1;
			ToT_data_4<=8'd3;
			timestamp_hit_4<=9'd3;
			FTOA_4<=4'd3;
			#50
			hit[4]<=0;
			hit_over[4]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==5)
		begin
			hit[5]<=1;
			ToT_data_5<=8'd2;
			timestamp_hit_5<=9'd2;
			FTOA_5<=4'd2;
			#50
			hit[5]<=0;
			hit_over[5]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==6)
		begin
			hit[6]<=1;
			ToT_data_6<=8'd1;
			timestamp_hit_6<=9'd1;
			FTOA_6<=4'd1;
			#50
			hit[6]<=0;
			hit_over[6]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else if(i==7)
		begin
			hit[7]<=1;
			ToT_data_7<=8'd8;
			timestamp_hit_7<=9'd8;
			FTOA_7<=4'd8;
			#50
			hit[7]<=0;
			hit_over[7]<=1;
		#5 shake_hands_next<=1;
		#25 shake_hands_next<=0;
		end else ;
                
                
            
        end
	end





always #12.5 clk_40MHz<=~clk_40MHz;
always #0.78125 clk_640MHz<=~clk_640MHz;
always #12.5 push_clk<=~push_clk;//外部输入的配置时钟，现在给40MHz




endmodule
