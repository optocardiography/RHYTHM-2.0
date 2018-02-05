%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Description: An update of Dr. Matt Kay's getsilh.m file. This code is a
% simplification of his function. It identifies the largest connected
% component based on the user input threshold. It also performs
% morphological opening and closing to soften the region.
%
% Inputs:
%   a = the image of the heart
%   level = the threshold
%   aabb = whether the region of interest is above (1) or below (0) the 
%   threshold
%
% Outputs:
%   silh = the binary image resulting from thresholding and morphological
%   opening and closing

%% Code %%
  function [silh]=calcSilhWindow(a,top,bot)
  % Create binary image based on threshold method
  bw1 = (a <= top).*(a >= bot);
  
  % Find largest connected component
  CC = bwconncomp(bw1);
  biggestCC = zeros(1,length(CC.PixelIdxList));
  for n = 1:length(CC.PixelIdxList)
      biggestCC(n) = length(CC.PixelIdxList{n});
  end
  [~,I] = sort(biggestCC,'descend');
  biggestCC = CC.PixelIdxList{I(1)};
  
  % Create binary image largest CC
  bw1 = zeros(size(a));
  bw1(biggestCC) = 1;
  
  % Perform morphological opening (get rid of spurs) and closing (get rid
  % of invaginations and holes)
  SE = strel('disk',6,0);
  bw1 = imopen(bw1,SE);
  silh = imclose(bw1,SE);
  
end
  
