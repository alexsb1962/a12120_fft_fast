// вычисляет БПФ, амплитуду, и переписывает в usb
//`timescale 1ns / 1ps
module calc_cypres(
                ifclk,        // тактовую для интерфейса  поставляет  cypres 
                fd,           // шина данных cypress
                flaga,        // кричит нулем о заполненности slave fifo
                slwr,         // 
                data_sin,
                data_cos,
                fifo_ready,   // есть данные в fifo
                reset
              );
              
  parameter LEN_FFT = 8192 ;
  parameter PHI = 65536/LEN_FFT ;
  parameter CALC_PIPELINE_LEVEL = 28 ;

  input ifclk,flaga,reset,fft_enable;
  output reg[15:0] fd;
  output reg slwr;
  input[15:0] data_sin,data_cos;
  output reg[18:0] ram_adr0,ram_adr1;

  reg[3:0]  tact=0;
  
  reg fft_reset, fft_sink_valid;
  reg   fft_source_ready;
  wire [15:0] fft_source_real,fft_source_image;
  wire [5:0] fft_source_exp;
  wire[1:0] fft_source_error;
  wire fft_source_sop,fft_source_eop,fft_sink_ready;
  wire fft_sink_sop,fft_sink_eop;
  reg[15:0] rfft_sink_real,rfft_sink_image;
  
  reg[15:0] r_real,r_image;
  reg[5:0] r_exp;
  reg[15:0] fd_next;
  wire[31:0] wrf_log;
  reg[7:0] pipe_cnt;


  reg[13:0] count;
  
  reg reset_usb = 1;
  reg reset_usb1 = 1;
  reg start_read;
  reg start;
  
  wire[15:0] hann_sin,hann_cos,hann_real,hann_image;
  wire hann_valid;
  
 
  calc calc1(
       .clk(ifclk),
       .i_real(r_real),
       .i_image(r_image),
       .i_exp(r_exp),
       .rf_log(wrf_log) );

  
  fft mfft(
	.clk(ifclk),
	.reset_n( fft_reset ),
	.inverse(1'b0),                    // только прямое преобразование
	.sink_valid(fifo_ready),           // прямо на выход fifo
	.sink_sop(fft_sink_sop),
	.sink_eop(fft_sink_eop),
	.sink_real(hann_real),
	.sink_imag(hann_image),
	.sink_error(2'b0),
	
	.source_ready(fft_source_ready),
	.sink_ready(fft_sink_ready),
	.source_error(fft_source_error),
	.source_sop(fft_source_sop),
	.source_eop(fft_source_eop),
	.source_valid(fft_source_valid),
	.source_exp(fft_source_exp),
	.source_real(fft_source_real),
	.source_imag(fft_source_image)
 );
 
 nco hann_c(
           .phi_inc_i(PHI),      
           .fsin_o(hann_sin),
           .fcos_o(hann_cos),
           .clk(ifclk),
           .reset_n(fft_reset),
           .out_valid(hann_valid),
           .clken(1'b1)
 );
 hann  hann1( .cos(hann_cos), .data(data_cos), .result(hann_real) );
 hann  hann2( .cos(hann_cos), .data(data_sin), .result(hann_image));
 
     
assign fft_sink_sop = ( count==0 ) ? 1:0;
assign fft_sink_eop = ( count==(LEN_FFT-1)  ) ? 1:0;

 
  always @( posedge ifclk)
  begin
     if(reset) begin
         tact<=fft_enable?0:10;
         fft_reset<=0;
         fft_sink_valid=0;
         reset_usb<=1;
         reset_usb1<=1;
         count<=0;
         ram_adr0<=0;
         ram_adr1<=0;
         slwr<=1;
         fft_source_ready <= 1;
         start_read<=0;
     end
     else  begin
     
         case (tact)
            //  закачать данные в fft 
            0: begin
                  // на этом шаге пытаемся реализовать всю логику ввода данных в fft
                  fft_reset<=1; // снял сброс
                  if(fft_sink_ready & hann_valid) // wait fft ready and sin ready?
                  begin
                     count<=count+fifo_ready;
                     tact<=0;
                  end
                  else begin
                     tact<=0;
                  end
               end
            1: begin
               end
            2: begin
                  if( fft_sink_eop ) begin
                     tact<=3;  // на последний такт
                     count<=0;
                  end
                  else begin
                     tact<=2; // типа выставляем данные на каждом такте
                  end
               end
            3:begin
                  count<=1;
                  tact<=4; // 
               end
            4:begin
                  tact<=5; // на ожидание конца работы
               end
            5: begin
                  if(  (fft_source_valid  &   fft_source_sop )  | start_read   )
                  begin
                     start_read<=1;
                     // аргументы вычислительного блока 
                     r_real<=fft_source_real;
                     r_image<=fft_source_image;
                     r_exp<=fft_source_exp;

                     fft_source_ready<=0;
                     
                     case (pipe_cnt)
                        0: begin
                             fd <= wrf_log[15:0];
                             fd_next <= wrf_log[31:16];
                             tact<=6;
                           end
                        1: begin
                             fd <= r_exp[5] ? {10'b1111111111,r_exp[5:0]} : {10'd0000000000,r_exp[5:0]}  ;
                             fd_next <= r_exp[5] ? {10'b1111111111,r_exp[5:0]} : {10'd0000000000,r_exp[5:0]}  ;
                             tact<=6;
                             pipe_cnt<=pipe_cnt-1;
                           end
                        default : begin
                                     tact<=5;
                                     pipe_cnt<=pipe_cnt-1;
                                  end
                     endcase
                     
                     
                  end
                  else begin
                     pipe_cnt<=CALC_PIPELINE_LEVEL;
                     tact<=5;
                  end
               end
            6: begin
                  if(!flaga)
                  begin
                       tact<=6;   // ждем готовность
                  end
                  else begin
                       slwr=0;
                       tact=7;
                  end
                end
            7: begin
                  slwr<=1;
                  fd<=  fd_next;   // для сл. транзакции
                  tact<=8;
               end
            8: begin
                  if(!flaga)
                  begin
                     tact<=8;
                  end
                  else begin
                     slwr<=0;
                     tact<=9;
                  end
               end
            9: begin
                  slwr=1;
                  tact=5;
                  fft_source_ready<=1;
               end
               
               // no fft
            10: begin
                     fd<=ram_data0;  // 
                     tact<=11;
               end
            11: begin
                  if(!flaga)
                  begin
                       tact<=11;   // ждем готовность
                  end
                  else begin
                       slwr=0;
                       tact=12;
                  end
                end
            12: begin
                  slwr<=1;
                  fd<=ram_data1;   // для сл. транзакции
                  tact<=13;
               end
            13: begin
                  if(!flaga)
                  begin
                     tact<=13;
                  end
                  else begin
                     slwr<=0;
                     tact<=14;
                  end
                  ram_adr0<=ram_adr0+1;
                  ram_adr1<=ram_adr1+1;
               end
            14: begin
                  slwr=1;
                  tact=10;
               end
            
         endcase
     end  // if(reset)
  end // always
  
 
endmodule

(* multstyle = "dsp" *)
module hann(
       input signed [15:0] cos,
       input signed [15:0] data,
       output[15:0] result
        
);


  wire signed [31:0] mprom;
  wire  [15:0] cs1;

  mult16x16 m16( .dataa({1'b0,cs1[15:1]} ), .datab(data), .result(mprom)  ); 
  assign cs1 = 32767 - cos[15:0];
  assign result[15:0] = mprom[31:16];

endmodule 