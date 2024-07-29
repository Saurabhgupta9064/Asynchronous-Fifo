
module async_fifo(
  wr_clk,rd_clk,rst,wr,rd,wdata,rdata,valid,empty,full,overflow,underflow  );

parameter data_width=8;
input wr_clk;
input rd_clk;
input rst;
input [data_width-1:0] wdata;

output reg [data_width-1:0] rdata;
output full;
 output empty;
 output reg valid;
 output reg underflow;
 output reg overflow;

parameter fifo_depth=8;
parameter adress_size=4;

reg [ adress_size-1:0] wr_pointer ,wr_pntr_g_s2 ,wr_pntr_g_s1;
reg [ adress_size-1:0] rd_pointer ,rd_pntr_g_s2 ,rd_pntr_g_s1;

wire  [ adress_size-1:0] wr_pntr_g;
wire  [ adress_size-1:0] rd_pntr_g;


reg [data_width-1:0] mem[fifo_depth-1:0];

//writing data in fifo
always @(posedge wr_clk) begin
	if (rst) wr_pointer<=0;
	else begin
	if( wr && !full) begin
	wr_pointer <= wr_pointer+1;
	mem[wr_pointer] <= wr_data;
		end
	end
end
	



//reading data in fifo
	always @(posedge rd_clk) begin
	if (rst) rd_pointer<=0;
	else begin
	if( rd && !empty) begin
	rd_pointer <= rd_pointer+1;
	rdata <= mem[rd_pointer] ;
	
		end
	end
end
	
	// b2g wr_pointer
	assign wr_pntr_g = wr_pointer ^(wr_pointer>>1);
	assign rd_pntr_g = rd_pointer ^(rd_pointer>>1);
	
	//2 stage synchroniser for write pointer wrt rd clk
	
	always@(posedge rd_clk) begin 
	if(rst) begin
	wr_pntr_g_s1 <=0;
	wr_pntr_g_s2 <=0;
	end
	else begin 
	wr_pntr_g_s1 <=wr_pntr_g;
	wr_pntr_g_s2 <=wr_pntr_g_s1;
	end
end
	
		//2 stage synchroniser for read pointer wrt wr clk
	
	always@(posedge wr_clk) begin 
	if(rst) begin
	rd_pntr_g_s1 <=0;
	rd_pntr_g_s2 <=0;
	end
	else begin 
	rd_pntr_g_s1 <=rd_pntr_g;
	rd_pntr_g_s2 <=rd_pntr_g_s1;
	end
end
	
// empty condition 
assign empty= (rd_pntr_g== wr_pntr_g_s2);
assign full= ( wr_pntr_g[adress_size-1]!= rd_pntr_g_s2[adress_size-1])
					&& ( wr_pntr_g[adress_size-2]!= rd_pntr_g_s2[adress_size-2])
					&& ( wr_pntr_g[adress_size-1]== rd_pntr_g_s2[adress_size-1]) ;
					
//overflow

always@(posedge wr_clk) overflow = full && wr_en	;

always@(posedge rd_clk) begin
	underflow <= empty && rd;
	valid <= (rd && !empty );
	end
endmodule
