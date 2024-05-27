//给出特定的模拟的TOA和TOT，得到数字的TOA和TOT
//批量从一个文件中得到TOA，从连一个文件中得到TOT

`timescale 100ps/10fs

module tb_top_super_pixel_toa_tot();
reg clk_40MHz,clk_640MHz,push_clk,rst_n,rst_n_pixel;
reg mode,shutter;
reg Dpulse,Apulse_en;
reg [7:0] hit;
reg [8:0] TimeStamp_b;
reg [8:0] TimeStamp;
reg [5:0] config_info;
reg addr_col,shake_hands_next;
reg [25:0] last_data;

wire [5:0] next_config_info;
wire [25:0] arbiter_data;
wire shake_hands_last;
wire [7:0] Apulse_en_super_pixel;
wire [3:0] config_DAC_0,config_DAC_1,config_DAC_2,config_DAC_3,config_DAC_4,config_DAC_5,config_DAC_6,config_DAC_7;
top_single_super_pixel inst(
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
		shake_hands_next,
		
		//push_data_out,
		next_config_info,
		shake_hands_last,
		config_DAC_0,
		config_DAC_1,
		config_DAC_2,
		config_DAC_3,
		config_DAC_4,
		config_DAC_5,
		config_DAC_6,
		config_DAC_7,
		Apulse_en_super_pixel,
		arbiter_data
);


integer handle_hit;

reg [16:0] hit_now_toa [57:0];
reg [16:0] hit_now_tot [57:0];

reg [4:0] FTOA_temp1 [31:0];
reg [4:0] FTOA_temp2 [31:0];
reg [7:0] ToT_temp1 [255:0];
reg [7:0] ToT_temp2 [255:0];
reg [8:0] TimeStamp_temp1 [512:0];
reg [8:0] TimeStamp_temp2 [512:0];
integer temp1;
integer num;
initial begin
    //数据转换
    $readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\TB_all\\LFSR_5bit.txt",FTOA_temp1,0,30);
    $readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\TB_all\\LFSR_8bit.txt",ToT_temp1,0,254);
    $readmemb("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\TB_all\\Timestamp.txt",TimeStamp_temp1,0,511);
    for(temp1=0;temp1<31;temp1=temp1+1) begin
        FTOA_temp2[FTOA_temp1[temp1]]=temp1;
    end
    for(temp1=0;temp1<255;temp1=temp1+1) begin
        ToT_temp2[ToT_temp1[temp1]]=temp1;
    end
    for(temp1=0;temp1<512;temp1=temp1+1) begin
        TimeStamp_temp2[TimeStamp_temp1[temp1]]=temp1;
    end

    //读取击中数据
    //读toa
    handle_hit=$fopen("C:\\Users\\dell\\Desktop\\code_4_17_test\\hit_toa.txt","r");
    for(temp1=0;temp1<58;temp1=temp1+1) begin
        $fscanf(handle_hit,"%d",hit_now_toa[temp1]);
    end
    for(temp1=0;temp1<58;temp1=temp1+1) begin
        $display("toa:%d",hit_now_toa[temp1]);
    end
    $fclose(handle_hit);
    //读tot
    handle_hit=$fopen("C:\\Users\\dell\\Desktop\\code_4_17_test\\hit_tot.txt","r");
    for(temp1=0;temp1<58;temp1=temp1+1) begin
        $fscanf(handle_hit,"%d",hit_now_tot[temp1]);
    end
    for(temp1=0;temp1<58;temp1=temp1+1) begin
        $display("tot:%d",hit_now_tot[temp1]);
    end
    $fclose(handle_hit);


    //打开记录数据的
    handle_hit = $fopen("C:\\Users\\dell\\Desktop\\code_4_17_test\\code_4_17_test\\code_4_17_test\\front\\TB_4_1\\test_hit_total/test_hit_toa_tot.txt","w");
    //一边监控arbiter_data的值，一边进行仿真
    

    //设置初始值
    clk_40MHz=1;
    clk_640MHz=1;
    push_clk=1;
    //循环测试每个hit的情况
    fork
        hit_total;
        monitor;
    join
    #1000
    $fclose(handle_hit);
    #1000
    $stop;

end


task hit_total;
    for(num=0;num<58;num=num+1) begin
        hit_input_ns(hit_now_toa[num],hit_now_tot[num]);
    end

endtask


task monitor;
        //数据分别是，temp1，TOA,TOT,arbiter_data,TOA,FTOA,TOT,对应的十进制TOA、FTOA、TOT,对应的到达时间，对应的长度
        $fmonitor(handle_hit,"%d %d %d %b %b %b %b %d %d %d %f %d",num,hit_now_toa[num],hit_now_tot[num],arbiter_data,arbiter_data[25:17],arbiter_data[16:12],arbiter_data[11:4],TimeStamp_temp2[arbiter_data[25:17]],FTOA_temp2[arbiter_data[16:12]],ToT_temp2[arbiter_data[11:4]],(TimeStamp_temp2[arbiter_data[25:17]]-1)*25-FTOA_temp2[arbiter_data[16:12]]*1.5625,ToT_temp2[arbiter_data[11:4]]*25);
endtask


task hit_input_ns;
    input [16:0] hit_temp_toa;
    input [16:0] hit_temp_tot;
    begin
        if(num==0) begin
            super_pixel_init_1;
            test_hit(hit_temp_toa,hit_temp_tot);
            #(60000-hit_temp_toa-hit_temp_tot);
        end else begin
            super_pixel_init_2;
            test_hit(hit_temp_toa,hit_temp_tot);
            #(60000-hit_temp_toa-hit_temp_tot);
        end
    end
endtask


task test_hit;
    input [16:0] hit_temp_toa;
    integer i;
    input [16:0] hit_temp_tot;
begin
    for(i=0;i<hit_temp_toa;i=i+1) begin
        #1;
    end
    hit[0]=1;
    #hit_temp_tot
    hit[0]=0;
end
endtask


task super_pixel_init_1;
    begin
        rst_n=0;
        rst_n_pixel=0;
        TimeStamp_b=9'd0;
        addr_col=0;
        last_data=26'd0;
        shake_hands_next=0;
        hit=8'd0;
        mode=0;
        shutter=0;
        Dpulse=0;
        Apulse_en=0;
        config_info=6'b111100;
        
        #250
        rst_n=1;
        rst_n_pixel=1'b1;
        shake_hands_next=1;
    end

endtask

task super_pixel_init_2;
    begin
        rst_n=0;
        rst_n_pixel=0;
        TimeStamp_b=9'b111111111;
        addr_col=0;
        last_data=26'd0;
        shake_hands_next=0;
        hit=8'd0;
        mode=0;
        shutter=0;
        Dpulse=0;
        Apulse_en=0;
        config_info=6'b111100;
        
        #250
        rst_n=1;
        rst_n_pixel=1'b1;
        shake_hands_next=1;
    end

endtask



always #250 TimeStamp_b<=TimeStamp_b+1;
always @(TimeStamp_b) begin
    TimeStamp <= {(TimeStamp_b >> 1'b1) ^ TimeStamp_b};
end
always #7.8125 clk_640MHz<=~clk_640MHz;
always #125 clk_40MHz<=~clk_40MHz;
always #125 push_clk<=~push_clk;//外部输入的配置时钟，现在给40MHz



endmodule