#! /bin/bash 

scp  -P 25564 -r paam@169.235.21.73:~/Research/data/V-C/ ./
scp -P 25564 -r paam@169.235.21.73:/home/paam/Research/cuda-samples/Samples/3_CUDA_Features/StreamPriorities/*.csv ./
