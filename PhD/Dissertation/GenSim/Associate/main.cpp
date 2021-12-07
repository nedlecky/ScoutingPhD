#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// VRand correctly generates random numbers 0-(maxRand-1) for maxRand up
//   to 2^31.  This routine is importand since the library rand() function
//   only generates random integers up through 2^15
int VRand(int maxRand)
{
	int r=rand() | (rand()<<15) | ((rand()&1)<<30);

	return r%maxRand;
}

class Memory
{
private:
	char* complete;
	int len;
public:
	Memory();
	~Memory();
	void Set(char* data);
	void SetRandom(int minLen,int maxLen);
	int Len(void) {return len;}
	char* Complete(void) {return complete;}
};

int main()
{
	printf("Association Test\n");

	int nMemories=100;

	srand(132);

	int nNeedle=VRand(nMemories);

	printf("Generating...");
	Memory* needle=NULL;
	Memory* haystack=new Memory[nMemories];
	for(int i=0; i<nMemories; i++)
		haystack[i].SetRandom(20,20);
	needle=&(haystack[nNeedle]);
	printf("complete.\n");


	printf("Searching for %d...",nNeedle);
	for(i=0; i<nMemories; i++)
	{
		printf("%d: %s\n",i,haystack[i].Complete());
	}
	printf("complete.\n");

	return 0;
}

Memory::Memory()
{
	complete=NULL;
}
Memory::~Memory()
{
	if(complete!=NULL) delete complete;
}
void Memory::Set(char* data)
{
	if(complete!=NULL) delete complete;
	complete=strdup(data);
	len=strlen(complete);
}
void Memory::SetRandom(int minLen,int maxLen)
{
	if(complete!=NULL) delete complete;

	int range=maxLen-minLen;
	if(range<=0)
		len=minLen;
	else
		len=rand()%range+minLen;

	complete=new char[len+1];
	complete[len]=0;
	for(int i=0; i<len; i++)
		complete[i]=rand()%26+'A';
}