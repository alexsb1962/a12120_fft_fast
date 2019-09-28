//(* preserve *)
//(* dont_merge *)
 module asvm12120_fft(

//  cypres
	output[15:0]  fd,
	input flaga,flagb,
	output slwr,slrd,
	
//  74hc595
    output ds,lclk,clk595,

//
    input ifclk,     // cypress
    input sclk,      // это пришло от 9517 (можно lvds)

//   память
     inout[15:0] ramd0,ramd1,
     output reg[18:0] rama0,rama1,
     output reg ramoe0,ramoe1,ramwe0,ramwe1,

//   adc	
     input[11:0] adc_data,
     output chan,

//  port E
     input pe7,pe6,pe5,
//
     input k13,
     output k14,k15,k16,k17,k18,k19,k20,k21,k22,k23

	
);

reg[11:0]  adcds,adcd,input1,input2; 
reg[31:0] md=0,mode_reg=0;          // регистр режима
reg res,res1,res2,reset_all=1,adc_chan,perenos;
reg[3:0] len_reg;
reg[15:0] get_frec;

wire[11:0] adc_sub;
 
wire[15:0] cos,sin;
reg[15:0] reg_cos,reg_sin;
reg reset_fft=1, wrreq=0;

reg[1:0] m_120;
reg[3:0] m_fft;   

reg sink_valid=0, sink_sop=0, sink_eop=0, source_ready=0, rdreq;
wire sink_ready, source_valid, source_sop, source_eop;

reg[5:0] l_count;  reg[14:0] v_count;

wire cypres_ready, rdempty;
reg  calc_valid;

wire[15:0] sin48,cos48 ; 

// просто переименовываем сигналы от CYPRESS
wire clk=pe6;
wire load=pe7;
wire data=pe5;

reg[31:0] test_data;

parameter LEN_FFT=8192;


// прием управляющего слова
   always @( posedge clk )
   begin
       if(load) begin
          // запись
          mode_reg=md;
       end
       else begin
          // сдвиг
          md[30:0]<=md[31:1];
          md[31]<= data;
       end
   end
      

   always @( posedge ifclk)
   begin
      res=mode_reg[7]; 
      len_reg=mode_reg[11:8];
      adc_chan=mode_reg[6];
      perenos=mode_reg[5];        // либо с умножением на  гетеродин либо просто фильтрация
      get_frec[15:0] = mode_reg[31:16]; // частота гетеродина
   end
   
   always @ (posedge sclk)
   begin
      res1<=res;
      res2<=res1;
      reset_all<=res2;
   end
   
   
// 
    always @ (posedge sclk)
    begin 
       adcds[11:0]<=adc_data[11:0];  // защелкнул
       input1<=adcds;                // поборолся с метастабильностью adc_sub;
       input2<=adc_sub;              // вычел (мне нужно число со знаком)
       adcd[11:0]<=input2;           // конвейер для очистки задержки на вычитание 
       
       reg_cos<=cos;    
       reg_sin<=sin;
    end
   sub2048 sub(.dataa(input1),.result(adc_sub)  ); 
   
   always @(posedge ifclk)
   begin
       // формирование тестовых сигналов для cypres
       if(reset_all)
       begin
          test_data<=0;
          calc_valid<=0;
       end
       else begin
          calc_valid<=1;
          if(cypres_ready)   test_data<=test_data+1;
       end
   end



    cypres cyp_inst(
                .ifclk(ifclk),        
                .fd(fd),       
                .flaga(flaga),    
                .slwr(slwr),     
                .fdata(test_sin),    
                .sink_ready(cypres_ready), 
                .sink_valid(calc_valid), 
                .reset(reset_all)
              );
              
	
	assign k20 = cypres_ready;  //otl
	assign k22 = reset_all;  //otl
	assign k18 = ifclk;  //otl
	assign k19 = flaga;  //otl
		      

endmodule

//`timescale 1ns / 1ps
module cypres(
                ifclk,        
                fd,           // шина данных cypress
                flaga,        // кричит нулем о заполненности slave fifo
                slwr,         // сигнал записи в slave fifo cypres
                fdata,        // 32 бит float
                sink_ready,   // готовность модуля к приему данных
                sink_valid,   // данные для модуля актуальны
                reset
              );
              

  input ifclk,flaga,reset,sink_valid;
  output reg[15:0] fd;
  output reg slwr=1;
  output reg sink_ready=0;
  input[31:0] fdata;
  reg[31:0] rfdata;
  
  reg[1:0]  m1=0;

  always @( posedge ifclk)
  begin
     if( reset ) begin
         slwr<=1;
         sink_ready<=0;
         m1<=0;
     end
     else begin
          // выставить сигнал готовности к приему
          // взять данные для последующей обработки (с учетом готовности источника) и выставить состояние не готов к приему
          // выполнить две транзакции с учетом сигнала flag
          // после выполнения второй транзакции выставить сигнал готовности к приему
          // перейти к второму пункту
          case (m1)
             0: begin
                   sink_ready<=1;
                   m1<=1;
                end
             1: begin
                   if( sink_valid )
                   begin
                      rfdata <= fdata;
                      fd <= fdata[15:0];
                      sink_ready <= 0;  // не готов к приему данных
                      if( flaga )
                      begin
                         slwr<=0;
                         m1<=3;
                      end
                      else begin
                         slwr<=1;
                         m1<=2;    // на ожидание готовности usb
                      end
                   end
                   else begin
                      m1<=1;      // ждем готовности источника
                   end
                end
             2: begin
                   if(flaga)
                   begin
                      slwr<=0;
                      m1<=3;
                   end
                   else begin
                      slwr<=1;
                      m1<=2;
                   end
                end
             3: begin
                   fd <= rfdata[31:16];
                   if(flaga)
                   begin
                      slwr<=0;
                      sink_ready<=1; // готов к приему очередной порции
                      m1=1;
                   end
                   else begin
                      slwr<=1;
                      m1=3;
                   end
                end
          endcase
     end
  end
  
  
  endmodule
  
