%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Babak Taati - May 4, 2005
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009

function [pointCloudIndex,nearestPt] = callbackClickA3DPoint(pointCloud,point,norms)
% % % point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the angles between the normals and the camera position using the law
% of cosines: c^2 = a^2+b^2-2*a*b*cosC -> C = cos^-1((c^2-a^2-b^2)/(2*a*b))
pointNorms = pointCloud+norms;
b = sqrt(sum(norms.^2));
a = sqrt(sum((pointCloud-repmat(camPos',[1 size(pointCloud,2)])).^2));
c = sqrt(sum((pointNorms-repmat(camPos',[1 size(pointCloud,2)])).^2));
camAng = acosd((c.^2-a.^2-b.^2)./(-2*a.*b));
keep = find(camAng<90);


% find the nearest neighbour to the clicked point 
pointCloudIndex = dsearchn(rotatedPointCloud(1:2,keep)', ... 
    rotatedPointFront(1:2)');
pointCloudIndex = keep(pointCloudIndex);
nearestPt = pointCloud(:,pointCloudIndex);

% % % hold on
% % % scatter3(nearestPt(1),nearestPt(2),nearestPt(3),'ro','SizeData',128)
% 

% % % h = findobj(gca,'Tag','pt'); % try to find the old point
% % % selectedPoint = pointCloud(:, pointCloudIndex); 
% % % 
% % % if isempty(h) % if it's the first click (i.e. no previous point to delete)
% % %     
% % %     % highlight the selected point
% % %     h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
% % %         selectedPoint(3,:), 'r.', 'MarkerSize', 20); 
% % %     set(h,'Tag','pt'); % set its Tag property for later use   
% % % 
% % % else % if it is not the first click
% % % 
% % %     delete(h); % delete the previously selected point
% % %     
% % %     % highlight the newly selected point
% % %     h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
% % %         selectedPoint(3,:), 'r.', 'MarkerSize', 20);  
% % %     set(h,'Tag','pt');  % set its Tag property for later use

end

% % % fprintf('you clicked on point number %d\n', pointCloudIndex);
