`timescale 1ns/10fs

module single_tb();

reg clk_gating_single_pixel_40MHz,clk_gating_single_pixel_640MHz;
reg hit_pixel,out_flag,shutter,hit_pixel_edge;
reg hit_or;
reg [8:0] TimeStamp;

wire hit_over;
wire [8:0] timestamp_hit;
wire [7:0] ToT_data;
wire [4:0] FTOA;

single_pixel_parallel inst(
    clk_gating_single_pixel_40MHz,
    clk_gating_single_pixel_640MHz,
	hit_pixel,
	out_flag,
	shutter,
	TimeStamp,
	hit_pixel_edge,
	hit_or,

	hit_over,
	ToT_data,
	timestamp_hit,
    FTOA
);

initial  begin
    clk_gating_single_pixel_40MHz<=0;
    clk_gating_single_pixel_640MHz<=0;
    hit_pixel<=0;
    out_flag<=0;
    shutter<=0;
    TimeStamp<=9'd0;
    hit_pixel_edge<=0;
    hit_or<=0;

    #12.5
    out_flag<=1;
    #12.5
    out_flag<=0;
    fork
        //生成40M门控时钟
        clk_40M_generate;
        //生成640M门控时钟
        clk_640M_generate;
        //生成hit_pixel
        hit_pixel_generate;
        //生成hit_pixel_edge
        hit_pixel_edge_generate;
    join
    #50 out_flag<=1;
    #12.5 out_flag<=0;
    #12.5 shutter<=1;
    fork
        //生成40M门控时钟
        hit_pixel_generate_shutter;
        clk_40M_generate_shutter;
        hit_pixel_edge_generate_shutter;
    join
    #50
    fork
        //生成40M门控时钟
        hit_pixel_generate_shutter;
        clk_40M_generate_shutter;
        hit_pixel_edge_generate_shutter;
    join
    #100
    fork
        //生成40M门控时钟
        hit_pixel_generate_shutter;
        clk_40M_generate_shutter;
        hit_pixel_edge_generate_shutter;
    join
    #25
    fork
        //生成40M门控时钟
        hit_pixel_generate_shutter;
        clk_40M_generate_shutter;
        hit_pixel_edge_generate_shutter;
    join
    #5 shutter<=0;
end

task hit_pixel_edge_generate;
    begin
        #25
        hit_pixel_edge<=1;
        #5 hit_pixel_edge<=0;
    end

endtask

task hit_pixel_edge_generate_shutter;
    begin
        hit_pixel_edge<=1;
        #5 hit_pixel_edge<=0;
    end

endtask


task hit_pixel_generate_shutter;
begin
    hit_pixel<=1;
    #50 hit_pixel<=0;
end
endtask

task hit_pixel_generate;
begin
    #25
    hit_pixel<=1;
    #75 hit_pixel<=0;
end
endtask


task clk_40M_generate_shutter;
begin
    clk_gating_single_pixel_40MHz<=~clk_gating_single_pixel_40MHz;
    repeat(3) #12.5 clk_gating_single_pixel_40MHz<=~clk_gating_single_pixel_40MHz;
end
endtask

task clk_40M_generate;
begin
    #25
    #25
    clk_gating_single_pixel_40MHz<=~clk_gating_single_pixel_40MHz;
    repeat(5) #12.5 clk_gating_single_pixel_40MHz<=~clk_gating_single_pixel_40MHz;
end
endtask

task clk_640M_generate;
begin
    #12.5
    clk_gating_single_pixel_640MHz<=~clk_gating_single_pixel_640MHz;
    repeat(15) #0.78125 clk_gating_single_pixel_640MHz<=~clk_gating_single_pixel_640MHz;
end
endtask

always #25 TimeStamp=TimeStamp+1;

endmodule





