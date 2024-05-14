`timescale 1ns/10fs

module tb_top_super_pixel_4();
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


integer handle_7ns;
initial begin
    clk_40MHz=1;
    clk_640MHz=1;
    push_clk=1;
    handle_7ns = $fopen("./test_hit_7ns.txt","w");
        
        fork
            hit_7ns;
            monitor;
        join
    #100
    $fclose(handle_7ns);
    #100
    $stop;

end


task monitor;
        $fmonitor(handle_7ns,"arbiter_data is:%b ,TOA is:%b ,FTOA is:%b ,TOT is:%b .",arbiter_data,arbiter_data[25:17],arbiter_data[16:12],arbiter_data[11:4]);
endtask

task hit_7ns;
    integer j;
    for(j=0;j<25;j=j+1) begin
        if(j==0) begin
            super_pixel_init_1;
            test_hit_7ns(j);
            #(200-j-7);
        end else begin
            super_pixel_init_2;
            test_hit_7ns(j);
            #(200-j-7);
        end
            
            //$fmonitor(handle_16ns,"Offset is:%d ,arbiter_data is:%b ,TOA is:%b ,FTOA is:%b ,TOT is:%b .",j,arbiter_data,arbiter_data[25:17],arbiter_data[16:12],arbiter_data[11:4]);
        end
endtask


task test_hit_7ns;
    input  [4:0] Offset ;
    integer i;
begin
    
    for(i=0;i<Offset;i=i+1) begin
        #1;
    end
    hit[0]=1;
    #7
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
        
        #25
        rst_n=1;
        last_data=26'd0;
        config_info=6'b111100;
        shake_hands_next=1;
        #200
        #50
        rst_n_pixel=1'b1;
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
        
        #25
        rst_n=1;
        last_data=26'd0;
        config_info=6'b111100;
        shake_hands_next=1;
        #200
        #50;
        rst_n_pixel<=1'b1;
    end

endtask



always #25 TimeStamp_b<=TimeStamp_b+1;
always @(TimeStamp_b) begin
    TimeStamp <= {(TimeStamp_b >> 1'b1) ^ TimeStamp_b};
end
always #0.78125 clk_640MHz<=~clk_640MHz;
always #12.5 clk_40MHz<=~clk_40MHz;
always #12.5 push_clk<=~push_clk;//外部输入的配置时钟，现在给40MHz



endmodule