#include <stdio.h>
#include <stdlib.h>

__global__ void vectorAdd(int* a, int* b, int* c, int n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    
    if(tid < n)
        c[tid] = a[tid + b[tid]];
}

int main() {
    int n = 1 << 20;
    
    //Host pointers
    int* h_a;
    int* h_b;
    int* h_c;
    
    //Device pointers
    int* d_a;
    int* d_b;
    int* d_c;

    size_t bytes = n * sizeof(int);
    //Allocate memory (RAM)
    h_a = (int*) malloc(bytes);
    h_b = (int*) malloc(bytes);
    h_c = (int*) malloc(bytes);

    for(int i = 0; i < n; ++i) {
        h_a[i] = 1;
        h_b[i] = 2;
    }

    //Allocate memory (VRAM)
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    //Init block and grid size
    int block_size = 1024;
    int grid_size  = (int) ceil((float) n / block_size);
    printf("Grid size is %d\n", grid_size);

    //Copying mem...
    cudaMemCpy(d_a, h_a, bytes, cudaMemCpyHostToDevice);
    cudaMemCpy(d_b, h_b, bytes, cudaMemCpyHostToDevice);

    vectorAdd<<<grid_size, block_size>>>(d_a, d_b, d_c, n);
    
    cudaMemCpy(h_c, d_c, bytes, cudaMemCpyDeviceToHost);

    for(int i = 0; i < n; ++i) {
        if(h_c != 3){ 
            printf("Error!\n");
            break;
        }
    }
    printf("Completed successfully!\n");

    //Free mem...
    free(h_a);
    free(h_b);
    free(h_c);

    //Free vram
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}