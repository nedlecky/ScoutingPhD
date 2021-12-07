#include <stdio.h>
#include <stdlib.h>

int brand(void)
{
	return rand()>(RAND_MAX/2);
}

int main()
{
	int nInputs=6;
	int nSamples=30;
	
	FILE* fp=fopen("test.dat","w");
	fprintf(fp,"%d %d\n",nInputs,nSamples);

	for(int i=0; i<100; i++)
	{
		int a=brand();
		int b=brand();
		int c=brand();
		int d=brand();
		int e=brand();
		int f=brand();

		int g=a&b | b&c | d&e | e&f;

		fprintf(fp,"%d %d %d %d %d %d %d\n",a,b,c,d,e,f,g);
	}

	fclose(fp);
	return 0;
}
