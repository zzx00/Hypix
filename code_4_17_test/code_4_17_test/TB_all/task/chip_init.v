task chip_init;
	begin
		clk_40MHz = 1'b1;
		spi_cs = 1'b1;
		spi_sdi = 1'b0;
		rst_n = 1'd0;
		hit = 1'd0;
		mode_in = 0;
		//hit_0 = 1'b0;
		//hit_1 = 1'b0;
		//hit_2 = 1'b0;
		//hit_3 = 1'b0;
		shutter_in = 1'b0;
		shake_hands_col_in = 1'b1;
		config_info_in = 2'b00;
		push_clk_in =1'b0;
		#100
		rst_n = 1'b1;
	end
endtask