// LENEURALNET.H
// Neural Network Libraries
// Copyright Lecky Engineering, LLC c. 1999,2000
// All Rights Reserved

// Revision History:
// Version 1.0.2 01-19-2000
// Version 1.0.3 01-21-2000
//		Generalized for dual non-linearites
//		Made notation consistent with documentation
// Version 1.0.4 01-24-2000
//		More notational inconsistencies
//		Added LEAlinear for testing purposes
// Version 1.0.5 02-10-2000
//		Added leEcalc

#if !defined (LENEURALNET_H)
#define LENEURALNET_H

#ifdef LENEURALNET_EXPORTS
#define LENEURALNET_API __declspec(dllexport)
#else
#define LENEURALNET_API __declspec(dllimport)
#endif

#include "LEmatrix.h"

// Activation Functions
typedef LENEURALNET_API double(*ActivationFunction)(double x);
LENEURALNET_API double LEAlinear(double x);
LENEURALNET_API double LEAhardlimit(double x);
LENEURALNET_API double LEAsymhardlimit(double x);
LENEURALNET_API double LEAlinearthresh(double x);
LENEURALNET_API double LEAsigmoid(double x);
LENEURALNET_API double LEAsymsigmoid(double x);
LENEURALNET_API double LEAtanh(double x);
LENEURALNET_API double LEAaugrat(double x);

// Error reducer; returns 0.5*sum_of_squares_of_all_elements_of_e
LENEURALNET_API double leEcalc(LEmatrix& e);

// Apply activation functions to a matrix
LENEURALNET_API LEmatrix& leSigma(LEmatrix& m,ActivationFunction func);
LENEURALNET_API LEmatrix& leSigmabar(LEmatrix& m,ActivationFunction func);

// Single Neuron, augmented matrices, Vtranspose (degenerates to SingleLayer)
LENEURALNET_API LEmatrix& leOneNeuron(LEmatrix& vT,LEmatrix& x,ActivationFunction func);

// Single Layer, augmented matrices, Vtranspose
LENEURALNET_API LEmatrix& leOneLayer(LEmatrix& VT,LEmatrix& x,ActivationFunction func);

// Two layer NN, augmented matrices, linear outputs, Vtranspose
LENEURALNET_API LEmatrix& leTwoLayerLinear(LEmatrix& VT,LEmatrix& WT,
	LEmatrix& x,ActivationFunction func);

// Two layer NN, augmented matrices, same nonlinearity both layers, Vtranspose
LENEURALNET_API LEmatrix& leTwoLayer(LEmatrix& VT,LEmatrix& WT,
	LEmatrix& x, ActivationFunction func1,ActivationFunction func2);

// Two layer NN, unaugmented matrices, linear outputs, Vtranspose
LENEURALNET_API LEmatrix& leTwoLayerLinearUnaug(LEmatrix& VbarT,LEmatrix& bv,
	LEmatrix& WbarT,LEmatrix& bw,LEmatrix& xbar,ActivationFunction func);

// Two layer NN, unaugmented matrices, same nonlinearity both layers, Vtranspose
LENEURALNET_API LEmatrix& leTwoLayerUnaug(LEmatrix& VbarT,LEmatrix& bv,
	LEmatrix& WbarT,LEmatrix& bw,LEmatrix& xbar,
	ActivationFunction func1,ActivationFunction func2);

// Two layer NN Function Approximator
// 2 Layer NN, tanh layer1 linear layer2, V&Wtranspose, x augmented
LENEURALNET_API LEmatrix& leNNApprox1(LEmatrix& VT,LEmatrix& WT,LEmatrix& x);
LENEURALNET_API double leTrainApprox1(LEmatrix& VT,LEmatrix& WT,LEmatrix& p,LEmatrix& Y,
									  int L,int maxEpochs,double eta,double eLimit);

#endif