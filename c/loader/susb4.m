function var=susb
dos('debug\loader.exe '    );

fres=fopen('result1.bin','r');
mas=fread(fres,inf,'int16');
mas=mas(1:2000);
fclose(fres);
n=size(mas);
subplot(2,2,1);plot(mas(1:n)),grid;
n=n(1) /2;
subplot(2,2,2);
m=mas.*hanning(n*2);
m=m';

fm=fft(m);
ang0=angle( max(fm(100:n)) )*180/pi;

amp=abs(fm)./n;
yf=amp./4095;
yd=20*log10(yf);
tact=40;
fr=0:(tact/2)/n:tact/2;
plot(fr(1:n),yd(1:n)   ),grid;
axis([0,tact/2,-140,0]);
zoom xon;
%----------------------------------------------------
fres=fopen('result2.bin','r');
mas=fread(fres,inf,'int16');
fclose(fres);
n=size(mas);
subplot(2,2,3);plot(mas(1:n)),grid;

n=n(1) /2;
subplot(2,2,4);
m=mas.*hanning(n*2);
m=m';

fm=fft(m);
ang1=angle( max(fm(100:n) ) )*180/pi;
ang=ang1-ang0;
if ang<0
     ang=-ang-180;
end
ang
amp=abs(fm)./n;
yf=amp./4095;
yd=20*log10(yf);
tact=40;
fr=0:(tact/2)/n:tact/2;
plot(fr(1:n),yd(1:n)   ),grid;
%plot(yd(1:n)   );
axis([0,tact/2,-140,0]);
zoom xon;
var=ang;

