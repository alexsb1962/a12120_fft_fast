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
  