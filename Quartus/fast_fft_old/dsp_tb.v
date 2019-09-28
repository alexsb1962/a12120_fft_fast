
`timescale 1ns / 1ns
module dsp_tb;
  
  reg         ifclk;        // тактовую для интерфейса  поставляет  cypres 
  wire[15:0]   fd;           // шина данных cypress
  reg         flaga;        // кричит нулем о заполненности slave fifo
  wire         slwr,slrd;         // 
  wire[15:0]   ramd0;
  wire[15:0]   ramd1;
  wire[18:0]   rama0;
  wire[18:0]   rama1;
  reg         reset;
  reg sclk;
  
  reg[15:0] cnt;
  reg bank;
   
  wire sin_valid;
  wire[15:0] sin,cos;
 
  reg[3:0] shift;
   
  reg clk,load,data;
  reg[55:0] md;
  reg[6:0] kol;
  
  wire[11:0] adc_data;
  
  integer file,count;
  reg[15:0] r_fd;
  reg k23;
  wire[15:0] data595;

initial
   begin
     file = $fopen("a_sim.txt");
     count=0;
     clk=0; load=0; data=0;
     flaga=1;
     md = 56'd0;
     md[55]=0;  md[54]=1;
     md[31:0] = 32'd0;   //32'h40000000;   //32'h3f800000;
     md[47:32] = 3;
     #0 ifclk = 1'b0;
     #0 reset = 1'b1;
     #32 reset = 1'b0;
     #0  k23=1;
  end
    
   // Clock Generation                                                                         
   always   begin      #10 ifclk = 1'b1;      #10 ifclk = 1'b0;   end
   always   begin      #12 sclk = 1'b1;      #12 sclk = 1'b0;   end
   
   
   // имитируем SRAM
sram sram0(.data(ramd0), .adr(rama0), .we(ramwe0), .oe(ramoe0) );
sram sram1(.data(ramd1), .adr(rama1), .we(ramwe1), .oe(ramoe1) );


// вывод шины usb в ......
always @( negedge slwr)
begin
   r_fd=fd;
   $fdisplay ( file,"%x   ",fd);
   count=count+1;
   if(count > 5000)
   begin
      $finish;
   end
end

// имитация входных управляющих сигналов
always @( ifclk)
begin
   if (reset)
   begin
      shift<=0;
      kol<=56;
   end
   else begin
      case (shift)
         0: begin     data<=md[0];  md<= md>>1; shift<=1;end
         1: begin    clk<=1; shift<=2; end
         2: begin    clk<=0; kol<=kol-1; shift<=3;end
         3: begin
              if( kol==0) begin
                 load<=1;
                 shift<=4;
              end
              else begin
                  shift<=0;
              end
            end
         4: begin   shift<=5; end
         5: begin
                 load<=0;
                 shift<=6;
            end
         6: begin
                 shift<=7;
            end
         7: begin
                 shift<=7;
            end
      endcase
   end
end

    nco   sin_prob( .phi_inc_i(10923 ),
                        .fsin_o(sin),
                        .fcos_o(cos),
						.clk(sclk),
						.reset_n(!reset),
						.clken(1'b1)
					  );
assign adc_data[11:0] =  sin[15:4] +2048;


asvm12120_fft ds1(
//  cypres
	.fd(fd),
	.flaga(flaga), .flagb(flagb),
	.slwr(slwr),  .slrd(slrd),
	
//  74hc595
    .ds(ds),.lclk(lclk),.clk595(clk595),

//
    .ifclk(ifclk),
    .sclk(sclk),      // это пришло от 9517 (можно lvds)

//   память
     .ramd0(ramd0),.ramd1(ramd1),
     .rama0(rama0),.rama1(rama1),
     .ramoe0(ramoe0), .ramoe1(ramoe1), 
     .ramwe0(ramwe0), .ramwe1(ramwe1),

//   adc	
//     .adc_data(2),
     .adc_data(adc_data),
     .chan(chan),

//  port E
     .pe7(load),.pe6(clk),.pe5(data),
//
     .k13(k13),.k14(k14),.k15(k15),.k16(k16),.k17(k17),.k18(k18),.k19(k19),.k20(k20),.k21(k21),.k22(k22),.k23(k23)

);

r595 inst595(.clk(clk595),  .ds(ds), .load(lclk), .data(data595) );

endmodule

//-----------------------------------------------------------------------------------
module r595( input clk, input ds, input load, output reg[15:0] data );
reg [15:0] vreg;
always @(posedge clk)
begin
   vreg[15:0]<={ vreg[14:0],ds};
end

always @( load )
begin
   if(load) data<=vreg;
end
endmodule
//-----------------------------------------------------------------------------------
module sram(
    input[18:0] adr,
    input we,
    input oe,
    inout[15:0] data);
    
    reg [15:0] ram[2**18-1:0];
    
    always @( we)
    begin
       if(!we) ram[adr]<=data; 
    end
    assign data = oe ? 16'hZZZZ : ram[adr];
endmodule
