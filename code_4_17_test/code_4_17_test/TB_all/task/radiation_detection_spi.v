task radiation_detection_spi;
	integer i;
	integer x;
	integer y;
	integer z;//x双列，y超级像素，z超级像素内第几个单像素
	
	begin
		shake_hands_col_in = 1'b0;
		$display("------------------------------------------------------------------------------------------------");
		$display("---radiation_detection(spi Dpulse)---");
		//关闭时钟，开始配置 clk_out = {clk_40MHz & mask_pulse_en_temp}，
		//令mask_pulse_en_temp为低，减少配置像素点时产生功耗，防止配置中启动计数器
		//spi_write(3'b000, 8'b00000000);
		//打开spi控制的shake_hands_col
		spi_write(3'b000, 8'b01000000);
		//配置Dpulse和mask
		for(i = 0; i <= 3; i = i + 1)
			begin
				spi_write(3'b001, 8'b00111101);//10101010(Mask)   11111111(Mask & Dpulse)
			end
		//把dpulse和mask往上推
		for(i = 0; i <= 16; i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end
		//打开时钟
		spi_write(3'b000, 8'b11000000);
		//模拟TOT
		#200
		//关闭时钟
		spi_write(3'b000, 8'b01000000);
		//dpulse和mask全部给0再往上推一遍
		for(i = 0; i <= 3; i = i + 1)
			begin
				spi_write(3'b001, 8'b00000000);
			end
		//把dpulse和mask往上推
		for(i = 0; i <= 16; i = i + 1)
			begin
				spi_write(3'b111, 8'b00000000);
			end
		//打开时钟读出数据
		spi_write(3'b000, 8'b11000000);
		#150000;
		/*
		$display("------------------------------------------------------------------------------------------------");
		$display("---radiation_detection(spi single_pixel_test)---");//完整的测试应该每一行每一列都试一遍
		single_pixel_test(0, 0, 1);
		*/
		/*
		for(x = 0; x <= 31; x = x + 1)
			for(y = 0; y <= 15; y = y + 1)
				for(z = 0; z <= 7; z = z + 1)
					begin
						single_pixel_test(x, y, z);
					end
		*/
		/*
		$display("------------------------------------------------------------------------------------------------");
		$display("---all_hit(spi)---");
		hit[1023:0]    = 1024'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
		hit[2047:1024] = 1024'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
		hit[3071:2048] = 1024'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
		hit[4095:3072] = 1024'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
		#200
		hit[1023:0]    = 1'b0;
		hit[2047:1024] = 1'b0;
		hit[3071:2048] = 1'b0;
		hit[4095:3072] = 1'b0;
		#150000
		$display("---hit_16---");
		#30
		hit = 16'b1111111111111111;
		#30
		hit = 1'b0;
		#30
		hit[1] = 1'b0;
		#30
		hit = 1'b0;
		#200
		hit = 1'b0;
		#200
		hit = 1'b0;
		#200
		hit = 1'b0;
		#200
		hit = 1'b0;
		#800
		hit = 1'b0;
		#20
		hit = 16'd0;
		#10000
		$display("---hit_coverage---");
		hit    = 64'b00000001;
		#2000
		hit = 64'b11100101;
		#30
		hit = 64'b00000001;
		#203
		hit = 64'b00000101;
		#401
		hit = 64'b01010101;
		#200
		hit = 64'b11110101;
		#2009
		hit = 64'b00000101;
		#200
		hit = 64'b01001101;
		#2321
		hit = 64'b00000000;
		#465
		hit = 64'b00000000;
		#4
		hit = 64'b00000000;
		#67
		hit = 64'b00000000;
		#10000;
		
	end
	*/
endtask