#include <stdio.h>
#include <math.h>
#include <memory.h>
#include <conio.h>

#define TRUE -1
#define FALSE 0


int Fact(int n)
{
	if(n<=0) return 1;
	if(n>12)
	{
		printf("Fact(%d) overflow\n",n);
		return 999999999;
	}

	int f=1;
	for(int i=2; i<=n; i++) f*=i;
	return f;
}

int Comb(int a,int b)
{
	return Fact(a)/Fact(b)/Fact(a-b);
}
int Perm(int a,int b)
{
	return Fact(a)/Fact(a-b);
}

void ISort(int* v,int n)
{
	int fGo=TRUE;

	while(fGo)
	{
		fGo=FALSE;
		for(int i=1; i<n; i++)
			if(v[i-1]>v[i])
			{
				fGo=TRUE;
				int t=v[i-1];
				v[i-1]=v[i];
				v[i]=t;
			}
	}
}

int main()
{
	printf("Coverage Simulator\n");

	for(int n=1; n<=10; n++)		// number of probes
		for(int k=3; k<=6; k++)  // possible outcomes per probe
		{
			int total=(int)pow(k,n);

			int* f=new int[k+1];	// frequencies
			memset(f,0,(k+1)*sizeof(int));

			
			int* S=new int[n];
			memset(S,0,n*sizeof(int));

			int* Scopy=new int[n];

			for(int j=0; j<total; j++)
			{
				memcpy(Scopy,S,n*sizeof(int));
				ISort(Scopy,n);
				int s0=Scopy[0];
				int sCount=1;
				for(int ii=1; ii<n; ii++)
					if(Scopy[ii]!=s0)
					{
						s0=Scopy[ii];
						sCount++;
					}
				f[sCount]++;

				// increment S to next possibility
				int index=n-1;
				int fGo=TRUE;
				do
				{
					S[index]++;
					fGo=FALSE;
					if(S[index]==k)
					{
						S[index]=0;
						if(index>0) 
						{
							index--;
							fGo=TRUE;
						}
					}
				} while(fGo);

			}

			printf("%2d %2d %7d ",k,n,total);
			for(int i=1; i<=k; i++)
			{
				double g=f[i]/Perm(k,i);
				double gt=0;
				double g1=pow(1,n)/Fact(1);
				double g2=pow(2,n)/Fact(2) - g1;
				double g3=pow(3,n)/Fact(3) - g2;
				double g4=pow(4,n)/Fact(4) - g3 - g2/Fact(2);
				double g5=pow(5,n)/Fact(5) - g4 - g3/Fact(2) - g2/Fact(3);
				double g6=pow(6,n)/Fact(6) - g5 - g4/Fact(2) - g3/Fact(3) - g2/Fact(4);
				//double g1=pow(1,n)/Fact(1);
				//double g2=pow(2,n)/Fact(2) - pow(1,n);
				//double g3=pow(3,n)/Fact(3) - pow(2,n)/Fact(2);// + pow(1,n);
				//double g4=pow(4,n)/Fact(4) - pow(3,n)/Fact(3) + pow(2,n)/(Fact(2)*Fact(2));
				//double g5=pow(5,n)/Fact(5) - pow(4,n)/Fact(4) + pow(3,n)/(Fact(3)*Fact(3)) + pow(2,n)/8;//Fact(2) + pow(1,n);
				//double g6=pow(6,n)/Fact(6) - pow(5,n)/Fact(5) + pow(4,n)/Fact(4);// + pow(3,n)/Fact(3) + pow(2,n)/Fact(2) + pow(1,n);				//double g6=pow(6,n)/Fact(6) - g5 - g4/Fact(2) - g3/Fact(3) - g2/Fact(4);
				switch(i)
				{
					case 1:
						gt=g1;
						break;
					case 2:
						gt=g2;
						break;
					case 3:
						gt=g3;
						break;
					case 4:
						gt=g4;
						break;
					case 5:
						gt=g5;
						break;
					case 6:
						gt=g6;
						break;
				}

				printf("%.0lf (%.0lf %.0lf)",g,gt,gt-g);
			}
			printf("\n");

			delete Scopy;
			delete S;
			delete f;
		}



	return 0;
}