%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%% remove_BKGRD is a signial conditioning function
% new_data = remove_BKGRD(data,bg) removes the
% segments the tissue of interest and image background from the CMOS
% black and white background image, bg.  By segmenting the foreground
% image, a mask can be created to zero out background pixels.
% 
% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% 
% bg = black and white background image from the CMOS camera.  This is a
% 100X100 pixel image from the micam ultima system. bg is stored in the
% handles structure handles.bg.
%
%thresh = must be between 0 and 1. % of graythreshold used for image segmentation
%
% perc_ex = must be between 0 and 1. Represents exclusion criteria. Groups
% of pixels less than X% of total image size are removed.

% OUTPUT
% new_data = cmos data that has the background pixels zeroed out by the
% background mask

% METHOD 1
% This method uses edge detection to detect all objects in the black and
% white image.  First a Canny filter is used to detect all edges in an
% image and estimate a general threshold. We multiply Matlab's
% auto-threshold by .55 to ensure that all edges are found.  Next, the edges
% are dialated using a cross structuring element (strel) in order to
% connect non-continuous edges.  Islands of background pixels can be filled
% using imfill  to create an filled outline of the tissue of interest. This
% process works reasonably well to isolate most of the tissue of interests
% but not all tissue has been identified. As a work around, the process is
% repeated for the largest area of connected pixels.

% Method 2
% This method converts the background image to a gray scale image. Next,
% matlabs automatic gray scale function determines an appropriate gray
% scale threshold to segment the image into a binary mask. This threshold
% is adjusted with the threshold fudge factor (thresh: 0-1). Finally,
% pixel groups less than X% (defined by perc_ex) of the image size are
% removed.

% REFERENCES
% Check out the example at the link below
% http://www.mathworks.com/products/image/demos.html?file=/products/demos/shipping/images/ipexcell.html
% http://www.mathworks.com/products/image/demos.html?file=/products/demos/shipping/images/ipexrice.html
% ADDITIONAL NOTES
% The amount of dialation, filling, and erosion needed will be highly
% dependent on how well the camera is focused.  These processes may need
% to be tweaked per experiment.

% RELEASE VERSION 1.0.1

% AUTHOR: Jacob Laughner (jacoblaughner@gmail.com)

function new_data = remove_BKGRD(data,bg,thresh,perc_ex)
%% Method 1: Edge Detection
% % Find threshold for edge detection of background image
% [junk threshold] = edge(bg,'canny');
% fudgeFactor = 0.2;
% 
% % Apply edge detection filter with 50% of Matlab's suggested threshold
% BWs = edge(bg,'canny', threshold * fudgeFactor);
% 
% % Build cross structuring element for image dialation
% se90 = strel('line', 6, 90);
% se0 = strel('line', 5, 0);
% 
% % Dialate image with structuring element and fill holes in image background
% BWsdil1 = imdilate(BWs, [se90 se0]);
% BWdfill1 = imfill(BWsdil1, 'holes');
% 
% % Identify largest area of connected components and isolate these pixels
% % from image.  These isolate pixels should account for the majority of the
% % tissue of interest
% cc =bwconncomp(BWdfill1);
% labeled = labelmatrix(cc);
% stats = regionprops(cc,'Area');
% [val id] = max([stats.Area]);
% mask_temp = labeled == id;
% BW_new = mask_temp.*BWdfill1;
% 
% % Dialate and fill the image again to finish segementation of all pixels of
% % interest
% BWsdil2 = imdilate(BW_new, [se90 se0]);
% BWdfill2 = imfill(BWsdil2, 'holes');
% 
% % Smoothen object using erosion
% seD = strel('diamond',3);
% BWfinal = imerode(BWdfill2,seD);
% BWfinal = imerode(BWfinal,seD);
% 
% % Create a matrix mask the length of the cmos data and apply mask to remove
% % background pixels
% mask = repmat(BWfinal,[1 1 size(data,3)]);
% new_data = data.*mask;

%% Method 2: Thresholding
% Threshold Image
BG = mat2gray(bg);
level = graythresh(BG);
BW = im2bw(BG,level*thresh);
BW2 = bwareaopen(BW, ceil(perc_ex*size(BG,1)*size(BG,2)));
BW3 = imfill(BW2,'holes');
mask = repmat(BW3,[1 1 size(data,3)]);
new_data = data.*mask;




