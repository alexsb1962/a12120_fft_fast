
#include "math.h"
#include "stdio.h"
#include "windows.h"

int main(int argc, char* argv[])
{

   DWORD *w;
   float res,farg;
   int n,arg;
   FILE *txt;
   BYTE nt=0;
   BYTE i,b;

   b=0;
   for(i=8,b=1;  i;  i--,b<<=1){
       nt++;
   }


   w= (DWORD*)&res;
   fopen_s( &txt, "log.txt", "w" );

   

   for(n=4;n>=-20;n--){
      farg=pow(2.0,-n);
      farg=farg/8192;
      res=log(  farg  )*2;
	  nt=n;
	  fprintf(txt,"6'h%02x :f_exp<=32'h%08x  ; // farg=%f,log=%f \n",nt,*w,farg,res);
   }


   fclose(txt);
	return 0;
}

