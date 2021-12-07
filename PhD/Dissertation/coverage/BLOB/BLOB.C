#include <stdio.h>
#include <stdlib.h>

#include <mvtools.h>
#include <itimgmgr.h>


void draw_crosshair(ImgWin* iw, int x, int y, int size, BYTE color)
{
	im_win_set_gr_color(iw,color);
	gr_line_xy(iw->overlay,NULL,x,y-size/2,x,y+size/2);
	gr_line_xy(iw->overlay,NULL,x-size/2,y,x+size/2,y);
}

void main()
{
Erflag error;
DWORD i;
ImgWin* iw;
Image* ov;
Image* im;
MVT_BLOB_PARAMS* blob_params;
MVT_BLOB_RESULTS* blob_results;
int dx,dy;
char image_file[256];
char *install_dir;
	
	// build full path of image file
	install_dir = im_get_install_dir(NULL,0);
	sprintf(image_file,"%s\\images\\4circle.bmp",install_dir);

	// get size of image file
	im_file_get_size(image_file,0,&dx,&dy,NULL,NULL);

	// create image window
	iw = im_win_create(dx,dy,NULL,FALSE);

	// set image window title
	im_win_set_title(iw, "Blob example");

	// get pointers to image and overlay
	ov = iw->overlay;		
	im = iw->image;

	// load image from file
	im_file_read(im,image_file,0);

	// Create blob parameters structure 
	blob_params = mvt_blob_create_params(&error);

	// Look for dark blobs (blob_color must be 0 or 255!)
	blob_params->blob_color = 0;

	// Create blob results structure - initially can hold 100 blobs, allow it to grow 
	blob_results = mvt_blob_create_results(100, TRUE, &error);

	// threshold image
	mvt_thresh_st(im,20,20,25,20,70,0);

	// Find blobs in image
	mvt_blob_find(im, blob_params, blob_results, 0);

	printf("%d blobs were found\n",MVT_NUM_BLOBS_FOUND(blob_results));

	// Show blob results
	im_win_set_gr_color(iw,250);
	for (i = 0; i < MVT_NUM_BLOBS_FOUND(blob_results); i++)
	{
		// Print blob results to console
		printf("%d area: %d perim: %d cent: %.2f,%.2f 1st point: %d,%d topleft: %d,%d botright: %d,%d\n",
			i,MVT_BLOB_AREA(blob_results,i),MVT_BLOB_PERIM(blob_results,i),
			MVT_BLOB_XCENT(blob_results,i),MVT_BLOB_YCENT(blob_results,i),
			MVT_BLOB_XFIRST(blob_results,i),MVT_BLOB_YFIRST(blob_results,i),
			MVT_BLOB_XMIN(blob_results,i),MVT_BLOB_YMIN(blob_results,i),
			MVT_BLOB_XMAX(blob_results,i),MVT_BLOB_YMAX(blob_results,i));

		// Overlay bounding box 
		gr_rectangle(ov, NULL, MVT_BLOB_XMIN(blob_results,i), MVT_BLOB_YMIN(blob_results,i), 
								MVT_BLOB_WIDTH(blob_results,i), MVT_BLOB_HEIGHT(blob_results,i));
		// Overlay crosshair at centroid 
		draw_crosshair(iw,(int)(MVT_BLOB_XCENT(blob_results,i)),(int)(MVT_BLOB_YCENT(blob_results,i)),10,250);
	}
	// Update image window 
	im_win_update(iw,TRUE);

	// prompt user
	printf("press any key to end example and close window\n");
	getchar();

	// delete image window structure & close physical window
	im_win_delete(iw,TRUE);

	// Free blob parameters & results structures
	mvt_blob_delete_params(blob_params);
	mvt_blob_delete_results(blob_results);
}
