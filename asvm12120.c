#pragma NOIV                    // Do not generate interrupt vectors
//-----------------------------------------------------------------------------
//   File:      gpiftool.c
//   Contents:  Hooks required to implement USB peripheral function.
//              Code written for EZUSB FX2 128-pin REVE...
//              Firmware tested on EZUSB FX2 128-pin (CY3681 DK)
//   Copyright (c) 2001 Cypress Semiconductor All rights reserved
//-----------------------------------------------------------------------------
#include "fx2.h"
#include "fx2regs.h"
#include "fx2sdly.h"            // SYNCDELAY macro

#define setb(port,bit) port|=(1<<bit)
#define clrb(port,bit) port&=~(1<<bit)
#define tstb(port,bit) (port & (1<<bit))


extern BOOL GotSUD;             // Received setup data flag
extern BOOL Sleep;
extern BOOL Rwuen;
extern BOOL Selfpwr;

// ------------------------------------------------------------------
// ------------переменные, функции и описания добавлены мной-----------------------------
#define nCONFIG   2  // pe2
#define nSTATUS   4  // pe4
#define DATA0     0  // pe0
#define DCLK      1  // pe1
#define CONF_DONE 3  // pe3
#define s_data 5  // pe5
#define s_clk 6  // pe6
#define s_load 7  // pe7
#define sdio9517 1
#define sclk9517 4
#define cs9517 3


void knock(void){
BYTE i;
   clrb(IOE,DCLK); setb(IOE,DCLK);
   SYNCDELAY; 
    clrb(IOE,DCLK);
   SYNCDELAY;
}
 
void ShiftOneByte( BYTE b){
BYTE i;
   // выдвинуть один байт 
   for(i=0;i<8;i++){
      if(tstb(b,i)) setb(IOE,DATA0);else clrb(IOE,DATA0); 
      knock();      
   }
}
// -----------------------------------------


void LoadByteCondition(void){
	setb(IOE,s_load);SYNCDELAY;
    setb(IOE,s_clk);SYNCDELAY;
	clrb(IOE,s_load);SYNCDELAY;
	clrb(IOE,s_clk);SYNCDELAY;
}
void StartCondition(void){
    setb(IOE,s_clk);SYNCDELAY;
	setb(IOE,s_load);SYNCDELAY;
	clrb(IOE,s_clk);SYNCDELAY;
	clrb(IOE,s_load);SYNCDELAY;
}

void ShiftByte( BYTE b){
BYTE i;
      for(i=0;i<8;i++){
         if(tstb(b,i)) setb(IOE,s_data);
		 else clrb(IOE,s_data); 
         setb(IOE,s_clk);SYNCDELAY;
		 clrb(IOE,s_clk);SYNCDELAY;
      }
}
void ShiftByteStart( BYTE b){
BYTE i;
      for(i=0;i<7;i++){
         if(tstb(b,i)) setb(IOE,s_data);
		 else clrb(IOE,s_data); 
         setb(IOE,s_clk);SYNCDELAY;
		 clrb(IOE,s_clk);SYNCDELAY;
      }
      if(tstb(b,7)) setb(IOE,s_data);
      else clrb(IOE,s_data); 
	  StartCondition();
}

//-------------------------------------------------------------------

void Shift9517(BYTE b){
BYTE i;
    for(i=0x80;i;i>>=1){
      if(b & i)  setb(IOC,sdio9517);else clrb(IOC,sdio9517);
	  SYNCDELAY;
      clrb(IOC,sclk9517);SYNCDELAY;setb(IOC,sclk9517);
	}

}
//-------------------------------------------------------------------


BYTE Configuration;             // Current configuration
BYTE AlternateSetting;          // Alternate settings


// 512 for high speed, 64 for full speed
static WORD enum_pkt_size = 0x0000;
static WORD paket = 0x0000;
static BYTE start = FALSE;
//-----------------------------------------------------------------------------
// Task Dispatcher hooks
//   The following hooks are called by the task dispatcher.
//-----------------------------------------------------------------------------
void TD_Init( void ){  // Called once at startup
BYTE b;
														   
  CPUCS = 0x10;  //  for 48MHz operation CLKOE=0, don't drive CLKOUT
//  SYNCDELAY; IFCONFIG = 0xe3; // 48МГц, drive, синхронный, slave fifo
//  SYNCDELAY; IFCONFIG = 0x03+0x80+0x20; // 30МГц, drive, синхронный, slave fifo
  SYNCDELAY; IFCONFIG = 0x03+0x80+0x20+0x40; // 48МГц, drive, синхронный, slave fifo
//  SYNCDELAY; IFCONFIG = 0xeB; // 48МГц, drive, асинхронный, slave fifo

  SYNCDELAY;  EP2CFG = 0xA2;   
  SYNCDELAY;  EP6CFG = 0xE2;   
  SYNCDELAY;  EP8CFG = 0xE2;   

  // EP4 are not used in this implementation...
  SYNCDELAY;   EP4CFG = 0x20;                // clear valid bit
//  SYNCDELAY;   EP8CFG = 0x60;                // clear valid bit

  SYNCDELAY;  FIFORESET = 0x80;             // activate NAK-ALL to avoid race conditions
  SYNCDELAY;  FIFORESET = 0x02;             // reset, FIFO 2
  SYNCDELAY;  FIFORESET = 0x04;             // reset, FIFO 4
  SYNCDELAY;  FIFORESET = 0x06;             // reset, FIFO 6
  SYNCDELAY;  FIFORESET = 0x08;             // reset, FIFO 8
  SYNCDELAY;  FIFORESET = 0x00;             // deactivate NAK-ALL

  // 16-bit bus (WORDWIDE=1)...
  SYNCDELAY;    EP2FIFOCFG = 0x01;
  SYNCDELAY;    EP6FIFOCFG = 0x01;  // no autoin 16 bit			   
//  SYNCDELAY;    EP6FIFOCFG = 0x01+0x08;  //  autoin

  SYNCDELAY; PINFLAGSAB=0x0e; // назначен flaga на случай полного fifo 6

  // OUT endp's come up "unarmed" in the cpu domain
  // ...to "arm" the endp's when AUTOOUT=0 the cpu write's xBCL w/skip=1 (N times)
  SYNCDELAY;  EP2BCL = 0x80;                // arm first buffer
  SYNCDELAY;  EP2BCL = 0x80;                // arm second buffer
  SYNCDELAY;  EP2BCL = 0x80;                // arm third buffer
  SYNCDELAY;  EP2BCL = 0x80;                // arm fourth buffer

  // IN endp's come up in the cpu/peripheral domain

  // setup INT4 as internal source for GPIF interrupts
  // using INT4CLR (SFR), automatically enabled
  INTSETUP |= 0x03;   // Enable INT4 FIFO/GPIF Autovectoring
  SYNCDELAY;          // used here as "delay"
	EXIF &=  ~0x40;     // just in case one was pending...
  SYNCDELAY;          // used here as "delay"
  GPIFIRQ = 0x02;
  SYNCDELAY;   GPIFIE = 0x02;      // Enable GPIFWF interrupt
  SYNCDELAY;   EIE |= 0x04;        // Enable INT4 ISR, EIE.2(EIEX4=1)

  // порт Е предназначен для общения с альтерой
   setb(OEE,DATA0);
   clrb(IOE,DCLK);   setb(OEE,DCLK);
   setb(IOE,nCONFIG);setb(OEE,nCONFIG);
   clrb(IOE,s_data);setb(OEE,s_data);
   clrb(IOE,s_clk);setb(OEE,s_clk);
   clrb(IOE,s_load);setb(OEE,s_load);

// порт С - программирование AD9517
   IOC=0x1f;
   OEC=0x1f;


}

#define GPIFTRIGWR 0
#define GPIFTRIGRD 4

#define GPIF_EP2 0
#define GPIF_EP4 1
#define GPIF_EP6 2
#define GPIF_EP8 3



void TD_Poll( void )   {
   BYTE b,Num,kol,k;
WORD num,i;
  // Handle OUT data...   // is the host sending data...
  if( !( EP2468STAT & 0x01 ) )  {
    // EP2EF=0, when endp buffer "not" empty
    b=EP2FIFOBUF[0];
	SYNCDELAY;  FIFORESET = 0x80;   // activate NAK-ALL to avoid race conditions

    switch (b){
    case 0x80:
         // процедура входа в режим конфигурации
           SYNCDELAY;EP6FIFOCFG = 0x01;  //  noautoin
           SYNCDELAY;FIFORESET=6; SYNCDELAY;FIFORESET=0;
         // запуск конфигурации импульсом nCONFIG
            clrb(IOE,nCONFIG); EZUSB_Delay(1);setb(IOE,nCONFIG);EZUSB_Delay(1);
    break;

    case 0x81:
         // очередная порция конфигурационных данных
         // передается хостом порциями не более 512-3 байт. Первые 2 байта после команды - длина
         num=EP2FIFOBUF[1]+EP2FIFOBUF[2]*256;

         for(i=3;i<num+3;i++){
            ShiftOneByte(EP2FIFOBUF[i]);
         }

    break;

    case 0x82:
         // процедура выхода из режима конфигурации
         for(i=0;i<100;i++) knock();
//         LoadControlWord(0x80,0x00);
         EZUSB_Delay(1);
    break;

    case 0x83:
         // чтение статуса порта Е
         EP6FIFOBUF[0]=IOE;
         SYNCDELAY; EP6BCH=1; SYNCDELAY; EP6BCL=0;         
    break;

    case 0x84:
         // переключение режима fifo6
         SYNCDELAY;FIFORESET=6;
         if (EP2FIFOBUF[1]){
            SYNCDELAY;EP6FIFOCFG=0x01+0x08;
         } else{
            SYNCDELAY; EP6FIFOCFG=0x01;
         } // if
         FIFORESET=0;         
    break;

    case 0x85:
         // запуск выборки
         // канал, частоту и сброс на альтеру
      
		    ShiftByte(EP2FIFOBUF[1] | 0x80);
		    ShiftByte(EP2FIFOBUF[2] );
		    ShiftByte(EP2FIFOBUF[3] );
		    ShiftByteStart(EP2FIFOBUF[4] );

		    // массив
			kol=EP2FIFOBUF[6];
		 for(i=6,k=0; k<(kol+2); k++ ){
			ShiftByte( EP2FIFOBUF[i]); i++;
			ShiftByte( EP2FIFOBUF[i]); i++;
			LoadByteCondition(); 
		 }
         // переключить ep6 в режим autoin
         SYNCDELAY;    EP6FIFOCFG = 0x01+0x08;  //  autoin
         // очистить fifo6
         SYNCDELAY;FIFORESET=6;  SYNCDELAY;FIFORESET=0;

         // канал, частоту и  снять сброс 
         ShiftByte(EP2FIFOBUF[1] );
		 ShiftByte(EP2FIFOBUF[2] );
		 ShiftByte(EP2FIFOBUF[3] );
		 ShiftByteStart(EP2FIFOBUF[4] );

    break;

    case 0x8d:
         // установить TTL
         // канал, частоту и сброс на альтеру

		    ShiftByte(EP2FIFOBUF[1] | 0x80);
		    ShiftByte(EP2FIFOBUF[2] );
		    ShiftByte(EP2FIFOBUF[3] );
		    ShiftByteStart(EP2FIFOBUF[4] );
		    // массив
		 for(i=6;i<12;){
			ShiftByte( EP2FIFOBUF[i]); i++;
			ShiftByte( EP2FIFOBUF[i]); i++;
			LoadByteCondition(); 
		 }
         // переключить ep6 в режим autoin
         SYNCDELAY;    EP6FIFOCFG = 0x01+0x08;  //  autoin
         // очистить fifo6
         SYNCDELAY;FIFORESET=6;  SYNCDELAY;FIFORESET=0;

         // канал, частоту и  снять сброс 
		 ShiftByte(EP2FIFOBUF[1] );
		 ShiftByte(EP2FIFOBUF[2] );
		 ShiftByte(EP2FIFOBUF[3] );
		 ShiftByteStart(EP2FIFOBUF[4] );

    break;


    case 0x8b:
         // выставить состояние порта с0..4
         IOC=EP2FIFOBUF[1];
       //  for(;;){ IOC=0;	 SYNCDELAY; IOC=0xff; 	 SYNCDELAY;}
    break;


    case 0x8a:
         // shift bytes to ad9517
         setb(OEC,sclk9517);
		 // ставим \cs
		 clrb(IOC,cs9517);									   
         Num=EP2FIFOBUF[1]; // Сколько пишем?
		 for(b=0;b<Num;b++){
		     Shift9517(EP2FIFOBUF[b+2]);
		 }
		 // Снимаем \CS
		 setb(IOC,cs9517);
		 // переводим clk в третье состояние
         clrb(OEC,sclk9517);

    break;

    case 0x8c:
	/*
         //  чтение 1 байта из EEPROM
		 EZUSB_InitI2C();
		 // передать адрес
		 EZUSB_WriteI2C(0, 1, EP6FIFOBUF);
		 EZUSB_Delay(10);
		 // читать 256 байт из eeprom
		 EZUSB_ReadI2c(0,255,EP6FIFOBUF);			   
         SYNCDELAY; EP6BCH=1; SYNCDELAY; EP6BCL=0;         
	*/
    break;


    default:
    break;

    }// switch

    SYNCDELAY;EP2BCL = 0x80; // re-arm (skip packet) ep2
    SYNCDELAY;  FIFORESET = 0x0;
     
  } //if ep2 не пустой?
 }   // TD_Poll

BOOL TD_Suspend( void )
{ // Called before the device goes into suspend mode
   return( TRUE );
}

BOOL TD_Resume( void )
{ // Called after the device resumes
   return( TRUE );
}

//-----------------------------------------------------------------------------
// Device Request hooks
//   The following hooks are called by the end point 0 device request parser.
//-----------------------------------------------------------------------------
BOOL DR_GetDescriptor( void )
{
   return( TRUE );
}

BOOL DR_SetConfiguration( void )
{ // Called when a Set Configuration command is received

  if( EZUSB_HIGHSPEED( ) )
  { // ...FX2 in high speed mode
    SYNCDELAY;                  //
    EP6AUTOINLENH = 0x02;       // set core AUTO commit len = 512 bytes
    SYNCDELAY;                  //
    EP6AUTOINLENL = 0x00;
    SYNCDELAY;                  //
    enum_pkt_size = 512;        // max. pkt. size = 512 bytes
  }
  else
  { // ...FX2 in full speed mode
    SYNCDELAY;                  //
    EP6AUTOINLENH = 0x00;       // set core AUTO commit len = 64 bytes
    SYNCDELAY;                  //
    EP6AUTOINLENL = 0x40;
    SYNCDELAY;                  //
    enum_pkt_size = 64;         // max. pkt. size = 64 bytes
  }

  Configuration = SETUPDAT[ 2 ];
  return( TRUE );        // Handled by user code
}

BOOL DR_GetConfiguration( void )
{ // Called when a Get Configuration command is received
   EP0BUF[ 0 ] = Configuration;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);          // Handled by user code
}

BOOL DR_SetInterface( void )
{ // Called when a Set Interface command is received
   AlternateSetting = SETUPDAT[ 2 ];
   return( TRUE );        // Handled by user code
}

BOOL DR_GetInterface( void )
{ // Called when a Set Interface command is received
   EP0BUF[ 0 ] = AlternateSetting;
   EP0BCH = 0;
   EP0BCL = 1;
   return( TRUE );        // Handled by user code
}

BOOL DR_GetStatus( void )
{
   return( TRUE );
}

BOOL DR_ClearFeature( void )
{
   return( TRUE );
}

BOOL DR_SetFeature( void )
{
   return( TRUE );
}

#define VX_B2 0xB2              // turn OFF debug LEDs...
#define VX_B4 0xB4              // read GPIFTRIG register
#define VX_B5 0xB5              // GPIFABORT
#define VX_B7 0xB7              // re-initialize, call TD_Init( );
#define VX_B8 0xB8              // do a "soft reset", vector to org 00h
#define VX_B9 0xB9              // commit IN pkt. via INPKTEND=6

// Core uses bRequest value 0xA0 for Anchor downloads/uploads...
// Cypress Semiconductor reserves bRequest values 0xA1 through 0xAF...
// Your implementation should not use the above bRequest values...
// Also, previous fw.c versions trap all bRequest values 0x00 through 0x0F...
//
//   bRequest value: SETUPDAT[1]
//   standard, 0x00 through 0x0F
//
//   bmRequest value: SETUPDAT[0]
//   standard,  0x80 IN   Token
//   vendor,    0xC0 IN   Token
//   class,     0xA0 IN   Token
//   standard,  0x00 OUT  Token
//   vendor,    0x40 OUT  Token
//   class,     0x60 OUT  Token

BOOL DR_VendorCmnd( void )
{

  // Registers which require a synchronization delay, see section 15.14
  // FIFORESET        FIFOPINPOLAR
  // INPKTEND         OUTPKTEND
  // EPxBCH:L         REVCTL
  // GPIFTCB3         GPIFTCB2
  // GPIFTCB1         GPIFTCB0
  // EPxFIFOPFH:L     EPxAUTOINLENH:L
  // EPxFIFOCFG       EPxGPIFFLGSEL
  // PINFLAGSxx       EPxFIFOIRQ
  // EPxFIFOIE        GPIFIRQ
  // GPIFIE           GPIFADRH:L
  // UDMACRCH:L       EPxGPIFTRIG
  // GPIFTRIG

  // Note: The pre-REVE EPxGPIFTCH/L register are affected, as well...
  //      ...these have been replaced by GPIFTC[B3:B0] registers

	switch( SETUPDAT[ 1 ] )
	{
    case VX_B2:
    { // turn OFF debug LEDs...


      *EP0BUF = VX_B2;
      break;
    }
    case VX_B4:
    {
      *EP0BUF = GPIFTRIG;
      break;
    }
    case VX_B5:
    {
      GPIFABORT = 0xFF;
      *EP0BUF = VX_B5;
      break;
    }
    case VX_B7:
    {
      TD_Init( );
      *EP0BUF = VX_B7;
      break;
    }
    case VX_B8:
    {
      EP0BCH = 0;
      EP0BCL = 1;                   // Arm endpoint with # bytes to transfer
      EP0CS |= bmHSNAK;             // Acknowledge handshake phase of device request
      SYNCDELAY;                    // used here as "delay"
      SYNCDELAY;                    // used here as "delay"

      EA = 0;

      // ...do a "soft" code only RESET... vector to ORG 0x0000
      ( ( void ( code * ) ( void ) ) 0x0000 ) ( );

      *EP0BUF = VX_B8;
      break;
    }
    case VX_B9:
    {
      // AUTOIN=0, so 8051 pass pkt. to host...
      SYNCDELAY;                //
      INPKTEND = 0x06;          // ...commit however many bytes in pkt.
      SYNCDELAY;                //
                                // ...NOTE: this also handles "shortpkt"
      *EP0BUF = VX_B9;
      break;
    }
    default:
    {
   //   ledX_rdvar = LED3_ON;     // debug visual, stuck "ON" to warn developer...
	    return( FALSE );          // no error; command handled OK
    }
	}

  EP0BCH = 0;
  EP0BCL = 1;                   // Arm endpoint with # bytes to transfer
  EP0CS |= bmHSNAK;             // Acknowledge handshake phase of device request

	return( FALSE );              // no error; command handled OK
}

//-----------------------------------------------------------------------------
// USB Interrupt Handlers
//   The following functions are called by the USB interrupt jump table.
//-----------------------------------------------------------------------------

// Setup Data Available Interrupt Handler
void ISR_Sudav( void ) interrupt 0
{
   GotSUD = TRUE;         // Set flag
   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmSUDAV;      // Clear SUDAV IRQ
}

// Setup Token Interrupt Handler
void ISR_Sutok( void ) interrupt 0
{
   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmSUTOK;      // Clear SUTOK IRQ
}

void ISR_Sof( void ) interrupt 0
{
   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmSOF;        // Clear SOF IRQ
}

void ISR_Ures( void ) interrupt 0
{
   if ( EZUSB_HIGHSPEED( ) )
   {
      pConfigDscr = pHighSpeedConfigDscr;
      pOtherConfigDscr = pFullSpeedConfigDscr;
   }
   else
   {
      pConfigDscr = pFullSpeedConfigDscr;
      pOtherConfigDscr = pHighSpeedConfigDscr;
   }

   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmURES;       // Clear URES IRQ
}

void ISR_Susp( void ) interrupt 0
{
   Sleep = TRUE;
   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmSUSP;
}

void ISR_Highspeed( void ) interrupt 0
{
   if ( EZUSB_HIGHSPEED( ) )
   {
      pConfigDscr = pHighSpeedConfigDscr;
      pOtherConfigDscr = pFullSpeedConfigDscr;
   }
   else
   {
      pConfigDscr = pFullSpeedConfigDscr;
      pOtherConfigDscr = pHighSpeedConfigDscr;
   }

   EZUSB_IRQ_CLEAR( );
   USBIRQ = bmHSGRANT;
}
void ISR_Ep0ack( void ) interrupt 0
{
}
void ISR_Stub( void ) interrupt 0
{
}
void ISR_Ep0in( void ) interrupt 0
{
}
void ISR_Ep0out( void ) interrupt 0
{
}
void ISR_Ep1in( void ) interrupt 0
{
}
void ISR_Ep1out( void ) interrupt 0
{
}
void ISR_Ep2inout( void ) interrupt 0
{
}
void ISR_Ep4inout( void ) interrupt 0
{
}
void ISR_Ep6inout( void ) interrupt 0
{
}
void ISR_Ep8inout( void ) interrupt 0
{
}
void ISR_Ibn( void ) interrupt 0
{
}
void ISR_Ep0pingnak( void ) interrupt 0
{
}
void ISR_Ep1pingnak( void ) interrupt 0
{
}
void ISR_Ep2pingnak( void ) interrupt 0
{
}
void ISR_Ep4pingnak( void ) interrupt 0
{
}
void ISR_Ep6pingnak( void ) interrupt 0
{
}
void ISR_Ep8pingnak( void ) interrupt 0
{
}
void ISR_Errorlimit( void ) interrupt 0
{
}
void ISR_Ep2piderror( void ) interrupt 0
{
}
void ISR_Ep4piderror( void ) interrupt 0
{
}
void ISR_Ep6piderror( void ) interrupt 0
{
}
void ISR_Ep8piderror( void ) interrupt 0
{
}
void ISR_Ep2pflag( void ) interrupt 0
{
}
void ISR_Ep4pflag( void ) interrupt 0
{
}
void ISR_Ep6pflag( void ) interrupt 0
{
}
void ISR_Ep8pflag( void ) interrupt 0
{
}
void ISR_Ep2eflag( void ) interrupt 0
{
}
void ISR_Ep4eflag( void ) interrupt 0
{
}
void ISR_Ep6eflag( void ) interrupt 0
{
}
void ISR_Ep8eflag( void ) interrupt 0
{
}
void ISR_Ep2fflag( void ) interrupt 0
{
}
void ISR_Ep4fflag( void ) interrupt 0
{
}
void ISR_Ep6fflag( void ) interrupt 0
{
}
void ISR_Ep8fflag( void ) interrupt 0
{
}
void ISR_GpifComplete( void ) interrupt 0
{
}
void ISR_GpifWaveform( void ) interrupt 0
{  // FIFORd WF detected peripheral prematurely empty (less than max. pkt. size)

  GPIFABORT = 0xFF;             // abort to handle shortpkt

  SYNCDELAY;                    // used here as "delay"
	EXIF &=  ~0x40;
  INT4CLR = 0xFF;               // automatically enabled at POR
  SYNCDELAY;
}
