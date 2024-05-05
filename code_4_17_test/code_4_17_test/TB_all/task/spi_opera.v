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