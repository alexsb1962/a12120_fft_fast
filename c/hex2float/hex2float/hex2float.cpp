// hex2float.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <windows.h>

int _tmain(int argc, _TCHAR* argv[]){

#define len 64;

   FILE *fin;
   WORD exp,i,w1,w2;
   DWORD w;
   float r;

   fin=fopen("a_sim.txt","r");

   for(i=0; i<=len; i++) {
      fscanf(fin,"%x",&w1);
      fscanf(fin,"%x",&w2);
	  if(i==0){
          exp=w1;
      }
      
   }
   

	return 0;
}

