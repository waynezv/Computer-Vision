#ifndef M_MALLOC_H
#define M_MALLOC_H

#ifdef _DEBUG
   #define DEBUG_CLIENTBLOCK   new( _CLIENT_BLOCK, __FILE__, __LINE__)
#else
   #define DEBUG_CLIENTBLOCK
#endif

#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

#ifdef _DEBUG
#define new DEBUG_CLIENTBLOCK
#endif

template <typename Type>
Type* buildVector(int mRows){  
   Type *imPr = new Type [mRows];
   for (int i=0; i < mRows; i++) imPr[i] = 0; 
   return imPr;
}

template <typename Type>
void destroyVector(Type *imPr, int mRows){  
   delete [] imPr ;
}

template<typename Type>
Type** buildMatrix(int mRows, int nCols){
   Type **imPr = new Type* [mRows];
   for (int i=0; i<mRows; i++){
      imPr[i] = buildVector<Type>(nCols);      
   }
   return imPr;
}

template<typename Type>
void destroyMatrix(Type **imPr, int mRows, int nCols){  
   for (int i=0; i<mRows; i++){
      destroyVector<Type>(imPr[i], nCols);
   }
   delete [] imPr;
}


template<typename Type> 
Type*** buildArrayThree(int mRows, int nCols, int numIm){
   Type ***imPr = new Type** [mRows];

   for (int i=0; i<mRows; i++){
      imPr[i] = new Type* [nCols] ;
      for (int j=0; j<nCols; j++){
         imPr[i][j] = buildVector<Type>(numIm);         
      }
   }
   return imPr;
}

template<typename Type> 
void destroyArrayThree(Type ***imPr, int nRows, int nCols, int numIm){
   for (int i=0; i<nRows; i++){
      for (int j=0; j<nCols; j++){
         destroyVector<Type>(imPr[i][j], numIm);         
      }
      delete [] imPr[i];
   }
   delete [] imPr;   
}

template<typename Type>
Type**** buildArrrayFour(int d1, int d2, int d3, int d4){
   Type ****imPr = new Type***[d1];
   for (int i=0; i < d1; i++){
      imPr[i] = buildArrayThree(d2, d3, d4);
   };
   return imPr;
}

template<typename Type>
void destroyArrrayFour(Type**** imPr, int d1, int d2, int d3, int d4){   
   for (int i=0; i < d1; i++){
      imPr[i] = destroyArrayThree(d2, d3, d4);
   };
   delete [] imPr;
   return imPr;
}

template<typename Type>
Type** buildVectors(int nVec, int *vecSzs){
   Type **imPr = new Type*[nVec];
   for (int i=0; i < nVec; i++){
      imPr[i] = buildVector(vecSzs[i]);
   }
   return imPr;
}

template<typename Type>
void destroyVectors(Type** imPr, int nVec, int *vecSzs){   
   for (int i=0; i < nVec; i++){
      imPr[i] = destroyVector(vecSzs[i]);
   }
   delete [] imPr;   
}



#endif