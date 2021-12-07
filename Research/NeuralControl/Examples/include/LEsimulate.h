// LESIMULATE.H
// Simulation and Numerical Integration Libraries
// Copyright Lecky Engineering, LLC c. 1999,2000
// All Rights Reserved

// Revision History:
// Version 1.0.0 02-10-2000
// Version 1.1.0 05-10-2000		Added leODErk4Aug(...)

#if !defined(LESIMULATE_H)
#define LESIMULATE_H

#ifdef LESIMULATE_EXPORTS
#define LESIMULATE_API __declspec(dllexport)
#else
#define LESIMULATE_API __declspec(dllimport)
#endif

#include "LEmatrix.h"

typedef LESIMULATE_API void(*DifferentialFunction)(double x[],double xdot[]);
typedef LESIMULATE_API void(*DifferentialFunctionAug)(double x[],double xdot[],void* params);
LESIMULATE_API LEmatrix& leODEeuler(DifferentialFunction func,double t0,double tf,double dt,LEmatrix& x0);
LESIMULATE_API LEmatrix& leODErk2(DifferentialFunction func,double t0,double tf,double dt,LEmatrix& x0);
LESIMULATE_API LEmatrix& leODErk3(DifferentialFunction func,double t0,double tf,double dt,LEmatrix& x0);
LESIMULATE_API LEmatrix& leODErk4(DifferentialFunction func,double t0,double tf,double dt,LEmatrix& x0);
LESIMULATE_API LEmatrix& leODErk4Aug(DifferentialFunctionAug func,double t0,double tf,double dt,LEmatrix& x0,void* param);
LESIMULATE_API LEmatrix& leODErkf5(DifferentialFunction func,double t0,double tf,LEmatrix& x0,
					double epsilon,double dt0,double dtmin,double dtmax,
					LEmatrix& xscale);

#endif

