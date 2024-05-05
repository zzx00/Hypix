//对一级仲裁后的数据进行二级仲裁
module data_route_proc(
	clk_40MHz,
	rst_n,
	route_data_0,
	route_data_1,
	empty_merge,
	shakehands_proc,
	
	route_data_proc,
	shake_hands_merge
);

	input clk_40MHz;
	input rst_n;
	input [27:0] route_data_0;
	input [27:0] route_data_1;

	//列尾fifo空满情况，感觉也只需要两个
	input [1:0] empty_merge;
	input shakehands_proc;
	
	//output empty_proc;
	output [27:0] route_data_proc;
	output [1:0] shake_hands_merge;
	
	reg [27:0] route_data_proc;
	reg [1:0] shake_hands_merge;
	
	//一个IDLE加上合并两个数据，只需要三个状态，2位就行
	reg [1:0] current_state;
	reg [1:0] next_state;
	parameter IDLE = 2'b00;
	parameter Merge_0 = 2'b01;
	parameter Merge_1 = 2'b10;
	

	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					current_state <= IDLE;
				end
			else
				begin
					current_state <= next_state;
				end
		end
	//循环仲裁，如果都有数据，0-1，1-0
	always @(current_state or empty_merge or rst_n)
		begin
			if(!rst_n)
				begin
					next_state = IDLE;
				end
			else
				case(current_state)
					IDLE : 
						begin
							if(empty_merge == 2'b11)//表示两个fifo都为空
								begin
									next_state = IDLE;
								end
							else
								begin
									next_state = Merge_0;
								end
						end
					Merge_1 :
						begin
							if(empty_merge == 2'b11)
								begin
									next_state = IDLE;
								end
							else
								begin
									next_state = Merge_0;
								end
						end
					Merge_0 :
						begin
							if(empty_merge == 2'b11)
								begin
									next_state = IDLE;
								end
							else
								begin
									next_state = Merge_1;
								end
						end
					default :
						begin
							next_state = IDLE;
						end
				endcase
		end
	
	always @(current_state or shakehands_proc or route_data_0 or route_data_1 or rst_n)
		begin
			if(!rst_n)
				begin
					route_data_proc = 28'd0;
					shake_hands_merge = 2'd0;
				end
			else 
				case(current_state)
					IDLE :
						begin
							route_data_proc = 28'd0;
							shake_hands_merge = 2'd0;
						end
					Merge_0 : 
						begin
							if(shakehands_proc)
								begin
									route_data_proc = route_data_0;
									shake_hands_merge = 2'b01;
								end
							else
								begin
									route_data_proc = 28'd0;
									shake_hands_merge = 2'd0;
								end
						end
					Merge_1 : 
						begin
							if(shakehands_proc)
								begin
									route_data_proc = route_data_1;
									shake_hands_merge = 2'b10;
								end
							else
								begin
									route_data_proc = 28'd0;
									shake_hands_merge = 2'd0;
								end
						end
					default :
						begin
							route_data_proc = 28'd0;
							shake_hands_merge = 2'd0;
						end
				endcase
		end
	
endmodule