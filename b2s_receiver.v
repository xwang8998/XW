/******************************************************************************************
Author:          Bob Liu
E-mail�?         <a target="_blank" href="mailto:shuangfeiyanworld@163.com">shuangfeiyanworld@163.com</a>
File Name:      b2s_receiver.v
Function:       b2s接收�?, 默认接收32bit数据，接收数据宽度请与发送端发�?�数据宽度保持一�?
Version:         2013-5-13 v1.0
********************************************************************************************/
module        b2s_receiver
(
        clk,                //时钟基准,不限频率大小,但必须与发�?�端�?�?
        mclk,
        b2s_din,        //b2s发�?�端发�?�过来的信号
		finish,
		
        dout              //b2s接收端解码出的数�?
);
parameter         WIDTH=64;        //★设定b2s接收数据位数, 默认接收32bit数据，接收数据宽度请与发送端发�?�数据宽度保持一�?

input                                        clk;
input                                        mclk;
input                                        b2s_din;
output        [WIDTH-1:0]         dout;
output      reg  finish;
//==================================================
//b2s_din信号边沿�?�?
//==================================================
reg        [1:0]        b2s_din_edge=2'b01;
always @ (posedge clk)
begin
        b2s_din_edge[0] <= b2s_din;
        b2s_din_edge[1] <= b2s_din_edge[0];
end
// BUFG BUFG_inst (  
// .O(clk_o), //ʱ�ӻ�������ź�  
// .I(clk) // /ʱ�ӻ��������ź�  
// );  
 debug_receiber u_debug_receiber(
.clk(mclk),


.probe0(state0),
.probe1(state),
.probe2(time_cnt),
.probe3(b2s_din)
);
//==================================================
//time_cnt -- 存储b2c_din信号下降沿及其最近的下一个上升沿之间的时�?
//==================================================
reg        [1:0]         state0;
reg        [7:0]                time_cnt_r;
always @ (posedge clk)
begin
        case(state0)
        0:        begin
                        time_cnt_r<=8'b0;
                        state0<=2'd1;
                end
        1:        begin
                        if(b2s_din_edge==2'b10)
                                state0<=2'd2;
                        else
                                state0<=state0;
                end
        2:        begin
                        if(b2s_din_edge==2'b01)
                                begin
                                        state0<=2'd0;
                                end
                        else 
                                time_cnt_r<=time_cnt_r+1'b1;
                end
        default:        begin
                                        time_cnt_r<=8'b0;
                                        state0<=2'd0;
                            end
        endcase
end

wire [9:0]        time_cnt;
assign        time_cnt=(b2s_din_edge==2'b01)?time_cnt_r:'b0;        //当b2s_din上升沿瞬�?,读取time_cnt_r的�??

//==================================================
//b2s解码时序
//==================================================
reg        [2:0]                        state;
reg        [7:0]                        count;        //★与接收数据位数保持�?�?(如接�?32bit数据�?,count宽度�?5;接收8bit�?,count宽度�?4)
reg        [WIDTH-1:0]           dout_r;
always @ (posedge clk)
begin
        case(state)
        0:        begin
                        count<=WIDTH;
                        if((time_cnt>230)&&(time_cnt<250))        //判断起始信号
                                state<=3'd1;
                        else
                                state<=state;
                end
        1:        begin
                        if((time_cnt>10)&&(time_cnt<25))          //判断接收到的位是否为1
                                begin
                                        dout_r[WIDTH-1]<=1'b1;
                                        state<=3'd2;
                                end
                        else if((time_cnt>50)&&(time_cnt<145)) //判断接收到的位是否为0
                                begin
                                        dout_r[WIDTH-1]<=1'b0;
                                        state<=3'd2;
                                end
                        else
                                begin
                                        state<=state;
                                end
                end
        2:        begin
                        count<=count-1'b1;        //每读取一个bit,count计数�?1
                        state<=3'd3;
                end
        3:        if(count==0)                        //数据读取完毕,返回并继续下�?组数据的读取
                        begin
                                state<=3'd0;
								finish <=1'b1;
                        end
                else	
						begin
                        state<=3'd4;                        //数据未读取完�?,则进行移�?
						finish <=1'b0;
						end
        4:        begin
                        dout_r<=(dout_r>>1); //数据右移1�?
                        state<=3'd1;
                end
        default:        begin
                                        state<=3'd0;
                                        count<=WIDTH;
                            end
        endcase
end

assign        dout=(count==0)?dout_r:dout;        //每当�?组数据读取完�?,则更新一次dout的�??

endmodule        