#include <stdio.h>
#include <string.h>

#define msize 4
typedef struct mat
{
	int x[msize][msize];
} matstruct;

/* Original */
void matmult1(matstruct* x,matstruct* y,matstruct* z)
{
	int i,j,k;

	for(i=0; i<msize; i++)
	for(j=0; j<msize; j++)
	{
		z->x[i][j]=0;
		for(k=0; k<msize; k++)
			z->x[i][j]+=x->x[i][k]*y->x[k][j];
	}
}

/* Unroll */
void matmult2(matstruct* x,matstruct* y,matstruct* z)
{
	int i,j,k;

	for(i=0; i<msize; i++)
		for(j=0; j<msize; j++)
		{
			z->x[i][j]=0;
			for(k=0; k<msize; k++)
			{
				z->x[i][j]+=x->x[i][k]*y->x[k][j]; k++;
				z->x[i][j]+=x->x[i][k]*y->x[k][j];
			}
		}
}

/* Pointers */
void matmult3(matstruct* x,matstruct* y,matstruct* z)
{
	int i,j,k;
	int *zp;
	int *xp,*xpFinal;
	int sum;

	for(i=0; i<msize; i++)
	{
		zp=&z->x[i][0];
		for(j=0; j<msize; j++)
		{
			sum=0;
			xp=&x->x[i][0];
			xpFinal=xp+msize;
			k=0;
			while(xp<xpFinal)  
			sum+=*xp++*y->x[k++][j];
			*zp++=sum;
		}
	}
}

/* Pointers plus unroll */
void matmult4(matstruct* x,matstruct* y,matstruct* z)
{
	int i,j,k;
	int *zp;
	int *xp,*xpFinal;
	int sum;

	for(i=0; i<msize; i++)
	{
		zp=&z->x[i][0];
		for(j=0; j<msize; j++)
		{
			sum=0;
			xp=&x->x[i][0];
			xpFinal=xp+msize;
			k=0;
			while(xp<xpFinal)  
			{
				sum+=*xp++*y->x[k++][j];
				sum+=*xp++*y->x[k++][j];
				sum+=*xp++*y->x[k++][j];
				sum+=*xp++*y->x[k++][j];
			}
			*zp++=sum;
		}
	}
}

/* Double pointers plus unroll */
void matmult5(matstruct* x,matstruct* y,matstruct* z)
{
	int i,j,k;
	int *xp,*xpFinal;
	int *yp;
	int *zp;
	int sum;

	for(i=0; i<msize; i++)
	{
		zp=&z->x[i][0];
		for(j=0; j<msize; j++)
		{
			sum=0;
			xp=&x->x[i][0];
			xpFinal=xp+msize;
			yp=&y->x[0][j];
			while(xp<xpFinal)  
			{
				sum+=*xp++* *yp; yp+=msize;
				sum+=*xp++* *yp; yp+=msize;
				sum+=*xp++* *yp; yp+=msize;
				sum+=*xp++* *yp; yp+=msize;
			}
			*zp++=sum;
		}
	}
}

void Show(matstruct* mat)
{
	int i,j;
	char buf[1024];
	char tbuf[1024];

	for(i=0; i<msize; i++)
	{
		buf[0]=0;
		for(j=0; j<msize; j++)
		{
			sprintf(tbuf," %4d",mat->x[i][j]);
			strcat(buf,tbuf);
		}
		printf("%s\n",buf);
	}
}

void RndMat(matstruct* mat)
{
	int i,j;
	for(i=0; i<msize; i++)
		for(j=0; j<msize; j++)
			mat->x[i][j]=rand()%msize;
}

int matcmp(matstruct* m1,matstruct* m2)
{
	int i,j;
	for(i=0; i<msize; i++)
		for(j=0; j<msize; j++)
			if(m1->x[i][j]!=m2->x[i][j]) return 0;

	return 1;
}

int main()
{
	int i;
	int nErrors;

	matstruct x;
	matstruct y;
	matstruct z1,z2,z3,z4,z5;
	
	
	RndMat(&x);
	RndMat(&y);
	
	Show(&x);
	Show(&y);
	
	for(i=0; i<1; i++)
	matmult1(&x,&y,&z1);
	matmult2(&x,&y,&z2);
	matmult3(&x,&y,&z3);
	matmult4(&x,&y,&z4);
	matmult5(&x,&y,&z5);
	
	Show(&z1);
	printf("Check: ");
	nErrors=0;
	if(matcmp(&z1,&z2)) printf("2"); else nErrors++;
	if(matcmp(&z1,&z3)) printf("3"); else nErrors++;
	if(matcmp(&z1,&z4)) printf("4"); else nErrors++;
	if(matcmp(&z1,&z5)) printf("5"); else nErrors++;
	if(nErrors) printf("\nCODING ERRORS!");
	printf("\n");
	

	return 0;
}