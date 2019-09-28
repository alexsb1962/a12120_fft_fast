function var=susb(arg)
%fn=fopen('r.txt','w');
%fprintf(fn,'%d\n\r',len);
%fprintf(fn,'%d\n\r',dev);
%fprintf(fn,'%d\n\r',chan);
%fclose(fn);
dos('debug\loader.exe '    );
fres=fopen(arg,'r');
mas=fread(fres,inf,'float32');
fclose(fres);
mas=10*mas /log(10);
%mas=mas *20;
n=size(mas);
plot(mas(1:n)),grid;
%zoom xon;
var=mas;

