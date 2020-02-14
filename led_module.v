`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/08 21:18:43
// Design Name: 
// Module Name: led_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_module(
    clk,led_out,rst,led0_rgb,led1_rgb,led2_rgb,led3_rgb

    );
   input clk;
   input rst;
    output  [3:0] led_out;// led4  h5  
                          //  led5 j5  
                          //  led6 t9
                          //led7   t10
    output [2:0]led0_rgb;
    output [2:0]led1_rgb;
    output [2:0]led2_rgb;  
    output [2:0]led3_rgb;  
    
    reg [29:0]cnt;
    reg  [3:0]led_out;
    wire clk_25m;
    
    
     clk_wiz_0 inst
     (
    // Clock in ports
     .clk_in1(clk),
     // Clock out ports  
     .clk_out1(),
     .clk_out2(),
     .clk_out3(clk_25m),
     // Status and control signals               
     .locked(locked)            
     );
     wire  [7:0]a,b;
     assign a = 8'd3;
     assign b = 8'd6;
    // wire [15:0]out;
     mul8X8 u_mul(
     .reset_n(!rst),
     .clk(clk_25m),
     .a(a),
     .b(b),
     .out_data(),
     .en(rst) 
     
     );
     
    always @ (posedge clk_25m or negedge rst )
    
    begin
    if(!rst)
        begin 
        cnt<=30'd0;
        end 
    else if (cnt==30'd10_000_000)
     begin 
        cnt<=30'd0;
     end
    else 
        cnt<=cnt+1'b1;
     
    end 
       
    always @ (posedge clk or negedge rst )
    begin 
    if (!rst )
    begin 
    led_out<=4'b1000;
    end 
    else  if (cnt==30'd10_000_000)
    begin 
            if (led_out==4'b0000)
                led_out<=4'b1000;
            else 
                led_out<={1'b0,led_out[3:1]};
    end 
    end 
    
    
    reg [3:0]cnt1;
    reg [2:0]led0_rgb;
    reg [2:0]led1_rgb;
    reg [2:0]led2_rgb;  
    reg [2:0]led3_rgb;  
   
        always @ (posedge clk or negedge rst )
    
    begin
    if(!rst)
        begin 
        cnt1<=4'd0;
        end 
    else if (cnt==36'd10_000_000)
     begin 
        cnt1<=cnt1+1'b1;
     end
    else if (cnt1==4'd6)
        cnt1<=4'd0;
     
    end 
        always @ (posedge clk or negedge rst )
    begin 
    if (!rst )
    begin 
    led0_rgb<=3'b001;
    led1_rgb<=3'b001;
    led2_rgb<=3'b001;
    led3_rgb<=3'b001;
    end 
    else  if (cnt1==4'd6)
    begin 
         if(led0_rgb==3'b111)
                led0_rgb<=3'b001;
         else 
                led0_rgb<=led0_rgb+1'b1;
         if(led1_rgb==3'b111)
                led1_rgb<=3'b001;
         else 
                led1_rgb<=led1_rgb+1'b1;
         if(led2_rgb==3'b111)
                led2_rgb<=3'b001;
         else 
                led2_rgb<=led2_rgb+1'b1;
         if(led3_rgb==3'b111)
                led3_rgb<=3'b001;
         else 
                led3_rgb<=led3_rgb+1'b1;

         
    end 
    end 
endmodule
