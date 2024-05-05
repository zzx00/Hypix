task single_pixel_test;
	integer i;
	input [1:0] x;//4个双列
	input  y;//2个超级像素
	input [2:0] z;
	
	begin
		$display("---single_pixel_test %d_%d_%d---", x, y ,z);
		//关闭时钟，开始配置
		//spi_write(3'b010, 8'b00000000);
		//打开spi控制的shake_hands_col
		spi_write(3'b000, 8'b01000000);
		//配置Dpulse和mask，打开第x双列第y个超级像素第z个单像素dpulse开关
		for(i = 0; i < (x/4); i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		case(x%4)
			2'b00 : spi_write(3'b001, 8'b01000000);
			2'b01 : spi_write(3'b001, 8'b00010000);
			2'b10 : spi_write(3'b001, 8'b00000100);
			2'b11 : spi_write(3'b001, 8'b00000001);
		endcase
		for(i = 0; i < (8 - (x/4) - 1); i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		//把dpulse和mask往上推1次，推到第一个像素点
		spi_write(3'b100, 8'b00000000);
		//把dpulse和mask恢复全0
		for(i = 0; i < 8; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		for(i = 0; i < (y * 8 + z); i = i + 1)
			begin
				spi_write(3'b100, 8'b00000000);
			end
		//打开时钟
		spi_write(3'b010, 8'b10000000);
		//模拟TOT
		#200
		//关闭时钟
		spi_write(3'b010, 8'b00000000);
		//dpulse和mask全部给0再往上推一遍，清空像素配置
		for(i = 0; i < 8; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		for(i = 0; i <= 127; i = i + 1)
			begin
				spi_write(3'b100, 8'b00000000);
			end
		//打开时钟，读取数据
		spi_write(3'b010, 8'b10000000);
		#20000;
	end
endtask