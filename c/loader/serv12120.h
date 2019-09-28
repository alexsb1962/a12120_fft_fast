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


// ������� ���������� asvm1403, ���� ������ ��������� - 
// ��������� ���� � �������. � ���� ������ ����� ���������� ........
// ��������� � ������� CloseHandle.
 HANDLE  Open12120(void);

 // �������� �������������� ������������ �� ����� .rbf
BOOL LoadConfig(HANDLE h12120, char * ConfigFileName);

// ��������� ����������� ������
float SetFrec(HANDLE h12120,WORD RDevider, BYTE Prescaler, BYTE ACounter,WORD BCounter, BYTE NCODevider,BYTE Devider32);
// ��������� - ��������� �������



// ��������� �������
BOOL GetASVM12120(HANDLE h12120,BOOL Chan,BOOL Perenos,BOOL fft, BYTE Frec, WORD * bufer, DWORD Len,  WORD Get,
				  WORD NumTTL,WORD Delay, WORD *TTL);

//BOOL GetASVM1242(HANDLE h1242,BOOL Chan, BYTE Frec, WORD * bufer, DWORD Len);

// h12120 -- HANDLE ��������� ����������
// Chan  -- 0 ��� 1 --> ����� ������
// Perenos -- � ���������� ������ ������ ������ 1
//            0- ������ � ������ ����� ������
// fft - ��������� ������ ���
// Frec  -- �������� ������� 0..6
// bufer -- ������ ��� �������
// Len   -- ����� ������� ����������� ������ 512
// Get  -- ������� ���������� (��� �������� 120��� � ������� ���������� 20 ��� Get=10923)!!!! 
// NumTTL -- ���������� ���������� (���� ����� 0, �� ���������� �� ������������)
// Delay  -- ��������  1/48 mksec �� �������. ������ ���� �� ����� 90 ��.
// TTL    -- ������ � ������������ TTL

// ���������� ������ TTL
void SetTTL12120(HANDLE h12120,BOOL Chan,WORD TTL);
// ����� ������  ���� ���������� �� ��������� "������������������" ������������ ����




// ��� ��� ����������� ������������
DWORD BulkRead12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data);
BOOL BulkWrite12120( HANDLE hDevice, BYTE Pipe, DWORD Len, BYTE * Data);
#define ASVM1403_DUAL_IOCTL_800 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define ASVM1403_DUAL_IOCTL_801 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define ASVM1403_DUAL_IOCTL_802 CTL_CODE(FILE_DEVICE_UNKNOWN, 0x802, METHOD_BUFFERED, FILE_ANY_ACCESS)
BOOL LoadConfig(HANDLE Handle, char * filename);
void SetPortC(HANDLE h12120,BYTE b); // ����� � ���� C
void SetByte9517(HANDLE h12120, WORD Adr,BYTE b); // ������ ������ ����� ������� ������������ 9517



#endif
