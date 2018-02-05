%% Generate Square Kernel
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: This function generates a square kernel of the desired size
% tailored to the image provided in the input.
%
% Input:
% im = the image variable
% num = the width of the kernel, should be greater than 3 and odd
%
% Output:
% kernel = it's in the name

%% Code %%
function [kernel] = makeSquareKernel2D(im,num)
% Get the number of rows for figuring out index values
imY = size(im,1);
% Create variable for vertical component
vert = (-(num-1)/2:(num-1)/2)';
% Create empty variable for kernel
kernel = zeros(length(vert),length(vert));
% Create kernel
for n = 1:length(vert)
    if n == round(num/2)
        kernel(:,n) = vert;
    elseif n < round(num/2)
        kernel(:,n) = -imY*(n+floor(num/2)-((n-1)*2+1))+vert;
    elseif n > round(num/2)
        kernel(:,n) = imY*(n-round(num/2))+vert;
    end
end

end