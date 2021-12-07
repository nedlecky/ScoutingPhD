MVTools Blob Example
-----------------------

This example is an example of MVTool's mvt_blob functions.
Blobs are found in an image from a file. Bounding boxes are written to 
the overlay and blob information is printed to the console output. 
The initialization functions: mvt_blob_create_params
and mvt_blob_create_results must be called once, before mvt_blob_find. 
The image processed by mvt_blob_find must be thresholded first.