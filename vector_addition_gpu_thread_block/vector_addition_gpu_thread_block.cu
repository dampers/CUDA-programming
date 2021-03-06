#include <stdio.h>

#define N 32

__global__ void device_add(int *a, int *b, int *c)
{
    int index = threadIdx.x + blockIdx.x*blockDim.x;
    c[index] = a[index] + b[index];
}

void fill_array(int *data)
{
    for(int idx=0;idx<N;idx++)
        data[idx] = idx;
}

void print_output(int *a, int *b, int *c)
{
    for(int idx=0;idx<N;idx++)
        printf("\n %d + %d = %d", a[idx], b[idx], c[idx]);
}

int main()
{
    int *a, *b, *c;
    int *d_a, *d_b, *d_c;
    int thread_per_block = 0, no_of_blocks = 0;
    int size = N * sizeof(int);
 
    a = (int *)malloc(size);
    fill_array(a);
    b = (int *)malloc(size);
    fill_array(b);
    c = (int *)malloc(size);
    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

    
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
    thread_per_block = 4;
    no_of_blocks = N / thread_per_block;
    device_add<<<no_of_blocks,thread_per_block>>>(d_a, d_b, d_c);
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
    
    print_output(a, b, c);
    free(a);free(b);free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}
