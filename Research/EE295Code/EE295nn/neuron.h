#if !defined(neuron_h)
#define neuron_h

class Neuron
{
private:
	int nInputs;
	double* weights;
public:
	Neuron();
	~Neuron();
	void InitializeWeights(void);
	void NumInputs(int x);
	int NumInputs(void);
	double Sigma(double x);
	void ShowWeights(void);
	double Execute(double* inputs);
};


#endif