#include <stdio.h>

__global__ void VectorAdd(int *a, int *b, int *c)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	c[tid] = a[tid] + b[tid];
}

int main()
{
	const int size = 512*65535;
	const int BufferSize = size*sizeof(int);

	int *InputA, *InputB, *Result;
	InputA = (int*)malloc(BufferSize);
	InputB = (int*)malloc(BufferSize);
	Result = (int*)malloc(BufferSize);
	
	int i = 0;
	for(i=0;i<size;i++)
	{
		InputA[i] = i;
		InputB[i] = i;
		Result[i] = 0;
	}

	int *dev_A, *dev_B, *dev_R;
	cudaMalloc((void**)&dev_A, size*sizeof(int));
	cudaMalloc((void**)&dev_B, size*sizeof(int));
	cudaMalloc((void**)&dev_R, size*sizeof(int));

	cudaMemcpy(dev_A, InputA, size*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_B, InputB, size*sizeof(int), cudaMemcpyHostToDevice);

	VectorAdd<<<65535, 512>>>(dev_A, dev_B, dev_R);
	cudaMemcpy(Result, dev_R, size*sizeof(int), cudaMemcpyDeviceToHost);

	for(i=0;i<5;i++)
		printf("Result[%d] : %d\n", i, Result[i]);
	printf("......\n");

	for(i=size-5;i<size;i++)
		printf("Result[%d] : %d\n", i, Result[i]);

	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_R);
	free(InputA);
	free(InputB);
	free(Result);

	return 0;
}