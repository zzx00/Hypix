`timescale 1ns/10fs

module tb_column_super_pixel();

reg clk_40MHz,clk_640MHz,push_clk,rst_n,rst_n_pixel;
reg mode,shutter;
reg Dpulse,Apulse_en;
reg [8:0] TimeStamp;
reg [15:0] hit;
reg [5:0] config_info;
reg shake_hands_col;
wire [63:0] config_DAC;
wire [25:0] col_data;
//wire hit_or_column;

top_column_super_pixel inst(
        clk_40MHz, 
        clk_640MHz,
        rst_n,
        rst_n_pixel,
        Dpulse,
        Apulse_en,
        hit,
        push_clk,
        TimeStamp,
        shutter,
        mode,
        //push_data,
        //mask_pulse_DAC_config,
        config_info,
        shake_hands_col,
        config_DAC,
        col_data
);
integer i;

initial begin
        clk_40MHz<=1;
        clk_640MHz<=0;
        push_clk<=0;
        rst_n<=0;
        rst_n_pixel<=0;
        TimeStamp<=9'd0;
        hit<=8'd0;
        mode<=0;
        shutter<=0;
        Dpulse<=1;
        Apulse_en<=1;
                #25
        rst_n<=1;
        config_info<=6'b111100;
        shake_hands_col<=1;
                #(25*16)
        #50
        Dpulse<=0;
        rst_n_pixel<=1;
        for(i=0;i<16;i=i+1)
        begin
                //产生击中信号
                hit_generate;
                #75;
                
            
        end
end


    task hit_generate;
    begin
        hit[i]<=1;
        #50
        hit[i]<=0;
    end
       
    endtask




always #25 TimeStamp<=TimeStamp+1;

always #12.5 clk_40MHz<=~clk_40MHz;
always #0.78125 clk_640MHz<=~clk_640MHz;
always #12.5 push_clk<=~push_clk;//外部输入的配置时钟，现在给40MHz

endmodule