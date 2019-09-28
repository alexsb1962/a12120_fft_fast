// hex2float.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <windows.h>
#include <math.h>

int main(void){

#define len 2048

   FILE *fin,*fout;
   DWORD w,*pw;
   WORD i,w1,w2,*pw1=(WORD*)&w,*pw2=(WORD*)&w +1;
   float *pr=(float*)&w ,  amp;
   short int exp;

   union ff{
       float f;
       BYTE  b[4];
   } fb;

   fb.f=2;
   fb.f=2000000/64.0;
   fb.b[3]=fb.b[3]+1;
   fb.b[3]=fb.b[3]+1;
   fb.b[3]=0x45;  fb.b[2]=0xa9; fb.b[1]=0x00; fb.b[0]=0x00;
   fb.b[3]=0x45;  fb.b[2]=0xa9; fb.b[1]=0x00; fb.b[0]=0x00;
/*
   fin=fopen("d:\\adc\\asvm12120_new\\quartus\\with_fft\\a_sim.txt","r");
   fout=fopen("d:\\adc\\asvm12120_new\\quartus\\with_fft\\a_sim_f.txt","w");

   for( i=0; i<=len; i++){

      if(i==0){
          fscanf(fin,"%x",&exp);
          fscanf(fin,"%x",&exp);
          exp=-exp;
      }else{
          fscanf(fin,"%x",&w1);
          fscanf(fin,"%x",&w2);
          *pw1=w1;
          *pw2=w2;

          amp=*pr;
          if(amp!=0.0) amp=amp+log(2.0)*exp;

          fprintf(fout,"%f\n", amp);
//          fprintf(fout,"%d   %f\n",i,*pr);
      }

   }      
      
    fclose(fin);fclose(fout);
    */
	return 0;
}

