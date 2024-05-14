//spi接口与寄存器堆的连接模块，各信号含义在两个模块中，不做赘述
module spi_data_trans(
		rst_n,
		spi_clk,
		spi_sdi,
		spi_cs,
		config_do,
		route_data_proc,
		
		spi_sdo,
		config_en,
		push_clk,
		shutter,
		mode,
		rst_n_pixel,
		Apulse_en,
		cfig_data,
		shake_hands_col
	);

	input rst_n;
    input spi_clk;
    input spi_sdi;
	input spi_cs;
	input config_do;
	input [27:0] route_data_proc;
	
    output spi_sdo;
    output config_en;
    output push_clk;
	output shutter;
	output mode;
	output [5:0] cfig_data;
	output shake_hands_col;
	output rst_n_pixel;
	output Apulse_en;
	wire rst_n_pixel;
	wire rst_n_pixel_temp;
	assign rst_n_pixel=rst_n & rst_n_pixel_temp;
	
	wire [7:0] read_data;
	wire [7:0] data_out;
	wire wr_en;
	wire [2:0] index;
	
	spi_interface u_spi_interface(
		.rst_n(rst_n),
		.spi_clk(spi_clk),
		.spi_sdi(spi_sdi),
		.spi_cs(spi_cs),
		.read_data(read_data),
		.config_do(config_do),
		
		.spi_sdo(spi_sdo),
		.data_out(data_out),
		.wr_en(wr_en),
		.index(index),
		.config_en(config_en),
		.push_clk(push_clk)
	);
	
	ctrl_registers u_ctrl_registers(
		.rst_n(rst_n),
		.spi_clk(spi_clk),
		.spi_if_dout(data_out),
		.spi_if_index(index),
		.spi_if_wr_en(wr_en),
		.route_data_proc(route_data_proc),
		
		.read_data(read_data),
		.shake_hands_col(shake_hands_col),
		.shutter(shutter),
		.mode(mode),
		.rst_n_pixel(rst_n_pixel_temp),
		.Apulse_en(Apulse_en),
		.cfig_data(cfig_data)
	);

endmodule