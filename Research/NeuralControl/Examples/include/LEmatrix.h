// LEMATRIX.H
// Matrix Libraries
// Copyright Lecky Engineering, LLC c. 1999,2000
// All Rights Reserved

// Revision History:
// Version 1.0.2  01-19-2000
// Version 1.0.3  02-02-2000
//	Added SetBlank
// Version 1.0.4  02-05-2000
//		Added matrix/scalar
//		Faster matmult
//		Added rat,Row/Col Juggle,leRandInt,Max,Min,leMax,leMin
// Version 1.0.5  03-07-2000
//		Added Invert and leInvert
// Version 1.1.0  03-13-2000
//		Added open operator scalar*mat, scaler+mat, etc.
//		Roundrobin of temp matrices for +,-,*,/

#if !defined(LEMATRIX_H)
#define LEMATRIX_H

#ifdef LEMATRIX_EXPORTS
#define LEMATRIX_API __declspec(dllexport)
#else
#define LEMATRIX_API __declspec(dllimport)
#endif

class LEMATRIX_API LEmatrix;

// The LEmatrix Object
class LEMATRIX_API LEmatrix
{
protected:
	// internal use only
	int nRows,nCols;			// size of the matrix
	int nAllocRows,nAllocCols;	// allocated storage for the matrix (>= size)
	char* name;					// printing name of the matrix
	double** d;					// dynamically allocated coefficient storage
public:
	// creation, adjustment, display
	LEmatrix(char* namestr=NULL,int nR=1,int nC=1);
	~LEmatrix();
	void DeleteAll(void);						// clear all matrix name and storage
	void SetName(char* namestr);				// set name to show when printing
	char* Name(void) {return name;}				// return name displayed when printing
	int Nrows(void) {return nRows;}				// return number of rows
	int Ncols(void) {return nCols;}				// return number of cols
	void SetSize(int nR,int nC);				// set matrix size to nR x nC
	void MakeSameSize(LEmatrix& m);				// resize to be the same size as m
	void Randomize(double min,double max);		// set all coeffs randomly from min to max
	void JuggleRows(int n,LEmatrix* m=NULL);	// randomly swap rows n times
	void JuggleCols(int n,LEmatrix* m=NULL);	// randomly swap cols n times
	void Print(int dp=2);						// print myself with dp decimal places
	double** rat(void) {return d;}				// tricky internal function

	// operators
	double* operator[](int r) {return d[r];}
	LEmatrix& operator=(LEmatrix& m);
	LEmatrix& operator=(double x);
	LEmatrix& operator*(LEmatrix& m);
	LEmatrix& operator*(double x);
	LEmatrix& operator/(double x);
	LEmatrix& operator+(LEmatrix& m);
	LEmatrix& operator+(double x);
	LEmatrix& operator-(LEmatrix& m);
	LEmatrix& operator-(double x);

	void SetIdentity(void);						// make into an identity matrix
	void SetZero(void);							// set all coeffs to zero
	void SetBlank(void);						// set all coeffs to smallest value <>0
	LEmatrix& AppendRows(LEmatrix& m);			// append the rows of m onto me
	LEmatrix& AppendCols(LEmatrix& m);			// append the columns of m onto me
	int Save(char* filename,int dp=4,			// save as filename with dp decimals
		bool hideBlank=false);					// if hideBlank=true, supress tiny nums
	int Load(char* filename);					// reload from filename

	// internal versions of global functions
	LEmatrix& Transpose(void);					// transpose myself
	LEmatrix& Invert(void);						// invert myself
	double Trace(void);							// return trace of the matrix
	double Norm2(void);							// return Eucl vec norm row or col vec
	double Max(void);							// return max el of matrix
	double Min(void);							// return min el of matrix
	
	// size m and setup row 0 and col 0 as label rows
	//	row 0 goes from minX[0] to maxX[0] in stepX[0] increments
	//	col 0 goes from minX[1] to maxX[1] in stepX[1] increments
	void SizeAndLabel(double* minX,double* maxX,double* stepX);
};
typedef LEmatrix* pLEmatrix;

// Global Functions
LEMATRIX_API       int leRandInt(int lo,int hi);	// return random int lo <= x <= hi
LEMATRIX_API      void lePrint(LEmatrix& m,int dp=2);// display m with dp decimals
LEMATRIX_API LEmatrix& leTranspose(LEmatrix& m);	// return a transposed copy of m
LEMATRIX_API LEmatrix& leInvert(LEmatrix& m);		// return the inverse of m
LEMATRIX_API    double leTrace(LEmatrix& m);		// return the trace of m
LEMATRIX_API    double leNorm2(LEmatrix& m);		// return the Euclidean vec norm of m
LEMATRIX_API    double leMax(LEmatrix& m);			// return max el of matrix
LEMATRIX_API    double leMin(LEmatrix& m);			// return min el of matrix
LEMATRIX_API LEmatrix& leRow(LEmatrix& m,int r);	// return row r of m
LEMATRIX_API LEmatrix& leCol(LEmatrix& m,int c);	// return column c of m
LEMATRIX_API LEmatrix& leDiag(LEmatrix& m);			// turn vector into diagonal mat
LEMATRIX_API LEmatrix& leIdentMat(int n);			// return an nxn identity matrix
LEMATRIX_API LEmatrix& leZeroMat(int n);			// return an nxn matrix of all 0s
LEMATRIX_API LEmatrix& leRowAvg(LEmatrix& m);		// return the average of each row in n
LEMATRIX_API LEmatrix& leColAvg(LEmatrix& m);		// return the average of each col in n

// Open operators
LEMATRIX_API LEmatrix& operator*(double x,LEmatrix& m);
LEMATRIX_API LEmatrix& operator+(double x,LEmatrix& m);
LEMATRIX_API LEmatrix& operator-(double x,LEmatrix& m);


#endif

