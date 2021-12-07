#include <stdio.h>
#include <stdlib.h>

#include <mvtools.h>
#include <itimgmgr.h>
#include <math.h>

class Blob
{
public:
	int x0,y0,dx,dy,area,numholes;
	double cx,cy;
public:
	Blob();
	~Blob();
};

const int nParams=139;
const int pOccupation=0;
const int pAspect=1;
const int pNumHoles=2;
const int pPower=3; // through 18
const int pBalance=19; // through 138

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
};

void draw_crosshair(ImgWin* iw, int x, int y, int size, BYTE color);
IMGCALL Erflag WINAPI mvt_convolve_3x3_2dec(Image *src, Image *dst, int *coef,
	int outlimit);
void RowSort(Blob* blob,int nBlobs,double avgHeight);
char Label(int b);
BOOL Overlap(double l1,double h1,double l2,double h2);
BOOL Distinguishable(int* selected,int nParams,int nBlobs,BlobStat* blobstat);


int lengthenCoeff[4][10]=
   {
   { 0, 0, 0,
     1, 1, 1,
     0, 0, 0,
   3},
   { 0, 0, 1,
     0, 1, 0,
     1, 0, 0,
   3},
   { 0, 1, 0,
     0, 1, 0,
     0, 1, 0,
   3},
   { 1, 0, 0,
     0, 1, 0,
     0, 0, 1,
   3}
};

int angleCoeff[4][10]=
   {
   { 1, 1, 1,
     1, 1, 1,
    -2,-2,-2,
   1},
   { 1, 1, 1,
     1, 1,-2,
     1,-2,-2,
   1},
   { 1, 1,-2,
     1, 1,-2,
     1, 1,-2,
   1},
   { 1, 1, 1,
    -2, 1, 1,
    -2,-2, 1,
   1}
};


const int maxBlobs=100;
const int nExpected=38;
void main(int argc,char** argv)
{

	int imageDx,imageDy;
	char image_file[256];
	sprintf(image_file,"\\sher32\\images\\ocv\\micfnt01.bmp");
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

	// Output ROIs in display window
	ImgWin* outw = im_win_create(inDx/2*2+30,inDy/2*5+10,NULL,FALSE);
	im_win_set_title(outw,"Output Window");
	HWND hOutWnd=FindWindow(NULL,"Output Window");
	SetWindowPos(hOutWnd,HWND_TOP,imageDx+50,0,0,0,SWP_NOSIZE);
	Image* outim = outw->image;
	Image* outroi=im_rroi(outim,0,0,inDx/2,inDy/2);
	Image* outroi2=im_rroi(outim,0,0,inDx/2/2,inDy/2/2);
	Image* outroi3=im_rroi(outim,0,0,inDx/2/2/2,inDy/2/2/2);

	// Main console window positioning
	char appName[128];
	sprintf(appName,"\"%s\"",argv[0]);
	HWND hAppWnd=FindWindow(NULL,appName);
	SetWindowPos(hAppWnd,HWND_TOP,0,outw->image->dy+50,0,0,SWP_NOSIZE);
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
		sprintf(image_file,"\\sher32\\images\\ocv\\micfnt%02d.bmp",image);

		int baseThresh=53;
		int firstDThresh=-6;
		int lastDThresh=6;
		for(int dThresh=firstDThresh; dThresh<=lastDThresh; dThresh++)
		{
			int thresh=baseThresh+dThresh;
			
			im_file_read(im,image_file,0);

			// wavelet decomposition ideas...
			if(dThresh==firstDThresh)
			{
				for(int split=0; split<4; split++)
				{
					im_move_rroi(outroi,0,split*outroi->dy);
					im_move_rroi(outroi2,outroi->dx,split*outroi->dy);
					im_move_rroi(outroi3,outroi->dx+outroi2->dx,split*outroi->dy);
					mvt_convolve_3x3_2dec(roi,outroi,angleCoeff[split],OL_ABS);
					//mvt_threshold(outroi,250,0,255);
					mvt_convolve_3x3_2dec(outroi,outroi2,lengthenCoeff[split],OL_ABS);
					//mvt_threshold(outroi2,250,0,255);
					mvt_convolve_3x3_2dec(outroi2,outroi3,lengthenCoeff[split],OL_ABS);
					//mvt_threshold(outroi3,250,0,255);
				}
				im_win_update(outw,TRUE);
			}

			mvt_copy(roi,roicopy);
			mvt_smooth(roicopy,roi);
			mvt_copy(roi,roicopy);
			mvt_smooth(roicopy,roi);
			mvt_thresh_st(roi,15,15,25,20,thresh,1);
			mvt_blob_find(roi,blob_params,blob_results, 0);

			int nBlobs=(int)MVT_NUM_BLOBS_FOUND(blob_results);
			if(nBlobs>maxBlobs) nBlobs=maxBlobs;

			//if(printf("%d blobs were found\n",MVT_NUM_BLOBS_FOUND(blob_results));

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
		blobstat[i].PrintStats();
	}
	
	int selected[nParams];
	for(i=0; i<nParams; i++) selected[i]=TRUE;
	BOOL d=Distinguishable(selected,nParams,nExpected,blobstat);
	printf("Distinguisable=%d\n",d);

	printf("press any key to end example and close window\n");
	getchar();

	im_delete(roi);
	im_delete(roicopy);
	im_delete(outroi);
	im_delete(outroi2);
	im_delete(outroi3);
	im_win_delete(iw,TRUE);
	im_win_delete(outw,TRUE);

	mvt_blob_delete_params(blob_params);
	mvt_blob_delete_results(blob_results);
}

// Blob Methods
Blob::Blob()
{
}
Blob::~Blob()
{
}

// Decimating 3x3
IMGCALL Erflag WINAPI mvt_convolve_3x3_2dec(Image *src, Image *dst, int *coef,
	int outlimit)
{
	static const char funname[] = "mvt_convolve_3x3_2dec";
	int dx = min(src->dx,dst->dx*2);
	int dy = min(src->dy,dst->dy*2);
	int sum,middleRow;

	if (!mvt_iti_board_present())
		return(im_error(funname, MVT_NO_FRAME_GRABBER, NULL));

/* Src & Dst Images must be different */
	if (src == dst)
		return(im_error(funname, MVT_SAME_SRC_AND_DST, NULL));

/* Both Images must be type BYTE */
	if ((src->type != IM_BYTE) || (dst->type != IM_BYTE))
		return(im_error(funname, IM_BYTE_ONLY, NULL));

/* Can't 3x3 over tiny dimensions */
	if (dx < 3 || dy < 3)
		return(im_error(funname,IM_TOO_SMALL,NULL));

	if (1/*!mvt_use_mmx()*/) {
		int hm1 = dy-1;
		int c0=coef[0];
		int c1=coef[1];
		int c2=coef[2];
		int c3=coef[3];
		int c4=coef[4];
		int c5=coef[5];
		int c6=coef[6];
		int c7=coef[7];
		int c8=coef[8];
		int div=coef[9];
		if (div==1) div=0;

		int outRow=0;
		for (middleRow=1; middleRow<hm1; middleRow+=2)
		{
			PBYTE pp = dst->rat[outRow++];
			PBYTE p1=src->rat[middleRow-1];
			PBYTE p2=src->rat[middleRow];
			PBYTE p3=src->rat[middleRow+1];
			PBYTE p1Lim = p1+dx-2;
			while (p1<p1Lim) 
			{
				sum = c0 * *p1++;
				sum += c1 * *p1++;
				sum += c2 * *p1;
				sum += c3 * *p2++;
				sum += c4 * *p2++;
				sum += c5 * *p2;
				sum += c6 * *p3++;
				sum += c7 * *p3++;
				sum += c8 * *p3;
				if(div) sum=sum/div;
				if (outlimit != OL_WRAP) {
					if (outlimit == OL_ABS)
						sum = abs(sum);
					else
						if (sum < 0) sum = 0;
					if (sum > 255) sum = 255;
				}
				*pp++=sum;
			}
		}
	}
	else // MMX Version
	{}
	return (IM_OK);
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
	double occupation=(double)blob->area / (double)(blob->dx*blob->dy);
	double aspect=(double)blob->dy/(double)blob->dx;
	AddStat(pOccupation,occupation);
	AddStat(pAspect,aspect);
	AddStat(pNumHoles,blob->numholes);

	int x0=blob->x0;
	int y0=blob->y0;
	int dx=blob->dx;
	int dy=blob->dy;

	Image* roi=im_rroi(im,x0,y0,dx,dy);

	// Power computations
	int structDx=(dx+3)/4;
	int structDy=(dy+3)/4;
	if(structDx<1) structDx=1;
	if(structDy<1) structDy=1;
	double structSize=structDx*structDy;

	im_resize_rroi(roi,structDx,structDy);

	double power[4][4];
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
			power[row][col]=cnt/structSize;
		//mvt_constant(roi,128);
			AddStat(pPower+row*4+col,power[row][col]);
		}

	// Balance Computations (120 of these; 16 choose 2)
	int stat=0;
	for(row=0; row<4; row++)
		for(int col=0; col<4; col++)
			for(int row2=0; row2<4; row2++)
				for(int col2=0; col2<4; col2++)
					if(row!=row2 || col!=col2)
						AddStat(stat++,power[row][col]/power[row2][col2]);
	
	im_delete(roi);
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
		lolim[i]=mean[i]-2*stddev[i];
		hilim[i]=mean[i]+2*stddev[i];

		if(lolim[i]>low[i]) lolim[i]=low[i];
		if(hilim[i]<high[i]) hilim[i]=high[i];
	}
}

void BlobStat::PrintStats(void)
{
	printf("M ");
	for(int i=0; i<nParams; i++)
	{
		printf("%.3lf ",mean[i]);
	}
	printf("\n");

	printf("S ");
	for(i=0; i<nParams; i++)
	{
		printf("%.3lf ",stddev[i]);
	}
	printf("\n");

	printf("H ");
	for(i=0; i<nParams; i++)
	{
		printf("%.3lf ",high[i]);
	}
	printf("\n");

	printf("L ");
	for(i=0; i<nParams; i++)
	{
		printf("%.3lf ",low[i]);
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
	int lastConflict;
	BOOL fUnique;
	BOOL fPass=TRUE;
	
	int* madeUnique=new int[nParams];
	memset(madeUnique,0,nParams*sizeof(int));
	
	for(int b=0; b<nBlobs; b++)
	{
		for(int n=1; n<nParams; n++)
		{
			fUnique=TRUE;
			for(int c=0; c<nBlobs && fUnique; c++)
			{
				if(b==c) continue;
				fUnique=FALSE;
				BOOL fDistinguishable=FALSE;
				for(int i=0; i<n && !fDistinguishable; i++)
				{
					if(Overlap(blobstat[b].lolim[i],blobstat[b].hilim[i],
						blobstat[c].lolim[i],blobstat[c].hilim[i]))
						lastConflict=c;
					else
					{
						fDistinguishable=TRUE;
						madeUnique[n]++;
					}
				}
				if(fDistinguishable) fUnique=TRUE;
			}
			if(fUnique)
			{		
				printf("%c %d unique after %d parameters\n",Label(b),b,n);
				break;
			}
		}
		if(!fUnique)
			{		
				printf("%c %d NOT UNIQUE (lastConflict = %c)\n",Label(b),
					b,Label(lastConflict));
				fPass=FALSE;
			}
	}
return fPass;
}
