// FFNN.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <memory.h>
#include <math.h>
#include <stdlib.h>

#include "ffnn.h"
#include <conio.h>

double randm1p1(void)
{
	double x=(double)rand()*2./(double)RAND_MAX - 1.;
	return x;
}
double sigmoid(double x)
{
	if(x<-50) return 0.0;
	if(x>50.) return 1.0;
	return 1./(1.+exp(-x));
}

Layer::Layer(int nIn,int nOut)
{
	Init(nIn,nOut);
}
Layer::Layer(Layer& layer,int nOut)
{
	Init(layer.OutputCount(),nOut);
	input=layer.OutputPtr();
	layer.SetOutputErrors(back_errors);
}
void Layer::Init(int nIn,int nOut)
{
	nInputs=nIn;
	nOutputs=nOut;

	input=NULL;
	output=new double[nOutputs];

	output_errors=NULL;
	back_errors=new double[nInputs];
	
	for(int i=0; i<nOutputs; i++)
		output[i]=0;
	for(i=0; i<nInputs; i++)
		back_errors[i]=0.;
}
Layer::~Layer()
{
	if(output) delete output;
	if(back_errors) delete back_errors;
}

void Layer::ShowInputs(void)
{
	for(int i=0; i<nInputs; i++)
		printf("in%02d: %6.3lf\n",i,input[i]);
}
void Layer::ShowOutputs(void)
{
	for(int i=0; i<nOutputs; i++)
		printf("out%02d: %6.3lf\n",i,output[i]);
}
void Layer::ShowOutputErrors(void)
{
	for(int i=0; i<nOutputs; i++)
		printf("oe%02d: %6.3lf\n",i,output_errors[i]);
}

AmplifierLayer::AmplifierLayer(Layer& layer) : Layer(layer,layer.OutputCount())
{
	Init();
}

AmplifierLayer::AmplifierLayer(int nIn) : Layer(nIn,nIn)
{
	Init();
}

void AmplifierLayer::Init(void)
{
	m=new double[nInputs];
	b=new double[nInputs];
	Reset();
}
AmplifierLayer::~AmplifierLayer()
{
	if(m) delete m;
	if(b) delete b;
}
void AmplifierLayer::Reset(void)
{
	for(int i=0; i<nInputs; i++)
	{
		m[i]=1.;
		b[i]=0.;
	}
}
void AmplifierLayer::SetScaling(TestData& data,int fInput)
{
	Reset();
	if(data.NElements()<nInputs) return;

	double* minVal=new double[nInputs];
	double* maxVal=new double[nInputs];
	for(int i=0; i<nInputs; i++)
	{
		minVal[i] =  999999999.;
		maxVal[i] = -999999999.;
	}

	for(i=0; i<data.NSamples(); i++)
		for(int j=0; j<nInputs; j++)
		{
			double val=data[i][j];
			if(val<minVal[j]) minVal[j]=val;
			if(val>maxVal[j]) maxVal[j]=val;
		}

	// compute m and b
	for(i=0; i<nInputs; i++)
	{
		if(fInput)
		{
			m[i]=1./(maxVal[i]-minVal[i]);
			b[i]=-minVal[i]/(maxVal[i]-minVal[i]);
		}
		else
		{
			m[i]=maxVal[i]-minVal[i];
			b[i]=minVal[i];
		}
	}
	delete minVal;
	delete maxVal;
}
void AmplifierLayer::UnityScaling(void)
{
	for(int i=0; i<nInputs; i++)
	{
		m[i]=1.;
		b[i]=0.;
	}
}
void AmplifierLayer::ShowScaling(void)
{
	for(int i=0; i<nInputs; i++)
		printf("inscale %02d: %6.3lf %6.3lf\n",i,m[i],b[i]);
}
void AmplifierLayer::ForwardProp(void)
{
	for(int i=0; i<nInputs; i++)
		output[i] = m[i]*input[i] + b[i];
}
void AmplifierLayer::CalcError(void)
{
	for(int i=0; i<nInputs; i++)
		back_errors[i] = output_errors[i]/m[i];
}

OutputLayer::OutputLayer(Layer& layer,int nOut) :
Layer(layer,nOut)
{
	Init();
}
void OutputLayer::Init(void)
{
	weights=new double*[nOutputs];
	for(int i=0; i<nOutputs; i++)
	{
		weights[i]=new double[nInputs];
		for(int j=0; j<nInputs; j++)
			weights[i][j]=0.;
	}
}
OutputLayer::~OutputLayer()
{
	if(weights)
	{
		for(int i=0; i<nOutputs; i++)
			delete weights[i];
		delete weights;
	}
}
void OutputLayer::RandomizeWeights(void)
{
	for(int i=0; i<nOutputs; i++)
		for(int j=0; j<nInputs; j++)
			weights[i][j]=randm1p1();
}
void OutputLayer::ShowWeights(void)
{
	for(int i=0; i<nOutputs; i++)
	{
		printf("w%02d: ",i);
		for(int j=0; j<nInputs; j++)
			printf("%6.3lf ",weights[i][j]);
		printf("\n");
	}
}
void OutputLayer::ForwardProp(void)
{
	double* outp=output;
	for(int i=0; i<nOutputs; i++)
	{
		double* inp=input;
		//printf("first OL inp is %6.3lf\n",*inp);
		double* inpFinal=input+nInputs;
		double* weight=weights[i];
		double sum=0;
		while(inp<inpFinal)
			sum += *weight++ * *inp++;
		*outp++=sigmoid(sum);
	}
}
void OutputLayer::CalcError(void)
{
	for(int i=0; i<nInputs; i++)
	{
		double sum=0;
		for(int j=0; j<nOutputs; j++)
			sum+=weights[j][i]*output_errors[j];
		double s=input[i];
		back_errors[i] = sum * s*(1.-s);
	}
}
void OutputLayer::UpdateWeights(double beta)
{
/*ShowWeights();
getch();
ShowOutputErrors();
getch();
ShowInputs();
getch();*/
	for(int i=0; i<nInputs; i++)
	{
		double sum=0;
		for(int j=0; j<nOutputs; j++)
		{
			weights[j][i] += beta*output_errors[j]*input[i];
		}
	}
/*ShowWeights();
getch();*/
}


FFNN::FFNN(int nLay,int* layerSize)
{
	nLayers=nLay;
	layer=new Layer*[nLayers+1];
	layer[0]=new AmplifierLayer(layerSize[0]);
	for(int i=1; i<nLayers; i++)
		layer[i]=new OutputLayer(*layer[i-1],layerSize[i]);
	layer[nLayers]=new AmplifierLayer(*layer[nLayers-1]);
	
	RandomizeWeights();
}
FFNN::~FFNN()
{
	for(int i=0; i<nLayers+1; i++)
		if(layer[i]) delete layer[i];
	delete layer;
}
void FFNN::ForwardProp(double* in)
{
	layer[0]->SetInput(in);
	for(int i=0; i<nLayers+1; i++)
		layer[i]->ForwardProp();
}
void FFNN::RandomizeWeights(void)
{
	for(int i=1; i<nLayers; i++)
		layer[i]->RandomizeWeights();
}

void FFNN::BackwardProp(double* expected)
{
	int nOutputs=layer[nLayers]->OutputCount();

	double* errors=new double[nOutputs];
	for(int i=0; i<nOutputs; i++)
		errors[i]=expected[i]-layer[nLayers]->GetOutput(i);
	layer[nLayers]->SetOutputErrors(errors);

	for(i=nLayers; i>0; i--)
		layer[i]->CalcError();
	delete errors;
}

void FFNN::UpdateWeights(double beta)
{
	for(int i=1; i<nLayers; i++)
		layer[i]->UpdateWeights(beta);
}
double FFNN::Evaluate(TestData& in,TestData& out,int fShow)
{
	int n=in.NSamples();
	if(out.NSamples()!=n)
	{
		printf("EVALUATE: in samples <> outsamples\n");
		return 0;
	}

	int nInputs=layer[0]->InputCount();
	int nOutputs=layer[nLayers]->OutputCount();
	if(nInputs!=in.NElements())
	{
		printf("input NN=%d data=%d\n",nInputs,in.NElements());
		return 0;
	}
	if(nOutputs!=out.NElements())
	{
		printf("output NN=%d data=%d\n",nOutputs,out.NElements());
		return 0;
	}

	printf("Evaluate:\n");
	double* sum=new double[nOutputs];
	for(int i=0; i<nOutputs; i++) sum[i]=0.;
	for(i=0; i<n; i++)
	{
		ForwardProp(in[i]);
		if(fShow)
		{
			printf("in %6.3lf %6.3lf ",in[i][0],in[i][1]);
			printf("out %6.3lf %6.3lf act ",out[i][0],out[i][1]);
		}
		for(int j=0; j<nOutputs; j++)
		{
			double x=((OutputLayer*)layer[nLayers])->GetOutput(j);
			if(fShow) printf("%6.3lf ",x);
			double error=x-out[i][j];
			sum[j]+=error*error;
		}
		if(fShow) printf("\n");
	}

	for(i=0; i<nOutputs; i++)
		printf("  %02d: %6.3lf\n",i,sqrt(sum[i]/(double)n));

	return 0;
}
void FFNN::ShowAllOutputs(void)
{
	for(int i=0; i<nLayers+1; i++)
	{
		printf("Layer %d:\n",i);
		layer[i]->ShowOutputs();
	}
}

TestData::TestData(int nEl,int nSamp)
{
	nElements=nEl;
	nSamples=nSamp;
	data=new double*[nSamples];
	for(int i=0; i<nSamples; i++)
		data[i]=new double[nElements];
}
TestData::~TestData()
{
	if(data)
	{
		for(int i=0; i<nSamples; i++)
			delete data[i];
		delete data;
	}
}
double* TestData::operator [](int n)
{
	return data[n];
}
void TestData::Show(void)
{
	for(int i=0; i<nSamples; i++)
	{
		printf("%03d: ",i);
		for(int j=0; j<nElements; j++)
			printf("%6.3lf ",data[i][j]);
		printf("\n");
	}
}

