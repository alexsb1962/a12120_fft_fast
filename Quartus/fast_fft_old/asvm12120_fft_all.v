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

wire cypres_ready, calc_valid, rdempty;

wire[15:0] sin48,cos48 ; 

// просто переименовываем сигналы от CYPRESS
wire clk=pe6;
wire load=pe7;
wire data=pe5;

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

/*
 // квадратурный перенос вниз 
   sincos  sc(  .outsin(sin),.outcos(cos), .sig(adcd),.perenos(perenos), .get(get_frec),.clock(sclk), .reset(reset_all));

 // fifo переноса от 120 на 48 
 
   always @( posedge sclk)   // здесь запись в fifo каждого третьего отсчета ( 40 МГц)
   begin
       if(reset_all)
       begin
          m_120=0;
          wrreq=0;
       end
       else begin
          case (m_120)
             0: begin
                   wrreq=0;
                   m_120<=1;
                end
             1: begin
                  m_120<=2;
                end
             2: begin
                  wrreq<=1;
                  m_120<=0;
                end
          endcase
       end
   end
  
   
   always @(posedge ifclk) // здесь извлечение из fifo и запись на вход fft
   begin
     if(reset_all)
     begin
        reset_fft<=0;
        m_fft<=0;
        sink_valid<=0; sink_sop<=0; sink_eop<=0; source_ready<=0;
        l_count<=20;
        v_count<=LEN_FFT-1;
     end
     else begin
        case (m_fft)
           0: begin
                 l_count<=l_count-1;
                 if( l_count == 0 )  // задержка на запуск и латентность fifo
                 begin
                    reset_fft<=1;
                    m_fft<=1;
                 end
                 else begin
                    m_fft<=0;
                 end
              end
           1: begin   // запуск fft
                 if(sink_ready)           // готовность модуля fft к приему данных
                 begin
                    sink_sop<=1;           // начало пакета
                    sink_valid<=1;        // данные готовы
                    m_fft<=2;
                 end
                 else begin
                    m_fft<=1;
                 end
              end
           2: begin   
                 sink_sop<=0;
                 v_count<=v_count-1;
                 if(v_count == 0)
                 begin
                    sink_eop<=1;            // конец пакета
                    m_fft<=3;
                 end
                 else begin       // to fft
                    if( ! rdempty)             
                    begin
                       rdreq<=1;
                       sink_valid<=1;
                    end
                    else begin
                       rdreq<=0;
                       sink_valid<=0;
                    end
                    m_fft<=2;
                 end
              end
           3: begin
                 sink_eop<=0;
                 m_fft<=4;
              end
           4: begin
                 if( source_valid  &&  source_sop) begin
                    source_ready<=1;
                    m_fft<=5;
                 end
                 else begin
                    m_fft<=4;
                 end 
              end
              /*
           5: begin   // пошло чтение из fft и запись в cypress с учетом латентности при вычислениях
                 if(com_latency_count == 0 )
                 begin
                    source_ready<=0;
                    cypress_data<= result;
                    if(flaga)
                    begin
                       fd<=cypress_data[15:0];
                       slwr<=0;
                       m_fft<=6;                    
                    end
                    else begin   
                    end
                 end
                 else begin
//                    com_latency_count = com_latency_count - 1;
                    m_fft<=5;   // холостые прогоны до появления правильных данных
                 end
              end
              */
        endcase
     end
   end
    
*/
// статические и отладочные сигналы
 
    assign chan=adc_chan;    // управление реле переключения каналов

	//assign k15=vsp[2];   //otl
	//assign k14 = ifclk;  //otl
	
	assign k20 = adc_chan;  //otl
	assign k22 = reset_all;  //otl
	
 /*
   fifo_120_48	fifo_120_48_sin (
	.aclr ( reset_all ),
	.data ( reg_sin ),
	.rdclk ( ifclk ),
	.rdreq ( rdreq ),
	.wrclk ( sclk ),
	.wrreq ( wrreq ),
	.q ( sin48 ),
	.rdempty ( rdempty ),
	.wrfull ( wrfull_sig )
	);
   fifo_120_48	fifo_120_48_cos (
	.aclr ( reset_all ),
	.data ( reg_cos ),
	.rdclk ( ifclk ),
	.rdreq ( rdreq ),
	.wrclk ( sclk ),
	.wrreq ( wrreq ),
	.q ( cos48 ),
	.rdempty ( rdempty_sig ),
	.wrfull ( wrfull_sig )
	);

   fft dut_fft(
		      .clk(ifclk),
		      .reset_n(reset_fft),
		      .inverse(0),
		      .sink_real(cos48),
		      .sink_imag(sin48),
		      .sink_sop(sink_sop),
		      .sink_eop(sink_eop),
		      .sink_valid(sink_valid),
              .sink_error(sink_error),
              .source_error(source_error),
		      .source_ready(source_ready),
		      .sink_ready(sink_ready),
		      .source_real(source_real),
		      .source_imag(source_imag),
		      .source_exp(source_exp),
		      .source_valid(source_valid),
		      .source_sop(source_sop),
		      .source_eop(source_eop)
		      );
*/		      
 cypres_cyp_inst(
                .ifclk(ifclk),        
                .fd(fd),       
                .flaga(flaga),    
                .slwr(slwr),     
                .fdata(test_sin),    
                .sink_ready(cypres_ready), 
                .sink_valid(calc_valid), 
                .reset(reset_all)
              );
              
		      

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
  
