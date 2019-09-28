function var=susb
dos('debug\loader.exe '    );

fres=fopen('result1.bin','r');
mc=fread(fres,inf,'int16');
fclose(fres);
fres=fopen('result2.bin','r');
ms=fread(fres,inf,'int16');
fclose(fres);

n=size(ms); n=n(1);
%ms=ms';
%mc=mc';
ms=ms.*hann(n(1) );
mc=mc.*hann(n(1) );

mcc=complex(mc,ms);
fm=fft(mcc);

amp=abs(fm)./n(1);
%plot(amp),grid;


yf=amp./4095;
yd=20*log10(yf);

len=n(1);
m(1:len/2-1)=yd(len/2-1:-1:1);
m(len/2:len-1)=yd(len-1:-1:len/2);

plot(m   ),grid;
%axis([0,tact/2,-140,0]);
