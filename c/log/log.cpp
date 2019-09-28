
#include "stdafx.h"
#include "math.h"

int main(int argc, char* argv[])
{

   float arg,res;
   int n;

   for(n=-20;n<=4;n++){
       arg=n;
       res=log(arg);
	   printf("n=%d, arg=%d,   res=%d\n");
   }
	return 0;
}

