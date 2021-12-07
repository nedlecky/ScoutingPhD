#include <stdio.h>
#include <windows.h>

int magic;

DWORD WINAPI MyThread(LPVOID param)
{
	int pid=*((int*)param);
	printf("Thread %d started\n",pid);
	Sleep(1000);

	for(int i=0; i<2; i++)
	{
		printf("%2d: %d %d\n",pid,magic,rand());
		Sleep(1000);
	}

	printf("Thread %d ends.\n",pid);
	return 0;
}

const int nslaves=10;

int main()
{
	printf("Hello, world.\n");
	
	magic=100;

	unsigned long* tids=new unsigned long[nslaves];

	for(int p=0; p<nslaves; p++)
	{
		int x=p;
		HANDLE ret=CreateThread(NULL,0,MyThread,&x,0,tids+p);
		Sleep(10);
	}

	Sleep(1000);
	magic=200;
	Sleep(1000);

	delete tids;
	return 0;
}