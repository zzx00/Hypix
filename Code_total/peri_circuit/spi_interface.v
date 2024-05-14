//spi通信接口
module spi_interface(
		rst_n					,
		spi_clk					,
		spi_sdi					,//spi主机向从机发送的串行数据
		spi_cs					,//spi片选信号
		read_data				,//依据地址读出的数据
		config_do				,//像素配置模式下移位输出sdo
				
		spi_sdo					,//spi从机向主机发送的串行数据
		data_out				,//输出，存至寄存器堆
		wr_en					,//写使能，每次spi写完8个数据后写使能拉高将这八个数据传输至寄存器堆
		
		index					,//索引号，即对应寄存器地址位
		config_en				,//001号寄存器，即像素配置数据寄存器配置结束后的一个标志信号
		push_clk				//配置时钟
	);

	input rst_n;
    input spi_clk;
    input spi_sdi;
	input spi_cs;
    input [7:0] read_data;
	input config_do;
	
    output spi_sdo;
    output [7:0] data_out;
    output wr_en;
    output [2:0] index;
    output config_en;
    output push_clk;
	
	//spi_fsm_counter为spi数据传输计数器，当前spi设计单次传输16bit数据包对应这4bit位宽
	reg [3:0] spi_fsm_counter;
	reg spi_syn_valid;//spi为外部信号需要同步
	reg spi_packet_valid;//spi数据传输过程标志
	reg wr_flag;//spi读写信号0为写1为读
	reg [2:0] index;
	
	reg [7:0] data_out;
	reg spi_sdo;
    wire wr_en;//当前数据包发送完，可写入寄存器堆的使能信号，此时数据才能真正要存入寄存器堆的数据，传输过程中的数据不完整。
    reg config_en;//配置信息可写入寄存器堆的使能信号，配置信息位于001号寄存器后6位，每次数据包发送结束告知pixel_config完成当前像素双列6bit信息配置
    reg push_clk;
///////////////config_en//////////////////
	always @(posedge spi_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					config_en <= 1'b0;
				end
			else
				begin
					//spi_fsm_counter == 4'b1110时当前数据包传输结束，(index == 3'b001) && (!wr_flag)对应001号寄存器且是写状态时发送config_en
					if((index == 3'b001) && (!wr_flag))
						begin
							if(spi_fsm_counter == 4'b1110)
								begin
									config_en <= 1'b1;
								end
							else
								begin
									config_en <= 1'b0;
								end
						end
					else
						begin
							config_en <= 1'b0; 
						end
				end 
		end
	
	//对应111号寄存器且是写状态时发送push_clk推送配置信息
	always @(posedge spi_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					push_clk <= 1'b0;
				end
			else
				begin
					if((index == 3'b111) && (!wr_flag))
						begin
							if(spi_fsm_counter == 4'b1000 | spi_fsm_counter == 4'b1001)
								begin
									push_clk <= 1'b1;
								end
							else
								begin 
									push_clk <= 1'b0;
								end
						end
					else
						begin
							push_clk <= 1'b0;
						end
				end 
		end

///////////spi fsm/////////////////////////////
	//同步
	always @(posedge spi_clk or posedge spi_cs)
		begin
			if(spi_cs)
				begin
					spi_syn_valid <= 1'b0;
				end
			else
				begin
					if(spi_sdi)
						begin
							spi_syn_valid <= 1'b1;
						end
					else
						begin
							spi_syn_valid <= spi_syn_valid;
						end
				end 
		end

	//在同步信号有效期间内spi_fsm_counter增加，传输数据
	always @(posedge spi_clk or posedge spi_cs)
		begin
			if(spi_cs)
				begin
					spi_fsm_counter <= 4'b0000;
				end
			else
				begin
					if(spi_fsm_counter == 4'b1111)
						begin
							spi_fsm_counter <= 4'b1111;
						end
					else if(spi_syn_valid)
						begin
							spi_fsm_counter <= spi_fsm_counter + 4'b0001;
						end
					else
						begin
							spi_fsm_counter <= spi_fsm_counter;
						end
				end 
		end

	//spi_packet_valid意为当前数据包正在发送
	always @(posedge spi_clk or posedge spi_cs)
		begin
			if(spi_cs)
				begin
					spi_packet_valid <= 1'b0;
				end
			else
				begin
					if((~spi_syn_valid) | (spi_syn_valid & (spi_fsm_counter==4'b1111)))
						begin
							spi_packet_valid <= spi_sdi;
						end
					else
						begin
							spi_packet_valid <= spi_packet_valid;
						end	
				end 
		end


/////////////spi write data path////////////////////////////
	always @(posedge spi_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					wr_flag <= 1'b0;   
					index <= 3'b000;  
					data_out <= 8'b11111111;    
				end
			else
				begin
					if(spi_packet_valid)
						begin
							//根据spi_fsm_counter数值依次传输数据信息，
							//目前地址少，可以看到spi_fsm_counter有一些数值例如100没有操作，地址多了之后每个数值对应传输的数据要有改动
							case(spi_fsm_counter)
								4'b0000:wr_flag <= spi_sdi;
								4'b0001:index[2] <= spi_sdi;
								4'b0010:index[1] <= spi_sdi;
								4'b0011:index[0] <= spi_sdi;
								4'b0101:data_out[7] <= spi_sdi;
								4'b0110:data_out[6] <= spi_sdi;
								4'b0111:data_out[5] <= spi_sdi;
								4'b1000:data_out[4] <= spi_sdi;
								4'b1001:data_out[3] <= spi_sdi;
								4'b1010:data_out[2] <= spi_sdi;
								4'b1011:data_out[1] <= spi_sdi;
								4'b1100:data_out[0] <= spi_sdi;
								default :
									begin
										wr_flag <= wr_flag;   
										index <= index;  
										data_out <= data_out; 
									end 
							endcase
						end 
					else
						begin
							wr_flag <= 1'b0;   
							index <= 1'b0;  
							data_out <= 1'b0; 
						end
				end
		end

//数据包传输过程内，写状态且数据发送完毕可，令wr_en为高电平
assign wr_en = ((spi_fsm_counter == 4'b1110) & (!wr_flag) & spi_packet_valid) ? 1'b1 :1'b0;

//assign spi_sdo_oen = ~spi_cs;
///////////////////spi read data path////////////////////////////////////////////////////
  
always @(posedge spi_clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				spi_sdo <= 1'b0;
			end
		else if(spi_syn_valid)
			begin
				case(spi_fsm_counter)
					4'b0000:spi_sdo <= 1'b0;
					4'b0001:spi_sdo <= 1'b1;
					4'b0010:spi_sdo <= 1'b0;
					4'b0011:spi_sdo <= 1'b0;
					4'b0100:spi_sdo <= 1'b1;
					4'b0101:spi_sdo <= 1'b0; 
					4'b0110:spi_sdo <= 1'b0;
					4'b0111:
						begin
							//在配置过程中读输出，sdo输出pixel config中移位寄存器配置信息的最后1bit数据
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							//非配置情况，从寄存器堆中选取对应数据输出
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[7];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1000:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[6];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1001:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[5];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1010:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[4];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1011:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[3];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1100:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[2];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1101:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[1];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1110:
						begin
							if(config_en)	
								begin
									spi_sdo <= config_do;
								end
							else if(wr_flag & spi_packet_valid )
								begin
									spi_sdo <= read_data[0];
								end
							else
								begin
									spi_sdo <= 1'b0;
								end
						end
					4'b1111:
						begin
							spi_sdo <= 1'b0;
						end
				endcase
			end
	end  

endmodule
