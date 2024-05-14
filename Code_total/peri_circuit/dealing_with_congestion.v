module dealing_with_congestion(
	clk_40MHz,
	rst_n,
	data_eoc_left,//左侧双列传输过来的数据例如eoc0
	data_eoc_right,//右侧双列传输过来的数据例如eoc1，间隔四个双列防止拥塞
	//我们可以间隔一个双列
	TimeStamp,//时间戳
	push_clk,//配置时钟
	shake_hands_col,//仅shake_hands_col高电平时允许该拥塞缓解模块发送数据
	
	data_eoc_arbiter,//选择两双列仲裁数据之一传输
	//addr_mux_congestion,
	TimeStamp_left,
	TimeStamp_right,
	push_clk_left,
	push_clk_right,
	shake_hands_col_left,
	shake_hands_col_right
);

	input clk_40MHz;
	input rst_n;
	input [25:0] data_eoc_left;
	input [25:0] data_eoc_right;
	input [8:0] TimeStamp;
	input push_clk;
	input shake_hands_col;
	
	output [26:0] data_eoc_arbiter;
	//output addr_mux_congestion;
	output [8:0] TimeStamp_left;
	output [8:0] TimeStamp_right;
	output push_clk_left;
	output push_clk_right;
	output shake_hands_col_left;
	output shake_hands_col_right;
	
	reg [26:0] data_eoc_arbiter;
	//reg addr_mux_congestion;
	reg shake_hands_col_left;
	reg shake_hands_col_right;
	
	assign TimeStamp_left = TimeStamp;
	assign TimeStamp_right = TimeStamp;
	assign push_clk_left = push_clk;
	assign push_clk_right = push_clk;
	
	parameter superpix_left = 1'b0;
	parameter superpix_right = 1'b1;
	
	reg current_state;
	reg next_state;
	
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					current_state <= superpix_left;
				end
			else 
				begin
					current_state <= next_state;
				end
		end
	
	always @(rst_n or current_state or data_eoc_right or data_eoc_left or shake_hands_col)
		begin
			if(!rst_n)
				begin
					next_state = superpix_left;
				end
			else
				begin
					case(current_state)
						//每一侧输出数据后将状态转换到另一侧，给予每侧相同的数据输出机会
						superpix_left : 
							begin
								if(data_eoc_right != 26'd0 & shake_hands_col == 1'b1)
									begin
										next_state = superpix_right;
									end
								else
									begin
										next_state = superpix_left;
									end
							end
						superpix_right : 
							begin
								if(data_eoc_left != 26'd0 & shake_hands_col == 1'b1)
									begin
										next_state = superpix_left;
									end
								else
									begin
										next_state = superpix_right;
									end
							end
						default :
							begin
								next_state = superpix_left;
							end
					endcase
				end
		end

	always @(rst_n or current_state or data_eoc_right or data_eoc_left or shake_hands_col)
		begin
			if(!rst_n)
				begin
					//addr_mux_congestion = 1'b0;
					data_eoc_arbiter = 27'd0;
					shake_hands_col_left = 1'b1;
					shake_hands_col_right = 1'b1;
				end
			else
				begin
					case(current_state)
						superpix_left : 
							begin
								//addr_mux_congestion = 1'b0;
								shake_hands_col_left = shake_hands_col;
								//左侧双列有数据时shake_hands_col_left依据shake_hands_col确定选择左侧双列数据还是阻塞双列数据
								if(data_eoc_left != 26'd0)
									data_eoc_arbiter = {data_eoc_left, 1'b0};
								else
									data_eoc_arbiter = {data_eoc_right, 1'b1};
								//左侧双列为0时切换到右侧双列shake_hands_col_right依据shake_hands_col确定选择左侧双列数据还是阻塞双列数据
								if(data_eoc_left == 26'd0)
									begin
										shake_hands_col_right = shake_hands_col;
									end
								else
									begin
										shake_hands_col_right = 1'b0;
									end
							end
						superpix_right : 
							begin
								//addr_mux_congestion = 1'b1;
								shake_hands_col_right = shake_hands_col;
								if(data_eoc_right != 26'd0)
									data_eoc_arbiter = {data_eoc_right, 1'b1};
								else
									data_eoc_arbiter = {data_eoc_left, 1'b0};
								if(data_eoc_right == 26'd0)
									begin
										shake_hands_col_left = shake_hands_col;
									end
								else
									begin
										shake_hands_col_left = 1'b0;
									end
							end
						default :
							begin
								//addr_mux_congestion = 1'b0;
								data_eoc_arbiter = 27'd0;
								shake_hands_col_left = 1'b1;
								shake_hands_col_right = 1'b1;
							end
					endcase
				end
		end

endmodule
