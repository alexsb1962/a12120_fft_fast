//(* preserve *)
//(* dont_merge *)
 module fast_fft(

//  cypres
	output[15:0]  fd,
	input flaga,flagb,
	output slwr,slrd,
	
//  74hc595
    output ds,lclk,clk595,

//
    input ifclk,     // cypress
    input sclk,      // ��� ������ �� 9517 (����� lvds)

//   ������
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

reg[11:0]  adcds,input1,input2; 
reg[11:0] adcd;
reg[31:0] md=0,mode_reg=0;          // ������� ������
reg res,res1,res2,reset_all=1,adc_chan,perenos;
reg[3:0] len_reg;
reg[15:0] get_frec;

wire[11:0] adc_sub;
 
wire[15:0] cos,sin;
reg  wr_fifo=0, reset_fifo;
wire rdempty_fifo;
wire[31:0] q_fifo; wire[15:0] fifo_real,fifo_image;
wire[3:0] used_fifo; 

reg[1:0] m_120;
reg[3:0] tact;   

reg fft_sink_sop,fft_sink_eop,fft_sink_valid, reset_fft=1, reset_nco_hann, fft_source_ready;
reg[15:0] count;
reg[7:0] start_count=0;
wire hann_valid;
reg[15:0] hann_cos1,hann_cos2;
wire[15:0] hann_real,hann_image,hann_cos;
wire   fft_sink_ready, fft_source_valid,  fft_source_sop,fft_source_eop;
wire[15:0] fft_source_real,fft_source_image;
wire[5:0] fft_source_exp;
wire[1:0] fft_source_error;
reg fft_read_state;
wire w_fft_source_ready;
wire clk40;


// ������ ��������������� ������� �� CYPRESS
wire clk=pe6;
wire load=pe7;
wire data=pe5;

reg[31:0] test_data;
wire [15:0 ] test_cos;

parameter UP2=13;
parameter LEN_FFT=8192;
parameter PHI = 65536/LEN_FFT ;

 assign ramd0 = 0; 
 assign ramd1 = 0;
 always @(*) begin      rama0<=0; rama1<=0;  ramwe0=1;ramwe1=1; ramoe0=1; ramoe1=1; end //�� ����������


// ����� ������������ �����
   always @( posedge clk )
   begin
       if(load) begin
          // ������
          mode_reg=md;
       end
       else begin
          // �����
          md[30:0]<=md[31:1];
          md[31]<= data;
       end
   end
   
// tb 
     
      

   always @( posedge ifclk)
   begin
      res=mode_reg[7]; 
      len_reg=mode_reg[11:8];
      adc_chan=mode_reg[6];
      perenos=mode_reg[5];        // ���� � ���������� ��  ��������� ���� ������ ����������
      get_frec[15:0] = mode_reg[31:16]; // ������� ����������
   end
   
   always @ (posedge sclk)
   begin
      res1<=res;
      res2<=res1;
      reset_all<=res2; // !!!!!!!!!!!!!!
 //     reset_all<=flagb;
   end
   
   
// 
    always @ (posedge sclk)
    begin 
       adcds[11:0]<=adc_data[11:0];  // ���������
       input1<=adcds;                // ��������� � ����������������� ;
       input2<=adc_sub;              // ����� (��� ����� ����� �� ������)
       adcd[11:0]<=input2;           // �������� ��� ������� �������� �� ��������� 
    //    adcd[11:0]<=test_cos[15] ? {4'b1111,test_cos[15:8]} : {4'b0000,test_cos[15:8]}; 
     //     adcd[11:0]<= test_cos[15:4]; // ������ ������
    end
   sub2048 sub(.dataa(input1),.result(adc_sub)  ); 
   
 
    nco test(
//           .phi_inc_i(16'd10923-1000),      
           .phi_inc_i(16'd9831),      
           .fcos_o(test_cos),
//           .fsin_o(hann_sin),  // �� ���������� 
           .clk(sclk),
           .reset_n( !reset_all ),
          // .out_valid(hann_valid),
           .clken(1'b1)
 );


   
 // ������� ����
//   sincos  sc(  .outsin(sin),.outcos(cos), .sig(adcd),.perenos(perenos), .get(get_frec),.clock(sclk), .reset(reset_all));
//   sincos  sc(  .outsin(sin),.outcos(cos), .sig(adcd),.perenos( 1 ), .get(16'd10923),.clock(sclk), .reset(reset_all));


   sincos  sc(  .outsin(sin),.outcos(cos), .sig(adcd),.perenos( 1 ), .get(16'd10923),.clock(sclk), .reset(reset_all));
  
   always @(posedge sclk)  // ������ � fifo ������� 3-���
   begin
      if(reset_all)
      begin
         m_120<=0;
         wr_fifo<=0;
      end
      else begin
         case (m_120)
            0:begin
                m_120<=1;
              end
            1:begin
                wr_fifo<=1;
                m_120<=2;
              end
            2:begin
                wr_fifo<=0;
                m_120<=0;
              end
              
         endcase
      end
   end
   
   
      always @( posedge ifclk)  // ����������� ������ ��� fft � ���� ��������� �������
      begin
        hann_cos1<=hann_cos;
        hann_cos2<=hann_cos1;
        if(reset_all) begin
           count<=LEN_FFT-2;
           start_count<=150;
           tact<=0;
           fft_sink_valid<=0; fft_sink_sop<=0; fft_sink_eop<=0; fft_source_ready<=0;
           reset_fft<=1; reset_nco_hann<=1; reset_fifo<=1;
           fft_read_state<=0;
        end
        else begin
          // fft_sink_sop<=( count==(LEN_FFT-2) ) ? 1 : 0;
          // fft_sink_eop<=( count==0  ) ? 1 : 0;
           case (tact)
              0: begin   
                    // ����� �� ������������ "�������� � 0"
                    //   fft_source_ready<=1;
                    if( start_count == 0 ) begin
                       reset_nco_hann<=0;
                       tact<=1;
                    end
                    else begin
                       start_count<=start_count-1;
                       tact<=0;
                    end  
                 end
              1: begin
                    // ���� ���������� nco ��� ���� + ����������� fifo
                       reset_fifo<=0;
                       if( rdempty_fifo ) begin
                          tact<=1;
                       end             
                       else begin          
                          if( hann_valid )  begin
                             tact<=2;
                             reset_fft<=0;
                          end
                          else begin
                             tact<=1;
                          end
                       end
                 end
              2: begin
//                     reset_fifo<=0;
                     fft_sink_valid<=1;
                     fft_sink_sop<=1;
                     tact<=3;
                 end
              3: begin
                    fft_sink_sop<=0;
                    if(rdempty_fifo) begin
                        tact<=3;
                    end
                    else begin
                       if(count == 0) begin
                         fft_sink_eop<=1;
                         //count<=LEN_FFT-2;
                         tact<=4;
                       end
                       else begin
                          count<=count-1;
                          tact<=3;
                       end
                    end
                 end
              4: begin
                    fft_sink_eop<=0;
                    fft_sink_sop<=1;    
                    tact<=rdempty_fifo  ?  4 :5;
                 end
              5: begin
                    // ���� ���������� fft
//                    fft_sink_valid<=0;
                    fft_sink_sop<=0;    
                    if(fft_source_valid  &&   fft_source_sop) begin
                       tact<=5; 
                       fft_read_state<=1;
                    end
                    else begin
                       tact<=5;
                    end
                 end
         endcase
       end // if
    end  // always         

fifo32	fifo32_inst (
	.data  ( {sin[15:0],cos[15:0]} ),
	.rdclk ( ifclk ),
	.rdreq ( fft_sink_ready ),
	.wrclk ( sclk ),
	.wrreq ( wr_fifo ),
	.q ( q_fifo ),
	.rdempty ( rdempty_fifo ),
	.aclr(reset_fifo)   ,        // ????
	.rdusedw(used_fifo)
	);

  wire cypres_ready;
  assign w_fft_source_ready=fft_read_state ? cypres_ready : fft_source_ready;
  fft mfft(
	.clk(ifclk),
	.reset_n( !reset_fft ),
	.inverse(1'b0),                    // ������ ������ ��������������
	.sink_valid(!rdempty_fifo ),
//	.sink_valid(1),
	.sink_sop(fft_sink_sop),
	.sink_eop(fft_sink_eop),
	.sink_real(hann_real), .sink_imag(hann_image),        // ��� � ����� ! 
//	.sink_real(1000),	.sink_imag(10000),      
	.sink_error(2'b0),
	
	.source_ready(w_fft_source_ready),
//	.source_ready( 1 ),
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
           .fcos_o(hann_cos),
//           .fsin_o(hann_sin),  // �� ���������� 
           .clk(ifclk),
           .reset_n( !reset_nco_hann ),
           .out_valid(hann_valid),
           .clken(1'b1)
 );
 
assign fifo_real=q_fifo[15:0];  assign fifo_image=q_fifo[31:16]; 
hann  hann_real_inst( .cos(hann_cos2), .data( fifo_real ), .result(hann_real ) );
hann  hann_image_inst( .cos(hann_cos2), .data( fifo_image ), .result(hann_image) );

//hann  hann_real_inst( .cos(hann_cos2), .data( 10000 ), .result(hann_real ) );
//hann  hann_image_inst( .cos(hann_cos2), .data( 10000 ), .result(hann_image) );


    cypres cyp_inst(
                .ifclk(ifclk),        
                .fd(fd),       
                .flaga(flaga),    
                .slwr(slwr),     
                .real_data(fft_source_real), .image_data(fft_source_image), .exp_data(fft_source_exp),        
//                .real_data(sin), .image_data(cos), .exp_data(-1),        
                .sink_ready(cypres_ready), 
                .sink_valid(fft_source_valid), 
//                .sink_valid(1), 
                .reset(reset_all)
              );
              
	
/*
pll40	pll40_inst (
	.inclk0 ( sclk ),
	.c0 ( clk40 )
	);
*/
	assign k20 = cypres_ready;  //otl
	assign k22 = rdempty_fifo;  //otl
	assign k18 = fft_source_valid;  //otl
	assign k19 = fft_read_state;  //otl
		      

endmodule
//-------------------------------------------------------------------------------------------------------------------------
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
//-------------------------------------------------------------------------------------------------------------------------


//`timescale 1ns / 1ps
module cypres(
                ifclk,        
                fd,           // ���� ������ cypress
                flaga,        // ������ ����� � ������������� slave fifo
                slwr,         // ������ ������ � slave fifo cypres
                real_data, image_data, exp_data,        
                sink_ready,   // ���������� ������ � ������ ������
                sink_valid,   // ������ ��� ������ ���������
                reset
              );
              

  input ifclk,flaga,reset,sink_valid;
  output reg[15:0] fd;
  output reg slwr=1;
  output reg sink_ready=0;
  input[15:0] real_data, image_data;
  input[5:0] exp_data;
  wire[31:0] fdata_calc;
  reg[31:0] rfdata;
  
  reg[2:0]  m1=0;

  always @( posedge ifclk)
  begin
     if( reset ) begin
         slwr<=1;
         sink_ready<=0;
         m1<=0;
     end
     else begin
          // ��������� ������ ���������� � ������
          // ����� ������ ��� ����������� ��������� (� ������ ���������� ���������) � ��������� ��������� �� ����� � ������
          // ��������� ��� ���������� � ������ ������� flag
          // ����� ���������� ������ ���������� ��������� ������ ���������� � ������
          // ������� � ������� ������
          case (m1)
             0: begin
                   sink_ready<=1;
                   slwr<=1;
                   m1<=1;
                end
             1: begin
                   if( sink_valid )      // ���� ���� �������� ?
                   begin
                      rfdata <= fdata_calc;
                      fd <= fdata_calc[15:0];
//                      fd <= 1;
                      sink_ready <= 0;  // �� ����� � ������ ������
                      m1<=2;
                   end
                   else begin
                      m1<=1;      // ���� ���������� ���������
                   end
                end
             2: begin
                   if(flaga)
                   begin
                      slwr<=0;
                      m1<=3;
                   end
                   else begin
                      m1<=2;
                   end
                end
             3: begin
                   slwr<=1;
                   m1<=4;
                end
             4: begin
                   fd <= rfdata[31:16];
 //                  fd <= 2;
                   m1<=5;
                end
             5: begin
                   if(flaga)
                   begin
                      slwr<=0;
                      m1=6;
                   end
                   else begin
                      m1=5;
                   end
                end
             6: begin
                      slwr<=1;
                      sink_ready<=1; // ����� � ������ ��������� ������
                      m1=1;
                end
          endcase
     end
  end
  
  calc calc_inst(
      .ifclk(ifclk),
      .reset(reset),
      .real_data(real_data),
      .image_data(image_data),
      .exp_data(exp_data),
      .source_data(fdata_calc)
);

  
endmodule
  

module calc(
      ifclk,
      reset,
      real_data,image_data,exp_data,
      source_data
);
   input ifclk;
   input reset;
   input[15:0] real_data, image_data;
   input[5:0] exp_data;
   output reg[31:0] source_data;
   
   wire[31:0] fdata,logdata,sqrdatasin,sqrdatacos,sqradd,sqrdata;
   reg[31:0]  logarg;
   reg[31:0]  sqradd1;
   reg[15:0] sin,cos;
   wire[7:0] expb;
   
   assign expb=  (exp_data[5] ? {2'b11,exp_data[5:0]} +8'd12     :     {2'b00,exp_data[5:0]    }   -8'd12 ) ; // -5 (������� �� ?)

   
   always @(posedge ifclk)
   begin
      // �������� ��� ���������� �������� �� ��������������
       //rfamp[31:0]<=  {wamp[31],  wamp[30:23]-expb, wamp[22:0] };
      sqradd1<=sqradd+1;
      logarg<={fdata[31], fdata[30:23]-expb, fdata[22:0] } ;   // � ������ ����������
      source_data<=logdata;
   end 
   
   
   int2float int2float_inst (
	.clock(ifclk),
	.clk_en(1),
	.dataa(sqradd1),
	.result(fdata)
   );
	
   log log_inst(
        .clock(ifclk),
        .data(logarg),
        .result(logdata)
   );      
   
   sqr16 m1_inst(
        .clock(ifclk),
        .dataa(real_data),
        .result(sqrdatasin)
   );      
   sqr16 m2_inst(
        .clock(ifclk),
        .dataa(image_data),
        .result(sqrdatacos)
   );      
   
  add32 add_inst(
        .dataa(sqrdatasin),
        .datab(sqrdatacos),
        .result(sqradd)
   );      
   
   
endmodule
