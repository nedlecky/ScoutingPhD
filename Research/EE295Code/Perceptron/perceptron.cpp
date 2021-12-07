/*
	This program implements a single output neuron and trains from a
	knowledge file using the Perceptron training algorithm.
   
    Usage:
		perceptron m/0 alpha filename
		  where:
	      'm' converts 0 inputs to -1 (and uses SIGN neuron -1/+1)
		  '0' leaves 0 inputs at 0 (and uses STEP neuron 0/1)
		  alpha is learning rate (double precision)
		  filename is the input file

	Example:
		perceptron m 1.2 194.txt

	File Format:
		nInputs nSamples
		in1 in2 in3 ... inN out
		in1 in2 in3 ... inN out
		...
		where:
		  nInputs is N, the number of input colummns
		  nSamples is the number of training samples in the set
*/
	  
		
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include <math.h>

#define TRUE -1
#define FALSE 0

/* one complete training sample:
   all inputs, and the desired output */
typedef struct trainingTag
{
	int* inputs;	/* input list (length is k.nInputs) */
	int output;		/* desired output */
} training;

/* the knowledge base */
struct knowledge
{
	int nInputs;	/* how many inputs into the neuron? */
	int nSamples;	/* how many training structures? */
	training* t;	/* the training structures */
} k;

/* a neuron:
   just a list of weights, where weight 0 always gets -1 for
   input to implement the threshold operation */
struct neuron
{
	double* weights;
} n;

/* Global flag; use 0/1 logig values or -1/1 */
int fUseZeros;

/* FUNCTION PROTOTYPES */
/* KB Operations */
int  ReadKnowledge(char* fname);
void ShowKnowledge(int test);
void ForgetKnowledge(void);

/* Generic Neuron Operations */
void SetupNeuron(void);
void ForgetNeuron(void);
void ShowNeuron(void);
void ResetWeightNeuron(void);
int  ApplyNeuron(int* inputs);

/* Perceptron Learning */
int  UpdatePerceptron(int* inputs,int output,double alpha);
int  TrainPerceptron(int nEpochs,double alpha);

/* Main Procedure
   Usage: perada <m|0> <alpha> <inputfile>
   */
int main(int argc,char** argv)
{
	char* fname;
	int nEpochs;
	double alpha=0.1;

	/* zero out knowledge base */
	k.nSamples=0;
	k.nInputs=0;
	k.t=NULL;
	
	if(argc!=4)
	{
		printf("Usage: perceptron <m|0> <alpha> <inputfile>\n");
		printf("  m treats 0s as -1, 0 treats them as 0\n");
		return 1;
	}

	/* parse command line arguments */
	if(argv[1][0]=='0')
		fUseZeros=TRUE;
	else
		fUseZeros=FALSE;

	if(sscanf(argv[2],"%lf",&alpha)!=1)
	{
		printf("ERROR interpreting alpha=[%s].\n",argv[1]);
		return 2;
	}
	fname=argv[3];

	printf("Neuron Simulator Alpha=%lf Input=%s\n",alpha,fname);

	/* load knowledge base from specified file */
	if(!ReadKnowledge(fname))
	{
		printf("ERROR reading [%s].\n",fname);
		return 3;
	}

	/* display input KB, and setup to run */
	ShowKnowledge(FALSE);
	SetupNeuron();

	/* PERCEPTRON Training and TEST */
	nEpochs=TrainPerceptron(50000,alpha);
	if(nEpochs<50000)
		printf("Needed %d Training Epochs to converge.\n",nEpochs);
	else
		printf("ERROR ERROR Did Not Converge!!!\n");
	ShowNeuron();
	//ShowKnowledge(TRUE);

	/* Cleanup */
	ForgetNeuron();
	ForgetKnowledge();

	return 0;
}

/* PERCEPTRON LEARNING */
int UpdatePerceptron(int* inputs,int output,double alpha)
/* returns 0 for no error, 1 for error detected */
{
	int i;
	int cur;
	double error;
	int input;

	/* current neuron reaction and error */
	cur=ApplyNeuron(inputs);
	error=output-cur;

	for(i=0; i<k.nInputs+1; i++)
	{
		/* handles the dummy input -1 which implements
		   the threshold */
		if(i==0) input=-1;
		else input=inputs[i-1];

		/* the beloved perceptron learning rule */
		n.weights[i]=n.weights[i] + alpha * input * error;
	}
	
	if(error) return 1;
	else return 0;
}

/* Run all knowledge sample past the neuron nEpochs times
   (or until no modifications necessary) */
int TrainPerceptron(int nEpochs,double alpha)
/* returns number of epochs run */
{
	int i,j;
	int errors=TRUE;

	for(i=0; i<nEpochs && errors; i++)
	{
		errors=FALSE;
		for(j=0; j<k.nSamples; j++)
			if(UpdatePerceptron(k.t[j].inputs,k.t[j].output,alpha))
				errors=TRUE;
	}
	
	return i;
}


/* GENERIC NEURON SETUP/DISPLAY/OPERATE FUNCTIONS */
/* allocate neuron storage */
void SetupNeuron(void)
{
	n.weights=(double*)malloc((k.nInputs+1)*sizeof(double));
	ResetWeightNeuron();
}

/* free neuron storage */
void ForgetNeuron(void)
{
	free(n.weights);
}

/* display current neuron weights */
void ShowNeuron(void)
{
	int i;

	for(i=0; i<k.nInputs+1; i++)
		printf("Weight %d = %.5lf\n",i,n.weights[i]);
}

/* clear neuron weights */
void ResetWeightNeuron(void)
{
	int i;

	for(i=0; i<k.nInputs+1; i++)
		n.weights[i]=1;
}

/* Neuron transfer function */
int ApplyNeuron(int* inputs)
{
	int i;
	double sum;

	sum= -1.0 * n.weights[0];
	for(i=0; i<k.nInputs; i++)
		sum += inputs[i]*n.weights[i+1];

	if(fUseZeros) /* step version */
	{
		if(sum>0.5) return 1;
		else return 0;
	}
	else /* sign version */
	{
		if(sum>0) return 1;
		else return -1;
	}
}

/* KNOWLEDGE BASE INPUT/DISPLAY FUNCTIONS */
/* read in the knowledge base from a file */
int ReadKnowledge(char* fname)
{
	int i,j;
	int inputs,samples;
	FILE* fp;

	/* open up the input file and get the number
	   of inputs and samples */
	fp=fopen(fname,"r");
	if(fp==NULL) return FALSE;

	if(2!=fscanf(fp,"%d %d",&inputs,&samples))
	{
		printf("Can't read inputs/samples.\n");
		fclose(fp);
		return FALSE;
	}

	/* allocate training structures */
	k.nSamples=samples;
	k.nInputs=inputs;
	k.t=(training *)malloc(samples*sizeof(training));

	/* pull in the samples */
	for(i=0; i<k.nSamples; i++)
	{
		k.t[i].inputs=(int*)malloc(inputs*sizeof(int));
		for(j=0; j<inputs; j++)
		{
			if(1!=fscanf(fp,"%d",&(k.t[i].inputs[j])))
			{
				printf("ERROR 1 reading file.\n");
				fclose(fp);
				return FALSE;
			}
			if(!fUseZeros)
				if(k.t[i].inputs[j]==0) k.t[i].inputs[j]=-1;
		}
		if(1!=fscanf(fp,"%d",&(k.t[i].output)))
		{
			printf("ERROR 2 reading file.\n");
			fclose(fp);
			return FALSE;
		}
		if(!fUseZeros)
			if(k.t[i].output==0) k.t[i].output=-1;
	}

	
	return TRUE;
}

/* display the knowledge base */
void ShowKnowledge(int test)
{
	int i,j;
	char buf[128];
	char tbuf[32];

	printf("Knowledge Base (%d inputs, %d samples)\n",
		k.nInputs,k.nSamples);

	for(i=0; i<k.nSamples; i++)
	{
		buf[0]=0;
		for(j=0; j<k.nInputs; j++)
		{
			sprintf(tbuf,"%2d",k.t[i].inputs[j]);
			strcat(buf,tbuf);
		}
		sprintf(tbuf,"  %2d",k.t[i].output);
		strcat(buf,tbuf);
		printf("%3d: %s",i,buf);
		if(test)
			printf(" %2d",ApplyNeuron(k.t[i].inputs));
		printf("\n");
	}
}

/* erase the knowledge base */
void ForgetKnowledge(void)
{
	int i;

	for(i=0; i<k.nSamples; i++)
		free(k.t[i].inputs);
	
	free(k.t);
}
