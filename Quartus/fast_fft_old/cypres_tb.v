`timescale 1ns / 1ps
module fifo_120_48_tb;


   reg clk, ifclk;
   reg reset_n;
   
   
   reg[3:0] m_clk=0,m_ifclk=0;
   
   reg[15:0] data=0;
   reg rdreq, wrreq;
   wire[15:0] q;
   wire wrfull_sig, rdempty; 

initial
   begin
    
     #0 clk = 1'b0;
     #0 ifclk = 1'b0;
     #0 reset_n = 1'b0;
     #92 reset_n = 1'b1;
  end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Clock Generation                                                                         
   ///////////////////////////////////////////////////////////////////////////////////////////////
   always
   begin
           #4 clk = 1'b1;
	       #4 clk = 1'b0;
   end
   always
   begin
           #11 ifclk = 1'b1;
	       #11 ifclk = 1'b0;
   end

  always @ (posedge clk)
  begin
     if(!reset_n)
     begin
        m_clk<=0;
        rdreq<=0;
     end
     else begin
         data<=data+1;
         case (m_clk)
           0: begin
                m_clk<=1;
              end
           1: begin
                wrreq<=1;
                m_clk<=2;
              end
           2: begin
                wrreq<=0;
                m_clk<=3;
              end
           3: begin
                wrreq<=0;
                m_clk<=0;
              end
            
         endcase
     end
  end
  
  always @ (posedge ifclk)
  begin
     if(!reset_n)
     begin
        m_ifclk<=0;
        wrreq<=0;
     end
     else begin
         case (m_ifclk)
            0: begin
                  m_ifclk<=1;
               end
            1: begin
                  rdreq<=1;
                  m_ifclk<=2;
               end
            2: begin
                  rdreq<=0;
                  m_ifclk<=3;
               end
            3: begin
                  m_ifclk<=4;
               end
            4: begin
                  m_ifclk<=5;
               end
            5: begin
                  m_ifclk<=0;
               end
         endcase
     end
  end
  
  
 
   fifo_120_48	fifo_120_48_sin (
	.aclr ( !reset_n ),
	.data ( data ),
	.rdclk ( ifclk ),
	.rdreq ( rdreq ),
	.wrclk ( clk ),
	.wrreq ( wrreq ),
	.q ( q ),
	.rdempty ( rdempty ),
	.wrfull ( wrfull_sig )
	);

endmodule			
									 
