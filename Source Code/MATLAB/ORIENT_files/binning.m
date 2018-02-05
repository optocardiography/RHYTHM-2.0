%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Spatially averages CMOS data with using a uniform binning algorithm

%INPUTS
%data = cmos data with structure N * N * time
%N = structure of input data, bin size

%OUTPUT 
%[data] = binned data

%METHOD
% The binning filter performs a 2D convolution of the data matrix with a 
% a matrix of ones. This technique averages a pixels with a specific number
% of neighbors. For example, if N = 3, binning averages each point 
% with eight points immediately surrounding it. 

%% Code
function [data] = binning(data,N)
avePattern = ones(N,N);
for i = 1:size(data,3)
    temp = data(:,:,i);
    temp = (1/N^2)*conv2(temp,avePattern,'same');
    data(:,:,i) = temp;
end