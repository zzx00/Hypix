`timescale 1ns/10fs
module tb_digital_top_8_8();
reg clk_40MHz,rst_n,shutter_in,mode_in,spi_sdi,spi_cs,push_clk_in,shake_hands_col_in;
wire [15:0] hit_0_left,hit_0_right,hit_1_left,hit_1_right;
reg [1:0] config_info_in;
wire spi_sdo,route_data_proc;
wire [63:0] config_DAC_0,config_DAC_1,config_DAC_2,config_DAC_3;
reg spi_clk,clk_640MHz;
reg Dpulse;
reg [63:0] hit;
assign hit_0_left=hit[15:0];
assign hit_0_right=hit[31:16];
assign hit_1_left=hit[47:32];
assign hit_1_right=hit[63:48];

digital_top_8_8 inst(
		clk_40MHz,
		//spi_clk,
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

	parameter clk_period = 25;
	parameter spi_clk_period = 25;
	
	always #12.5 clk_40MHz = ~clk_40MHz;
	//always #20 spi_clk = ~spi_clk;
    always #0.78125 clk_640MHz=~clk_640MHz;


    // `include "C:/Users/dell/Desktop/code_4_1_test/TB_all/task/chip_init.v"
    // `include "C:/Users/dell/Desktop/code_4_1_test/TB_all/task/single_pixel_test.v"
    // `include "C:/Users/dell/Desktop/code_4_1_test/TB_all/task/spi_opera.v"

    initial begin
        // clk_640MHz=0;
        // spi_clk=0;
        chip_init;
        // #25
		// hit[0]=1;
		// hit[1]=1;
		// hit[62]=1;
		// hit[63]=1;
		// #75
		// hit[0]=0;
		// #25
		// hit[1]=0;
		// #25
		// hit[62]=0;
		// #25
		// hit[63]=0;
		// #500

        // shutter_in=1'b1;
        // #100;
        // hit[0]=1;
        // #75
        // hit[0]=0;
        // hit[1]=1;
        // #75
        // hit[1]=0;
        // #50
		// hit[62]=1;
		// hit[48]=1;
		// #50
		// hit[62]=0;
		// hit[48]=0;
		// #25
        // shutter_in=1'b0;
		// #10000
		// #100
		// //给一个延迟，不然正确写不进去
        // single_pixel_test(0,0,000);
		// #100
		// single_pixel_test(1,1,111);
		// #100
		// single_pixel_test(3,1,111);
		// #100
		// single_pixel_test(0,1,101);
		// #100
		// single_pixel_test(2,0,110);
		SPI_DAC;

        $stop;
    end


/***********chip init*****************/
task chip_init;
	begin
		clk_40MHz = 1'b1;
        clk_640MHz=1'b1;
		spi_cs = 1'b1;
		spi_sdi = 1'b0;
		rst_n = 1'd0;
		hit = 1'd0;
        spi_clk=1'b1;
		mode_in = 0;
		//hit_0 = 1'b0;
		//hit_1 = 1'b0;
		//hit_2 = 1'b0;
		//hit_3 = 1'b0;
		shutter_in = 1'b0;
		shake_hands_col_in = 1'b1;
		config_info_in = 2'b00;
		push_clk_in =1'b0;
		Dpulse<=0;
		#100
		rst_n = 1'b1;
	end
endtask


task SPI_DAC;
	integer i;
	reg [5:0] DAC_mem_0 [15:0];
	reg [5:0] DAC_mem_1 [15:0];
	reg [5:0] DAC_mem_2 [15:0];
	reg [5:0] DAC_mem_3 [15:0];
	begin
		#100
		$readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\DAC_config/DAC_0.txt",DAC_mem_0);
		$readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\DAC_config/DAC_1.txt",DAC_mem_1);
		$readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\DAC_config/DAC_2.txt",DAC_mem_2);
		$readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\DAC_config/DAC_3.txt",DAC_mem_3);
		#100
		spi_write(3'b000, 8'b11000000);
		for(i=0;i<16;i=i+1) begin
			spi_write(3'b001, {2'b0,DAC_mem_3[i]});
			spi_write(3'b001, {2'b0,DAC_mem_2[i]});
			spi_write(3'b001, {2'b0,DAC_mem_1[i]});
			spi_write(3'b001, {2'b0,DAC_mem_0[i]});
			spi_write(3'b111, 8'b00000000);
			$display("DAC_mem_3_%d :%b",i,DAC_mem_3[i]);
			$display("DAC_mem_2_%d :%b",i,DAC_mem_2[i]);
			$display("DAC_mem_1_%d :%b",i,DAC_mem_1[i]);
			$display("DAC_mem_0_%d :%b",i,DAC_mem_0[i]);
		end
	end
	


endtask





/************single_pixel_test***********/
task single_pixel_test;
	integer i;
	input [1:0] x;
	input y;
	input [2:0] z;
	
	begin
		$display("---single_pixel_test %d_%d_%d---", x, y ,z);
		//关闭时钟，开始配置
		//spi_write(3'b010, 8'b00000000);
		//打开spi控制的shake_hands_col
		#100
		spi_write(3'b000, 8'b11000000);
		//配置Dpulse和mask，打开第x双列第y个超级像素第z个单像素dpulse开关
		if(z!=3'b111 | y!=1'b1) begin
		for(i = 0; i < 4; i = i + 1)
			begin
				spi_write(3'b001, 8'b00111100);
			end
		for(i = 0; i < ((1-y) * 8 + (7-z)); i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end
		for(i = 0; i < 3-x; i = i + 1)
			begin
				spi_write(3'b001, 8'b00111100);
			end
		spi_write(3'b001, 8'b00111101);
		for(i=0;i<x;i=i+1) begin
			spi_write(3'b001, 8'b00111100);
		end
		spi_write(3'b111, 8'b00000000);
		for(i = 0; i < 4; i = i + 1)
			begin
				spi_write(3'b001, 8'b00111100);
			end
		for(i = 0; i < 16-((1-y) * 8 + (7-z))-1; i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end

		end else if(z==3'b111 & y==1'b1) begin
			for(i = 0; i < 3-x; i = i + 1)
				begin
					spi_write(3'b001, 8'b00111100);
				end
			spi_write(3'b001, 8'b00111101);
			for(i=0;i<x;i=i+1) 
				begin
				spi_write(3'b001, 8'b00111100);
				end
			spi_write(3'b111, 8'b00000000);
			for(i = 0; i < 4; i = i + 1)
				begin
					spi_write(3'b001, 8'b00111100);
				end
			for(i = 0; i < 15; i = i + 1)
				begin
					spi_write(3'b111, 8'b00000000);
				end

		end



		// for(i = 0; i < x; i = i + 1)
		// 	begin
		// 		spi_write(3'b001, 8'b00111100);
		// 	end
		// spi_write(3'b001, 8'b00111101);
		// for(i = 0; i < (4 - x - 1); i = i + 1)
		// 	begin
		// 		spi_write(3'b001, 8'b00111100);
		// 	end
		// //把dpulse和mask往上推1次，推到第一个像素点
		// spi_write(3'b111, 8'b00000000);
		// //把dpulse和mask恢复全0
		// for(i = 0; i < 4; i = i + 1)
		// 	begin
		// 		spi_write(3'b001, 8'b00111100);
		// 	end
		// for(i = 0; i < (y * 8 + z); i = i + 1)
		// 	begin
		// 		spi_write(3'b111, 8'b00000000);
		// 	end
		//打开像素复位
		//spi_write(3'b000, 8'b11000000);
		//模拟TOT
		#200
		Dpulse<=1;
		#200
		Dpulse<=0;
		#200
		//打开像素复位
		spi_write(3'b000, 8'b01001000);
		Dpulse<=1;
		#200
		Dpulse<=0;
		#2000
		//spi_write(3'b000, 8'b11001000);
		//dpulse和mask全部给0再往上推一遍，清空像素配置
		for(i = 0; i < 4; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		for(i = 0; i <= 15; i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end
		//打开时钟，读取数据
		//spi_write(3'b000, 8'b11000000);
		#2000;
	end
endtask












/********************spi opera**************************/
task write_clk;
	integer i;
	begin
		spi_clk = 1'b0;
		for(i = 0; i <= 15; i = i + 1)
			begin
				#(spi_clk_period/2)
				spi_clk = ~spi_clk;
				#(spi_clk_period/2)
				spi_clk = ~spi_clk;
			end
	end
endtask

task write_cs;
	integer i;
	begin
		spi_cs = 1'b0;
		for(i = 0; i <= 15; i = i + 1)
			begin
				# spi_clk_period;
			end
		spi_cs = 1'b1;
		#spi_clk_period;
	end
endtask

task write_data;
	input [2:0] index;
	input [7:0] data_in;
	integer i;
	begin
		spi_sdi = 1'b1;
		#spi_clk_period;
		spi_sdi = 1'b0;//write
		#spi_clk_period;
		for(i = 3; i >= 1; i = i - 1)
			begin
				spi_sdi = index[i-1];
				#spi_clk_period;
			end
		spi_sdi = 1'b0;
		#spi_clk_period;
		for(i = 8; i >= 1; i = i - 1)
			begin
				spi_sdi = data_in[i-1];
				#spi_clk_period;
			end
		spi_sdi = 1'b0;
	end
endtask

//datas_syn是不是在读操作时sdo线上的100100
task read_data;
	input [2:0] index;
	output [6:0] data_syn;
	output [7:0] data_sdo;
	reg [6:0] data_syn;
	reg [7:0] data_sdo;
	integer i;
	begin
		spi_sdi = 1'b1;
		#spi_clk_period;
		spi_sdi = 1'b1;//read
		#spi_clk_period;
		for(i = 3; i >= 1; i = i - 1)
			begin
				data_syn[i + 3] = spi_sdo;
				spi_sdi = index[i-1];
				#spi_clk_period;
			end
		spi_sdi = 1'b0;
		for(i = 3; i >= 0; i = i - 1)
			begin
				data_syn[i] = spi_sdo;
				#spi_clk_period;
			end
		for(i = 8; i >= 1; i = i - 1)
			begin
				data_sdo[i-1] = spi_sdo;
				#spi_clk_period;
			end
		spi_sdi = 1'b0;
	end
endtask

task spi_write;
	input [2:0] index;
	input [7:0] data_in;
	
	begin
		fork
			write_clk;
			write_cs;
			write_data(index, data_in);
		join
	end
endtask


task spi_read;
	input [2:0] index;
	output [6:0] data_syn;
	output [7:0] data_sdo;
	
	begin
		fork
			write_clk;
			write_cs;
			read_data(index, data_syn, data_sdo);
		join
	end
	
endtask

endmodule