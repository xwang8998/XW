/*-----------------------------------------------------------------------

Date                :        2017-09-028
Description            :        Design for uart_tx_driver.

-----------------------------------------------------------------------*/

module uart_tx_driver
(
    //global clock
    input                    clk            ,        //system clock
    input                    rst_n        ,         //sync reset
    
    //uart interface
    output    reg                uart_tx        ,

    //user interface
    input            [1:0]    bps_select    ,        //波特率�?�择
    input            [7:0]    uart_data    ,        
    input                    data_en        ,        //发�?�数据使�?
    output    reg                uart_tx_end ,
	output    reg  txfifo_clk
); 


//--------------------------------
//Funtion :    参数定义
                        //24m  115200  38.17k
parameter            BPS_4800    =    14'd5000    ,//24m/4800
                    BPS_9600    =    14'd2500    ,//104uS
                    BPS_115200    =    14'd1250        ;//8.8uS

reg            [13:0]        cnt_bps_clk                ;
reg            [13:0]        bps                        ;
reg                        bps_clk_en                ;    //bps使能时钟
reg            [3:0]        bps_cnt                    ;
wire        [13:0]        BPS_CLK_V = bps >> 1    ;
//--------------------------------
//Funtion :    波特率�?�择          

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        bps <= 1'd0;
    else if(bps_select == 2'd0)
        bps <= BPS_115200;
    else if(bps_select == 2'd1)
        bps <= BPS_9600;
    else
        bps <= BPS_4800;
end

//--------------------------------
//Funtion :    波特率计�?

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_bps_clk <= 1'd0;
    else if(cnt_bps_clk >= bps - 1 && data_en == 1'b0)
        cnt_bps_clk <= 1'd0;
    else
        cnt_bps_clk <= cnt_bps_clk + 1'd1;
end
 
//--------------------------------
//Funtion :    波特率使能时�?

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        bps_clk_en <= 1'd0;
    else if(cnt_bps_clk == BPS_CLK_V - 1)
        bps_clk_en <= 1'd1;
    else
        bps_clk_en <= 1'd0;
end

//----------1----------------------
//Funtion :    波特率帧计数

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        bps_cnt <= 1'd0;
    else if(bps_cnt == 11)
        bps_cnt <= 1'd0;
    else if(bps_clk_en)
        bps_cnt <= bps_cnt + 1'd1;
end

//--------------------------------
//Funtion :    uart_tx_end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        uart_tx_end <= 1'd0;
    else if(bps_cnt == 11)
        uart_tx_end <= 1'd1;
    else
        uart_tx_end <= 1'd0;
end
//dubug1 u_dubug1(
//.clk(clk),
//
//
//.probe0(rst_n),
//.probe1(uart_tx),
//.probe2({4'b0,bps_cnt}),
//.probe3({4'b0,bps_cnt})
//);
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        txfifo_clk <= 1'd0;
    else if(bps_cnt == 10)
        txfifo_clk <= 1'd1;
    else
        txfifo_clk <= 1'd0;
end
//--------------------------------
//Funtion :       发�?�数�?

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        uart_tx <= 1'd1;
    else case(bps_cnt)
        4'd0     : uart_tx <= 1'd1; 
        
        4'd1     : uart_tx <= 1'd0; //begin
        4'd2     : uart_tx <= uart_data[0];//data
        4'd3     : uart_tx <= uart_data[1];
        4'd4     : uart_tx <= uart_data[2];
        4'd5     : uart_tx <= uart_data[3];
        4'd6     : uart_tx <= uart_data[4];
        4'd7     : uart_tx <= uart_data[5];
        4'd8     : uart_tx <= uart_data[6];
        4'd9     : uart_tx <= uart_data[7];
        
        4'd10     : uart_tx <= 1; //stop
        default : uart_tx <= 1;    
    endcase
end




endmodule