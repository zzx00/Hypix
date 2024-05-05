//像素阵列与外围电路通信电路，为像素阵列提供时间戳计数器、掩码、握手协议等信息，为外围电路提供写使能等
module End_of_Col(
		clk_40MHz			,
		rst_n				,
		rst_n_pixel			,
		col_data			,//列尾传过来的数据，保持两周期后回到0
		push_flag			,//mask、pulse、DAC配置时钟使能
		addr_config			,//对应的列地址（固定）
		fifo_full			,//本级fifo满
		//route_fifo_full	,//路由fifo差一个满（预留一个数据位）
		
		col_fifo_data		,//传至fifo的数据
		//route_fifo_data	,//本级fifo满传至路由fifo的数据
		TimeStamp			,//时间戳，每列一个，防止延时过长
		wr_fifo				,//写信号
		//wr_route_fifo		,//路由写信号
		push_clk			,//mask、pulse、DAC配置时钟
		//rst_n_out			,
		shake_hands_col	 //fifo_full为0时从每一列的最后一个仲裁器取数的标志
	);

	input clk_40MHz;
	input rst_n;
	input rst_n_pixel;
	//input smode;
	//input [24:0] col_data;
	input [26:0] col_data;
	//位宽不对，少了一位
	input push_flag;
	input  addr_config;//只需要1bit的addr_config
	input fifo_full;
	//input route_fifo_full;

	output [27:0] col_fifo_data;//5FTOA+9TOA+8TOT+6addr
	//output [29:0] route_fifo_data;
	output [8:0] TimeStamp;//送到像素阵列的格雷码
	output wr_fifo;
	//output wr_route_fifo;
	output push_clk;
	output shake_hands_col;
	//output rst_n_out;
	
	reg [27:0] col_fifo_data;
	//reg [29:0] route_fifo_data;
	reg [8:0] TimeStamp_binary;//当前产生的二进制码
	wire wr_fifo;
	//reg [23:0] col_data_temp_0;
	//reg wr_route_fifo;
	wire shake_hands_col;
	wire [8:0] TimeStamp;
	//wire [8:0] TimeStamp_gray;//从像素阵列传来的格雷码时间戳
	//wire [8:0] TimeStamp_gray_bin;//将格雷码时间戳转化为二进制
	
	//assign TimeStamp_gray = col_data[23:15];
	assign TimeStamp = {(TimeStamp_binary >> 1'b1) ^ TimeStamp_binary};//二进制码转格雷码输出
	//assign TimeStamp_gray_bin = rst_n ? {TimeStamp_gray[8], (TimeStamp_gray_bin[8:1] ^ TimeStamp_gray[7:0])} : 9'd0;//格雷码转二进制码
	
	assign shake_hands_col = !fifo_full;
	assign wr_fifo = !fifo_full;
	//assign rst_n_out=rst_n & rst_n_pixel;
	
	assign push_clk = push_flag;
	
	//assign shake_hands_col = !fifo_full;
	
	/*always @(col_data)
		begin
			if(col_data != 24'd0)
				begin
					wr_fifo = 1'b1;
					last_flag = 1'b0;
				end
			else
				begin
					wr_fifo = 1'b0;
					last_flag = 1'b1;
				end
		end*/
		
	
	always @(posedge clk_40MHz or negedge rst_n_pixel)
		begin
			if(!rst_n_pixel)
				begin
					col_fifo_data <= 28'd0;
				end
			/*else if(smode)
				begin
					col_fifo_data <= 29'd0;
				end*/
			//粒子径迹追踪模式下col_data[12:5]代表TOT，col_data[25:17]代表TOA
			//光子计数模式下这两组寄存器也代表了PC和iTOT，为0则数据无效
			//写注释的时候感觉这个TOA应该可以为0，这里为什么加这个条件忘记了，如果去掉“| col_data[25:17] != 9'd0”验证没问题的话，应该把这部分删掉
			
			//你把寄存器顺序改了，代码逻辑里面的也要改啊
			else if((col_data[12:5] != 8'd0 | col_data[26:18] != 9'd0) & shake_hands_col)
				begin
					col_fifo_data <= {col_data, addr_config} ;
				end
			else
				begin
					col_fifo_data <= col_fifo_data;
				end
		end

	//二进制时间戳计数器
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					TimeStamp_binary <= 9'd0;
				end
			else
				begin
					TimeStamp_binary <= TimeStamp_binary + 1'b1;
				end
		end
	
endmodule
