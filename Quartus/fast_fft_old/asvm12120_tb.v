`timescale 1ns / 1ps
module fifo_120_48_tb;


   reg clk, ifclk;
   reg reset_n;
   
   
   reg[3:0] m_clk=0,m_ifclk=0;
   
   wire[15:0] fd ;
   reg flaga=1,flagb=1;

initial
   begin
    
     #0 clk = 1'b0;
     #0 ifclk = 1'b0;
     #0 reset_n = 1'b0;
     #92 reset_n = 1'b1;
     data_f = $fopen("cypres.txt","w");
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
     end
  end
  
  
 asvm12120_fft asvm12120_fft_inst(
	.fd(fd),
    .flaga(flaga), .flagb(flagb),
	.slwr(slwr), .slrd(slrd),
	
    .ds(ds), .lclk(lclk), .clk595(clk595),

     .ifclk(ifclk),     // cypress
     .sclk(sclk),      // это пришло от 9517 (можно lvds)

     .ramd0(ramd0), .ramd1(ramd1),
     .rama0(rama0), .rama1(rama1),
     .ramoe0(ramoe0), .ramoe1(ramoe1), .ramwe0(ramwe0), .ramwe1(ramwe1),

     .adc_data(adc_data),
     .chan(chan),
     
     .pe7(pe7), .pe6(pe6), .pe5(pe5),

     .k13(k13),
     .k14(k14), .k15(k14), .k16(k16), .k17(k17), .k18(k18), .k19(k19), .k20(k20), .k21(k21), .k22(k22), .k23(k23)

	
);

endmodule			
  

									 
