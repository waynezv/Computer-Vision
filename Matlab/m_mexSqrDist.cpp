#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "m_malloc.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){   
   /* check for the proper no. of input and outputs */
   if (nrhs != 2)
   mexErrMsgTxt("2 input arguments are required");
   if (nlhs>1)
   mexErrMsgTxt("Too many outputs");

   /* Get the no. of dimentsions and size of each dimension in the input 
   array */
   const int *sizeData1 = mxGetDimensions(prhs[0]);
   const int *sizeData2 = mxGetDimensions(prhs[1]);

   /* Get the dimensions of the input image */
   int d = sizeData1[0]; 
   int n = sizeData1[1]; 
   int m = sizeData2[1];
   int Output = 0;

   /* Get the pointers to the input Data */  
   double *Data1Ptr = mxGetPr(prhs[0]);
   double *Data2Ptr = mxGetPr(prhs[1]);

   double **Data1, **Data2;

   Data1 = buildMatrix<double>(d, n);
   Data2 = buildMatrix<double>(d, m);

   
   // Assign the data 
   for (int j=0; j<n; j++){
      for (int i=0; i<d; i++){
         Data1[i][j] = ((double) (*Data1Ptr));
         Data1Ptr++;  
      }
   }

   for (int j=0; j<m; j++){
      for (int i=0; i<d; i++){
         Data2[i][j] = ((double) (*Data2Ptr));
         Data2Ptr++;  
      }
   }

   if (Output){
      printf("d: %d, n: %d, m: %d\n", d, n, m); 
   }

   
   /* Create the outGoing Array  */
   plhs[0] = mxCreateNumericMatrix(n, m, mxDOUBLE_CLASS, mxREAL);   
   double *labelOutPtr = mxGetPr(plhs[0]); 

   double tmp;
   for (int j=0; j < m; j++){
      for (int i=0; i < n; i++){
         tmp = 0;
         for (int k=0; k < d; k++){
            tmp += (Data1[k][i] - Data2[k][j])*(Data1[k][i] - Data2[k][j]);
         }
         *labelOutPtr = tmp;
         labelOutPtr++;
      }
   }

   destroyMatrix<double>(Data1, d, n);
   destroyMatrix<double>(Data2, d, m);
} 
  