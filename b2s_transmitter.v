/******************************************************************************************
Author:        Bob Liu
E-mail：       <a target="_blank" href="mailto:shuangfeiyanworld@163.com">shuangfeiyanworld@163.com</a>
File Name:    b2s_transmitter.v
Function:     b2s发送端, 默认发送32bit数据，数据宽度可更改
Version:       2013-5-13 v1.0
********************************************************************************************/
module        b2s_transmitter
(
        clk,                        //时钟基准,不限频率大小,但必须与接收端一致
        din,                        //待发送数据
		inout_en,
		finish,
		count_r,
        b2s_dout              //b2s数据输出端口
);
parameter        WIDTH=32;        //★设定b2s发送数据的位宽，可根据需要进行更改
parameter        RWIDTH=64;  
parameter        RSTH=399; 
parameter        RSTL=1279; 
parameter        CUT_WIDTH=14;
input                                    clk;
input        [WIDTH-1:0]       din;
output                                 b2s_dout;
output   reg inout_en;
output   reg finish;
output   count_r;
//==============================================================
//b2s数据发送时序
//==============================================================
reg                         b2s_dout_r;
reg        [5:0]         state;
reg        [CUT_WIDTH-1:0]         cnt;
reg		 [23:0]			 cnt1;	
reg       [7:0]           count_r;
reg        [5:0]         count;        //★与发送数据位宽保持一致(如发送32bit数据时,count宽度为5;发送8bit时,count宽度为4)




always @ (posedge clk)
begin
        case(state)
//初始化
        0:        begin
                        count<=6'b0;
                        b2s_dout_r<=1'b1;
                        if(cnt==19)                //b2s_dout_r高电平持续20个时钟
                                begin
                                        state<=6'd1;
                                        cnt<=10'b0;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end

//开始信号时序
        1:        begin
                        b2s_dout_r<=1'b0;
                        if(cnt==19)                //b2s_dout_r低电平持续20个时钟
                                begin
                                        state<=6'd2;
                                        cnt<=10'b0;
                                end
                        else
                                begin
                                        cnt<=cnt+1;
                                end
                end
        2:        begin
						
                        b2s_dout_r<=1'b1;
						
                        if(cnt==19)                //b2s_dout_r高电平持续20个时钟
                                begin
                                        cnt<=10'b0;
                                        state<=6'd3;
                                end
                        else
                                begin
                                        cnt<=cnt+1;
                                end
                end

//待发送数据的逻辑电平判断
        3:        begin
						
                        if(din[count]==1)
                                state<=6'd4;
                        else
                                state<=6'd8;
                end

//逻辑1的发送时序
        4:        begin
                        b2s_dout_r<=1'b0;
                        if(cnt==17)                //b2s_dout_r低电平持续10个时钟
                                begin
                                        cnt<=10'b0;
                                        state<=6'd5;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end
        5:        begin
                        b2s_dout_r<=1'b1;
                        if(cnt==148)                //b2s_dout_r高电平持续30个时钟
                                begin
                                        cnt<=10'b0;
                                        state<=6'd6;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end

//逻辑0的发送时序
        8:        begin
                        b2s_dout_r<=1'b0;
                        if(cnt==135)                //b2s_dout_r低电平持续30个时钟
                                begin
                                        cnt<=10'b0;
                                        state<=6'd9;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end
        9:        begin
                        b2s_dout_r<=1'b1;
                        if(cnt==30)                //b2s_dout_r高电平持续10个时钟
                                begin
                                        cnt<=10'b0;
                                        state<=6'd6;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end

//统计已发送数据位数
        6:        begin
                        count<=count+1'b1;
						//if(count==WIDTH)
						//b2s_dout_r<=1'b0;
                        state<=6'd7;
                end
        7:        begin
                        if(count==WIDTH)        //当一组数据所有位发送完毕,返回并继续下一次发送
                                begin
										
                                        b2s_dout_r<=1'b0;
										finish <= 1'b1;
										
										if(cnt==16)begin
										inout_en <= 1'b1;
										cnt<=10'b0;
										//count_r <= count_r + 1'b1;
										state<=6'd15;
										end
                                        //else if(cnt1==9999 )        //b2s_dout_r高电平持续1000个时钟
                                        //        begin
                                        //                cnt1<=24'b0;
                                        //                state<=6'd10;
										//				inout_en <= 1'b0;
										//				finish <= 1'b0;
										//				count <= 6'b0;
                                        //        end
                                        else
                                                begin
                                                //        cnt1<=cnt1+1;
														cnt<=cnt+1;
                                                end
                                end
                        else                                //当一组数据未发送完毕,则继续此组下一位数据的发送
                                state<=6'd3;
                end
		15:			begin
						b2s_dout_r<=1'b1;
						inout_en <= 1'b1;
						if(cnt == 149)
							begin 
								inout_en <= 1'b0;
								//b2s_dout_r<=1'b0;
								state<=6'd16;
								cnt<=10'b0;
								count_r <= count_r + 1'b1;
							
						// if(count_r == 64)	
								// begin 
								// count_r <= 8'b0;
								// state<=6'd10;
								// finish <= 1'b0;
								// count <= 6'b0;
								// end
						
						
									
							end
						else
                             begin
                                count_r <= count_r;
								cnt<=cnt+1;
                            end	
	
	
					end
		16:        begin
					case(count_r)	
					1,2,3,4,5,6,7,9,10,11,12,13,14,15,17,18,19,20,21,22,23,25,26,27,28,29,30,31,33,34,35,36,37,38,39,41,42,43,44,45,
					46,47,49,50,51,52,53,54,55,57,58,59,60,61,62,63:begin state<=6'd7;  end 
					0,8,16,24,32,40,48,56:begin
                        inout_en <= 1'b0;
                        b2s_dout_r<=1'b1;
                        if(cnt==999)                //b2s_dout_r高电平持续20个时钟
                                begin
                                        state<=6'd7;
                                        cnt<=10'b0;
										
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end		
					64: begin 
								count_r <= 8'b0;
								state<=6'd10;
								finish <= 1'b0;
								count <= 6'b0;
						end
					default  begin 
							count_r <= 0;
					end
				endcase
					end
		10:        begin
                        
                        b2s_dout_r<=1'b1;
                        if(cnt==999)                //b2s_dout_r高电平持续20个时钟
                                begin
                                        state<=6'd11;
                                        cnt<=10'b0;
										inout_en <= 1'b0;
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end		
        11: 		begin 
					b2s_dout_r<=1'b0;
					
					
					if(cnt==RSTL )        //b2s_dout_r低  500uS
                                                begin
                                                        cnt<=10'b0;
                                                        state<=6'd12;
														
                                                end
                                        else
                                                begin
                                                        cnt<=cnt+1;
                                                end
				end
		12:        begin
                        
                        b2s_dout_r<=1'b1;
						inout_en <= 1'b1;
                        if(cnt==69)                //b2s_dout_r高  35uS   放开1W控制权
                                begin
                                        state<=6'd13;
                                        cnt<=10'b0;
										
                                end
                        else
                                begin
                                        cnt<=cnt+1'b1;
                                end
                end				
		13:		begin
					b2s_dout_r<=1'b1;
					inout_en <= 1'b1;
					//if(cnt==RSTH )        //等待加密IC返回reset 拉低b2s_dout_r  200uS
					if(cnt1==399 )
                                                begin
                                                        cnt1<=24'b0;
                                                        state<=6'd14;
														b2s_dout_r<=1'b1;
														inout_en <= 1'b0;
                                                end
                                        else
                                                begin
                                                        cnt1<=cnt1+1;
                                                end
				end
		14:		begin
					b2s_dout_r<=1'b1;
					inout_en <= 1'b0;
					if(cnt==599 )        // 得到1 W 控制权，b2s_dout_r高  300uS  
                                                begin
                                                        cnt<=10'b0;
                                                        state<=6'd3;
														
														
                                                end
                                        else
                                                begin
                                                        cnt<=cnt+1;
                                                end
				end		
//default值设定
        default:        begin
                                        state<=6'd10;
                                        cnt<=10'b0;
										cnt1<=10'b0;
                                        count<=6'd0;
										inout_en <= 1'b0;
										finish <= 1'b0;
										count_r <= 8'b0;
                           end
        endcase
end

assign        b2s_dout=b2s_dout_r;

endmodule        