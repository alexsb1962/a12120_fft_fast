
DWORD BulkRead1403( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data){
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


BOOL BulkWrite1403( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data){
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


BOOL SetReset1403(HANDLE hDevice, BOOL Reset){
// установить или сн€ть RESET бит
BOOL Result;
DWORD nBytes;
VENDOR_REQUEST_IN   myRequest; // структура Vendor Request
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
       sprintf(NStr,"%s%1d",service_name,i); // им€ определ€етс€ драйвером!!!!
   //   printf(NStr);printf("\n");  // !!!!!!!!!!!!!
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


void load_asvm1403(HANDLE HDevice){
    //  загрузки
ANCHOR_DOWNLOAD_CONTROL downloadControl; // управл€юща€ структура дл€ DeviceIoControl
int count;
BOOL Result;
DWORD nBytes;


/*
    EZLOADER uses the 0xA0 Vendor Command to do an internal download to the CPUCS register to put the 8051 in RESET.
    EZLOADER uses the 0xA0 Vendor Command, that is handled by the Core ONLY, to download to internal memory the firmware image that loads external memory.
    EZLOADER uses the 0xA0 Vendor Command to do an internal download to the CPUCS register to take the 8051 out of RESET.
    EZLOADER uses the 0xA3 Vendor Command, that is handled by the 8051 firmware in step 2 above to load external memory (if required).
    EZLOADER uses the 0xA0 Vendor Command, that is handled by the Core ONLY, to download to internal memory the final firmware image (if required).
    EZLOADER uses the 0xA0 Vendor Command to do an internal download to the CPUCS register to put the 8051 in RESET.
    EZLOADER uses the 0xA0 Vendor Command to do an internal download to the CPUCS register to take the 8051 out of RESET.
*/


    // установить сброс
    SetReset1403(HDevice,1);

    // цикл записи в пам€ть контроллера
    // цикл по запис€м в массиве HexRecords

    // засунуть в контроллер включа€ последнюю запись
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

    // сн€ть сброс
    SetReset1403(HDevice,1);
    SetReset1403(HDevice,0);

    CloseHandle(HDevice);   // старого устройства в общем случае уже нет
    // пауза на врем€ перезагрузки драйверов
    Sleep(3000);

}

/*
HANDLE _cdecl Open1403(void){
   HANDLE HDevice;
   int i;
   BOOL Result;
   FILE *fp = NULL;
   int numread = 0, count;



// попытка открыти€ ASVM
 HDevice=open_device("\\\\.\\ASVM1403_dual");

 if( HDevice==INVALID_HANDLE_VALUE){

    // открытие устройства CYPRESS  дл€ последующей загрузки
     HDevice=open_device("\\\\.\\ezusb-");

    // неудача открыти€ стандартного драйвера означает,
    //что  устройство отключено или неисправно
    if(HDevice==INVALID_HANDLE_VALUE){
        SetLastError(1);
        return(INVALID_HANDLE_VALUE);
    }


    load_asvm1403(HDevice); 

    // вновь открытие asvm после загрузки кода
    HDevice=open_device("\\\\.\\ASVM1403_dual");

    // неудача открыти€ после загрузки кода
    if(HDevice==INVALID_HANDLE_VALUE){
        SetLastError(2);
        return(INVALID_HANDLE_VALUE);
    }

 }// if

 return(HDevice);
} // Open1403
*/

HANDLE _cdecl open_ezusb(void){
   HANDLE HDevice;


   if(firmware_loaded){
//      CloseHandle(curent_handle);
//        load_asvm1403(HDevice);
        HDevice=open_device("\\\\.\\ezusb-");
        curent_handle=HDevice; 
   } else{
        HDevice=open_device("\\\\.\\ezusb-");

        if(HDevice==INVALID_HANDLE_VALUE){
           SetLastError(1);
           return(INVALID_HANDLE_VALUE);
        }
        load_asvm1403(HDevice);
//      CloseHandle(HDevice);
        HDevice=open_device("\\\\.\\ezusb-");
        curent_handle=HDevice; 
        firmware_loaded=TRUE;
  }


 return(HDevice);
}

HANDLE _cdecl Open1403(void){
    open_ezusb();
}
