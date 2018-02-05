%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: Takes aligned projections for each mapping camera and makes
% data assignments from the mapping cameras onto the 3D geometry. This is
% primarily a modification and implementation of the code written by Dr.
% Matt Kay (circa 2004).
%
% Inputs:
%   Xshift = 
%   Yshift = 
%   shift = 
%   norms = 
%   centroids = 
%   cells = 
%   pts = 
%   neigh = 
%   neighnum = 
%   Parmap = 
%   Posmap = 
%   camera =
%   bg = 
%   geommask = 
%   nr = 
%   nc = 
%   looknmap = 
%   cmosData = 
%   fps =
%   opt_dir = 
%   filename = 
%
% Outputs:
%   dataProj =
%   geommask =
%   mask = 
%
%

%% CODE %%
function [dataProj,textProj,viewi,geommasks,mask] = dataProjection02(Xshift,...
    Yshift,shift,norms,centroids,cells,pts,neighs,neighnum,Parmap,...
    Posmap,camera,bgMask,bg,geommasks,nr,nc,looknmap,cmosData,fps,...
    opt_dir,filename)
%% User specified values %%
h = msgbox('Projecting....');

minangleDIRECT=95;  % front face angles must be greater than this, use 180 to force max angle assignment
minedgeDIRECT=0.9;
minedgeEDGE=0.55;     % 0.25 is too small!! use at least 0.5!! but 0.25 is same as 0.5; 0.25 is too small to make a difference
edgefiltval=16;      % was 20. reduced for comparison to 100 for spinny images
nuketopdata=0;       % if 1 then no texture mapping on the top of the model. Should be 0 for decimated models

txtyourfname={sprintf('%s_d',filename(1:2)),'cdf'};
edgesfname={sprintf('%sedges_d',filename(1:2)),'dat'};
viewsfname={sprintf('%sviews_d',filename(1:2)),'dat'};
infofname=sprintf('%s_textureinfo.txt',filename(1:2));      

%% Identify new masks using the aligned projected points %%
% Round values and remove those outside the boundary
mask = zeros(size(geommasks,1),size(geommasks,2));
for n = 1:4
    x = round(Xshift{n}); y = round(Yshift{n});
    % Identify X values to remove
    rmX = (x > nc) + (x < 1);
    if sum(rmX) > 0
        rmX = rmX.*(1:length(rmX))';
        rmX = unique(rmX);
        rmX = rmX(2:end);
    else
        rmX = [];
    end
    % Identify Y values to remove
    rmY = (y > nr) + (y < 1);
    if sum(rmY) > 0
        rmY = rmY.*(1:length(rmY))';
        rmY = unique(rmY);
        rmY = rmY(2:end);
    else
        rmY = [];
    end
    % Combine points removed based on X and Y
    rm = [rmX;rmY];
    x(rm) = [];
    y(rm) = [];
    % Identify heart pixels to keep
    ind = sub2ind([100 100],x,y);
    ind = unique(ind);
    geommasks((n-1)*100^2+ind) = 1;
    geommasks(:,:,n) = imfill(geommasks(:,:,n))';
    mask(:,:,n) = bgMask{n}.*geommasks(:,:,n);
end

%% Compute angles b/w normals and view directions %%
disp('Computing angles between normals and view directions .... ');
nviews = size(geommasks,3);
langle=zeros(size(norms,1),nviews+1);
fprintf('%d normals and %d views',size(langle,1),nviews);
% % % two_comp=0;   % 1 for 2 components, 0 for three
% % % if ~two_comp
disp('Computing angles using x,y, and z components.');
gg=norms*looknmap';
gg=acos(gg);
gg=real(gg);
langle(:,1:nviews)=gg.*180/pi;  % x,y, and z components

% Find max angle for each point
disp('Finding max angles ....');
for i=1:size(langle,1)
    candidatemax=find(langle(i,1:nviews)==max(langle(i,1:nviews)));
    if length(candidatemax)>1
        langle(i,end)=candidatemax(1);
    elseif length(candidatemax)==1
        langle(i,end)=candidatemax;
    end
end

%% Computing edge weights %%
disp('Computing edge weights ...');
ledge=zeros(size(norms,1),nviews+1);
for i=1:nviews
    fprintf('Computing weights for view %d ...',i);
    gg=find(langle(:,i)>90);  % find the front face
%     [Xigg,Yigg]=pred2([centroids(gg,1) centroids(gg,2) centroids(gg,3) ones(size(centroids(gg,1),1),1)],Rcmap(:,1:4,i),Parmap(:,i),camera);
    [Xigg,Yigg]=pred(centroids(gg,:),Parmap(:,i),Posmap(:,i),camera);
% %     Xigg=Xigg-pix(i,1)+1; Yigg=Yigg-pix(i,4)+1;
%     Xigg=Xigg-size(mask,2)+1; Yigg=Yigg-size(mask,2)+1; % adjusted for 100x100 cams
    Xigg = Xigg+shift(i,1);
    Yigg = Yigg+shift(i,2);
    out=find(Xigg<1 | Xigg>nc);
    if ~isempty(out)
        Xigg(out)=[];
        Yigg(out)=[];
        gg(out)=[];
    end
    out=find(Yigg<1 | Yigg>nr);
    if ~isempty(out)
        Xigg(out)=[];
        Yigg(out)=[];
        gg(out)=[];
    end
    com=sprintf('[conesilh,kernel]=conefilt(mask(:,:,%d),edgefiltval,1);',i);
    eval(com);
    ledge(gg,i)=interp2(conesilh,Xigg,Yigg);
    clear conesilh;
end

% Find maximum edge weights
disp('Finding max edge weights ....');
for i=1:size(ledge,1)
    gg=find(ledge(i,1:nviews)==max(ledge(i,1:nviews)));
    if (~isempty(gg) && length(gg)==1)
        ledge(i,end)=gg;            % max ledge
    elseif length(unique(langle(i,gg)))==1
        ledge(i,end)=gg(1);
    else
        ledge(i,end)=find(langle(i,1:nviews)==max(langle(i,gg)));  % max angle at max ledge
    end
end

%% Assign cells to views: DIRECT, OVERLAP, and EDGE %%
% This sets up the DIRECT views and smooths the edges of those views
% The next step finds the OVERLAP of the DIRECT views

% viewi(:,1-nviews)=0 or 1, indicating whether the cell was mapped by a particular view
% viewi(:,nviews+1)=integer b/w 1 and nviews+2. This number indicates the assigned view.
%      nviews+1 is overlap, nviews+2 is edge

viewi=zeros(size(langle,1),nviews+1);
for i=1:nviews
    fprintf('Finding cells in DIRECT view %d ...',i);
    gg=find(langle(:,i)>=minangleDIRECT & ledge(:,i)>=minedgeDIRECT);
    if isempty(gg)
        fprintf('Found NO cells in view %d ...',i);
    else
        viewi(gg,i)=1;
        fprintf('Found %d cells in DIRECT view %d ...',length(gg),i);
        fprintf('Smoothing edges of DIRECT view %d...',i);
        [viewi(:,i)]=smoothregionbdr(viewi(:,i),neighnum,neighs);
    end
end
clear pvect;

fprintf('Assigning OVERLAP and EDGE views...');
for i=1:size(viewi,1)
    gg=find(viewi(i,1:nviews));
    if ~isempty(gg);
        if length(gg)==1
            viewi(i,nviews+1)=gg;          % DIRECT
        else
            viewi(i,nviews+1)=nviews+1;    % OVERLAP
        end
    else
        gg=find(langle(i,1:nviews)>=90 & ledge(i,1:nviews)>=minedgeEDGE);
        if ~isempty(gg)
            viewi(i,nviews+1)=nviews+2;    % EDGE
            viewi(i,gg)=1;  % average these views
        end
    end
end

disp('Finding indicies of cells with multiple views...');
mults=sum(viewi(:,1:nviews),2);
multsover1=find(mults>1);
multsii=zeros(length(find(viewi(multsover1,1:nviews))),1);
multsjj=multsii;
kount=0;
for i=1:size(viewi,1)
    gg=find(viewi(i,1:nviews));
    if ~isempty(gg) && length(gg)>1
        for j=1:length(gg)
            kount=kount+1;
            multsii(kount)=i;
            multsjj(kount)=gg(j);
        end
    end
end

%--------------------------------------------
% projection and mapping

% txtkernel stores pixel locations and weights
% txtkernel{:,:,1} is array of pixel indicies
% txtkernel{:,:,2} is array of pixel weights
txtkernel=cell(size(viewi,1),nviews,2);
disp('Determining pixel kernels for each cell in each view ...');
for i=1:nviews
    fprintf('Doing this for view %d ...',i);
    gg=find(viewi(:,i));
    if ~isempty(gg);
        [Xigg,Yigg]=pred(centroids(gg,:),Parmap(:,i),Posmap(:,i),camera);
        Xigg = Xigg+shift(i,1);
        Yigg = Yigg+shift(i,2);
        out=find(Xigg<1 | Xigg>nc);
        if ~isempty(out)
            Xigg(out)=[];
            Yigg(out)=[];
            gg(out)=[];
        end
        out=find(Yigg<1 | Yigg>nr);
        if ~isempty(out)
            Xigg(out)=[];
            Yigg(out)=[];
            gg(out)=[];
        end
        V1=[pts(cells(gg,1),1) pts(cells(gg,1),2) pts(cells(gg,1),3)];
        V2=[pts(cells(gg,2),1) pts(cells(gg,2),2) pts(cells(gg,2),3)];
        V3=[pts(cells(gg,3),1) pts(cells(gg,3),2) pts(cells(gg,3),3)];
%         [XV1gg,YV1gg]=pred2([V1(:,1) V1(:,2) V1(:,3) ones(size(V1,1),1)],Rcmap(:,1:4,i),Parmap(1:8,i),camera);
        [XV1gg,YV1gg]=pred(V1,Parmap(:,i),Posmap(:,i),camera);
        XV1gg = XV1gg+shift(i,1);
        YV1gg = YV1gg+shift(i,2);
%         XV1gg=XV1gg-pix(i,1)+1;YV1gg=YV1gg-pix(i,4)+1;
%         [XV2gg,YV2gg]=pred2([V2(:,1) V2(:,2) V2(:,3) ones(size(V2,1),1)],Rcmap(:,1:4,i),Parmap(1:8,i),camera);
        [XV2gg,YV2gg]=pred(V2,Parmap(:,i),Posmap(:,i),camera);
        XV2gg = XV2gg+shift(i,1);
        YV2gg = YV2gg+shift(i,2);
%         XV2gg=XV2gg-pix(i,1)+1;YV2gg=YV2gg-pix(i,4)+1;
%         [XV3gg,YV3gg]=pred2([V3(:,1) V3(:,2) V3(:,3) ones(size(V3,1),1)],Rcmap(:,1:4,i),Parmap(1:8,i),camera);
        [XV3gg,YV3gg]=pred(V3,Parmap(1:8,i),Posmap(:,i),camera);
        XV3gg = XV3gg+shift(i,1);
        YV3gg = YV3gg+shift(i,2);
%         XV3gg=XV3gg-pix(i,1)+1;YV3gg=YV3gg-pix(i,4)+1;
        for j=1:size(gg,1)
            % Define the triangle's bounding square and round up to pixel edges
            % To do this, add or subtract 0.5 to grid the integer-valued pixels
            VXmax=ceil(max([XV1gg(j) XV2gg(j) XV3gg(j)])-0.5)+0.5;
            VXmin=floor(min([XV1gg(j) XV2gg(j) XV3gg(j)])+0.5)-0.5;
            VYmax=ceil(max([YV1gg(j) YV2gg(j) YV3gg(j)])-0.5)+0.5;
            VYmin=floor(min([YV1gg(j) YV2gg(j) YV3gg(j)])+0.5)-0.5;
            if VXmax>nc+0.5
                VXmax=nc+0.5;
            end
            if VXmin<0.5
                VXmin=0.5;
            end
            if VYmax>nr+0.5
                VYmax=nr+0.5;
            end;
            if VYmin<0.5
                VYmin=0.5;
            end
            % Define the pixel grid
            [pvX,pvY]=meshgrid((VXmin:1:VXmax),(VYmin:1:VYmax));
            intarea=zeros(size(pvX,1)-1,size(pvX,2)-1);
            Q=[XV1gg(j),YV1gg(j);XV2gg(j),YV2gg(j);XV3gg(j),YV3gg(j)];
            try                
                Q=checkpoly(Q*100)/100;  % multiply and divide by 100 to avoid numerical imprecision with checkpoly.m
            catch
                disp('Collinear Points');
            end
            % % %             txtyour(gg(j),i)=0;
            % plot(Q(:,1),Q(:,2),'k*');
            for pn = 1:size(pvX,1)-1
                for pm = 1:size(pvY,2)-1
                    % assign P for cw rotation (yes, cw! it works...)
                    P=[pvX(pn,pm+1) pvY(pn,pm+1);
                        pvX(pn+1,pm+1) pvY(pn+1,pm+1);
                        pvX(pn+1,pm) pvY(pn+1,pm);
                        pvX(pn,pm) pvY(pn,pm)];
                    % for pp=1:size(P,1)
                    %   plot(P(pp,1),P(pp,2),'o');
                    %   pause
                    % end
                    [~,~,intarea(pn,pm)]=convex_intersect(P,Q);
                    % fill(P(:,1),P(:,2),'y');
                    % if intarea(pi,pj)>0; fill(pint(:,1),pint(:,2),'g'); end;
                    % pause
                end
            end
            txtkernel{gg(j),i,1}=sub2ind([nr nc],pvY(1:end-1,...
                1:end-1)+0.5,pvX(1:end-1,1:end-1)+0.5);
            txtkernel{gg(j),i,2}=intarea;
        end
    end
end

% Open file for storing final texture values
tii = [];
if isempty(tii)
    txtfname=sprintf('%s.%s',char(txtyourfname(1)),char(txtyourfname(2)));
    tii=(1:size(cmosData{1},3));
else
    txtfname=sprintf('%s_%d-%d.%s',char(txtyourfname(1)),tii(1),tii(end),char(txtyourfname(2)));
end
fid=fopen(txtfname,'w','b');
% write the header
fprintf(fid,'header_lines=8\n');
fprintf(fid,'nchannels=%d\n',size(centroids,1));
fprintf(fid,sprintf('delta-t=%2.6f\n',1/fps(1)));
fprintf(fid,'n_samples=%d\n',length(tii));
fprintf(fid,'word_size=4\n');
fprintf(fid,'event=0\n');
fprintf(fid,'date=%s\n',date);
fprintf(fid,'data_source=%s/%s\n',opt_dir,filename);
% % % dat_precision=sprintf('uint%d',8*4);

disp('Projection and mapping ...');
% % % mapthresh=25;  % F value   THIS VALUE IS CURRENTLY NOT USED, MWK 5/31/04
% % % top_thresh=25; % angle, degrees from z axis
delete(h);
h = waitbar(0,'Projection and mapping...');
dataProj = zeros(size(norms,1),length(tii));

tex = zeros(nr,nc,4);
for j = 1:nviews
    tex(:,:,j) = bg{j};
end
assignTex=nan(size(norms,1),nviews+1);

% Assign fluorescent data
for k = 1:length(tii)
    dat = zeros(nr,nc,4);
    for j = 1:nviews
        dat(:,:,j)=cmosData{j}(:,:,k);
    end
    assignDat=nan(size(norms,1),nviews+1);
    
    for i=1:nviews
        %fprintf('Computing candidate DIRECT and EDGE textures for view %d at ti=%d\n',i,k);
        % find the faces visible from this view
        gg=find(viewi(:,i));
        thisdat=dat(:,:,i);
        tex = bg{i};
        if ~isempty(gg);
            for j=1:size(gg,1)
                assignDat(gg(j),i)=sum(sum(thisdat(txtkernel{gg(j),i,1})...
                    .*txtkernel{gg(j),i,2}))/sum(sum(txtkernel{gg(j),i,2}));
                % Single iteration for texture
                if k == 1
                    assignTex(gg(j),i)=sum(sum(tex(txtkernel{gg(j),i,1})...
                        .*txtkernel{gg(j),i,2}))/...
                        sum(sum(txtkernel{gg(j),i,2}));
                end
            end
        end
    end
    %%%% added fluorescence averaging within surface mesh cells. 6/4/04, MWKay
    
    % Assign one texture for each cell
    %fprintf('Assigning textures for k=%d\n',k);
    for i=1:size(assignDat,1)
        if (viewi(i,nviews+1)~=0 && viewi(i,nviews+1)<=nviews)   % DIRECT
            assignDat(i,end)=assignDat(i,viewi(i,nviews+1));
            if k == 1
                assignTex(i,end)=assignTex(i,viewi(i,nviews+1));
            end
        elseif viewi(i,nviews+1)>nviews                         % OVERLAP or EDGE
            gg=find(viewi(i,1:nviews));
            assignDat(i,end)=sum(assignDat(i,gg)...
                .*ledge(i,gg))/sum(ledge(i,gg));    % Weighted average
            % Single iteration for texture
            if k == 1
                assignTex(i,end)=sum(assignTex(i,gg)...
                    .*ledge(i,gg))/sum(ledge(i,gg));
            end
        end
    end
    
    %--------------------------------------------------
    % Get rid of sites on the top
    % (this is not needed for decimated models
    if nuketopdata
        thetaz=acos(norms(:,3)).*180/pn;
        thetaz=real(thetaz);
        gg=find(thetaz<=top_thresh);
        assignDat(gg,end)=NaN;
    end
    
    %--------------------------------------------------
    % set low sites to 1
    %gg=find(txtyour(:,end)<=mapthresh);
    %txtyour(gg,end)=1;
    
    %--------------------------------------------------
    % set NaN sites to 0
    gg=find(isnan(assignDat(:,end)));
    assignDat(gg,end)=0;
    
    %---------------------------------------------
    % save texture
    
    %fwrite(fid,txtyour(:,end),'float');
    % remember to write null data to electrode 1
%     fwrite(fid,[0 txtyour(:,end)'].*1000,dat_precision);
%     fprintf('Saved texture in %s',txtfname);
    dataProj(:,k) = assignDat(:,end);
    % Single iteration for texture
    if k == 1
        textProj = assignTex(:,end);
    end
    
    waitbar(k/length(tii))
end
close(h)
fclose(fid);

%% Identify the edge cells %%
disp('Finding points along edges ...');
edges=int8(zeros(size(viewi,1),1));
for j=1:size(edges,1)
    if neighnum(j)==3
        if (viewi(neighs{j}(1),end)-viewi(neighs{j}(2),end))~=0
            edges(j)=1;
        elseif (viewi(neighs{j}(1),end)-viewi(neighs{j}(3),end))~=0
            edges(j)=1;
        elseif (viewi(neighs{j}(2),end)-viewi(neighs{j}(3),end))~=0
            edges(j)=1;
        end
    end
    if neighnum(j)==2  % if cell is diff than either of its 2 neighs then on edge
        if (viewi(neighs{j}(1),end)-viewi(j,end))~=0
            edges(j)=1;
        elseif (viewi(j,end)-viewi(neighs{j}(2),end))~=0
            edges(j)=1;
        end
    end
end

end