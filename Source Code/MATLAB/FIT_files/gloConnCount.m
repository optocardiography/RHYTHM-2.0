%% Gloschat Connected Component Algorithm (gloConnect) %%
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: This function looks at the neighborhood of a pixel and
% identifies the number of connected components in the object (8-connect)
% and the background (4-connect). Special thanks to...
%
% Inputs:
% rm = the pixel neighborhood being analyzed
% oob = object (1) or background (0) indicator
%
% Outputs:
% connCount = the number of connected components

%% Code %%
function [connCount] = gloConnCount(rm,oob)
% Reshape the rm input
rm = reshape(rm,[3 3]);
% Add border for finding connectedness of outer pixels
objArray = zeros(5,5);
% Get height of matrix for calculating kernel math
objY = size(objArray,1);
if oob == 1
    % Input pixel neighborhood
    objArray(2:4,2:4) = rm;
    % Create kernels for object and background connectedness
    objKernel = [-objY-1 objY objY+1 -1 0 1 objY-1 objY objY+1];
elseif oob == 0
    % Flip to make the background the focus
    rm = double(rm == 0);
    % Input pixel neighborhood
    objArray(2:4,2:4) = rm;
    % Create kernels for object and background connectedness
    objKernel = [-1 -objY 0 +objY 1];
end
% Find object indices
objInd = find(objArray == 1);
% Column 2 is flagged ( == 1) if visited, column 3 is connected component #
objTracker = zeros(size(objInd,1),2);
% Create counter for object connectedness
objConnCount = 1;
objPixCount = 1;
if isempty(objInd)
    disp('HEY!')
else
    objPixQueue = objInd(1);
end
objActivePix = objPixQueue;
% Create matrix for tracking checked points
objArray2 = objArray;
while objTracker(size(objTracker,1),1) == 0
    % Log index
    objTracker(objPixCount,1) = objActivePix;
    % Set connectedness
    objTracker(objPixCount,2) = objConnCount;
    % Remove from objArray2
    objArray2(objActivePix) = 0;
    % Check if neighbors are connected
    objNbrInd = objActivePix+objKernel;
    objNbrVal = objArray2(objNbrInd);
% % %     objNbrVal(5) = 0;
    objNbrInd = objNbrInd(logical(objNbrVal));
    % Add neighbors to the queue
    objPixQueue = [objPixQueue objNbrInd];
    % Remove neighbors from objArray2
    objArray2(objNbrInd) = 0;
    % Remove current active pixel from queue
    objPixQueue(1) = [];
    if sum(sum(objArray2)) == 0 && isempty(objPixQueue)
        break
    elseif isempty(objPixQueue)
        % Increment connectedness counter
        objConnCount = objConnCount+1;
        % Find next active pixel
        nextActivePix = find(objArray2);
        objActivePix = nextActivePix(1);
        % Reset pixel queue
        objPixQueue = objActivePix;
    else
        % Set next active pixel
        objActivePix = objPixQueue(1);
    end
    % Update pixel counter
    objPixCount = objPixCount+1;
end
% Output object connectedness count
connCount = max(objTracker(:,2));

end
