//一个不太标准的异步FIFO，这里FIFO的深度与宽度均与论文中定义的不同，宽度差了4bit FTOA信息，深度论文中也写道有一些实验的想法在里面，就只给了6，验证下功能
module fifo_deep_two( 
		clk_40MHz			, 
		rst_n				, 
		wr_en				,//写信号
		//wr_route_en		,//路由过来的数据
		rd_en				,//读信号
		//route_data_in		,//路由数据
		col_fifo_data		,//本级fifo数据
		
		fifo_data			,//fifo数据输出至仲裁器
		full				,//给路由节点的fifo满信号
		empty				//空不可读
		//wr_en_fifo		//写时不可读
	);
	
	input clk_40MHz;
	input rst_n;
	input wr_en;
	//input wr_route_en;
	input rd_en;
	//input [29:0] route_data_in;
	input [27:0] col_fifo_data;
	
	output [27:0] fifo_data;
	output full;
	output empty;
	//output wr_en_fifo;
	
	reg [27:0] fifo_data;
	//reg wr_en_fifo; 
	
	reg [27:0] fifo_0;
	reg [27:0] fifo_1;

	//reg [28:0] route_fifo_0;
	//reg [28:0] route_fifo_1;
	wire full;
	reg [1:0] cnt_write;
	reg [1:0] cnt_read;
	reg [1:0] cnt_read_temp;
	wire [1:0]n_cnt_read;
	wire [1:0] full_empty_flag;
	wire [1:0] full_empty_flag_out;
	//空满信号，这里写了一下补码的运算，其实是没必要的
	assign full = (full_empty_flag_out == 2'b10) ? 1'b1 : 1'b0;
	assign empty = (full_empty_flag == 2'b00) ? 1'b1 : 1'b0;
	assign n_cnt_read = ({!cnt_read[1], !cnt_read[0]} + 1'b1);//连同符号位一起取反再加一
	assign full_empty_flag_out = cnt_write + n_cnt_read;
	assign full_empty_flag = cnt_write + ({ !cnt_read_temp[1], !cnt_read_temp[0]} + 1'b1);
	
	//本级fifo写，FIFO可写且有数据更新，且更新数据不为0时写入
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					cnt_write <= 2'b0;
				end
			else if(wr_en & col_fifo_data != fifo_0 & col_fifo_data != 28'd0)
				begin
					cnt_write <= cnt_write + 1'b1;
				end
			else
				begin
					cnt_write <= cnt_write;
				end
		end
	
	//写入之后数据逐渐向后推
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					fifo_0 <= 28'b0;
					fifo_1 <= 28'b0;
					
				end
			else if(wr_en & col_fifo_data != fifo_0 & col_fifo_data != 28'd0)
				begin
					fifo_0 <= col_fifo_data;
					fifo_1 <= fifo_0;
				end
			else
				begin
					fifo_0 <= fifo_0;
					fifo_1 <= fifo_1;
				end
		end

	//fifo读
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					cnt_read <= 2'd0;
				end
			else
				begin
					cnt_read <= cnt_read_temp;
				end
		end

	//非空且数据不为0则可读
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					cnt_read_temp <= 2'd0;
				end
			else if(rd_en & (fifo_data == 28'd0) & !empty)
				begin
					cnt_read_temp <= cnt_read_temp;
				end
			else if(rd_en & !empty)
				begin
					cnt_read_temp <= cnt_read_temp + 1'b1;
				end
			else
				begin
					cnt_read_temp <= cnt_read_temp;
				end
		end

	//根据当前空满标志数值推算当前FIFO最后一个数据在哪个位置并读出那个数据
	always @(posedge clk_40MHz or negedge rst_n)
		begin
			if(!rst_n)
				begin
					fifo_data <= 28'b0;
				end
			else if(!empty)
				begin
					case(full_empty_flag)
						//3'b000 : fifo_data = 1'b0;
						2'b01 : fifo_data <= fifo_0;
						3'b10 : fifo_data <= fifo_1;
						default : fifo_data <= 28'b0;
					endcase				
				end
			else
				begin
					fifo_data <= 28'b0;
				end
		end
		
endmodule
