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
		spi_write(3'b000, 8'b01000000);
		//配置Dpulse和mask，打开第x双列第y个超级像素第z个单像素dpulse开关
		for(i = 0; i < x; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		spi_write(3'b001, 8'b00000001);
		for(i = 0; i < (4 - x - 1); i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		//把dpulse和mask往上推1次，推到第一个像素点
		spi_write(3'b111, 8'b00000000);
		//把dpulse和mask恢复全0
		for(i = 0; i < 4; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		for(i = 0; i < (y * 8 + z); i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end
		//打开时钟
		spi_write(3'b000, 8'b11000000);
		//模拟TOT
		#200
		//关闭时钟
		spi_write(3'b000, 8'b01000000);
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
		spi_write(3'b010, 8'b10000000);
		#20000;
	end
endtask