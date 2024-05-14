//寄存器堆，由SPI进行配置
//改了点，往下翻看看
module ctrl_registers(
		rst_n					,
		spi_clk					,//spi配置时钟
		spi_if_dout				,//spi配置数据
		spi_if_index			,//spi配置地址
		spi_if_wr_en			,//spi写使能，每次spi写完8个数据后写使能拉高将这八个数据传输至寄存器堆
		route_data_proc			,//输出数据，用于测试观察
				
		read_data				,//数据通过sdo信号线读出的数据
		shake_hands_col			,//像素阵列数据传输使能
		shutter					,
		mode					,
		rst_n_pixel				,//像素复位信号,低电位有效
		Apulse_en				,
		cfig_data				//像素内部配置数据		
	);
	
	input rst_n;
	input spi_clk;
	input [7:0] spi_if_dout;
	input [2:0] spi_if_index;
	input spi_if_wr_en;
	input [27:0] route_data_proc;
	
	output [7:0] read_data;
	output shake_hands_col;
	output shutter;
	output mode;
	output rst_n_pixel;
	output Apulse_en;
	output [5:0] cfig_data;
	
	reg [7:0] read_data;
	reg shake_hands_col;
	reg shutter;
	reg mode;
	reg rst_n_pixel;
	reg [5:0] cfig_data;
	reg Apulse_en;
	
	always @(posedge spi_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					cfig_data <= 6'b00_0000;
					shake_hands_col <= 1'b0;
					shutter <= 1'b0;
					mode <= 1'b0;
					rst_n_pixel<=1'b1;
					Apulse_en<=1'b0;
				end
			else
				begin
					case(spi_if_index)
						3'b000:
							begin
								if(spi_if_wr_en) 
									begin
										Apulse_en <= spi_if_dout[7];
										shake_hands_col <= spi_if_dout[6];
										shutter <= spi_if_dout[5];
										mode <= spi_if_dout[4];
										rst_n_pixel<= spi_if_dout[3];
										
									end
								else
									begin
										shake_hands_col <= shake_hands_col;
										shutter <= shutter;
										mode <= mode;
										rst_n_pixel<=rst_n_pixel;
										Apulse_en <= Apulse_en;
									end
							end
						3'b001:
							begin
								if(spi_if_wr_en)
									begin
										cfig_data <= spi_if_dout[5:0];
									end
								else
									begin
										cfig_data <= cfig_data;
									end
							end
						default://这里补了后面三个，不知道为啥原代码里不写这三个
							begin
								cfig_data <= cfig_data;
                                shake_hands_col <= shake_hands_col;
								shutter <= shutter;
								mode <= mode;
								rst_n_pixel <= rst_n_pixel;
								Apulse_en <= Apulse_en;
							end
					endcase
				end
		end
	
	always @(spi_if_index   or shake_hands_col or shutter or cfig_data  or route_data_proc or mode or Apulse_en or rst_n_pixel)
		begin
			case(spi_if_index)
				3'b000 : read_data = {Apulse_en, shake_hands_col, shutter, mode ,rst_n_pixel, 1'b0, 1'b0, 1'b0};
				3'b001 : read_data = {1'b0,1'b0,cfig_data};
				3'b010 : read_data = {route_data_proc[7:0]};
				3'b011 : read_data = {route_data_proc[15:8]};
				3'b100 : read_data = route_data_proc[23:16];
				3'b101 : read_data = {4'b0, route_data_proc[27:24]};
				3'b110 : read_data = 8'b0;
				3'b111 : read_data = 8'b0;
				default : read_data = 8'b0;
			endcase
		end
		
endmodule