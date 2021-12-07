#include <stdio.h>
#include <stdlib.h>

#include <mvtools.h>
#include <itimgmgr.h>
#include <math.h>
#include <stdlib.h>

class Blob
{
public:
	int x0,y0,dx,dy,area,numholes;
	double cx,cy;
public:
	Blob();
	~Blob();
};

const int nBasicParams = 4*4;
const int nDifferenceParams = 120;
const int nSumParams = 120;
const int n3SumParams = 560;
const int nParams = nBasicParams + nDifferenceParams + nSumParams;
//const int nParams = nBasicParams + nBasicParams-1 + nBasicParams-1;


class BlobStat
{
public:
	double sum[nParams];
	double sumsq[nParams];
	double high[nParams];
	double low[nParams];
	double mean[nParams];
	double stddev[nParams];
	double hilim[nParams];
	double lolim[nParams];
	int N;
public:
	BlobStat();
	~BlobStat();
	void AddStat(int i,double val);
	void AddBlob(Blob* blob,Image* im);
	void ComputeStats(void);
	void PrintStats(void);
	void PrintStats(int* selected);
};

void draw_crosshair(ImgWin* iw, int x, int y, int size, BYTE color);
IMGCALL Erflag WINAPI mvt_convolve_3x3_2dec(Image *src, Image *dst, int *coef,
	int outlimit);
void RowSort(Blob* blob,int nBlobs,double avgHeight);
char Label(int b);
BOOL Overlap(double l1,double h1,double l2,double h2);
BOOL Distinguishable(int* selected,int nParams,int nBlobs,BlobStat* blobstat);
BOOL ScoutTrial(int nTrials,int nPicks,int nParams,int lowestParam,int highestParam,int nExpected,BlobStat* blobstat);



const int maxBlobs=100;
const int nExpected=38;
int selected[nParams];
void main(int argc,char** argv)
{

	printf("%d basic params, %d diffs, %d sums, %d 3sums (%d total)\n",
		nBasicParams,nDifferenceParams,nSumParams,n3SumParams,nParams);
	int imageDx,imageDy;
	char image_file[256];
	sprintf(image_file,"\\images\\ocv\\micfnt01.bmp");
	im_file_get_size(image_file,0,&imageDx,&imageDy,NULL,NULL);
	ImgWin* iw = im_win_create(imageDx,imageDy,NULL,FALSE);
	im_win_set_title(iw,"Input Window");
	HWND hInWnd=FindWindow(NULL,"Input Window");
	SetWindowPos(hInWnd,HWND_TOP,0,0,0,0,SWP_NOSIZE);

	Image* ov = iw->overlay;		
	Image* im = iw->image;

	// Input ROI positioning
	int inX0=70;
	int inY0=30;
	int inDx=330;
	int inDy=141;
	Image* roi=im_rroi(im,inX0,inY0,inDx,inDy);
	Image* roicopy=im_dup(roi);

	// Main console window positioning
	char appName[128];
	sprintf(appName,"\"%s\"",argv[0]);
	HWND hAppWnd=FindWindow(NULL,appName);
	SetForegroundWindow(hAppWnd);

	// Setup blob finding parameters
	int error;
	MVT_BLOB_PARAMS* blob_params = mvt_blob_create_params(&error);
	blob_params->blob_color = 255;
	blob_params->min_area=60;
	blob_params->min_height=20;
	blob_params->min_width=3;
	MVT_BLOB_RESULTS* blob_results = mvt_blob_create_results(maxBlobs,TRUE,&error);

	Blob* blob=new Blob[maxBlobs];
	BlobStat* blobstat=new BlobStat[nExpected];

	printf("Ready to go (any key)\n");
	getchar();

	double avgHeight=0;
	for(int image=1; image<=10; image++)
	{
		sprintf(image_file,"\\images\\ocv\\micfnt%02d.bmp",image);

		int baseThresh=53;
		int firstDThresh=-6;
		int lastDThresh=6;
		for(int dThresh=firstDThresh; dThresh<=lastDThresh; dThresh++)
		{
			int thresh=baseThresh+dThresh;
			
			im_file_read(im,image_file,0);

			mvt_copy(roi,roicopy);
			mvt_smooth(roicopy,roi);
			mvt_copy(roi,roicopy);
			mvt_smooth(roicopy,roi);
			mvt_thresh_st(roi,15,15,25,20,thresh,1);
			mvt_blob_find(roi,blob_params,blob_results, 0);

			int nBlobs=(int)MVT_NUM_BLOBS_FOUND(blob_results);
			if(nBlobs>maxBlobs) nBlobs=maxBlobs;

			//printf("%d blobs were found\n",MVT_NUM_BLOBS_FOUND(blob_results));

			mvt_constant(ov,0);
			im_win_set_gr_color(iw,250);
			if(nBlobs==nExpected)
			{
				for (int i=0; i<nBlobs; i++)
				{
					// load blob data
					blob[i].x0=MVT_BLOB_XMIN(blob_results,i);
					blob[i].y0=MVT_BLOB_YMIN(blob_results,i);
					blob[i].dx=MVT_BLOB_WIDTH(blob_results,i);
					blob[i].dy=MVT_BLOB_HEIGHT(blob_results,i);
					blob[i].cx=MVT_BLOB_XCENT(blob_results,i);
					blob[i].cy=MVT_BLOB_YCENT(blob_results,i);
					blob[i].area=MVT_BLOB_AREA(blob_results,i);
					blob[i].numholes=blob_results->blobs[i]->numholes;
				}
			
				if(avgHeight==0)
				{
					// compute average height for row sorting
					int sum=0;
					for(i=0; i<nBlobs; i++)
						sum+=blob[i].dy;
					avgHeight=sum/nBlobs;
					printf("avgHeight=%.1lf\n",avgHeight);
				}

				// sort and accumulate
				RowSort(blob,nBlobs,avgHeight);
				for (i=0; i<nBlobs; i++)
				{
					blobstat[i].AddBlob(&blob[i],im);
				}
			
				// annotate
				for (i=0; i<nBlobs; i++)
				{
					gr_rectangle(ov,NULL,blob[i].x0,blob[i].y0, 
						blob[i].dx,blob[i].dy);
					draw_crosshair(iw,(int)blob[i].cx,(int)blob[i].cy,10,250);
					char label[16];
					sprintf(label,"%d",i);
					gr_vectext(ov,NULL,blob[i].x0,blob[i].y0,10,0,label);
				}
			}
			else
			{
				printf("bad blob count image %d t=%d\n",image,thresh);
			}
			
			im_win_update(iw,TRUE);
		}
	}

	for(int i=0; i<nExpected; i++)
	{
		blobstat[i].ComputeStats();
		//printf("%c\n",Label(i));
		//blobstat[i].PrintStats();
	}

	// Hunt for the selection picks
	BOOL dist=FALSE;

	int best=40;
	for(int scout=0; scout<2; scout++)
	{
		if(ScoutTrial(1000000,best-1,nParams,0,nParams-1,nExpected,blobstat))
		{
			best--;
			scout--;
		}
	}

	// print database of last selected values
	for(i=0; i<nExpected; i++)
	{
		printf("%c\n",Label(i));
		blobstat[i].PrintStats(selected);
	}

	printf("press any key to end example and close window\n");
	getchar();

	im_delete(roi);
	im_delete(roicopy);
	im_win_delete(iw,TRUE);

	mvt_blob_delete_params(blob_params);
	mvt_blob_delete_results(blob_results);
}

BOOL ScoutTrial(int nTrials,int nPicks,int nParams,int lowestParam,int highestParam,int nExpected,BlobStat* blobstat)
{
	int nVals=highestParam-lowestParam+1;
	for(int t=0; t<nTrials; t++)
	{
		memset(selected,0,nParams*sizeof(int));
		for(int r=0; r<nPicks; r++)
		{
			int rval;
			do
				rval=lowestParam+rand()%nVals;
			while(selected[rval]);
			selected[rval]=TRUE;
		}

		int dist=Distinguishable(selected,nParams,nExpected,blobstat);
		if(dist)
		{
			// display selections
			for(int i=0; i<nParams; i++)
				putchar(selected[i]?'1':'0');
			printf("\n");
			printf("%d distinguishable=%d\n",nPicks,dist);
			return TRUE;
		}
	}
	return FALSE;
}

// Blob Methods
Blob::Blob()
{
}
Blob::~Blob()
{
}


void draw_crosshair(ImgWin* iw, int x, int y, int size, BYTE color)
{
	im_win_set_gr_color(iw,color);
	gr_line_xy(iw->overlay,NULL,x,y-size/2,x,y+size/2);
	gr_line_xy(iw->overlay,NULL,x-size/2,y,x+size/2,y);
}

// Sort blobs by "row"
void RowSort(Blob* blob,int nBlobs,double avgHeight)
{
	BOOL fGo=TRUE;
	double rowSlop=avgHeight*1.1;
	Blob tblob;

	while(fGo)
	{
		fGo=FALSE;
		for(int i=0; i<nBlobs-1; i++)
		{
			double dCy=blob[i].cy-blob[i+1].cy;

			BOOL fSwap=FALSE;
			if(dCy>rowSlop)
				fSwap=TRUE;
			else
				if(fabs(dCy)<rowSlop && blob[i].cx>blob[i+1].cx)
					fSwap=TRUE;
			if(fSwap)
			{
				tblob=blob[i];
				blob[i]=blob[i+1];
				blob[i+1]=tblob;
				fGo=TRUE;
			}
		}
	}

}

// BlobStat Methods
BlobStat::BlobStat()
{
	N=0;
	for(int i=0; i<nParams; i++)
	{
		sum[i]=0;
		sumsq[i]=0;
		high[i]=0;
		low[i]=999999;
		mean[i]=0;
		stddev[i]=0;
		hilim[i]=0;
		lolim[i]=0;
	}
}
BlobStat::~BlobStat()
{
}
void BlobStat::AddStat(int i,double val)
{
	sum[i]+=val;
	sumsq[i]+=val*val;
	if(val>high[i]) high[i]=val;
	if(val<low[i]) low[i]=val;
}

void BlobStat::AddBlob(Blob* blob,Image* im)
{
	int x0=blob->x0;
	int y0=blob->y0;
	int dx=blob->dx;
	int dy=blob->dy;

	Image* roi=im_rroi(im,x0,y0,dx,dy);

	int structDx=(dx+3)/4;
	int structDy=(dy+3)/4;
	if(structDx<1) structDx=1;
	if(structDy<1) structDy=1;
	double structSize=structDx*structDy;

	im_resize_rroi(roi,structDx,structDy);

	// Power Computations
	double* val=new double[nParams];
	int nextStat=0;
	for(int row=0; row<4; row++)
		for(int col=0; col<4; col++)
		{
			int xroi;
			int yroi;
			if(col<3) xroi=structDx*col;
			else xroi=dx-structDx;
			if(row<3) yroi=structDy*row;
			else yroi=dy-structDy;
			im_move_rroi(roi,x0+xroi,y0+yroi);
			double cnt=mvt_count_nz(roi);
		//mvt_constant(roi,128);
			val[nextStat] = cnt/structSize; // 0-1
			//val[nextStat] = 1. + cnt/structSize; // 1-2
			AddStat(nextStat++,val[nextStat]);
		}

	int p1,p2,p3;

	// 2-Difference Computations (120 of these; 16 choose 2)
	for(p1=0; p1<15; p1++)
		for(p2=p1+1; p2<16; p2++)
		{
			val[nextStat] = (1. + val[p1] - val[p2]) / 2.; // 0-1
			//val[nextStat] = (3. + val[p1] - val[p2]) / 2.; // 1-2
			AddStat(nextStat++,val[nextStat]);
		}
	
	// 2-Sum Computations
	for(p1=0; p1<15; p1++)
		for(p2=p1+1; p2<16; p2++)
		{
			val[nextStat] = (val[p1] + val[p2]) / 2.;  // any range
			AddStat(nextStat++,val[nextStat]);
		}
/*

	//int nBasic=nextStat;
	for(p1=0; p1<nBasicParams-1; p1++)
		AddStat(nextStat++,(val[p1]+val[p1+1])/2.);
	for(p1=0; p1<nBasicParams-1; p1++)
		AddStat(nextStat++,(3.+val[p1]-val[p1+1])/2.);
*/
	im_delete(roi);
	delete val;
	N++;
}

void BlobStat::ComputeStats(void)
{
	if(N<2) return;
	for(int i=0; i<nParams; i++)
	{
		mean[i]=sum[i]/N;
		double var=(N*sumsq[i] - sum[i]*sum[i])/N/(N-1.);
		if(var>0.) stddev[i]=sqrt(var);
		else stddev[i]=0;
		lolim[i] = low[i];
		hilim[i] = high[i];
		//lolim[i] = mean[i] - 2.*stddev[i];
		//hilim[i] = mean[i] + 2.*stddev[i];

		//if(lolim[i]>low[i]) lolim[i]=low[i];
		//if(hilim[i]<high[i]) hilim[i]=high[i];
	}
}

void BlobStat::PrintStats(void)
{
	int sel[nParams];
	memset(sel,1,nParams*sizeof(int));
	PrintStats(sel);
}
void BlobStat::PrintStats(int* selected)
{
	printf("M ");
	for(int i=0; i<nParams; i++)
	{
		if(selected[i]) printf("%lg ",mean[i]);
	}
	printf("\n");

	printf("S ");
	for(i=0; i<nParams; i++)
	{
		if(selected[i]) printf("%lg ",stddev[i]);
	}
	printf("\n");

	printf("H ");
	for(i=0; i<nParams; i++)
	{
		if(selected[i]) printf("%lg ",high[i]);
	}
	printf("\n");

	printf("L ");
	for(i=0; i<nParams; i++)
	{
		if(selected[i]) printf("%lg ",low[i]);
	}
	printf("\n");
}

char Label(int b)
{
	switch(b)
	{
	case 35: return '0';
	case 36: return '#';
	case 37: return '*';
	default:
		if(b<26) return b+'A';
		else return b-26+'1';
	}
}

BOOL Overlap(double l1,double h1,double l2,double h2)
{
	if(l1>=l2 && l1<=h2) return TRUE;
	if(h1>=l2 && h1<=h2) return TRUE;
	if(l2>=l1 && h2<=h1) return TRUE;
	return FALSE;
}

BOOL Distinguishable(int* selected,int nParams,int nBlobs,BlobStat* blobstat)
{
	for(int b=0; b<nBlobs-1; b++)
	{
		for(int c=b+1; c<nBlobs; c++)
		{
			if(b==c) continue;
			BOOL fSame=TRUE;
			for(int i=0; i<nParams && fSame; i++)
			{
				if(!selected[i]) continue;
				if(!Overlap(blobstat[b].lolim[i],blobstat[b].hilim[i],
					blobstat[c].lolim[i],blobstat[c].hilim[i]))
					fSame=FALSE;
			}
			if(fSame)
			{
				//printf("%c conflicts with %c\n",Label(b),Label(c));
				return FALSE;
			}
		}
	}
	return TRUE;
}
