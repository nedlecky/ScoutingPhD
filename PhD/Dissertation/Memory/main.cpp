#include <stdio.h>
#include <direct.h>
#include <string.h>
#include <math.h>

double high[38][19];
double low[38][19];
double avg[38][19];
double std[38][19];
double b[38][19];

typedef int BOOL;
#define TRUE -1;
#define FALSE 0;

BOOL Overlap(double l1,double h1,double l2,double h2)
{
	if(l1>=l2 && l1<=h2) return TRUE;
	if(h1>=l2 && h1<=h2) return TRUE;
	if(l2>=l1 && h2<=h1) return TRUE;
	return FALSE;
}
void VPrint(char* l,double* v)
{
	char lbuf[2048];
	char buf[24];
	lbuf[0]=0;
	for(int i=0; i<19; i++)
	{
		sprintf(buf,"%5.1lf ",v[i]);
		strcat(lbuf,buf);
	}
	printf("%.3s: %s\n",l,lbuf);
}
char Label(int b)
{
	switch(b)
	{
	case 35: return '0';
	case 36: return '#';
	case 37: return '*';
	default:
		if(b<26) return b+'A';
		else return b-26+'1';
	}
}

double IP(double* a,double* b)
{
	double sum=0;
	for(int i=0; i<19; i++)
		sum += a[i]*b[i];
	return sum;
}
double DEV(double* a,double* b)
{
	double sum=0;
	double sumsq=0;
	for(int i=0; i<19; i++)
	{
		double dx=a[i]-b[i];
		sum += dx;
		sumsq += dx*dx;
	}
	double count=19;
	double var=(count*sumsq - sum*sum)/count/(count-1.);
	return var;
}
main()
{
	printf("Memory Checker\n");

	_chdir("\\PhD\\Dissertation\\Memory");
	FILE* fp=fopen("\\char.txt","r");
	if(fp==NULL) printf("ERROR opening char.txt.\n");

	int i,j,k,c;

	for(c=0; c<38; c++)
	{
		int key;
		fscanf(fp,"%d",&key);
		for(i=0; i<19; i++)
			fscanf(fp,"%lf",&high[c][i]);

		fscanf(fp,"%d",&key);
		for(i=0; i<19; i++)
			fscanf(fp,"%lf",&low[c][i]);
		
		fscanf(fp,"%d",&key);
		for(i=0; i<19; i++)
			fscanf(fp,"%lf",&avg[c][i]);
		
		fscanf(fp,"%d",&key);
		for(i=0; i<19; i++)
			fscanf(fp,"%lf",&std[c][i]);
	}
	fclose(fp);


	printf("Vectors:\n");
	for(c=0; c<38; c++)
		VPrint("I",avg[c]);

	printf("A Generic Vector:\n");
	double sum[19];
	double gen[19];
	for(i=0; i<19; i++)
		sum[i]=0;

	for(c=0; c<38; c++)
		for(i=0; i<19; i++)
			sum[i]+=avg[c][i];

	for(i=0; i<19; i++)
		gen[i]=sum[i]/38;

	VPrint("G",gen);

	/*
	printf("Normalized:\n");
	for(c=0; c<38; c++)
		for(i=0; i<19; i++)
			avg[c][i]-=gen[i];
	for(c=0; c<38; c++)
		VPrint("I",avg[c]);
	*/

	/*
	printf("Normalized to Length:\n");
	for(c=0; c<38; c++)
	{
		double sum=0;
		for(i=0; i<19; i++)
			sum+=avg[c][i]*avg[c][i];
		double len=sqrt(sum);
		for(i=0; i<19; i++)
			b[c][i]=avg[c][i]/len;
	}
	for(c=0; c<38; c++)
		VPrint("B",b[c]);
	*/

	printf("Correlation Matrix:\n");
	for(c=0; c<38; c++)
	{
		char lbuf[2048];
		char buf[32];
		lbuf[0]=0;
		double minCorr=99999;
		int minK=0;
		double minCorr2=99999;
		int minK2=0;
		for(k=0; k<38; k++)
		{
			double corr=DEV(avg[c],avg[k]);
			sprintf(buf,"%3.0lf ",corr);
			strcat(lbuf,buf);
			if(corr<minCorr)
			{
				minCorr2=minCorr;
				minK2=minK;
				minCorr=corr;
				minK=k;
			}
			else
				if(corr<minCorr2)
				{
					minCorr2=corr;
					minK2=k;
				}
		}
		printf("%s    minCorr: %6.2lf at %3d minCorr2: %6.2lf at %3d\n",
			lbuf,minCorr,minK,minCorr2,minK2);
	}

	printf("Min sequential features\n");
	int lastConflict;
	BOOL fUnique;
	int madeUnique[19];
	memset(madeUnique,0,19*sizeof(int));
	for(int b=0; b<38; b++)
	{
		for(int n=1; n<19; n++)
		{
			fUnique=TRUE;
			for(c=0; c<38 && fUnique; c++)
			{
				if(b==c) continue;
				fUnique=FALSE;
				BOOL fDistinguishable=FALSE;
				for(i=0; i<n && !fDistinguishable; i++)
				{
					if(Overlap(low[b][i],high[b][i],low[c][i],high[c][i]))
						lastConflict=c;
					else
					{
						fDistinguishable=TRUE;
						madeUnique[n]++;
					}
				}
				if(fDistinguishable) fUnique=TRUE;
			}
			if(fUnique)
			{		
				printf("%c %d unique after %d parameters\n",Label(b),b,n);
				break;
			}
		}
		if(!fUnique)
			{		
				printf("%c %d NOT UNIQUE (lastConflict = %c)\n",Label(b),
					b,Label(lastConflict));
			}

	}
	for(i=0; i<19; i++)
		printf("%d: %d\n",i,madeUnique[i]);


	return 0;
}