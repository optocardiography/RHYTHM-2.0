%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Description: CMOSconverter is a function for extracting data from
% SciMedia's proprietary file format and saving it as a *.mat file for
% future use.
%
% INPUTS
% olddir = directory where file is located
% oldfilename = filename
% 
% OUTPUT
% cmosData = pertinent data as saved in this structure including: 
%                + intensity = cmosData and cmosData2
%                + analog channels = channel1 and channel2
%                + time per frame = acqFrequency
%                + rate of acquisition = frequency
%                + background image = bgimage
%                + dual camera setting = dual(1 - yes / 0 - no)
%
% REFERENCES
%
% ADDITIONAL NOTES
%
% RELEASE VERSION ?.?.?
%
% AUTHOR: SciMedia
%

%% Code
function cmosData = CMOSconverter(olddir,oldfilename)
newfilename = [oldfilename(1:length(oldfilename)-3),'mat'];
dirname = [olddir,'/'];
gsdFlag = 0;

%% RSH format data %%
if strcmp(oldfilename(end-2:end),'rsh')
    % Read the file
    disp(['converting ',oldfilename])
    fid=fopen([dirname,oldfilename],'r','b');
    fstr=fread(fid,'int8=>char')';
    fclose(fid);
    sampind2=strfind(fstr,'msec');
    
    % Sampling frequency
    acqFrontInd = strfind(fstr,'sample_time');
    acqBackInd = sampind2-acqFrontInd;
    [~,acqBackInd] = min(acqBackInd);
    acqBackInd = sampind2(acqBackInd)-2;
    acqFreq = str2double(fstr(acqFrontInd+13:acqBackInd));
    
    % Dual cam
    dualIndFront = strfind(fstr,'dual_cam');
    % This values is separated from the next by a line break aka char(10)
    dualIndBack = strfind(fstr(dualIndFront:dualIndFront+15),char(10))+dualIndFront-1;
    dual = str2double(fstr(dualIndFront+9:dualIndBack-1));
    
    % Save the frequency to put it in the .m file
    if dual ~= 0 && strcmp(fstr(3),'U')
        frequency = (1000/acqFreq)/2;
    else
        frequency = 1000/acqFreq;
    end
    
    % Locate the Data-File-List
    dataFileListInd = strfind(fstr,'Data-File');
    % Find the line breaks
    lineBreaksInd = strfind(fstr(dataFileListInd:end),char(10))+dataFileListInd-1;
    % Remove line break at end of string
    if lineBreaksInd(end) == length(fstr)
        lineBreaksInd = lineBreaksInd(1:end-1);
    end
    % Preallocate data file name variable
    dataPaths = cell(length(lineBreaksInd),1);
    % Grab data file names
    for n = 1:length(lineBreaksInd)
        if n == length(lineBreaksInd)
            dataPaths{n} = fstr(lineBreaksInd(n)+1:end);
        else
            dataPaths{n} = fstr(lineBreaksInd(n)+1:lineBreaksInd(n+1));
        end
        charCheck = repmat((1:32)',[1 length(dataPaths{n})]);
        tmp = repmat(dataPaths{n},[size(charCheck,1) 1]);
        tmp = sum(charCheck == tmp);
        tmp = (1:length(tmp)).*tmp;
        tmp = unique(tmp);
        tmp = tmp(2:end);
        dataPaths{n}(tmp) = [];
    end
    
    % Read out CMOS data
    num = length(dataPaths);
    % Check for old file format
    if strcmp(fstr(3),'U')
        % Check for dual camera
        if dual ~= 0
            cmosData = int32(zeros(100,100,(num-1)*256/2));
            cmosData2 = int32(zeros(100,100,(num-1)*256/2));
        else
            cmosData = int32(zeros(100,100,(num-1)*256));
        end
    else
        % Preallocate for new file format
        cmosData = int32(zeros(100,100,(num-1)*256));
    end
    
    % Analog inputs
    channel = cell(2,1);
    channel{1} = zeros(1,size(cmosData,3)*20);
    channel{2} = zeros(1,size(cmosData,3)*20);
    analogInd = 1:4:80;
    k=0;

    for i = 2:num
        fpath = [dirname dataPaths{i}];
        fid=fopen(fpath,'r','l');       % use big-endian format
        fdata=fread(fid,'int16=>int32')'; %
        fclose(fid);
        fdata = reshape(fdata,12800,[]);
        
        % Specify step size based on single or dual camera
        if dual ~= 0
            step = 2;
        else
            step = 1;
        end
        for j = 1:step:size(fdata,2);
            if dual == 0
                oneframe = fdata(:,j);  % one frame at certain time point
                oneframe = reshape(oneframe,128,100);
                cmosData(:,:,k*size(fdata,2)+j) = oneframe(21:120,:)';
%                 cmosData(:,:,k) = oneframe(21:120,:)';
            else
                newInd = (j+1)/2;
                oneframe = fdata(:,j);
                oneframe = reshape(oneframe,128,100);
                cmosData(:,:,k*(size(fdata,2)/2)+newInd) = oneframe(21:120,:)';
                oneframe2 = fdata(:,j+1);
                oneframe2 = reshape(oneframe2,128,100);
                cmosData2(:,:,k*(size(fdata,2)/2)+newInd) = oneframe2(21:120,:)';
            end
            chanInd = (1:length(analogInd))+length(analogInd)*(i-1);
            oneFrameInd1 = sub2ind([size(oneframe,1) size(oneframe,2)],...
                analogInd,repmat(3,[size(analogInd,1) size(analogInd,2)]));
            channel{1}(chanInd) = oneframe(oneFrameInd1);
            oneFrameInd2 = sub2ind([size(oneframe,1) size(oneframe,2)],...
                analogInd,repmat(3,[size(analogInd,1) size(analogInd,2)]));
            channel{2}(chanInd) = oneframe(oneFrameInd2);

        end
        % incremement counter to step forward in time
        k=k+1;
    end

    cmosData = cmosData(:,:,2:end);
    if dual~=0
        bgimage2 = cmosData2(:,:,1);
        cmosData2 = cmosData2(:,:,2:end);
    end
    clear fdata
    % Get background image for new file format
    fid=fopen([dirname,[oldfilename(1:end-1) 'm']],'r','l');
    fdata=fread(fid,'int16=>32')';
    fclose(fid);
    fdata = int32(reshape(fdata,12800,[]));
    fdata = reshape(fdata,128,100);
    bgimage = fdata(21:120,:)';
    
%% GSD data %%
else
    % Open header file
    gsdFlag = 1;
    fid=fopen([dirname,oldfilename],'r','b');
    fstr=fread(fid,'int8=>char')';
    fclose(fid);
    
    camTypeFlag = strfind(fstr, 'Camera');
    camType = fstr(camTypeFlag:camTypeFlag+1);
    if size(camType,2) == 0 
        % Grab header information
        ind = strfind(fstr,'Frame');
        numFrames = str2double(fstr(ind+13:ind+17));
        ind = strfind(fstr,'Sampling');
        acqFreq = str2double(fstr(ind+16:ind+19)); % in msec
        frequency = 1000/acqFreq;
        ind = strfind(fstr,'dual_cam');
        dual = str2double(fstr(ind+10));
    else
        ind = strfind(fstr,'frames');
        numFrames = str2double(fstr(ind+9:ind+13));
        ind = strfind(fstr,'Exposure');
        acqFreq = str2double(fstr(ind+21:ind+22)); % in msec
        frequency = 1000/acqFreq;
        dual = 0;
    end
    % Grab data %
    fpath = [dirname oldfilename(1:end-3) 'gsd'];
    % use big-endian format
    fid=fopen(fpath,'r','l');
    % Grab dimensions of data
    status = fseek(fid,256,'bof');
    xPixels = fread(fid,1,'short');      %nDataXsize
    yPixels = fread(fid,1,'short');      %nDataYsize
    xSkipPix = fread(fid,1,'short');     %nLeftSkip
    ySkipPix = fread(fid,1,'short');     %nTopSkip
    xActPix = fread(fid,1,'short');      %nImgXsize
    yActPix = fread(fid,1,'short');      %nImgYsize
    status = fseek(fid,328,'bof');
    nChanum = fread(fid,1,'short');
    nRate = fread(fid,1,'short');   %how many times faster analog acquisition is
    analogFreq = 1000/(acqFreq*nRate);
    % Grab background image
    status = fseek(fid,972,'bof');
    bgimage = fread(fid,xPixels*yPixels,'short');
    bgimage = reshape(bgimage,[xPixels yPixels])';
    bgimage = bgimage(ySkipPix+1:ySkipPix+yActPix,xSkipPix+1:xSkipPix+xActPix);
    % Grab optical data
    cmosData = fread(fid,xPixels*yPixels*numFrames,'short');
    cmosData = reshape(cmosData,[xPixels yPixels numFrames]);
    cmosData = cmosData(xSkipPix+1:xSkipPix+xActPix,ySkipPix+1:ySkipPix+yActPix,:);
    cmosData = flip(rot90(cmosData,3),2);
    if size(cmosData,1) ~= size(bgimage,1)
        % For some reason images taken with D225 cameras need to be rotated
        cmosData = flip(rot90(cmosData,3),2);
    end
    % Analog inputs 
    channel = cell(nChanum,1);
    status = fseek(fid,972+xPixels*yPixels*2*numFrames+25600,'bof');
    for n = 1:nChanum
           channel{n} = fread(fid,numFrames*nRate,'short');
    end    
end

%% Based on the assumption that the upstroke is downward, not upward.
len = size(cmosData,3);
thred = 2^16*3/4;
ind = reshape(1:size(cmosData,1)*size(cmosData,2),[size(cmosData,1) size(cmosData,2)]);
ind = repmat(ind,[1 1 len]);
step = reshape(0:size(cmosData,3)-1,[1 1 len]);
step = repmat(step*(size(cmosData,1)*size(cmosData,2)),[size(cmosData,1) size(cmosData,2) 1]);
ind = ind+step;
ind = ind(:,:,2:end);

%Identify signals that meet the criteria
check = abs(cmosData(:,:,2:end)-cmosData(:,:,1:end-1))>thred;
check = check.*ind;
check = unique(check);
check = check(2:end);

% For the values greater than zero
above = cmosData(check)>0;
cmosData(check(above)) = cmosData(check(above))-2^16;
% For the values less than zero
below = cmosData(check)<0;
cmosData(check(below)) = 2^16+cmosData(check(below));


cmosData = -cmosData;
if dual ~= 0
    if gsdFlag == 0
        cmosData2 = -cmosData2;
    end
end

% Build new filename
newfilename = [olddir,'/',newfilename];

%% conversion from CDS to DEF
cmosData=cmosData-repmat(bgimage,[1 1 size(cmosData,3)]);
if strcmp(fstr(3),'U')
    if dual ~= 0
        cmosData2=cmosData2-repmat(bgimage2,[1 1 size(cmosData2,3)]);
    end
end
% Save data as a *.mat file
if strcmp(fstr(3),'U')
    if dual == 0
        save(newfilename,'cmosData','channel','acqFreq','frequency', 'bgimage','dual');
    else
        save(newfilename,'cmosData','cmosData2','channel','acqFreq','frequency','bgimage','bgimage2','dual');
    end
else
    save(newfilename,'cmosData','channel','acqFreq','nRate','frequency', 'bgimage','dual');
end







