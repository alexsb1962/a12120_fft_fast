#include "serv12120.h"
#include "..\..\keil\firm12120.c"



BOOL firmware_loaded=FALSE;
HANDLE curent_handle=INVALID_HANDLE_VALUE;


USHORT GetPID(HANDLE hDevice){
BOOL Result;
USB_DEVICE_DESCRIPTOR Descriptor;
DWORD nBytes;
DWORD PID;

       Result=DeviceIoControl(hDevice,
	                      IOCTL_Ezusb_GET_DEVICE_DESCRIPTOR,
						  NULL, 0,
                          &Descriptor,
                          sizeof(USB_DEVICE_DESCRIPTOR),
                          (unsigned long *)&nBytes,
						  NULL
                         ) ;

	   return(Descriptor.idProduct);
}
void Calibrate9517(HANDLE h12120){
	// процедура калибровки ad9517
	// вызываем один раз после включения питания

    // аппаратный сброс
    SetPortC(h12120,0);
    SetPortC(h12120,0xff);
	Sleep(10);
     	
    // параметры настройки  
	SetByte9517( h12120,0x10, 0x7c);     // charge pump, power mode e.t.c...
	SetByte9517( h12120,0x11, 24);       // R counter  lsb(14bit)7..0  
	SetByte9517( h12120,0x12, 0);        // R counter  MSB(13..8)
	SetByte9517( h12120,0x13, 0);       // A counter decimal!!! 6bit
	SetByte9517( h12120,0x14, (WORD)560     );       // B counter lsb(13bit)7..0
	SetByte9517( h12120,0x15, (WORD)560 >>8 );       // B counter MSb(12..8)

	SetByte9517( h12120,0x16,0x07);     // Prescaler P 3
	SetByte9517( h12120,0x17, 0x04+0x01);      //   +  antibackslash pulse ?????

	SetByte9517( h12120,0x1C, 0x02);      //  выбор опорного входа
    SetByte9517( h12120,0x1A, 0x00);      //  LD pin
    SetByte9517( h12120,0x1B, 0x03);      //  refmon  pin
    SetByte9517( h12120,0x141, 0x40+0x10+0x08);      //  out5


    SetByte9517( h12120, 0x1E0,0x00);   //  
    SetByte9517( h12120, 0x1E1,0x2);   // выбрал ГУН в качестве источника для делителей

//    SetByte9517( h12120,0x141, 0x0+0x01);      //  lvds out5-
    SetByte9517( h12120,0x141, 0x06);      //  lvds out5+
	SetByte9517( h12120,0x142, 0x40+0x10+0x08+0x01);       // out6 cmos -
	SetByte9517( h12120,0x143, 0x40+0x10+0x08+0x01);       // out7 -

	SetByte9517( h12120,0xf0, 0x0c);       // out0 включил
	SetByte9517( h12120,0xf1, 0x03);       // out1 -

	SetByte9517( h12120,0x190, 0x32);       // 1-ый делитель 
	SetByte9517( h12120,0x191, 0x00);       // phase 
	SetByte9517( h12120,0x192, 0x00);       //  

	SetByte9517( h12120,0x199, 0x32);       // первая ступень 3-его делителя 
	SetByte9517( h12120,0x19b, 0x11);       // вторая ступень 3-его делителя 
	SetByte9517( h12120,0x19c, 0x20);       // bypass 2.2 

	SetByte9517( h12120,0x19e, 0x32);       // первая ступень 4-его делителя  
	SetByte9517( h12120,0x1a0, 0x11);       // вторая ступень 4-его делителя 
	SetByte9517( h12120,0x1a1, 0x20);       // bypass 3.2 

	SetByte9517( h12120,0x1A2, 0x00);       // duty cyrcle correction off?

    SetByte9517( h12120, 0x232,0x01);       // применить изменения

	// процедура калибровки ГУН
	SetByte9517( h12120,0x18, 0x06);
    SetByte9517( h12120, 0x232,0x01);  // принять изменения
	SetByte9517( h12120,0x18, 0x07);
    SetByte9517( h12120, 0x232,0x01);  // принять изменения
	Sleep(300);
}


BYTE FirstStart=1;
float SetFrec(HANDLE h12120,WORD RDevider, BYTE Prescaler, BYTE ACounter,WORD BCounter,
			  BYTE NCODevider,BYTE Devider32){

	if(FirstStart){
		Calibrate9517(h12120);
		FirstStart=0;
	}

	SetByte9517( h12120,0x10, 0x7c);     // charge pump, power mode e.t.c...
	SetByte9517( h12120,0x11, RDevider);       // R counter  lsb(14bit)7..0  
	SetByte9517( h12120,0x12, RDevider>>8);    // R counter  MSB(13..8)
	SetByte9517( h12120,0x13, ACounter);       // A counter decimal!!! 6bit
	SetByte9517( h12120,0x14, BCounter);       // B counter lsb(13bit)7..0
	SetByte9517( h12120,0x15, BCounter>>8);       // B counter MSb(12..8)

	SetByte9517( h12120,0x16,Prescaler);     // Prescaler P 3
	SetByte9517( h12120,0x17, 0x04+0x01);      //   +  antibackslash pulse ?????

	SetByte9517( h12120,0x1C, 0x02);      //  выбор опорного входа
    SetByte9517( h12120,0x1A, 0x00);      //  LD pin
    SetByte9517( h12120,0x1B, 0x03);      //  refmon  pin
    SetByte9517( h12120,0x141, 0x40+0x10+0x08);      //  out5


    SetByte9517( h12120, 0x1E0,NCODevider);   //  
    SetByte9517( h12120, 0x1E1,0x2);   // выбрал ГУН в качестве источника для делителей

//    SetByte9517( h12120,0x141, 0x0+0x01);      //  lvds out5-
    SetByte9517( h12120,0x141, 0x06);      //  lvds out5+
	SetByte9517( h12120,0x142, 0x40+0x10+0x08+0x01);       // out6 cmos -
	SetByte9517( h12120,0x143, 0x40+0x10+0x08+0x01);       // out7 -

	SetByte9517( h12120,0xf0, 0x0c);       // out0 включил
	SetByte9517( h12120,0xf1, 0x03);       // out1 -

//	SetByte9517( h12120,0x191, 0x01);       // phase ADC



	SetByte9517( h12120,0x190, Devider32);       // 1-ый делитель 
	SetByte9517( h12120,0x191, 0x00);       // phase 
	SetByte9517( h12120,0x192, 0x00);       //  

	SetByte9517( h12120,0x199, Devider32);       // первая ступень 3-его делителя 
	SetByte9517( h12120,0x19b, 0x11);       // вторая ступень 3-его делителя 
	SetByte9517( h12120,0x19c, 0x20);       // bypass 2.2 

	SetByte9517( h12120,0x19e, Devider32);       // первая ступень 4-его делителя  
	SetByte9517( h12120,0x1a0, 0x11);       // вторая ступень 4-его делителя 
	SetByte9517( h12120,0x1a1, 0x20);       // bypass 3.2 



	SetByte9517( h12120,0x1A2, 0x00);       // duty cyrcle correction off?



    SetByte9517( h12120, 0x232,0x01);       // применить изменения
    //Sleep(1);


    return(0);
}



BOOL GetASVM12120(HANDLE h12120,BOOL Chan,BOOL Perenos, BOOL fft, BYTE Frec, WORD * bufer, DWORD Len,  WORD Get,
				  WORD NumTTL,WORD Delay, WORD *TTL){
// получить выборку
// не менее 2к. Длина должна быть кратна 512 
//  Get - частота гетеродина ( 10486 - 20 МГц) 
BYTE Command[512],up2;
DWORD Ostatok;
WORD *Res;
WORD i,ic;

   if(h12120==INVALID_HANDLE_VALUE) return FALSE;
   if(Len % 512) return FALSE;
   if(Len > 32768L*8) return FALSE;
   if(Len < 2048) return FALSE;

   Command[0]=0x85;
   Command[1]=0;
   if(Chan)Command[1]=Command[1] | 0x40; // бит 6 - коммутатор каналов
   if(Perenos)Command[1]=Command[1] | 0x20; // бит 5 - вкл\выкл перенос спектра
//   if(ttl) Command[1]=Command[1] | 0x10;  // ttl
   if(fft) Command[1]=Command[1] | 0x08;  // fft
   up2=18-log((float)Len)/log(2.0)+0.5;   
   Command[2]=up2;
   Command[3]=Get;
   Command[4]=Get>>8;

   // количество комбинаций
   if(NumTTL>0) Command[6]=NumTTL+2;
   else Command[6]=0;
   Command[7]=0;
   // задержка между комбинациями
   Command[8]=Delay;
   Command[9]=Delay>>8;

   for(i=0,ic=10;i<NumTTL;i++,ic+=2){
	   Command[ic]=TTL[i];
	   Command[ic+1]=TTL[i]>>8;
   }

   //for(;;)
   if(!BulkWrite12120(h12120,0,512,Command)  ) return FALSE;

   Ostatok=Len; Res=bufer;
   do{
	   if(Ostatok>16384){
		   if(!BulkRead12120(h12120,1,32768,(BYTE*)Res)   ) return FALSE;;
		   Res+=16384;
		   Ostatok-=16384;
	   }else{
		   if(!BulkRead12120(h12120,1,Ostatok*2,(BYTE*)Res)     ) return FALSE;
		   Ostatok=0;
	   } // if
   }while(Ostatok);

   return TRUE;
}


void SetTTL12120(HANDLE h12120,BOOL Chan,WORD TTL){
// установить выходы TTL
BYTE Command[512],up2,i,ic;
WORD Get=10000,Delay=2000;
   if(h12120==INVALID_HANDLE_VALUE) return FALSE;


   Command[0]=0x8d;
   Command[1]=0;
   if(Chan)Command[1]=Command[1] | 0x40; // бит 6 - коммутатор каналов
   Command[1]=Command[1] | 0x20; // бит 5 - вкл\выкл перенос спектра
   Command[2]=up2;
   Command[3]=Get;
   Command[4]=Get>>8;

   // количество комбинаций
   Command[6]=1;
   Command[7]=0;
   // задержка между комбинациями
   Command[8]=Delay;
   Command[9]=Delay>>8;

   for(i=0,ic=10;i<1;i++,ic+=2){
	   Command[ic]=TTL;
	   Command[ic+1]=TTL>>8;
   }

   //for(;;)
   if(!BulkWrite12120(h12120,0,512,Command)  ) return FALSE;

   return TRUE;
}


BOOL BulkWrite12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data){
//  запись при работе с универсальным драйвером  (не более 64к)
BOOL Result;
BULK_TRANSFER_CONTROL  p;
DWORD nBytes;

   p.pipeNum=Pipe;
   Result=DeviceIoControl(hDevice,
	                      IOCTL_EZUSB_BULK_WRITE,
						  &p, sizeof(p),
                          Data,
                          Len,
                          (unsigned long *)&nBytes,
						  NULL
                         ) ;
   return( Result && (nBytes==Len));
}


DWORD BulkRead12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data){
//  чтение при работе с универсальным драйвером   (не более 64к)
BOOL Result;
BULK_TRANSFER_CONTROL  p;
DWORD nBytes;

   p.pipeNum=Pipe;
   Result=DeviceIoControl(hDevice,
	                      IOCTL_EZUSB_BULK_READ,
						  &p, sizeof(p),
                          Data,
                          Len,
                          (unsigned long *)&nBytes,
						  NULL
                         ) ;

   if(Result) return nBytes; else {nBytes=GetLastError();return 0;}
}





BOOL SetReset12120(HANDLE hDevice, BOOL Reset){
// установить или снять RESET бит
BOOL Result;
DWORD nBytes;
VENDOR_REQUEST_IN	myRequest; // структура Vendor Request
    myRequest.bRequest = 0xA0;
    myRequest.wValue = 0xE600; // using CPUCS.0 in FX2
    myRequest.wIndex = 0x00;
    myRequest.wLength = 0x01;
    myRequest.bData = (Reset) ? 1 : 0;
    myRequest.direction = 0x00;
    Result = DeviceIoControl (hDevice,
                        IOCTL_Ezusb_VENDOR_REQUEST,
                        &myRequest,
                        sizeof(VENDOR_REQUEST_IN),
                        NULL,
                        0,
                        (unsigned long *)&nBytes,
                        NULL);
    return(Result);

}


HANDLE open_device( char * service_name){
HANDLE  HDevice=INVALID_HANDLE_VALUE;
char NStr[64];
int i;

    for(i=0;i<10;i++){
       sprintf(NStr,"%s%1d",service_name,i);
   //	printf(NStr);printf("\n");  // !!!!!!!!!!!!!
       HDevice= CreateFile(NStr,
                      GENERIC_READ | GENERIC_WRITE,
                      FILE_SHARE_READ,
                      NULL,
                      OPEN_EXISTING,
                      0,
                      NULL);
       if(HDevice!=INVALID_HANDLE_VALUE) break;
	}
    return(HDevice);
}


void load_asvm12120(HANDLE HDevice){

ANCHOR_DOWNLOAD_CONTROL downloadControl; // управляющая структура для DeviceIoControl
int count;
BOOL Result;
DWORD nBytes;

    // установить сброс
    SetReset12120(HDevice,1);

    // цикл записи в память контроллера
    // цикл по записям в массиве HexRecords

    // засунуть в контроллер включая последнюю запись
      count=0;
      do{
         downloadControl.Offset=HexRecords[count].Address;
         Result = DeviceIoControl (HDevice,
							IOCTL_EZUSB_ANCHOR_DOWNLOAD,
							&downloadControl,
							sizeof(ANCHOR_DOWNLOAD_CONTROL),
							&(HexRecords[count].Data),
							HexRecords[count].Length,
							(unsigned long *)&nBytes,
							NULL);



      } while( HexRecords[count++].Type!=1     );

    // снять сброс
    SetReset12120(HDevice,1);
    SetReset12120(HDevice,0);

    CloseHandle(HDevice);   // старого устройства в общем случае уже нет
    // пауза на время перезагрузки драйверов
    Sleep(3000);

}


HANDLE _cdecl Open12120(void){
   HANDLE HDevice;


        HDevice=open_device("\\\\.\\A12120");
        if(HDevice==INVALID_HANDLE_VALUE){
           SetLastError(1);
           return(INVALID_HANDLE_VALUE);
		}
		if(GetPID(HDevice)==0xc370){
			load_asvm12120(HDevice);
            HDevice=open_device("\\\\.\\A12120");
			if(FirstStart){
                Calibrate9517(HDevice);
				SetFrec(HDevice,24, 0x07 , 0, 560 , 0,  0x32);
				Sleep(500);
         		FirstStart=0;
			}

 //           LoadConfig(HDevice,"..\\..\\max\\adc12120.rbf");
            LoadConfig(HDevice,"..\\..\\quartus\\fast_fft\\fast_fft.rbf"); 
	        if(GetPID(HDevice)==0xc371){
                return(HDevice);
            }
		}

 return(HDevice);
     //       LoadConfig(HDevice,"..\\..\\quartus\\dsp\\dsp.rbf");
}



BOOL LoadConfig(HANDLE h12120, char * ConfigFileName){
// загрузка конфигурационного файла 
// в ep1k30

HANDLE hConfigFile; 
DWORD Error,Len,Ostatok,i;
BYTE *Conf,*pConf;
BYTE Command[512];
	    
#define MaxDataLen  (512-3)


Conf=(BYTE*) malloc(sizeof(BYTE)*1000000);

    hConfigFile=CreateFile(ConfigFileName,
                      GENERIC_READ ,
                      FILE_SHARE_READ,
                      NULL,
                      OPEN_EXISTING,
                      0,
                      NULL);
	Error=GetLastError();
	if(hConfigFile==INVALID_HANDLE_VALUE) return FALSE;

    
    ReadFile(hConfigFile,Conf,1000000,&Len,NULL);
    

	Command[0]=0x80; // Дернуть выводом nConfig
	BulkWrite12120(h12120,0,512,Command);  // endpoint 2

	// ждать 1 в nSTATUS 
	do{
	   Sleep(1);
       Command[0]=0x83; // прочитать состояние порта е cy7c68013
	   BulkWrite12120(h12120,0,512,Command);  // endpoint 2
	   BulkRead12120(h12120,1,512,Command);  // endpoint 6
    }while(! (Command[0] & 0x10)  ) ;


	// запись!!
	pConf=Conf;
	Ostatok=Len;
	do{
		printf("Ostatok=%d  \n",Ostatok);

		Command[0]=0x81;
		if(Ostatok>=MaxDataLen){
	         Command[1]=MaxDataLen % 256; Command[2]=MaxDataLen / 256;
			 for(i=3;i<512;i++) Command[i]=*(pConf++);
			 Ostatok-=MaxDataLen;
		} else{
		      Command[1]=Ostatok % 256;
		      Command[2]=Ostatok / 256;
			  for(i=3;i<Ostatok+3;i++) Command[i]=*(pConf++);
              Ostatok=0;
		} // if
        BulkWrite12120(h12120,0,512,Command);

    } while(Ostatok);


	Command[0]=0x82; // последние сколько то тактов для завершения конфигурации
	BulkWrite12120(h12120,0,512,Command);  // endpoint 2
     
    // проверить  состояние вывода nSTATUS 
	Command[0]=0x83; // прочитать состояние порта е cy7c68013
	BulkWrite12120(h12120,0,512,Command);  // endpoint 2
	BulkRead12120(h12120,1,512,Command);  // endpoint 6
    if(Command[0] & 0x10) ;

    free(Conf);
    if(Command[0] & 0x10) 
		 return TRUE;
	     else return FALSE;

}


void SetPortC(HANDLE h12120,BYTE b){
// вывод в порт C 
BYTE Command[512];

     Command[0]=0x8b;
	 Command[1]=b;
     if(h12120==INVALID_HANDLE_VALUE) return ;
     BulkWrite12120(h12120,0,512,Command);
}


void SetByte9517(HANDLE h12120, WORD Adr,BYTE b){
BYTE Command[512];
   Command[0]=0x8a;
   Command[1]=3;  //выдвигаем 3 байта ( упр. слово и собственно байт)
   Command[3]=(BYTE)Adr;
   Command[2]=(BYTE)(Adr>>8); 
   Command[4]=b;
   BulkWrite12120(h12120,0,512,Command);
}