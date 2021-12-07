// SynapseModulation.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEmatrix.h"
#include "LEneuralnet.h"
#include "conio.h"

class NN2
{
private:
	int n,m,L;
	double eta;
	pLEmatrix py;
	pLEmatrix pz;
	pLEmatrix pV;
	pLEmatrix pW;
	pLEmatrix pVT;
	pLEmatrix pWT;
public:
	NN2(int nInputs,int nOutputs,int nHidden);
	~NN2();
	LEmatrix& Run_(LEmatrix& x);
	LEmatrix& Run(LEmatrix& x);
	void Print(int dp=2);
	void SetEta(double e) {eta=e;}
	double TrainOnce(LEmatrix& X,LEmatrix& Y);
};

NN2::NN2(int nInputs,int nOutputs,int nHidden)
{
	n=nInputs;
	m=nOutputs;
	L=nHidden;
	SetEta(0.1);

	py=new LEmatrix("y",m,1);
	pz=new LEmatrix("z",L+1,1);

	pV=new LEmatrix("V",n+1,L);
	pW=new LEmatrix("W",L+1,m);
	pV->Randomize(-0.1,0.1);
	pW->Randomize(-0.1,0.1);

	pVT=new LEmatrix("VT");
	pWT=new LEmatrix("WT");

	*pVT=leTranspose(*pV);
	*pWT=leTranspose(*pW);
}

NN2::~NN2()
{
	if(py) delete py;
	if(pz) delete pz;

	if(pV) delete pV;
	if(pW) delete pW;
	if(pVT) delete pVT;
	if(pWT) delete pWT;
}

LEmatrix& NN2::Run_(LEmatrix& x)
{
	*pz = leSigma((*pVT)*x,LEAtanh);
	*py = (*pWT) * (*pz);
	return *py;
}

LEmatrix& NN2::Run(LEmatrix& x)
{
	*py = (*pWT) * leSigma((*pVT)*x,LEAtanh);
	return *py;
}

void NN2::Print(int dp)
{
	pV->Print(dp);
	pW->Print(dp);
}

double NN2::TrainOnce(LEmatrix& X,LEmatrix& Y)
{
	LEmatrix del1t;
	LEmatrix tmpmat;
	LEmatrix Iz;
	LEmatrix e;
	LEmatrix del1,del2;
	Iz=leIdentMat(pz->Nrows());
	
	for(int c=0; c<X.Ncols(); c++)
	{
		int doCol = c;
		LEmatrix x("x");
		x = leCol(X,doCol);
		*py = Run_(x);

		e = leCol(Y,doCol) - (*py);

		// appropriate for linear output
		del2=e;

		// appropriate for tanh output
		//tmpmat=leDiag(y);
		//del2=(Iy-tmpmat*tmpmat)*e;

		// appropriate for tanh layer 1
		tmpmat=leDiag(*pz);
		del1=(Iz-tmpmat*tmpmat)*(*pW)*del2;

		// appropriate for sigmoid layer 1
		//tmpmat=leDiag(z);
		//del1=tmpmat*(Iz-tmpmat)*W*del2;

		LEmatrix del1t("del1t");
		del1t.SetSize(del1.Nrows()-1,1);
		for(int i=0; i<del1t.Nrows(); i++) del1t[i][0]=del1[i+1][0];
		(*pW) = (*pW) + ((*pz)*leTranspose(del2)*eta);
		(*pV) = (*pV) + (x*leTranspose(del1t)*eta);
		(*pVT) = leTranspose(*pV);
		(*pWT) = leTranspose(*pW);
	}

	// return error

	*py=Run(X);
	e = Y - (*py);
	double E = leEcalc(e);

	return E;
}


int main(int argc, char* argv[])
{
	printf("Synapse Modulation Tester\n");

	int nInputs=2;
	int nOutputs=2;
	NN2 net(nInputs,nOutputs,10);
	net.Print();

	int nSamples=20;
	LEmatrix Xbar("Xbar",nInputs,nSamples);
	Xbar.Randomize(-1,1);

	LEmatrix X("X",1,nSamples);
	X=1;
	X.AppendRows(Xbar);

	LEmatrix Y("Y",nOutputs,nSamples);
	for(int i=0; i<nSamples; i++)
		for(int j=0; j<nOutputs; j++)
		{
			switch(j)
			{
			case 0:
				Y[j][i]=Xbar[0][i]*Xbar[1][i]; break;
			case 1:
				Y[j][i]=Xbar[0][i]*Xbar[1][i]; break;
			}
		}

	X.Print();
	Y.Print();

	double E=999;
	int epoch=0;
	while(E>0.01 && epoch<10000)
	{
		E=net.TrainOnce(X,Y);
		if(kbhit())
		{
			char c=getch();
			if(c=='x') break;
		}

		if(epoch%1000==0)
			printf("%4d %.2lf\n",epoch,E);
		epoch++;
	}

	return 0;
}

