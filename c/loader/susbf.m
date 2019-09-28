function var=susb()
len=8192;
dos('debug\loader.exe '    );
fres=fopen('resultf.bin','r');
mas=fread(fres,inf,'float32');
fclose(fres);
%mas=mas-17.5341;
%mas=mas*4.3429;
%mas=mas*;
plot( mas (1:len-1) ),grid;
%axis([0,len,-70,+20]);
zoom on;
var=mas;

