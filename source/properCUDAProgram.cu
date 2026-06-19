#include <cuda_runtime.h>
#include "randomGen.h"
#include <memory>
#include <cuda/cmath>
#include <iostream>
#include <string>

__global__ void vecAdd(float* A , float* B , float* C , int vectorLength)
{
    int workerIndex = threadIdx.x + blockIdx.x * blockDim.x ;

    if( workerIndex < vectorLength )
    {
        C[workerIndex] = A[workerIndex] + B[workerIndex] ;
    }
}

void initArray(float* A , int length)
{
    for( int index { } ; index < length ; ++ index )
    {
        A[index] = static_cast<float>(prng::getReal(0.0,2147483646.0)) ;
    }   
}

void serialAddVec(float* A , float* B , float* C , int length)
{
    for( int index { } ; index < length ; ++ index )
    {
        C[index] = A[index] + B[index] ;    
    }
}

bool vectorApproximatelyEqual(float* A , float* B, int length , float epsilon = 0.00001 )
{
    for( int index { } ; index < length ; ++ index )
    {
        if( std::fabs( A[index] - B[index]  ) > epsilon )
        {
            std::cout << "Index mismatch : " << A[index] << "!=" << B[index] << '\n' ;
            return false ;
        } 
    }

    return true ;
}

void explicitMemoryExample( int vectorLength )
{
    //Pointers to host memory 
    float* A = nullptr ;
    float* B = nullptr ;
    float* C = nullptr ;
    float* comparisonResult = new float[vectorLength] ;

    //Pointers to device memory
    float* devA = nullptr ;
    float* devB = nullptr ;
    float* devC = nullptr ;

    //Allocate mem to the correct host mem addresses 
    cudaMallocHost(&A , vectorLength*sizeof(float));
    cudaMallocHost(&B , vectorLength*sizeof(float));
    cudaMallocHost(&C , vectorLength*sizeof(float));

    //Initialize arrays to host 
    initArray(A , vectorLength);
    initArray(B , vectorLength);

    //Allocate mem for the arrays to the GPU
    cudaMalloc(&devA , vectorLength*sizeof(float));
    cudaMalloc(&devB , vectorLength*sizeof(float));
    cudaMalloc(&devC , vectorLength*sizeof(float));

    //Copy the data from the host to the device
    //Also clean out any data that is located at our
    //results array
    cudaMemcpy(devA, A , vectorLength*sizeof(float) , cudaMemcpyHostToDevice);
    cudaMemcpy(devB, B , vectorLength*sizeof(float) , cudaMemcpyHostToDevice);
    cudaMemset(devC, 0 , vectorLength*sizeof(float));

    //Launch the kernel specified the execution config details 
    int threads = 1024 ;
    int blocks = cuda::ceil_div(vectorLength , threads) ;
    vecAdd<<<blocks, threads>>>(devA, devB , devC , vectorLength) ;

    //Synchronize by waiting the kernel to return 
    cudaDeviceSynchronize() ;

    //Copy results back to host 
    cudaMemcpy(C , devC , vectorLength*sizeof(float) , cudaMemcpyDeviceToHost);

    //Perform the same task at the CPU
    serialAddVec(A , B , comparisonResult , vectorLength) ;

    //Check if the CPU and GPU got the same answers
    if(vectorApproximatelyEqual(C , comparisonResult, vectorLength))
    {
        std::cout << "Explicit Memory: CPU and GPU answers match\n" ;
    }
    else
    {
        std::cout << "Explicit Memory: Error - CPU and GPU answers to not match\n" ;
    }

    //Free the device allocated arrays
    cudaFree(devA);
    cudaFree(devB);
    cudaFree(devC);

    //Free the host allocated arrays
    cudaFreeHost(A);
    cudaFreeHost(B);
    cudaFreeHost(C);

    //Delete the comparison result 
    delete[] comparisonResult ;

}

int main(int argc, char** argv)
{
    int vectorLength = 4096 ;

    if(argc >=2)
    {
        vectorLength = std::stoi(argv[1]);
    }

    explicitMemoryExample(vectorLength);

    return 0;
}
