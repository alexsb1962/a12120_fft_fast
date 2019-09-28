#include "serv12120.h"

#include "stdafx.h"


int main(int argc, char* argv[]){
HANDLE h12120,HResult;
WORD *Bufer1,*Bufer2,*BuferExp,Geterodin,w1,w2;
DWORD *BuferF,i;
float *Bufer;
//FILE *FResult;
DWORD time0,time1,Len,w,Kol;
float spd,ftact;
BYTE Frec,Chan,b;
float x;

WORD NumTTL=15;
WORD Delay=2000;
//WORD mTTL[16]={1,2,3,4,5,6,7,8,9,8,7,6,5,4,3,2};
WORD mTTL[16]=  {0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4};
float *fmas;


/*
    if(argc!=4) {   printf("Invalid nuber of parameters\n");  return(1); }

    if( sscanf(argv[1],"%d",&Len) !=1) { printf("Invalid Len parameter\n"); return(1);    }
    if( sscanf(argv[2],"%d",&Chan) !=1){ printf("Invalid Chan parameter\n");return(1);    }
    if( sscanf(argv[3],"%d",&Frec) !=1){ printf("Invalid Frec parameter\n");return(1);    }
*/

    x=70;

	Len=32768L*16;
	Len=8192L*2;
	Frec=0;
    Chan=0;
    Geterodin=10923;
 //   Geterodin=10923/3;
//    printf("Open device...");
    h12120=Open12120();
//    load_asvm12120(h12120);

    SetFrec(h12120,24, 0x07 , 0, 560 , 0,  0x32);
    LoadConfig(h12120,"..\\..\\quartus\\dsp\\dsp.rbf");

//    printf("Done.\n");
         time0=GetTickCount();
//         LoadConfig(h12120,"..\\..\\quartus\\dsp\\dsp.rbf"); 
         time1=GetTickCount();
         time1-=time0;
//         printf(" Load time=%d msec  \n",time1);

// Пробуем управление ad9517
//  N=(P*B)+A, F=Fref*N/R
/*
for(;;){
     ftact= SetFrec(h12120,24, 0x07 , 0, 560 , 0,  0x32);
	 Sleep(10);
     ftact= SetFrec(h12120,24, 0x07 , 0, 550 , 0,  0x32);
	 Sleep(10);
}
*/
/*
    ftact= SetFrec(h12120,24, 0x07 , 0, 560 , 0,  0x32);
  	Sleep(10);
*/	 
	Bufer=(float*)malloc(sizeof(float)*Len+2048);

//	SetTTL12120(h12120,Chan,0x5555);
         time0=GetTickCount();

//    GetASVM12120(h12120,Chan,1,Frec,Bufer,Len,Geterodin,NumTTL,Delay,mTTL);
	for(i=0;i<1;i++)
        GetASVM12120(h12120,Chan,1,1,Frec,Bufer,Len,Geterodin,0,60000,mTTL);
	time1=GetTickCount();
    time1-=time0;
    spd=  (float)(time1) / (float)(1000)  ;
    printf("time=%d ms  ,spd=%d\n",time1,spd);

//		 }

    
			 for(i=0; i<=8192;i++){
				 if ( Bufer[i]<0)
					 Bufer[i]=0;
			 }
    

	HResult=CreateFile("ResultF.bin",GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
    WriteFile(HResult,Bufer,sizeof(float)*Len/2,&Kol,NULL);
    CloseHandle(HResult);


   
    free(Bufer);
     
//	Sleep(1000);
//	return TRUE;
}



