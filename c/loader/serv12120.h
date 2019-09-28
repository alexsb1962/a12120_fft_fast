#ifndef serv12120
#define serv12120

#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include "DEVIOCTL.H"
#include "ezusbsys.h"
#include <math.h>
#include "usb100.h"


#define MAX_FILE_NAME 256
#define MAX_FILE_SIZE (64 * 1024)


// открыть устройство asvm1403, если первое включение - 
// загрузить софт и открыть. В этом случае время выполнения ........
// Закрывать с помощью CloseHandle.
 HANDLE  Open12120(void);

 // загрузка дополнительной конфигурации из файла .rbf
BOOL LoadConfig(HANDLE h12120, char * ConfigFileName);

// настройка синтезатора частот
float SetFrec(HANDLE h12120,WORD RDevider, BYTE Prescaler, BYTE ACounter,WORD BCounter, BYTE NCODevider,BYTE Devider32);
// Результат - расчетная частота



// получение выборки
BOOL GetASVM12120(HANDLE h12120,BOOL Chan,BOOL Perenos,BOOL fft, BYTE Frec, WORD * bufer, DWORD Len,  WORD Get,
				  WORD NumTTL,WORD Delay, WORD *TTL);

//BOOL GetASVM1242(HANDLE h1242,BOOL Chan, BYTE Frec, WORD * bufer, DWORD Len);

// h12120 -- HANDLE открытого устройства
// Chan  -- 0 или 1 --> номер канала
// Perenos -- В нормальном режиме работы всегда 1
//            0- сигнал и сигнал через фильтр
// fft - включение режима БПФ
// Frec  -- делитель частоты 0..6
// bufer -- память для выборки
// Len   -- длина выборки обязательно кратна 512
// Get  -- частота гетеродина (при тактовой 120Мгц и частоте гетеродина 20 Мгц Get=10923)!!!! 
// NumTTL -- количество комбинаций (Если равно 0, то коммутация не производится)
// Delay  -- задержка  1/48 mksec на единицу. Должна быть не менее 90 ед.
// TTL    -- массив с комбинациями TTL

// Установить выходы TTL
void SetTTL12120(HANDLE h12120,BOOL Chan,WORD TTL);
// Номер канала  надо передавать во избежание "непоизводительного" срабатывания реле




// это для внутреннего употребления
DWORD BulkRead12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data);
BOOL BulkWrite12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data);
#define ASVM1403_DUAL_IOCTL_800 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define ASVM1403_DUAL_IOCTL_801 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define ASVM1403_DUAL_IOCTL_802 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x802, METHOD_BUFFERED, FILE_ANY_ACCESS)
BOOL LoadConfig(HANDLE Handle, char * filename);
void SetPortC(HANDLE h12120,BYTE b); // вывод в порт C
void SetByte9517(HANDLE h12120, WORD Adr,BYTE b); // Запись одного байта массива конфигурации 9517



#endif
