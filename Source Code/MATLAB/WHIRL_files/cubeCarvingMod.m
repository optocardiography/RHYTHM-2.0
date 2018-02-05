%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Description: A modification of the occluding contours portion of whirl.m
% written by Dr. Matthew Kay. The silhsProcess_callback was getting
% excessively long so I decided to consolidate this code into a function.
% ATTENION: You will need to modify lines 129, 139, 149, 159, 169 to point
% to the Panoramic directory which should be downloaded with this set of
% functions. The recommended location for the Panoramic directory is in the
% Matlab root directory.
%
% Inputs:
% hdir = the home directory
% silhouettes = silhouettes
% lims = limits of the bounding box for the silhouettes
% angleStep = degree of each step
% n_images = total number of images used
% dofrontback = (1) collapse redudant images, (0) do not collapse
% angleArray = unsorted image angleArray
% rr = list of angleArray being used and their index
% snapshotArraySorted = sorted pairs [imageNo. , angle] 
% inumsort = sorted indices of images
% rsort = sorted angleArray
% startLevel = 
% octMax
% msgCenter
%

%% Code %%
function [status,fnametag] = cubeCarvingMod(geodir, projectDir,silhouettes,lims,...
    angleStep,n_images,angleArray,...
    rr,snapshotArraySorted,rsort,inumsort,...
    startLevel,maxLevel,msgCenter)
% Load external camera calibration values
[filename,pathname] = uigetfile('*.mat','Select camera calibration file (e.g. cal_009.mat).');
if filename ~= 0
    status = 1;
    cal_fname = fullfile(pathname, filename); 
    load(fullfile(pathname, filename));
    
    %% Load octreeMatrix basis %%
    [octreeBasisVertices,octreeBasisIncidence] = octree_basis;
    
    % Establish size and origin of initial carving cube
    % Keep it cubic!!!  This makes scaling volume and surface area much easier!
    
    xdim=6.0*25.0;  % mm
    ydim=xdim;    % mm
    zdim=xdim;    % mm
    
    X0=-0.5*xdim;
    Xn=0.5*xdim;
    Y0=-0.5*ydim;
    Yn=0.5*ydim;
    Z0=-0.5*zdim;
    Zn=0.5*zdim;
    
    levels=[(1:10)' (Xn-X0)./(2.^(1:10)')];        % Level number, length of step
    
    set(msgCenter,'String',sprintf('octreeMatrix levels:\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f\n%d\t%0.2f',...
        levels(1,1),levels(1,2),levels(2,1),levels(2,2),levels(3,1),levels(3,2),...
        levels(4,1),levels(4,2),levels(5,1),levels(5,2),levels(6,1),levels(6,2),...
        levels(7,1),levels(7,2),levels(8,1),levels(8,2),levels(9,1),levels(9,2),...
        levels(10,1),levels(10,2)),'FontSize',9);
    
    fnametag=inputdlg('Enter filename tag (ie: _povcyl_1mm_corrected):');
    if ~isempty(fnametag)
        savedir = geodir;
        
        % verticies of voxel progressBar-1 of octreeMatrix t is (remember, voxels are from 2:9):
        % vertexMatrix(octreeMatrix(t,find(octreeMatrix(t,:,progressBar)),1),:);
        level=startLevel;
        delta(1,1)=(Xn-X0)/(2^level);
        delta(1,2)=(Yn-Y0)/(2^level);
        delta(1,3)=(Zn-Z0)/(2^level);
        
        % create a grid x,y,z and a heartMask as inputs for a Marching
        % Cubes algorithm
        maskDims = 2^maxLevel;
        maskDelta(1)=(Xn-X0)/maskDims;
        maskDelta(2)=(Yn-Y0)/maskDims;
        maskDelta(3)=(Zn-Z0)/maskDims;
        [x,y,z]=meshgrid(X0:maskDelta(1):Xn,...
                         Y0:maskDelta(2):Yn,...
                         Z0:maskDelta(3):Zn);
        heartMask=zeros(size(x));
        
        %% Record analysis parameters in textfile %%
        parafname=strcat(fullfile(savedir,'whirl'),fnametag{1},'.txt');
        parafid=fopen(parafname,'w');
        fprintf(parafid,'angleStep, degree step: %4.3f \n',angleStep);
        fprintf(parafid,'n_images, total number of snapshots: %d \n',n_images);
        %fprintf(parafid,'dofrontback, 0: use all silhouettes or 1: use only largest silhouettes: %d \n',dofrontback);
        fprintf(parafid,'xdim, size of clay cube in x dir (mm): %4.3f \n',xdim);
        fprintf(parafid,'(X0,Xn) mm: (%4.3f,%4.3f) \n',X0,Xn);
        fprintf(parafid,'ydim, size of clay cube in y dir (mm): %4.3f \n',ydim);
        fprintf(parafid,'(Y0,Yn) mm: (%4.3f,%4.3f) \n',Y0,Yn);
        fprintf(parafid,'zdim, size of clay cube in z dir (mm): %4.3f \n',zdim);
        fprintf(parafid,'(Z0,Zn) mm: (%4.3f,%4.3f) \n',Z0,Zn);
        fprintf(parafid,'Levels: \n');
        for i=1:size(levels,1)
            for j=1:size(levels,2)
                fprintf(parafid,'%4.6f   ',levels(i,j));
            end
            fprintf(parafid,'\n');
        end
        fprintf(parafid,'startLevel, start at this spacing level: %d \n',startLevel);
        fprintf(parafid,'maxLevel, stop after completion of this spacing level: %d \n',maxLevel);
        fprintf(parafid,'fnametag: %s \n',fnametag{1});
        fprintf(parafid,'savedir: %s \n',savedir);
        
        fprintf(parafid,'Camera calibration Position and Parameters file: %s \n',fullfile(geodir, 'Calibration', filename));
        fprintf(parafid,'Angle array (angleArray):\n');
        for i=1:length(angleArray)
            fprintf(parafid,'%4.6f \n',angleArray(i));
        end
        fprintf(parafid,'Hemisphere array (rr):\n');
        for i=1:size(rr,1)
            for j=1:size(rr,2)
                fprintf(parafid,'%4.6f   ',rr(i,j));
            end
            fprintf(parafid,'\n');
        end
        fprintf(parafid,'Sorted snapshot array (snapshotArraySorted):\n');
        for i=1:size(snapshotArraySorted,1)
            for j=1:size(snapshotArraySorted,2)
                fprintf(parafid,'%4.6f   ',snapshotArraySorted(i,j));
            end
            fprintf(parafid,'\n');
        end
        
        %%
        goodthresh=0.95;
        % Determine rotation matrix for cube based on directionality of rotation
        if strcmp(cwtxt,'ccw')
            Rz = [cosd(-angleStep), -sind(-angleStep), 0;...
                  sind(-angleStep),  cosd(-angleStep), 0;...
                  0,              0,             1];
        else
            Rz = [cosd(angleStep), -sind(angleStep), 0;...
                  sind(angleStep),  cosd(angleStep), 0;...
                  0,              0,             1];
        end
        
        
        count = 0;
        progressBar = waitbar(count/(maxLevel-startLevel+1),sprintf('Creating octreeMatrix for level %d...',level));
        while level<=maxLevel
            %--------------------------------------------
            % Create the initial verticies matrix (vertexMatrix) and octreeMatrix matrix (octreeMatrix)
            
            % vertexMatrix(:,1)=x
            % vertexMatrix(:,2)=y
            % vertexMatrix(:,3)=z
            % vertexMatrix(:,4)=v (0 for outside, 1 for inside, NaN if not checked
            % vertexMatrix(:,5)=level, resolution level when this vertex was added
            
            % octreeMatrix is 3 dimensional: 
            % (Num of octrees) x (27 indicies denoting rows in vertexMatrix) x (9),
            % where octreeMatrix(:,:,1) contains vertexMatrix indicies 
            % and octreeMatrix(:,:,2:9) denotes voxel verticies
            % octreeMatrix(octree_num,:,1)=vertexMatrix indicies
            % octreeMatrix(octree_num,:,2:9)=voxel verticies
            % At each level the octreeMatrix matrix is rebuilt and the vertexMatrix matrix is expanded.
            
            if (level == startLevel)        
                if (level==1)
                    % масштабируем вершины на изображение
                    vertexMatrix=octreeBasisVertices*[(Xn-X0) 0 0; 0 (Yn-Y0) 0; 0 0 (Zn-Z0)];
                    % сдвигаем куб
                    sshift=zeros(27,3);
                    sshift(:,1)=X0;
                    sshift(:,2)=Y0;
                    sshift(:,3)=Z0;
                    vertexMatrix=vertexMatrix+sshift;
                    clear sshift
                    vertexMatrix(:,4)=NaN;
                    vertexMatrix(:,5)=1;
                    %octreeMatrix=zeros(1,27);
                    octreeMatrix=1:27;
                else
                    %TODO revise! does not work
                    loadPath = strcat(fullfile(projectDir,'whirl_octree_levels','level'),num2str(level),'.mat');
                    %whos ('-file', loadPath)
                    %load(loadPath, 'vert');
                    
                    vertexMatrix(:,1:3)=vertexMatrix(:,1:3)*[(Xn-X0) 0 0; 0 (Yn-Y0) 0; 0 0 (Zn-Z0)];
                    %vertexMatrix(:,1:3)=octreeBasisVertices*[(Xn-X0) 0 0; 0 (Yn-Y0) 0; 0 0 (Zn-Z0)];
                    sshift=zeros(size(vertexMatrix,1),3);
                    sshift(:,1)=X0;
                    sshift(:,2)=Y0;
                    sshift(:,3)=Z0;
                    vertexMatrix(:,1:3)=vertexMatrix(:,1:3)+sshift;
                    clear sshift
                end
            else
                % find voxels intersected by heart border,
                % then subdivide and repeat for each octreeMatrix
                % to which voxels were those that were inside belong
                % 'innerVertices' tells me which verticies were inside the volume
                % and which verticies were outside the volume of the verticies
                % which have not been checked.
                
                count = count+1;
                waitbar(count/(maxLevel-startLevel),progressBar,sprintf('Creating octreeMatrix for level %d...',level));
                
                innerVertices=find(vertexMatrix(:,4)>=goodthresh);  
                % Voxels to be subdivided have at least
                % one (but not all) vertex greater than 0.99
                % Use 0.95 to provide innerVertices surface definition.
                
                % Sum across all vertices in voxels (columns) to find 
                % voxels of interest, voxels that are both split and
                % completely inside the volume

                % Voxels that are completely inside the heart volume will
                % have a summed value of 0 while voxels completely inside
                % the volume will have a summed value of 8. Neither of
                % these eligible to be subdivied into a new octreeMatrix and
                % should be removed from consideration.

                % Matt Code %
                % Grab the vertex index from innerVertices.
                % Find which octrees contain that index
                clear ovi;
                for j=1:size(octreeMatrix,1)
                    for i=1:length(innerVertices)
                        [oviRowInd,oviColInd]=find(octreeMatrix(j,:)==innerVertices(i));
                        if ~isempty(oviRowInd)
                            if ~exist('ovi')
                                ovi=[j, oviColInd];
                            else
                                ovi=[ovi; j, oviColInd];
                            end
                        end
                    end
                end
                
                % ovi- octreeMatrix and vertex indicies
                % ovi(:,1) contains octreeMatrix numbers for verticies inside the volume
                % ovi(:,2) contains octreeMatrix vertex numbers for the verticies
                
                % with which octrees are we dealing?
                octreeIndices=unique(ovi(:,1));
                
                % now divide and conquer
                for i=1:length(octreeIndices)   % loop through each octreeMatrix
                    % get vertex numbers for this octreeMatrix that are inside the volume
                    oviStringsToProcess=ovi(ovi(:,1)==octreeIndices(i),2);
                    % which voxels have these vertex numbers?
                    % first built a 'mini' octreeBasisIncidence in incidenceVoxelStringsToProcess
                    incidenceVoxelStringsToProcess=octreeBasisIncidence(oviStringsToProcess,:);
                    % next find the voxel numbers
                    voxelIndicesToProcess=find(max(incidenceVoxelStringsToProcess,[],1)>0);  % these are actual voxel numbers for the respective octreeMatrix!
                    
                    % remove voxels totally inside the volume
                    isThereVoxelsInsideOfHeart=0;
                    voxelIndicesInsideOfHeart=[];
                    for j=1:length(voxelIndicesToProcess)
                        %if length(find(ismember([1 2 3 4 5 6 7 8],incidenceVoxelStringsToProcess(:,voxelIndicesToProcess(j)))))==8     % CAN I SPEED THIS UP????
                        if length(unique(incidenceVoxelStringsToProcess(:,voxelIndicesToProcess(j))))==9
                            voxelIndicesInsideOfHeart=[voxelIndicesInsideOfHeart,voxelIndicesToProcess(j)];
                            voxelIndicesToProcess(j)=NaN;
                            isThereVoxelsInsideOfHeart=1; 
                        end
                    end
                    if isThereVoxelsInsideOfHeart
                        voxelIndicesToProcess=voxelIndicesToProcess(find(~isnan(voxelIndicesToProcess)));
                    end
                    % add voxels inside of a heart into a mask
                    for j=1:length(voxelIndicesInsideOfHeart)
                        vni=find(octreeBasisIncidence(:,voxelIndicesInsideOfHeart(j))>0);
                        vvi=octreeMatrix(octreeIndices(i),vni);
                        vxyz=vertexMatrix(vvi,1:3);
                        xMaxInd=(vxyz(2,1)-X0)/maskDelta(1)+1;
                        xMinInd=(vxyz(1,1)-X0)/maskDelta(1)+1;
                        yMaxInd=(vxyz(5,2)-Y0)/maskDelta(2)+1;
                        yMinInd=(vxyz(1,2)-Y0)/maskDelta(2)+1;
                        zMaxInd=(vxyz(3,3)-Z0)/maskDelta(3)+1;
                        zMinInd=(vxyz(1,3)-Z0)/maskDelta(3)+1;
                        heartMask(xMinInd:xMaxInd, yMinInd:yMaxInd, zMinInd:zMaxInd)=1;
                    end
                    % we now have the voxel number of each voxel of the octreeMatrix
                    % (stored in voxelIndicesToProcess) intersected by heart border
                    % now subdivide each voxel, rebuild the 'octreeMatrix' matrix
                    % and append to the 'vertexMatrix' matrix
                    
                    for j=1:length(voxelIndicesToProcess)              % loop through each voxel of interest in the current octreeMatrix, all voxels are the same size
                        % find vertex number indicies of the voxel of interest
                        vni=find(octreeBasisIncidence(:,voxelIndicesToProcess(j))>0);
                        % actual indicies into vertexMatrix for each vertex  ***REVISED 1/29/02***
                        vvi=octreeMatrix(octreeIndices(i),vni);
                        % vertex locations are in order!
                        vxyz=vertexMatrix(vvi,1:3);
                        % now create an octreeMatrix inside the voxel
                        % first fill in the verticies that already exist!
                        if i==1 && j==1
                            okount=1;
                            new_octree=zeros(1,27).*NaN;
                            new_octree([1 4 9 11 17 19 24 27])=vvi;
                            delta(level,1)=(vxyz(2,1)-vxyz(1,1))/2;
                            delta(level,2)=(vxyz(5,2)-vxyz(1,2))/2;
                            delta(level,3)=(vxyz(3,3)-vxyz(1,3))/2;
                        else
                            okount=okount+1;
                            new_octree(okount,[1 4 9 11 17 19 24 27])=vvi;  % zeros elsewhere
                        end
                        
                        % New octreeMatrix limits
                        xn=vxyz(2,1);
                        x0=vxyz(1,1);
                        yn=vxyz(5,2);
                        y0=vxyz(1,2);
                        zn=vxyz(3,3);
                        z0=vxyz(1,3);
                        
                        new_vert=zeros(19,5).*NaN;
                        new_vert(:,5)=level;
                        new_vert(:,1:3)=octreeBasisVertices([2 3 5 6 7 8 10 12 13 14 15 16 18 20 21 22 23 25 26],:)*[(xn-x0) 0 0; 0 (yn-y0) 0; 0 0 (zn-z0)];
                        sshift=zeros(19,3);
                        sshift(:,1)=x0;
                        sshift(:,2)=y0;
                        sshift(:,3)=z0;
                        new_vert(:,1:3)=new_vert(:,1:3)+sshift;
                        
                        % on a max level add the smallest voxels to a mask
                        % that has at least one common vertice with a heart
                        if level == maxLevel
                            isOctreeCornerInside = vertexMatrix(vvi,4);
                            centerx = (x0+delta(level,1)-X0)/maskDelta(1)+1;
                            centery = (y0+delta(level,2)-Y0)/maskDelta(2)+1;
                            centerz = (z0+delta(level,3)-Z0)/maskDelta(3)+1;
                            for ii=1:size(isOctreeCornerInside,1)
                                if isOctreeCornerInside(ii)
                                    cornerx=(vxyz(ii,1)-X0)/maskDelta(1)+1;
                                    cornery=(vxyz(ii,2)-Y0)/maskDelta(2)+1;
                                    cornerz=(vxyz(ii,3)-Z0)/maskDelta(3)+1;
                                    heartMask(min(centerx,cornerx), min(centery,cornery), min(centerz,cornerz))=1;
                                    
                                end
                            end
                        end

                        
                        new_vert_ii=[1:19]+size(vertexMatrix,1);
                        
                        % do any of these verticies already exist in vertexMatrix?
                        % if so then delete from new_vert and update new_vert_ii
                        [C,rnew_vert,rvert]=intersect(new_vert(:,1:3),vertexMatrix(:,1:3),'rows');  % rows of new_vert that are already in vertexMatrix
                        clear C;
                        
                        if ~isempty(rnew_vert)   % if redundant verticies exist
                            new_vert_ii(rnew_vert)=rvert;  % This makes sense
                            new_new_vert=new_vert;
                            new_new_vert(rnew_vert,:)=[];  % drop redundant rows in new_vert
                            [C,r1,r2]=intersect(new_new_vert(:,1:3),new_vert(:,1:3),'rows');
                            clear C;
                            new_vert_ii(r2)=r1+size(vertexMatrix,1);
                            new_vert=new_new_vert;
                        end
                        
                        new_octree(okount,[2 3 5 6 7 8 10 12 13 14 15 16 18 20 21 22 23 25 26])=new_vert_ii;
                        vertexMatrix=[vertexMatrix; new_vert];
                        
                        if length(unique(new_octree(okount,:)))~=27
                            sprintf('Junk!')
                            return
                        end
                    end  % End voxel loop (j)
                end % End octreeMatrix loop (i), okount is combination of i and j
                octreeMatrix=new_octree;
            end
%             --------------------------------------------
            
            % vertexMatrix(:,4) of NaN: vertex not checked yet
            % vertexMatrix(:,4) of 0: vertex is definitely not in the volume
            % Matt's Code %
            sites2check=[find(vertexMatrix(:,4) == 1);find(isnan(vertexMatrix(:,4)))]; % indicies into vertexMatrix
            check_num=length(sites2check);
            % Variable for tracking if vertex is inside the volume
            check=ones(check_num,2);       
% % %             check = ones(check_num,73);
            check(:,1)=sites2check;
            % Loop for identifying which vertices are inside the volume
            rot_vert = vertexMatrix(:,1:3);
            for i=1:length(rsort)
                innerVertices=find((check(:,2))>0);   % must shave anything greater than zero that is not inside b/c projection
                if isempty(innerVertices)             % places verticies that are outside inside, depending upon view!
                    sprintf('No points inside volume. Aborting Snapshots. Restart and increase initial level.')
                    return
                else
                    % Project vertices onto camera model
                    [Xi,Yi]=pred([rot_vert(check(innerVertices,1),1) rot_vert(check(innerVertices,1),2) rot_vert(check(innerVertices,1),3)],par,pos,camera);
                    % Which points of Xi and Yi are inside the silhouette?
                    vicinity=ones(length(innerVertices),1);
                    vicinity(Xi<lims(i,1) | Xi>lims(i,2) | Yi<lims(i,3) | Yi>lims(i,4))=0;
                    check(innerVertices(~vicinity),2)=0;
                    vici=find(vicinity);
                    % Interpolation provides weight to points on the edge
                    Zi=interp2(silhouettes(:,:,i),Xi(vici),Yi(vici));
                    check(innerVertices(vici),2)=Zi;
                    % Rotate cube
                    rot_vert = (Rz*rot_vert')';
                end
            end
            vertexMatrix(check(:,1),4)=check(:,2);
            
            % keep up with the points that have been tested
            % Update which level of subdivision algorithm is on
            level=level+1;
        end % End level loop
        %close progress bar progressBar
        close(progressBar)
        h = msgbox('Saving surface data...');
        % Normalization %
        % Normalize and save data
        normalizedVertices=zeros(size(vertexMatrix,1),size(vertexMatrix,2)-1);
        normalizedVertices(:,1)=vertexMatrix(:,1)-min(vertexMatrix(:,1));
        normalizedVertices(:,2)=vertexMatrix(:,2)-min(vertexMatrix(:,2));
        normalizedVertices(:,3)=vertexMatrix(:,3)-min(vertexMatrix(:,3));
        normalizedVertices(:,4)=vertexMatrix(:,4);
        
        scale_x=max(normalizedVertices(:,1));
        scale_y=max(normalizedVertices(:,2));
        scale_z=max(normalizedVertices(:,3));
        
        
        save(strcat(fullfile(savedir,'octvert'),fnametag{1}),'octreeMatrix','vertexMatrix','delta'...
            ,'level','xdim','ydim','zdim','scale_x','scale_y','scale_z',...
            'rr','inumsort','rsort')
        scalesfname=strcat(fullfile(savedir,'scales'),fnametag{1},'.dat');
                
        fid=fopen(scalesfname,'w');
        fprintf(fid,'%4.3f\n',scale_x);
        fprintf(fid,'%4.3f\n',scale_y);
        fprintf(fid,'%4.3f\n',scale_z);
        fclose(fid);
        
        xyzvfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'.dat');
        fid=fopen(xyzvfname,'w');
        fwrite(fid,vertexMatrix(:,1:4)','float');   % Edited 3/12/02 from fwrite(fid,normalizedVertices','float');
        fclose(fid);
        
        fprintf(parafid,'Saved %d points in %s \n',size(vertexMatrix,1),xyzvfname);
        fclose(parafid);
        
        %return
        
        %% Rendering %%
        disp('Rendering ....')
       
        oldDir=pwd;
        
        % we use open source c-code 'Smooth Triangulated Mesh' version 1.1 
        % by Dirk-Jan Kroon to significantly accelerate computation 
        cd(fullfile(projectDir,'CPP_files'));
        if ispc
            mex smoothpatch_curvature_double.c -v
            mex smoothpatch_inversedistance_double.c -v
            mex vertex_neighbours_double.c -v
        elseif isunix
            mex -v GCC='/usr/bin/gcc-4.9' smoothpatch_curvature_double.c
            mex -v GCC='/usr/bin/gcc-4.9' smoothpatch_inversedistance_double.c
            mex -v GCC='/usr/bin/gcc-4.9' vertex_neighbours_double.c
        elseif ismac
            mex -v GCC='gcc' smoothpatch_curvature_double.c
            mex -v GCC='gcc' smoothpatch_inversedistance_double.c
            mex -v GCC='gcc' vertex_neighbours_double.c
        end
        cd(oldDir);
        
        FV = isosurface(heartMask, 0.5);
        tic;
        FV.vertices(:,:) = FV.vertices(:,:) - 1.0;
        globalShift = [X0 Y0 Z0];
        for i=1:3
            FV.vertices(:,i) = FV.vertices(:,i) * maskDelta(i) + globalShift(i);
        end
        FV2 = smoothpatch(FV,1,7);
 
        % check normal orientation and reorder triangle points if normal
        % directs inside of a heart
        modelCentroid = sum(FV2.vertices,1)/size(FV2.vertices,1);
        for i=1:size(FV2.faces,1)
            point1 = FV2.vertices(FV2.faces(i,1),:);
            point2 = FV2.vertices(FV2.faces(i,2),:);
            point3 = FV2.vertices(FV2.faces(i,3),:);
            centroid = (point1 + point2 + point3)/3.0;
            vecToCentroid = centroid - modelCentroid;
            vec1 = point2 - point1;
            vec2 = point3 - point1;
            normal = cross(vec1, vec2);
            if dot(normal,vecToCentroid)<0
                FV2.faces(i,:) = flip(FV2.faces(i,:));
            end
        end
        
        
        figure, 
        subplot(1,1,1), patch(FV2,'FaceColor',[0 0 1],'EdgeAlpha',0); view(3); camlight
        
        %print vtk file
        fileID = fopen(strcat('xyzv',fnametag{1},'_surf.vtk'),'w');
        fprintf(fileID,'# vtk DataFile Version 4.0\nvtk output\nASCII\nDATASET POLYDATA\n');
        fprintf(fileID,'POINTS %d float\n',size(FV2.vertices,1));
        for i=1:size(FV2.vertices,1)
            fprintf(fileID,'%f %f %f\n',FV2.vertices(i,2),FV2.vertices(i,1),FV2.vertices(i,3));
        end
        fprintf(fileID,'POLYGONS %d %d \n',size(FV2.faces,1), size(FV2.faces,1)*4);
        for i=1:size(FV2.faces,1)
            fprintf(fileID,'3 %d %d %d \n',FV2.faces(i,1)-1,FV2.faces(i,2)-1,FV2.faces(i,3)-1);
        end
        fprintf(fileID,' \n');
        fclose(fileID);
        
        %TODO print data and time correctly (uncomment corresponding lines
        %in following code
        
        %TODO check inputfname and print: 'Source file: %s'?
        %TODO print neighbours info      

        inputfname = strcat(fullfile(savedir,'xyzv'),fnametag{1},'.dat'); 
        
        
        %0) Save neighbors      
        neighsfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'_neighs.dat');
        fileID = fopen(neighsfname,'w');
        
        fprintf(fileID,'Header lines: 6\n');
        fprintf(fileID,'Source file: %s\n',inputfname);
        fprintf(fileID,'NumberOfCells: %d\n',size(FV2.faces,1));
        fprintf(fileID,'NumberOfComponents: 3\n');
        fprintf(fileID,'DataType: int\n');
        fprintf(fileID,'Created: sometime\n');
        
        % Suppose vertex has less than 21 adjacent faces, preallocate an insidence array: 
        maxInsidentFaces = 20;
        VertexAdjacentFaces=zeros(size(FV2.vertices,1), maxInsidentFaces);
        % Precompute insidence
        for i=1:size(FV2.faces,1)
            for j=1:3
                vertexInsidence = VertexAdjacentFaces(FV2.faces(i,j),:); 
                for k=1:maxInsidentFaces
                    if vertexInsidence(k) ~= 0 
                        continue;
                    else
                        VertexAdjacentFaces(FV2.faces(i,j), k)= i;
                        break;
                    end
                end
            end
        end

        %find neighbours and write them on file
        for i=1:size(FV2.faces,1)
            nNbr=0;
            nbrIDs = zeros(3);
            for k=1:3
                vertexInsidence = VertexAdjacentFaces(FV2.faces(i,k),:);
                ind2 = k+1;
                if ind2 > 3
                    ind2 = ind2-3;
                end
                ind3 = k+2;
                if ind3 > 3
                    ind3 = ind3-3;
                end
                for j=1:maxInsidentFaces
                    if vertexInsidence(j)==0
                        break;
                    else
                        neighCandidateID = vertexInsidence(j);
                        flag=0;
                        for ii=1:3
                            if FV2.faces(neighCandidateID,ii)==FV2.faces(i,ind2) ...
                            || FV2.faces(neighCandidateID,ii)==FV2.faces(i,ind3)
                                nNbr=nNbr+1;
                                nbrIDs(k)=vertexInsidence(j);
                                flag=1;
                                break;
                            end
                        end
                        if flag==1
                            break;
                        end
                    end
                end                
            end
            fwrite(fileID, nNbr, 'int'); % number of neighbors
            for i=1:nNbr
                fwrite(fileID, nbrIDs(i)-1, 'int'); % neighbor's number
            end
        end
        
        % old code for finding neighbours 
%         for i=1:size(FV2.faces,1)
%             nNbr=0;
%             nbrIDs = zeros(3);
%             for k=1:3
%                 edge=[FV2.faces(i,k);FV2.faces(i,rem(k,3)+1)]; %rem(k,3)+1 covers 'k+1=4' case
%                 for j=1:size(FV2.faces,1)
%                     for l=1:3
%                       tmp1 = [FV2.faces(j,l);FV2.faces(j,rem(l,3)+1)];
%                       tmp2 = [FV2.faces(j,rem(l,3)+1);FV2.faces(j,l)];
%                       if((isequal(edge,tmp1) ...
%                               || isequal(edge,tmp2)&&(i~=j))) 
%                           nNbr=nNbr+1;
%                           nbrIDs(k)=j;
%                       end
%                     end
%                 end
%             end
%             fwrite(fileID, nNbr, 'int'); % number of neighbors
%             for i=1:nNbr
%                 fwrite(fileID, nbrIDs(i)-1, 'int'); % neighbor's number
%             end
%         end
%         fclose(fileID);
        
        %1) Save points
        xyzvfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'_pts.dat');
        fileID = fopen(xyzvfname,'w');
        fprintf(fileID,'Header lines: 6\n');
        fprintf(fileID,'Source file: %s\n',inputfname);
        fprintf(fileID,'NumberOfTuples: %d\n',size(FV2.vertices,1));
        fprintf(fileID,'NumberOfComponents: 3\n');
        fprintf(fileID,'DataType: double\n');
        % CHECK AND UNCOMMENT
        %fprintf(fid,'Created: %s',time_string);
         fprintf(fileID,'Created: sometime\n');
        for i=1:size(FV2.vertices,1)
            fwrite(fileID, FV2.vertices(i,2), 'double'); % vertice x
            fwrite(fileID, FV2.vertices(i,1), 'double'); % vertice y
            fwrite(fileID, FV2.vertices(i,3), 'double'); % vertice z
        end
        fclose(fileID);
        
        %2) Save cells
        cellsfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'_cells.dat');
        fileID=fopen(cellsfname,'w');
        fprintf(fileID,'Header lines: 6\n');
        % CHECK:
        fprintf(fileID,'Source file: %s\n',inputfname);
        fprintf(fileID,'NumberOfTuples: %d\n',size(FV2.faces,1));
        fprintf(fileID,'NumberOfComponents: 3\n');
        fprintf(fileID,'DataType: int\n');
        % CHECK AND UNCOMMENT:
        %fprintf(fileID,'Created: %s',stime);
        fprintf(fileID,'Created: sometime\n');
        for i=1:size(FV2.faces,1)
            fwrite(fileID, FV2.faces(i,1)-1, 'int'); % triangle vertex id1
            fwrite(fileID, FV2.faces(i,2)-1, 'int'); % triangle vertex id2
            fwrite(fileID, FV2.faces(i,3)-1, 'int'); % triangle vertex id3
        end
        fclose(fileID);
        
        %3,4) Save centroids and normals
        centroidsfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'_centroids.dat');
        fileIDcentroid=fopen(centroidsfname,'w');
        fprintf(fileIDcentroid,'Header lines: 6\n');
        % CHECK inputfname:
        fprintf(fileIDcentroid,'Source file: %s\n',inputfname);
        fprintf(fileIDcentroid,'NumberOfTuples: %d\n',size(FV2.faces,1));
        fprintf(fileIDcentroid,'NumberOfComponents: 3\n');
        fprintf(fileIDcentroid,'DataType: double\n');
        % CHECK AND UNCOMMENT:
        %fprintf(fileIDcentroid,'Created: %s',stime);
         fprintf(fileIDcentroid,'Created: sometime\n');
        
        normalsfname=strcat(fullfile(savedir,'xyzv'),fnametag{1},'_normals.dat');
        fileIDnormal=fopen(normalsfname,'w');
        fprintf(fileIDnormal,'Header lines: 6\n');
        % CHECK inputfname:
        fprintf(fileIDnormal,'Source file: %s\n',inputfname);
        fprintf(fileIDnormal,'NumberOfTuples: %d\n',size(FV2.faces,1));
        fprintf(fileIDnormal,'NumberOfComponents: 3\n');
        fprintf(fileIDnormal,'DataType: double\n');
        % CHECK AND UNCOMMENT:
%        fprintf(fileIDnormal,'Created: %s',stime);
         fprintf(fileIDnormal,'Created: sometime\n');
        
        for i=1:size(FV2.faces,1)
            point1 = FV2.vertices(FV2.faces(i,1),:);
            point2 = FV2.vertices(FV2.faces(i,2),:);
            point3 = FV2.vertices(FV2.faces(i,3),:);
            centroid = (point1 + point2 + point3)/3.0;
            fwrite(fileIDcentroid, centroid(1), 'double'); % centroid x
            fwrite(fileIDcentroid, centroid(2), 'double'); % centroid y
            fwrite(fileIDcentroid, centroid(3), 'double'); % centroid z
            
            vec1 = point2 - point1;
            vec2 = point3 - point1;
            normal = cross(vec1, vec2);
            normalized = normal / norm(normal);
            
            fwrite(fileIDnormal, normalized(1), 'double'); %normal x
            fwrite(fileIDnormal, normalized(2), 'double'); %normal y
            fwrite(fileIDnormal, normalized(3), 'double'); %normal z
        end
        fclose(fileIDcentroid);
        fclose(fileIDnormal);
        delete(h);
    else
        status = 0;
    end
end