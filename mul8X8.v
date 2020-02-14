module mul8X8(
input reset_n,
input clk,
input [7:0] a,
input [7:0]b,
output [15:0]out_data,
input en 

);
reg out;
wire [7:0] b_wei;

assign b_wei = b;

reg [3:0]i;
always @(posedge clk or negedge reset_n)begin
	if(!reset_n)
		i <= 4'b0;
	else if(i>7)
		i <= 4'b0;
	else 
		i <= i + 1'b1;
end
reg [15:0]n_lang_a[7:0];
wire [15:0]lang_a;	
always @(posedge clk or negedge reset_n)begin
	if(!reset_n)
		n_lang_a[i] <= 16'b0;
	else if(b_wei[i] ==1)
		n_lang_a[i] <= (lang_a<<i);
	else 
		n_lang_a[i] <= 16'b0;
	end	

assign 	lang_a = {8'b0,a};	
reg [15:0]n_lang_a1;
always @(posedge clk)
begin
n_lang_a1 <= n_lang_a[0] + n_lang_a[1] +n_lang_a[2]+ n_lang_a[3] +n_lang_a[4] +n_lang_a[5] +n_lang_a[6] + n_lang_a[7];
end
assign out_data = n_lang_a1;
	

endmodule