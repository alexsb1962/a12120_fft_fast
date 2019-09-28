//(* preserve *)
//(* dont_merge *)
 module dsp(

//  cypres
	output[15:0]  fd,
	input flaga,flagb,
	output slwr,slrd,
	
//  74hc595
    output ds,lclk,clk595,

//
    input ifclk,
    input sclk,      // это пришло от 9517 (можно lvds)

//   память
     inout[15:0] ramd0,ramd1,
     output[18:0] rama0,rama1,
     output  ramoe0,ramoe1,ramwe0,ramwe1,

//   adc	
     input[11:0] adc_data,
     output chan,

//  port E
     input pe7,pe6,pe5,
//
     input k13,k23,
     output k14,k15,k16,k17,k18,k19,k20,k21,k22

	
);

reg[11:0]  adcds,input1,input2;
reg[15:0] adcd; 
reg[55:0] md=56'hffffffffffffff,mode_reg=56'hffffffffffffff;          // регистр режима
reg res,res1,res2,reset_all=1,adc_chan;

wire[11:0] adc_sub;  // входные отсчеты в дополнительном коде

wire clk,load,data;
  
wire[31:0] amp;


wire[31:0] delta;

wire[15:0] data595;

assign clk=pe6;
assign load=pe7;
assign data=pe5;

wire[7:0] debug_pio;
wire slwr_pio, cypres_ready;
wire[15:0] fd_pio;

    
    assign delta[31:0]=mode_reg[31:0];
    
// прием управляющего слова
   always @( posedge clk )    md[55:0]<={ data,md[55:1]  };
   always @( load )  if(load) mode_reg<=md;
  
   always @ (posedge sclk)   begin   res1<=mode_reg[55]; res2<=res1; reset_all<=res2; end    // сильно боимся дребезга 
   
   
// pipelines
    always @ (posedge sclk)
    begin 
       adcds[11:0]<=adc_data[11:0];  // просто прием и никаких больше действий !!!!!
       input2<=adc_sub;
       input1<=input2;
       adcd[15:0]<=input1[11] ? {4'b1111,input1[11:0]}:{4'b0000,input1[11:0]};  // входной для fft
       adc_chan<=mode_reg[54];
    end
   sub2048 sub(.dataa(adcds),.result(adc_sub)  ); //  ????????????
   
     
    
    assign chan=!adc_chan;    // управление реле переключения каналов

	assign k15=amp_wait;   //otl
	//assign k14 = ifclk;  //otl
	assign knob=!k23;
	assign k18 = debug_pio[0];
	assign k19 = amp_read;  //otl
	assign k20 = reset_all;  //otl
	assign k22 = sclk;  //otl

/*	
*/
  asvm600_nios asvm600_nios_inst
    (

      .avs_s0_read_to_the_ampl_mm              (amp_read),
      .avs_s0_readdata_from_the_ampl_mm        (amp),
      .avs_s0_wait_from_the_ampl_mm            (amp_wait),
    
      .ats_s0_address_to_the_asvm600_ram       (rama0),
      .ats_s0_data_to_and_from_the_asvm600_ram (ramd0),
      .ats_s0_read_n_to_the_asvm600_ram        (ramoe0),
      .ats_s0_write_n_to_the_asvm600_ram       (ramwe0),
      
      .sclk                                     (sclk),
      
      .in_port_to_the_full_knob_pio              ( {!k23, flaga } ),
      .out_port_from_the_debug_pio               (debug_pio),
      .out_port_from_the_fd_pio                  (fd),
//      .out_port_from_the_slwr_pio                (slwr_pio),
      .out_port_from_the_slwr_pio                (slwr),
      .out_port_from_the_shift595_pio            (data595),
      .in_port_to_the_level_pio                  (delta),
      
      
      .reset_n                                   (!reset_all)
    );


amplitude amp_inst(.clk(sclk), .reset_fft( debug_pio[7] ), .adcd(adcd),  .amp(amp),  .read(amp_read), .wait_r(amp_wait) );
//amplitude amp_inst(.clk(sclk), .reset_fft( debug_pio[7] ), .adcd(2047),  .amp(amp),  .read(amp_read), .wait_r(amp_wait) );
shift595 shift595_inst(.clk(ifclk), .data(data595),.clk595(clk595), .ds(ds), .load(lclk)   );
   

endmodule

//-------------------------------------------------------------------------------------------------------------------------
module amplitude(
      input wire clk,
      input wire reset_fft,
      input wire[11:0] adcd,
      output reg [31:0] amp,
      input  wire  read,
      output reg wait_r);
      

  parameter LEN_FFT = 4096 ;
  parameter PHI = 65536/LEN_FFT ;
  parameter PIPE_LEVEL = 44 ;

  reg[13:0] count;
  
  reg[2:0] tact;
  
  reg fft_sink_valid, fft_sink_sop, fft_sink_eop, fft_source_ready;
  wire fft_sink_ready, fft_source_valid, fft_source_sop;
  wire hann_valid;
  
  wire[15:0] hann_real;
  wire[15:0] hann_cos;
  wire[15:0] fft_source_real, fft_source_image;
  wire[5:0] fft_source_exp;
  reg[15:0] rfft_source_real, rfft_source_image;
  reg[5:0]  rfft_source_exp;
  wire[1:0] fft_source_error;
  
  
  wire[31:0] fft_amp;
  reg[5:0] pipe_count;
  reg clk_en;
  
  reg[3:0] cv;
      
      always @( posedge clk)
      begin
        if(reset_fft) begin
           count<=LEN_FFT-2;
           wait_r<=1;
           tact<=0;
           pipe_count<=PIPE_LEVEL;  // определяется латентностью вычисления амплитуды
           clk_en<=1;
           fft_sink_valid<=0; fft_sink_sop<=0; fft_sink_eop<=0; fft_source_ready<=0;
        end
        else begin
           fft_sink_sop<=( count==(LEN_FFT-2) ) ? 1 : 0;
           fft_sink_eop<=( count==0  ) ? 1 : 0;
           case (tact)
              0: begin
                    // Ждем готовность выхода синуса и готовность fft к приему
                    if(hann_valid && fft_sink_ready) begin
                       fft_sink_valid<=1;
                       fft_sink_sop<=1;
                       tact<=1;
                    end
                    else begin
                       tact<=0;
                    end
                 end
              1: begin
                    fft_sink_sop<=0;     // сигнал выставляется только на один такт
                    if(count == 0) begin
                       count<=LEN_FFT-2;
                       tact<=2;
                    end
                    else begin
                       count<=count-1;
                       tact<=1;
                    end
                 end
              2: begin
                    // ждем готовность fft
                    fft_sink_valid<=0;
                    if(fft_source_valid  &&   fft_source_sop) begin
                       cv<=1;
                       tact<=3;  // переход на работу с nios
                    end
                    else begin
                       tact<=2;
                    end
                 end
                 
              3: begin
                    if(read) begin
                       fft_source_ready <= 1;
                       clk_en<=1;
                       tact<=4;
                    end
                    else begin
                       tact<=3;
                    end
                 end
              4: begin
                    rfft_source_real<=fft_source_real;
                    rfft_source_image<=fft_source_image;
                    rfft_source_exp<=fft_source_exp;
//                    rfft_source_real<=2;
//                    rfft_source_image<=2;
//                    rfft_source_exp<=0;
                    cv<=cv+1;
                    
                    amp <= fft_amp;   // выставить результат
                    if(pipe_count==0) begin
                        fft_source_ready <= 0;
                        clk_en<=0;
                        tact<=5;
                    end
                    else begin
                       pipe_count<=pipe_count-1;
                       tact<= 4;
                    end
                 end
              5: begin
                    wait_r<=0;  // снять запрос ожидания
                    tact<=read ? 5 : 6;  // ждем, пока не снимет read
                 end
              6: begin
                   wait_r<=1;
                   tact<=3;   // на сл. транзакцию to next transaction
                   end
           endcase
        end
      end // always
 
 nco hann_c(
           .phi_inc_i(PHI),      
           .fcos_o(hann_cos),
//           .fsin_o(hann_sin),  // не используем 
           .clk(clk),
           .reset_n( !reset_fft ),
           .out_valid(hann_valid),
           .clken(1'b1)
 );
  fft mfft(
	.clk(clk),
	.reset_n( !reset_fft ),
	.inverse(1'b0),                    // только прямое преобразование
	.sink_valid(fft_sink_valid),
	.sink_sop(fft_sink_sop),
	.sink_eop(fft_sink_eop),
	.sink_real(hann_real),        // уже с окном ! 
	.sink_imag(0),                     // действительная выборка
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
 
hann  hann1( .cos(hann_cos), .data(adcd), .result(hann_real) );
ampl ampl_inst( .clk(clk), .clk_enable(clk_en), .i_real(rfft_source_real), .i_image(rfft_source_image), .i_exp(rfft_source_exp), .amp(fft_amp)  );
      
endmodule      
      
//-------------------------------------------------------------------------------------------------------------------------

(* multstyle = "dsp" *)
module  hann(
       input signed [15:0] cos,
       input signed [11:0] data,
       output[15:0] result  );
        
  wire signed [15:0] mprom;
  wire  [15:0] cs1;

  mult16x12 m16( .dataa( {1'b0,cs1[15:1]} ), .datab(data), .result(mprom)  );  //перeполнения не будет т.к. 12бит данных 
  assign cs1 = 32767 - cos[15:0];
  assign result[15:0] = mprom[15:0];  // возможно надо корректировать (поднять амплитуду)
endmodule

//-------------------------------------------------------------------------------------------------------------------------
module ampl(
    input clk,
    input wire clk_enable,
    input [15:0] i_real,
    input [15:0] i_image,
    input [5:0] i_exp,
    output reg [31:0] amp  );

wire[15:0] real_dop,image_dop;
wire[31:0] s1,s2,wamp,sqfamp,a;
reg[31:0]  rmagn=0,rfamp=0,rwamp,rsqfamp;
wire  [7:0]  expb;


sqr16 ss1(.dataa(i_real), .datab(real_dop),  .result(s1)  );
sqr16 ss2(.dataa(i_image),.datab(image_dop), .result(s2)  );
int2float itf(.clock(clk),.clk_en(clk_enable), .dataa(rmagn),  .result(wamp)   );
fsqrt  sqrt(.clock(clk),.clk_en(clk_enable), .data(rfamp),  .result(sqfamp)   );
float2int fti(.clock(clk),.clk_en(clk_enable), .dataa(sqfamp),  .result(a)   );

assign real_dop=i_real;
assign image_dop=i_image;
assign expb=  (i_exp[5] ? {2'b11,i_exp[5:0]} +8'd5     :     {2'b00,i_exp[5:0]    }   -8'd5 ) ; // -5 

always @(posedge clk)
begin
  if( clk_enable ) begin
       rmagn[31:0]<= s1+s2+1;
       rfamp[31:0]<=  {wamp[31],  wamp[30:23]-expb, wamp[22:0] };
       rsqfamp<=sqfamp;
       amp<=a;
//       amp<=sqfamp;
  end
end


endmodule
//-------------------------------------------------------------------------------------------------------------------------

module shift595(
      input clk,
      input[15:0] data,
      output reg clk595,
      output reg ds,
      output reg load);
   
reg[2:0] tact=0;
reg[4:0] cnt=15;
reg[15:0] sdata;
      
always @(posedge clk)
begin
   case (tact)
      0: begin
           ds<=sdata[0];
           sdata[15:0]<={1'b0, sdata[15:1]};
           tact<=1;
         end
      1: begin
            clk595<=1;
            tact<=2;
         end
      2: begin
            clk595<=0;
            tact<=3;
         end
      3: begin
            if(cnt==0) begin
               load<=1;
               cnt<=15;
               tact<=4;
            end
            else begin
               cnt<=cnt-1;
               tact<=0;
            end
         end
      4: begin
            load<=0;
            sdata<=data;
            tact<=0;
         end
      default : tact<=0;
   endcase
end      
      
      
endmodule      
      
      
