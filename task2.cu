#include <stdio.h>
#include <stdlib.h>

#define N 22

__global__ void MatAdd(int A[][N], int B[][N], int C[][N]){
           int i = threadIdx.x;
           int j = threadIdx.y;

           C[i][j] = A[i][j] + B[i][j];
}

void randmatfunc(int newmat[N][N]){
  int i, j, k; 
    for(i=0;i<N;i++){
        for(j=0;j<N;j++){
          k = rand() % 100 + 1;;
            printf("%d ", k);
            newmat[i][j] =k;
        }
        printf("\n");
       
    } 
  printf("\n--------------------------------------\n"); 
}

int main(){

int A[N][N];  
randmatfunc(A);
  
int B[N][N];  
randmatfunc(B);  



  int C[N][N];

  int (*d_A)[N], (*d_B)[N], (*d_C)[N];

  //Allocate memories for device copies of A,B,C
  
  cudaMalloc((void**)&d_A, (N*N)*sizeof(int));
  cudaMalloc((void**)&d_B, (N*N)*sizeof(int));
  cudaMalloc((void**)&d_C, (N*N)*sizeof(int));
  
  //Alloc space for host copies of A,B,C and setup input values

  cudaMemcpy(d_A, A, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_C, C, (N*N)*sizeof(int), cudaMemcpyHostToDevice);

  int numBlocks = 1;
  dim3 threadsPerBlock(N,N);
  
  //Launch MatAdd() kernel on GPU 
  
  MatAdd<<<numBlocks,threadsPerBlock>>>(d_A,d_B,d_C);

  //copy results back to host
  cudaMemcpy(C, d_C, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);

  int i, j; printf("C = \n");
    for(i=0;i<N;i++){
        for(j=0;j<N;j++){
            printf("%d ", C[i][j]);
        }
        printf("\n");
    }

  //cleanup
  cudaFree(d_A); 
  cudaFree(d_B); 
  cudaFree(d_C);

  printf("\n");

  return 0;
}

