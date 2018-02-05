%% Skeletonization Algorithm %%
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

function [skel] = skeletonization(GRID,k)
% Make copy of image
skel = GRID;
% Get height of image
imY = size(skel,1);
% Create 8 connectivity kernel
kernel8 = [-imY-1 -imY -imY+1 -1 0 1 imY-1 imY imY+1];
% Create 4 connectivity kernel
kernel4 = [-imY -1 0 1 +imY];
if k == 8
    kernel = kernel8;
elseif k == 4
    kernel = kernel4;
end

% Variable for storing removed border pixel indices
pixRemove = [];
pixRemove1 = 1;
pixRemove2 = 2;
% Pixels to check
% % % check = find(skel);
% Number of pixels to check
% % % numCheck = length(check);
% % % h = waitbar(0,'Skeletonization in process...');
% % % waitbar(0)
cnt1 = 1;
while pixRemove1 < pixRemove2
    
    % Length of pixRemove variable at begining of iteration
    pixRemove1 = length(pixRemove);
    
    % Grab the object pixels
    check = find(skel);
    % Identify the indices for the neighbors of each object pixel
    pixNbrs = repmat(check,[1 size(kernel,2)])+repmat(kernel,[size(check,1) 1]);
    % Grab the neighbors image value (0 or 1)
    findBorder = skel(pixNbrs);
    % Sum the neighbors values
    findBorder = sum(findBorder,2);
    % Border pixels will have at least one background neighbor
    findBorder = findBorder < k+1;

    % Grab border pixel indices from the grid
    pixBorder = check(findBorder);
    
    % Check to see if any are curve end pixels
    CE = skel(repmat(pixBorder,[1 size(kernel,2)])+...
        repmat(kernel,[size(pixBorder,1) 1]));
    % Remove them
    CE = sum(CE,2) == 2;
    pixBorder(CE) = [];
    
    % Create empty variable for simpleness check
    seed = [];
    cnt2 = 1;
    while ~isempty(pixBorder)
        % Grab a border pixel if seed is empty
        if isempty(seed)
            % Add to seed
            seed = pixBorder(1);
            % Remove from border variable
            pixBorder(1) = [];
        end
        
        % Check if pixel has become a curve end pixel
        if sum(skel(seed(1)+kernel)) <= 2
            % If so remove from the seed but not from the object
            seed(1) = [];
        else
            % If so test simpleness
            % Check if neighbors are object pixels
            seedNbrs = seed(1)+kernel;
            seedNbrVals = skel(seedNbrs);
            % Keep object pixels
            seedAdd = seedNbrs(logical(seedNbrVals));
            
            % Check if kept neighbors are in the border pixel variable
            seedAdd = double(repmat(pixBorder,[1 size(seedAdd,2)])==...
                repmat(seedAdd,[size(pixBorder,1) 1]));
            % Grab their index values
            seedAdd = find(sum(seedAdd,2));
            % Add these to seed and remove from pixBorder
            seed = [seed; pixBorder(seedAdd)];
            pixBorder(seedAdd) = [];
            
            % Check if active seed is simple, grab neighbhorhood around pixel
            rm = skel(seed(1)+kernel8);
            % Check object connectivity before removal
            obj1 = gloConnCount(rm,1);
            % Check background connectivity before removal
            bkg1 = gloConnCount(rm,0);
            rm(5) = 0;
            % Check object connectivity after removal
            obj2 = gloConnCount(rm,1);
            % Check background connectivity after removal
            bkg2 = gloConnCount(rm,0);
            
            % If the number of foreground and background components does
            % not change with removal it is simple and can be removed
            if obj1 == obj2 && bkg1 == bkg2
                % Remove the pixel from the image
                skel(seed(1)) = 0;
                % Place index in a removed pixel variable
                pixRemove = [pixRemove seed(1)];
                % Remove the pixel from the queue
                seed(1) = [];
            else
                % %             % Place index in a non simple pixel variable
                % %             nonSimple=[nonSimple; seed(1)];
                % Remove the pixel from the queue if non simple
                seed = seed(2:end);
            end;
        end
    end
    % length of pixRemove at the end of iteration
    pixRemove2 = length(pixRemove);
end

end
    
    
    
    
    
    
    
    
% % % % %     % Remove these pixels from the check variable
% % % % %     check(findBorder) = [];    
% % % % %     while ~isempty(pixBorder)
% % % % %         % Grab the start value assessing a connected component
% % % % %         seed = pixBorder(1);
% % % % %         if seed == 215169
% % % % %             disp('Hey! Listen!')
% % % % %         end
% % % % %         
% % % % %         pixBorder(1) = [];
% % % % %         while ~isempty(seed)
% % % % %             % Identify the connected neighbors
% % % % %             seedNbrsInd = seed(1)+kernel;
% % % % %             % Identify the neighbor values
% % % % %             seedNbrsVal = skelCE(seedNbrsInd)==1;
% % % % %             % Grab object neighbors
% % % % %             seedAdd = seedNbrsInd(seedNbrsVal);
% % % % %             % Determine if these are border pixels
% % % % %             seedNbrs = repmat(seedAdd',[1 size(kernel,2)])...
% % % % %                 +repmat(kernel,[size(seedAdd,2) 1]);
% % % % %             % Grab the neighbors image value (0 or 1)
% % % % %             seedFindBorder = skel(seedNbrs);
% % % % %             % Sum the neighbors values
% % % % %             seedFindBorder = sum(seedFindBorder,2);
% % % % %             % Border pixels will have at least one background neighbor
% % % % %             seedFindBorder = seedFindBorder < k+1;
% % % % %             % Remove non-border pixels
% % % % %             seedAdd = seedAdd(seedFindBorder);
% % % % % % % % % %             
% % % % % % % % % %             if sum(seedAdd==215169) > 0
% % % % % % % % % %                 disp('Hey! Listen!')
% % % % % % % % % %             end
% % % % %             % Remove them from the border pixel variable
% % % % %             if ~isempty(pixBorder)
% % % % %                 
% % % % %                 if sum(seedAdd==215169) > 0
% % % % %                     disp('Hey! Listen!')
% % % % %                 end
% % % % %                 % Use logic to identify matched pixels
% % % % %                 seedRemove = repmat(seedAdd,[size(pixBorder,1) 1]) == ...
% % % % %                     repmat(pixBorder,[1 length(seedAdd)]);
% % % % %                 % Find index of each matched pixel
% % % % %                 seedRemove = seedRemove.*repmat((1:length(pixBorder))',[1 length(seedAdd)]);
% % % % %                 % Sum to identify the matched index for each pixel, non matches
% % % % %                 % (equal to 0) mean it is not yet a border pixel
% % % % %                 seedRemove = sum(seedRemove);
% % % % %                 pixBorder(seedRemove(seedRemove~=0)) = [];
% % % % %                 % Add the object border neighbors to the seed queue
% % % % %                 seed = [seed seedAdd(seedRemove~=0)];
% % % % %             end
% % % % %             
% % % % %             
% % % % %             % Take first pixel in queue and grab its neighbor values
% % % % %             CE = skel(seed(1)+kernel);
% % % % %             if sum(CE) == 0
% % % % %                 disp('HEY! LISTEN!')
% % % % %             end
% % % % %             
% % % % %             
% % % % %             % Check if it has a single neighbor
% % % % %             if sum(CE) == 2
% % % % %                 % If it does place it in a tracking variable
% % % % %                 curveEnd = [curveEnd; seed(1)];
% % % % %                 % Remove from curve end skel variable
% % % % %                 skelCE(seed(1)) = 0;
% % % % %                 % Remove it from the queue
% % % % %                 seed = seed(2:end);
% % % % %             else
% % % % %                 if sum(CE) == 0
% % % % %                     disp('Hey! Listen!')
% % % % %                 end
% % % % %                 
% % % % %                 % If not, check how connectivity changes with removal
% % % % %                 % Grab neighbhorhood around pixel
% % % % %                 rm = skel(seed(1)+kernel8);
% % % % %                 % Check object connectivity before removal
% % % % %                 obj1 = gloConnCount(CE,rm,1);
% % % % %                 % Check background connectivity before removal
% % % % %                 bkg1 = gloConnCount(CE,rm,0);
% % % % %                 rm(5) = 0;
% % % % %                 % Check object connectivity after removal
% % % % %                 obj2 = gloConnCount(CE,rm,1);
% % % % %                 % Check background connectivity after removal
% % % % %                 bkg2 = gloConnCount(CE,rm,0);
% % % % %                 % If the number of foreground and background components does
% % % % %                 % not change with removal it is simple and can be removed
% % % % %                 if obj1 == obj2 && bkg1 == bkg2
% % % % %                     % Remove the pixel from the image
% % % % %                     skel(seed(1)) = 0;
% % % % %                     % Remove from curve end check image
% % % % %                     skelCE(seed(1)) = 0;
% % % % %                     % Place index in a removed pixel variable
% % % % %                     pixRemove = [pixRemove seed(1)];
% % % % %                     % Remove the pixel from the queue
% % % % %                     seed = seed(2:end);
% % % % %                 else
% % % % %                     % Place index in a non simple pixel variable
% % % % %                     nonSimple=[nonSimple; seed(1)];
% % % % %                     % Remove the pixel from the queue
% % % % %                     seed = seed(2:end);
% % % % %                 end
% % % % %             end
% % % % % %             disp(length(seed))
% % % % %         end
% % % % %     end
% % % % %     % Place the curve end and non simple pixels back in the check variable
% % % % %     check = [check; curveEnd; nonSimple];
% % % % %     % Update the waitbar
% % % % %     waitbar((length(pixRemove)+length(curveEnd)+length(nonSimple))/numCheck)
% % % % %     disp(numCheck-(length(pixRemove)+length(curveEnd)+length(nonSimple)))
% % % % % end
% % % % % % Close the waitbar
% % % % % close(h)
% % % % % end