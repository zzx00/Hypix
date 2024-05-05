module tb_super_pixel_candence (
    clk_40MHz,
    clk_640MHz,
    rst_n,
    rst_n_pixel,
    Dpulse,
    Apulse_en,
    shutter,
    mode,
    TimeStamp,
    hit,
    push_clk,
    //push_data_in,
    //mask_pulse_DAC_config,
    config_info,
    addr_col,
    last_data,
    shake_hands_next

);
    output clk_40MHz;
    output clk_640MHz;
    output rst_n;
    output rst_n_pixel;
    output Dpulse;
    output Apulse_en;
    output shutter;
    output mode;
    output [8:0] TimeStamp;
    output [7:0] hit;
    output push_clk;
    //push_data_in,
    //mask_pulse_DAC_config,
    output [5:0] config_info;
    output addr_col;
    output [25:0] last_data;
    output shake_hands_next;
    
    reg clk_40MHz,clk_640MHz,push_clk,rst_n,rst_n_pixel;
    reg mode,shutter;
    reg Dpulse,Apulse_en;
    reg [7:0] hit;
    reg [8:0] TimeStamp;
    reg [5:0] config_info;
    reg addr_col,shake_hands_next;
    reg [25:0] last_data;




initial begin
        clk_40MHz<=1;
        clk_640MHz<=1;
        push_clk<=1;
        rst_n<=0;
        rst_n_pixel<=0;
        TimeStamp<=9'd0;
        addr_col<=0;
        last_data<=26'd0;
        shake_hands_next<=0;
        hit<=8'd0;
        mode<=0;
        shutter<=0;
        Dpulse<=0;
        Apulse_en<=0;
        #25
        rst_n<=1;
        last_data<=25'd0;
        config_info<=6'b111100;
        shake_hands_next<=1;
        #200
        #50
        fork
                hit_generate;
                clk_640M_generate;
                #75;
        join
        rst_n_pixel<=1'b1;
        #100
        fork
                hit_generate;
                clk_640M_generate;
                #75;
        join
        #100
        fork
                hit_generate_2;
                clk_640M_generate_2;
                #75;
        join
        #100
        shutter<=1;
        hit_generate;
        #50
        hit_generate_2;
        #50
        shutter<=0;
        #500
        rst_n_pixel<=0;
        config_info<= 6'b111101;
        Apulse_en<=1;
        #250
        rst_n_pixel<=1;
        Dpulse<=1;
        #25
        Dpulse<=0;




end

//在时钟下降沿
task clk_640M_generate;
begin
    #12.5
    clk_640MHz<=~clk_640MHz;
    repeat(15) #0.78125 clk_640MHz<=~clk_640MHz;
end
endtask

task hit_generate;
    begin
        #12.5
        hit[0]<=1;
        #50
        hit[0]<=0;
    end
       
endtask


//正好在时钟上升沿
task hit_generate_2;
    begin
        hit[0]<=1;
        #50
        hit[0]<=0;
    end
       
endtask

task clk_640M_generate_2;
begin
    clk_640MHz<=~clk_640MHz;
    repeat(31) #0.78125 clk_640MHz<=~clk_640MHz;
end
endtask


always #25 TimeStamp<=TimeStamp+1;

always #12.5 clk_40MHz<=~clk_40MHz;
always #12.5 push_clk<=~push_clk;//外部输入的配置时钟，现在给40MHz


endmodule