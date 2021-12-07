// yfaPlot.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEmatrix.h"

int main(int argc, char* argv[])
{
	double yf=50;
	double tf=30;
	double ydotf=0;

	double minYT[]={0,0};
	double maxYT[]={yf,tf};
	double stepYT[]={0.5,0.5};
	LEmatrix result("result");
	result.SizeAndLabel(minYT,maxYT,stepYT);

	double y,t;
	for(int x1=1; x1<result.Nrows(); x1++)
	{
		y=result[x1][0];
		for(int x2=1; x2<result.Ncols(); x2++)
		{
			t=result[0][x2];
			double ydotfa=2*(yf-y)/(tf-t) - ydotf;
			result[x1][x2]=ydotfa;
		}
	}

	result.Save("plotdata.csv");
	return 0;
}

