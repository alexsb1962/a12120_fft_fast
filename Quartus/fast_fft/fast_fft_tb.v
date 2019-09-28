`timescale 1ns / 1ps
module fast_fft_tb;


   reg clk, ifclk;
   reg reset_n;
   
   
   reg[3:0] m_clk=0,m_ifclk=0;
   
   wire[15:0] fd ;
   reg flaga=1,flagb=1;

    reg[11:0] adc_data;
    reg rdreq, wrreq;
    wire [15:0] cos;
    wire[11:0] cs;

   wire slwr;

   wire chan;
           
    integer data_f;   //  файл для выхода
    integer gen_f;   //  файл для выхода
initial
   begin
    
     #0 clk = 1'b0;
     #0 ifclk = 1'b0;
     #0 reset_n = 1'b0;
     #15 reset_n = 1'b1;
     data_f = $fopen("cypres.txt","w");
     gen_f = $fopen("gen.txt","w");
  end
    
    assign cs[11:0]=cos[15:4];
   // Clock Generation                                                                         
   always   begin           #4 clk = 1'b1;	       #4 clk = 1'b0;           end
   always   begin           #11 ifclk = 1'b1;   	       #11 ifclk = 1'b0;   end
   
   wire reset_all;
   assign reset_all=!reset_n;

  
   always @(posedge clk)
   begin
       if(reset_all)
       begin
          adc_data<=0;
          flagb<=1;
       end
       else begin
             flagb<=0;   // для сброса используем
//           adc_data<=adc_data+1;
              adc_data<=cs +2048;
       	      $fdisplay(gen_f, "%d", adc_data );
       end
   end
  
   reg bank=0;
   reg [15:0] fdz;
   always @( posedge ifclk)
   begin
     if(reset_all)
     begin
        bank<=0;
     end
     else begin
           if(!slwr ) 
           begin 
              if(bank) begin
          	     $fdisplay(data_f, "%X", {fd,fdz} );
              end
              else begin
       	         fdz<=fd;
       	      end
       	      bank<=!bank;
           end
     end           
   end

 nco test_inst(
           .phi_inc_i(16'd10923+16'd1000),      
           .fcos_o(cos),
//           .fsin_o(hann_sin),  // не используем 
           .clk(clk),
           .reset_n( !reset_all),
           .clken(1'b1)
 );
 
  
  
  
 fast_fft asvm12120_fft_inst(
	.fd(fd),
        .flaga(flaga), .flagb(flagb),
	.slwr(slwr), .slrd(slrd),
	
    .ds(ds), .lclk(lclk), .clk595(clk595),

     .ifclk(ifclk),     // cypress
     
     
     .sclk(clk),      // это пришло от 9517 (можно lvds)
/*
     .ramd0(ramd0), .ramd1(ramd1),
     .rama0(rama0), .rama1(rama1),
     .ramoe0(ramoe0), .ramoe1(ramoe1), .ramwe0(ramwe0), .ramwe1(ramwe1),
    
    */
     .adc_data(adc_data),
     .chan(chan),
     
     .pe7(pe7), .pe6(pe6), .pe5(pe5),

     .k13(k13),
     .k14(k14), .k15(k14), .k16(k16), .k17(k17), .k18(k18), .k19(k19), .k20(k20), .k21(k21), .k22(k22), .k23(k23)

	
);



endmodule			
  

									 
