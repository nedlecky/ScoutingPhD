#if !defined(FFNN_H)
#define FFNN_H

double randm1p1(void);
double sigmoid(double x);

class TestData
{
private:
	int nElements;
	int nSamples;
	double** data;
public:
	TestData(int nEl,int nSamp);
	~TestData();
	void Show(void);
	double* operator[](int x);
	int NElements(void) {return nElements;}
	int NSamples(void) {return nSamples;}
};

class Layer
{
protected:
	int nInputs;
	int nOutputs;
	double* input;			// external reference
	double* output;			// hard storage
	double* output_errors;	// external reference
	double* back_errors;	// hard storage
public:
	Layer(int nIn,int nOut);
	Layer(Layer& layer,int nOut);
	void Init(int nIn,int nOut);
	~Layer();
	virtual void RandomizeWeights(void) {};
	virtual void UpdateWeights(double beta) {};
	void SetInput(double* in) {input=in;}
	void SetOutputErrors(double* in) {output_errors=in;}
	double* GetBackErrors(void) {return back_errors;}
	double GetOutput(int i) {return output[i];}
	void ShowInputs(void);
	void ShowOutputs(void);
	void ShowOutputErrors(void);
	int InputCount(void) {return nInputs;}
	int OutputCount(void) {return nOutputs;}
	double* OutputPtr(void) {return output;}
	virtual void ForwardProp(void) {};
	virtual void CalcError(void) {};
};

class AmplifierLayer : public Layer
{
private:
	double* m;
	double* b;
public:
	AmplifierLayer(int nIn);
	AmplifierLayer(Layer& layer);
	void Init(void);
	~AmplifierLayer();
	void Reset(void);
	void SetScaling(TestData& data,int fInput);
	void UnityScaling(void);
	void ShowScaling(void);
	void ForwardProp(void);
	void CalcError(void);;
};

class OutputLayer : public Layer
{
protected:
	double** weights;
public:
	OutputLayer(int nIn,int nOut);
	OutputLayer(Layer& layer,int nOut);
	void Init(void);
	~OutputLayer();
	void RandomizeWeights(void);
	void ShowWeights(void);
	void ForwardProp(void);
	void CalcError(void);
	void UpdateWeights(double beta);
};

class FFNN
{
private:
	int nLayers;
	Layer** layer;
//	int* layerSize;
public:
	FFNN(int nLay,int* layerSize);
	~FFNN();
	AmplifierLayer* InputAmps(void) {return (AmplifierLayer*)layer[0];}
	AmplifierLayer* OutputAmps(void) {return (AmplifierLayer*)layer[nLayers];}
	void RandomizeWeights(void);
	void ForwardProp(double* in);
	void BackwardProp(double* expected);
	void UpdateWeights(double beta);
	double Evaluate(TestData& in,TestData& out,int fShow=0);
	void ShowAllOutputs(void);
	Layer* LayerPtr(int i) {return layer[i];}
};



#endif