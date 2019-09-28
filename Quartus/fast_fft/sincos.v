// здесь перемножение и фильтраци€ 
//(* preserve *)
//(* multstyle = "dsp" *) 
module sincos(  outsin,outcos, sig,perenos,get, clock, reset);

   output reg[15:0] outsin,outcos;
   input[11:0] sig;
   input[15:0] get; 
   input perenos,clock,reset;

   reg[11:0]  sig_reg;
   wire[15:0]  get_sin,   get_cos; 
   reg[15:0]  get_sin_reg,  get_cos_reg;
   reg[15:0]  result_sin,result_cos;
   wire[15:0] m_sin, m_cos;
   reg [15:0] m_sin_reg, m_cos_reg,fir_cos_source,fir_sin_source,r_res_fir_sin,r_res_fir_cos;
   
   reg res_get;
   
   always @(negedge clock)
   begin
      res_get=!reset;
   end

   wire[31:0] fir_res_sin,fir_res_cos;


   // гетеродин 20 ћ√ц  при 120 тактовой
    nco   geterodin( .phi_inc_i(get),
                        .fsin_o(get_sin),
                        .fcos_o(get_cos),
						.clk(clock),
						.reset_n(res_get),
						.clken(1'b1)
					  );

  
   			
   // уножители синусной и косинусной составл€ющей

     mult16x12  mult_sin(  .clock(clock),
					       .dataa(get_sin_reg),
					       .datab(sig_reg),
                           .result(m_sin)
                         );

     mult16x12  mult_cos(  .clock(clock),
					       .dataa(get_cos_reg),
					       .datab(sig_reg),
                           .result(m_cos)
                         );




    // фильтры

     fir16 fir_sin(  .clk(clock),
                        .reset_n(!reset),
                        .ast_sink_data(fir_sin_source),
                        .ast_sink_valid(!reset),
                        .ast_sink_error(0),
                        .ast_source_ready(1),
                        .ast_source_data(fir_res_sin)
                     );
                     
     fir16 fir_cos(  .clk(clock),
                        .reset_n(!reset),
                        .ast_sink_data(fir_cos_source),
                        .ast_sink_valid(!reset),
                        .ast_sink_error(0),
                        .ast_source_ready(1),
                        .ast_source_data(fir_res_cos)
                     );

     always @(posedge  clock )  
     begin
	    // входной сигнал сразу защелкнуть
	    sig_reg <= sig;
	
	     // результат работы генератора защелкнуть на вс€кий случай
	    get_sin_reg<=get_sin;  get_cos_reg<=get_cos;
	
	    // результат работы умножителей защелкнуть
	    m_sin_reg<=m_sin; 	    m_cos_reg<=m_cos;
	    
        
	    // результат работы фильтрoв защелкнуть(* preserve *)
	    r_res_fir_sin<=fir_res_sin;
	    r_res_fir_cos<=fir_res_cos;
	    
	    
	    if(perenos)
		begin
            fir_sin_source<=m_sin_reg;
            fir_cos_source<=m_cos_reg;
            
	        outsin[15:0]<=r_res_fir_sin;
	        outcos[15:0]<=r_res_fir_cos;
        end
        else begin
            fir_sin_source[11:0]<=sig_reg;
            fir_sin_source[15:12]<=sig_reg[11]?4'b1111:4'b0000;
            fir_cos_source[11:0]<=sig_reg;
            fir_cos_source[15:12]<=sig_reg[11]?4'b1111:4'b0000;

//            outcos[11:0]<=sig_reg;
//            outcos[15:12]<=sig_reg[11]?4'b1111:4'b0000;
            outcos<=get_sin_reg;
	        outsin[15:0]<=r_res_fir_sin;

        end
        
/*  
      
            fir_sin_source<=m_sin_reg;
            fir_cos_source<=m_cos_reg;
            
	        outsin[15:0]<=r_res_fir_sin;
            outcos[11:0]<=sig_reg;
            outcos[15:12]<=sig_reg[11]?4'b1111:4'b0000;
//	        outcos[15:0]<=r_res_fir_cos;
*/            
            
	    
	    
        
      end


endmodule
