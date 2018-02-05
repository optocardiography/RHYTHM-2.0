%% FIT3 User Interface
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Description: Graphical user interface for calibrating 
% whole heart at 45 degree angles (negY, negX).

function FIT3
%% Create GUI structure
handles.scrnSize = get(0,'ScreenSize');
pR = figure('Name','FIT 3.0','Visible','off',...
    'Position',[1 1 980 660],'NumberTitle','Off');

% Screens for anlayzing data
axesSize = 600;
blockView = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[15 15 axesSize axesSize]);
overlayView = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Visible','off','Position',[15 15 axesSize axesSize]);

% Select Directory
dirSelect = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Select Geometry Directory','Position',[15 625 150 25],'Callback',...
    {@dirSelect_callback});
dirName = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized','String',...
    '','Enable','off','HorizontalAlignment','Left','Position',[180 625 660 25]);

% Hardware Settings
hardwareSettings = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Hardware Settings:','Position',[690 580 200 40]);
calibDirectText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized','String',...
    'Calibration Direction: ','Position',[620 565 140 25]);
calibDirectDrop = uicontrol('Parent',pR,'Style','popupmenu','FontUnits','normalized','String',...
    {'---','1. Clockwise','2. Counter-Clockwise'},'Position',...
    [765 565 210 25],'Callback',{@cwDrop_callback});
calibBlockText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized','String',...
    'Animal/Calibration Block: ','Position',[615 535 165 25]);
calibAnimalandBlock = uicontrol('Parent',pR,'Style','popupmenu','FontUnits','normalized','String',...
    {'---','Rabbit (1/4 inch)','Rat/Mouse (1/8 inch)','Pig w/ Brainvision (3/8 inch)','Pig w/ Andor (0.6 inch)'},...
    'Position',[765 535 150 25],'Callback',{@speciesAndBlockDrop_callback});
calibTypeTxt = uicontrol('Parent',pR,'String','Calibration Type:',...
    'Style','text','FontUnits','normalized',...
    'Position',[625 505 130 25]);
calibType = uicontrol('Parent',pR,'Style','popupmenu','FontUnits','normalized','Position',[765 505 170 25],...
    'String',{'Cube','Camera A','Camera B','Camera C','Camera D'});
calibCameraTxt = uicontrol('Parent',pR,'Style','text','FontUnits','normalized','String',...
    'Camera Type: ','HorizontalAlignment','Left','Position',[635 475 95 25]);
calibCameraType = uicontrol('Parent',pR,'Style','popupmenu','FontUnits','normalized',...
    'String',{'---','iDS_UI_3220CP-M-GL_with_f1.2','brainvision_ultimaL','IDS-UI-3280CP-C-HQ',...
    },'Position',[765 475 180 25]);
loadImage = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Load Image','Position',[700 445 79 25],'Callback',{@loadImage_callback});
resetImage = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Reset','Position',[800 445 79 25],'Callback',{@resetImage_callback});

% Thresholding
threshText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Thresholding:','Position',[690 385 200 40]);
cubeThreshText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Cube Threshold:','Position',[625 375 93 25]);
cubeThreshEditBot = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','0','Position',[635 355 30 20],'Callback',...
    {@cubeThreshEditBot_callback});
cubeThreshEditTop = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','1','Enable','off','Position',[875 355 30 20]);
cubeThreshSlider = uicontrol('Parent',pR,'Style','slider',...
    'Position',[670 355 200 20],'Callback',{@cubeThreshSlider_callback});
cubeGrab = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Spline','Position',[920 355 50 20],'Callback',...
    {@cubeGrab_callback});
gridThreshText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Grid Threshold:','Position',[625 325 93 25]);
gridThreshEditBot = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','0','Enable','off','Position',[635 310 30 20]);
gridThreshEditTop = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','1','Position',[875 310 30 20],'Callback',{@gridThreshEditTop_callback});
gridThreshSlider = uicontrol('Parent',pR,'Style','slider',...
    'Position',[670 310 200 20],'Callback',{@gridThreshSlider_callback});

% Skeletonization
skeletonText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Skeletonization:','Position',[690 255 200 40]);
skeletonConnText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Connectivity:','HorizontalAlignment','Left','Position',...
    [625 235 72 25]);
skeletonConnDrop = uicontrol('Parent',pR,'Style','popupmenu','FontUnits',...
    'normalized','String',{'4-connected','8-connected'},'Position',[700 235 120 25]);
skeletonRun = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Run','Position',[825 235 40 25],'Callback',{@skeletonRun_callback});

% Junction Assignment
junkText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Junction Assignment:','Position',[690 185 200 40]);
junkNbrText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Neighborhood Kernel Size:','HorizontalAlignment','Left',...
    'Position',[625 165 150 25]);
junkNbrEdit = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','9','Enable','off','Position',[765 168 40 25],'Callback',...
    {@junkNbrEdit_callback});
junkThreshText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Junction Threshold:','HorizontalAlignment','Left',...
    'Position',[625 135 109 25]);
junkThreshEditBot = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','0','Position',[625 115 40 20],...
    'Callback',{@junkThreshEditBot_callback});
junkThreshEditTop = uicontrol('Parent',pR,'Style','edit','FontUnits','normalized',...
    'String','1','Enable','off','Position',[875 115 40 20]);
junkThreshSlider = uicontrol('Parent',pR,'Style','slider',...
    'Position',[670 115 200 20],'Callback',{@junkThreshSlider_callback});
junkThreshLock = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Lock','Position',[920 115 50 20],'Callback',{@junkThreshLock_callback});
junkPtText = uicontrol('Parent',pR,'Style','text','FontUnits','normalized',...
    'String','Clean-up & Assignment:','Position',[615 82 134 25]);
junkAddPt = uicontrol('Parent',pR,'Style','togglebutton','FontUnits','normalized',...
    'String','Add','Position',[625 60 65 25],'Callback',...
    {@junkAddPt_callback});
junkRemovePt = uicontrol('Parent',pR,'Style','togglebutton','FontUnits','normalized',...
    'String','Remove','Position',[700 60 65 25],'Callback',...
    {@junkRemovePt_callback});
junkAssign = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Assign','Position',[775 60 65 25],'Callback',...
    {@junkAssign_callback});
junkCalibrate = uicontrol('Parent',pR,'Style','pushbutton','FontUnits','normalized',...
    'String','Calibrate','Position',[850 60 65 25],'Callback',...
    {@junkCalibrate_callback});

% Allow all GUI structures to be scaled when window is dragged
set([pR,blockView,hardwareSettings,...
    calibDirectText,calibDirectDrop,calibTypeTxt,calibType,...
    calibBlockText,calibAnimalandBlock,calibCameraTxt,calibCameraType,loadImage,...
    threshText,cubeThreshText,cubeThreshEditBot,cubeThreshEditTop,...
    cubeThreshSlider,cubeGrab,gridThreshText,gridThreshEditBot,...
    gridThreshEditTop,gridThreshSlider,skeletonText,...
    skeletonConnText,skeletonConnDrop,skeletonRun,junkThreshText,...
    junkThreshEditBot,junkThreshEditTop,junkThreshSlider,junkThreshLock,...
    junkText,overlayView,junkNbrText,junkNbrEdit,junkPtText,junkAddPt,...
    junkRemovePt,junkAssign,junkCalibrate,dirSelect,dirName,resetImage],'Units','normalized')

% Disable all point selection tools until an image is loaded
set([calibDirectDrop,calibAnimalandBlock,calibType,...
    calibCameraType,loadImage,cubeThreshEditBot,cubeThreshSlider,cubeGrab,...
    gridThreshEditTop,gridThreshSlider,skeletonConnDrop,...
    skeletonRun,junkThreshEditBot,junkThreshSlider,junkThreshLock,...
    junkNbrEdit,junkAddPt,junkRemovePt,junkAssign,junkCalibrate,resetImage],...
    'Enable','off')

% Center GUI on screen
movegui(pR,'center')
set(pR,'MenuBar','none','Visible','on')

%% Create Handles %%
% User-defined values
handles.zrange = [60 30];
handles.method = 2;
handles.geoDir = []; % experimental directory
handles.speciesID = 0; % experimental species
handles.species = [];
handles.angle = [45 45 315 225 135]; % the mapping cameras are currently labeled CW
handles.plane1fname = [];
handles.plane2fname = [];
handles.data = [];                  % calibration data
handles.calStep = 1;                % calibration index value
handles.xi = [];                    % x positions of the calibration points
handles.yi = [];                   % y positions of the calibraiton points
handles.calibXi = [];
handles.calibYi = [];
handles.camera = [];
handles.skipInd = [];                 % skipped calibration points
handles.CT = [];
handles.CMOScams = 'ABCD';
handles.cubeVal = [];
handles.gridVal = [];
handles.skelRunPress = 0;
handles.nbrLockPress = 0;
handles.skel = [];
handles.nbrKernelSize = str2double(get(junkNbrEdit,'String'));
handles.pixNbrhdCnt = [];
handles.skelJunk = [];
handles.junkCenter = [];
handles.junkLockPress = 0;

%% Select Experimental Directory %%
    function dirSelect_callback(~,~)
        % Grab current directory
        gcd = pwd;
        % Select experimental directory
        handles.geoDir = uigetdir(gcd,'Select the Geometry directory.');
        % Populate text field
        if handles.geoDir ~= 0
            % set the directory field
            set(dirName,'String',handles.geoDir)
            % change current directory accordingly
            cd(handles.geoDir)
            % Enable Harware Settings tools
            set([calibDirectDrop,calibAnimalandBlock,calibType,...
                calibCameraType,loadImage],'Enable','on')
        end
    end

%% Select Species I.D. and Calibration Block %%
    function speciesAndBlockDrop_callback(source,~)
        % Save out species i.d.
        handles.speciesID = get(source,'Value')-1;
        if handles.speciesID==1
            handles.species='rabbit';
        elseif handles.speciesID==2
            handles.species='rat_mouse';
        elseif handles.speciesID==3
            handles.species='pig_brainvision';
        elseif handles.speciesID==4
            handles.species='pig_andor';
        end
    end

%% Select Calibration Direction %%
    function cwDrop_callback(source,~)
        % Save out calibration direction
        tmp = get(source,'Value');
        if tmp == 1
            handles.calibDirect = '';
        elseif tmp == 2
            handles.calibDirect = 'cw';
        elseif tmp == 3
            handles.calibDirect = 'ccw';
        end
    end

%% Load Image Callback %%
    function loadImage_callback(~,~)
        % make sure in Geometry directory
        cd(handles.geoDir)
        % select the calibration file
        [handles.calfilename,handles.calpathname] = uigetfile('*.tiff','Pick calibration file.');
        if handles.calfilename ~= 0
            % load calibration image
            a = imread([handles.calpathname handles.calfilename]);
            handles.a=a;
            handles.aInfo = imfinfo([handles.calpathname handles.calfilename]);
            
            % plane 1 calibration filenames
            CT = get(calibType,'Value');
            
            % create filenames for calibration block locations and normals
            [plane1fname,plane2fname] = getCalibInfo(CT);
            handles.plane1fname = plane1fname;
            handles.plane2fname = plane2fname;
            
            % create calibration point variables
            handles.calpts_nd = [];
            
            % load calibration block files
            fid=fopen(sprintf('%s/%s',...
                handles.species,plane1fname));
            if fid~=-1
                fclose(fid);
                fprintf('Loading %s ...\n',handles.plane1fname);
                calpts1=load(sprintf('%s/%s',...
                    handles.species,plane1fname));
            else
                fprintf('Could not load %s!',plane1fname);
                return
            end
            fid=fopen(sprintf('%s/%s',...
                handles.species,plane2fname));
            if fid~=-1
                fclose(fid);
                fprintf('Loading %s ...\n',plane2fname);
                calpts2=load(sprintf('%s/%s',...
                    handles.species,plane2fname));
            else
                fprintf('Could not load %s\n!',plane2fname);
                return
            end
            handles.calpts_nd = [calpts1;calpts2];       % nondimensional calibration point positions in cube basis
            % Preallocate the data variable
            handles.data = zeros(size(handles.calpts_nd,1),8);
            
            % Preallocate xi and yi calibration coordinate variables
            handles.xi = zeros(size(handles.calpts_nd,1),1);
            handles.yi = zeros(size(handles.calpts_nd,1),1);
            handles.calibTxt = cell(length(handles.xi),1);
            handles.calibXi = zeros(size(handles.calpts_nd,1),1);
            handles.calibYi = zeros(size(handles.calpts_nd,1),1);
            
            % Launch calibration images
            axes(blockView)
            handles.A = image(handles.a);
            colormap('gray')
            set(blockView,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            % Grab image width and height values
            imageWidth = size(a,2);
            imageHeight = size(a,1);
            
            % Grab figure position information
            figPos = get(gcf,'Position');
            % Grab axes position information
            axesPos = get(blockView,'Position');
            % Grab the width and height of the axes and convert to pixels
            axesWidth = handles.scrnSize(3)*figPos(3)*axesPos(3);
            axesHeight = handles.scrnSize(4)*figPos(4)*axesPos(4);
            % Grab top left x and y coordinates
            axesX = axesPos(1);
            axesY = axesPos(2);
            
            if imageHeight > imageWidth
                % Find the new width in pixels based on the image proportions
                newWidth =  axesHeight*(imageWidth/imageHeight);
                % Convert back to a percentage
                newWidth = newWidth/(handles.scrnSize(3)*figPos(3));
                % Find the difference in values
                widthDiff = (axesPos(3)-newWidth)/2;
                % Change axes size and shift with these values
                
                axesWidthPercent = axesWidth/(handles.scrnSize(3)*figPos(3));
                set([blockView overlayView],'Position',[axesX axesY axesWidthPercent axesPos(4)])
                
                % Find new height in pixels based on image proportions
                newHeight = (imageHeight/imageWidth)*axesWidth;
                % Convert new value back to a percentage
                newHeight = newHeight/(handles.scrnSize(4)*figPos(4));
                % Find the vertical shift to keep axes centered
                heightDiff = (axesPos(4)-newHeight)/2;
                % Change axes size and shift with these values
                
                axesHeightPercent = axesHeight/(handles.scrnSize(4)*figPos(4));
                set([blockView overlayView],'Position',[axesX axesY axesPos(3) axesHeightPercent])
            end
            
            % Grab image max and min
            handles.imMax = double(max(max(handles.a(:,:,1))));
            handles.imMin = double(min(min(handles.a(:,:,1))));
            % Update top cube threshold edit boxes
            set([cubeThreshEditBot,gridThreshEditBot,gridThreshEditTop],...
                'String',num2str(min(min(handles.a(:,:,1)))));
            set(cubeThreshEditTop,'String',num2str(max(max(handles.a(:,:,1)))));
            set([cubeThreshSlider,gridThreshSlider],'Min',handles.imMin,'Max',handles.imMax,...
                'Value',handles.imMin,'SliderStep',[1/(handles.imMax+1) 10/(handles.imMax+1)])
            
            % Enable all point selection tools until an image is loaded
            set([cubeThreshEditBot,cubeThreshSlider,cubeGrab,gridThreshEditTop,...
                gridThreshSlider,skeletonConnDrop,skeletonRun,resetImage],'Enable','on')
            
            % Diable Hardware Settings
            set([calibDirectDrop,calibAnimalandBlock,calibType,...
                calibCameraType,loadImage],'Enable','off')
            
        end
    end


%% Reset Image Callback %%
    function resetImage_callback(~,~)
        % Reset image to white
        cla(blockView)
        cla(overlayView)
        
        % Enable drop-downs
        set([calibDirectDrop,calibAnimalandBlock,calibType,...
            calibCameraType,loadImage],'Enable','on')
        % Disable thresholding and skeletonization tools
        set([cubeThreshEditBot,cubeThreshSlider,cubeGrab,gridThreshEditTop,...
            gridThreshSlider,skeletonConnDrop,skeletonRun,resetImage],'Enable','off')
        set([junkNbrEdit,junkThreshEditBot,junkThreshSlider,...
            junkThreshLock,cubeGrab],'Enable','off')
        % Switch string to run
        set(skeletonRun,'String','Run')
        % Switch press tracker
        handles.skelRunPress = 0;
        set(junkThreshLock,'String','Lock')                        
        handles.junkLockPress = 0;
    end

%% Cube Thresholding Top Edit Box Callback %%
    function cubeThreshEditBot_callback(source,~)
        % Get the threshold value
        handles.cubeVal = str2double(get(source,'String'));
        % Update slider position
        set(cubeThreshSlider,'Value',handles.cubeVal)
        % Grab background image
        I = handles.a;
        % Use a threshold to grab the block
        handles.TH = I(:,:,1) >= handles.cubeVal;
        % Identify largest connected component to separate from noise in bkgrd
        CC = bwconncomp(handles.TH,4);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        BW = zeros(size(handles.TH,1),size(handles.TH,2));
        BW(CC.PixelIdxList{idx}) = 1;
        % Erode and dilate to eliminate spurs
        handles.se = strel('square',7);
        BW2 = imerode(BW,handles.se);
        BW3 = imdilate(BW2,handles.se);
        % Dilate and erode to close any gaps
        BW4 = imdilate(BW3,handles.se);
        handles.BW5 = imerode(BW4,handles.se);
        % Isolate this portion of the image
        I2 = I;
        I2(~repmat(handles.BW5,[1 1 3])) = 0;
        % Convert image to a grayscale image
        handles.BW = rgb2gray(I2);
        
        % Update the viewer with the mask overlayed on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        set(blockView,'XTick',[],'YTick',[])
        
    end


%% Cube Thresholding Slider Callback %%
    function cubeThreshSlider_callback(source,~)
        % Get the threshold value
        handles.cubeVal = double(round(get(source,'Value')));
        % Update edit box value position
        set(cubeThreshEditBot,'String',num2str(handles.cubeVal))
        % Grab background image
        I = handles.a;
        % Use a threshold to grab the block
        handles.TH = I(:,:,1) >= handles.cubeVal;
        % Identify largest connected component to separate from noise in bkgrd
        CC = bwconncomp(handles.TH,4);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        BW = zeros(size(handles.TH,1),size(handles.TH,2));
        BW(CC.PixelIdxList{idx}) = 1;
        % Erode and dilate to eliminate spurs
        handles.se = strel('square',7);
        BW2 = imerode(BW,handles.se);
        BW3 = imdilate(BW2,handles.se);
        % Dilate and erode to close any gaps
        BW4 = imdilate(BW3,handles.se);
        handles.BW5 = imerode(BW4,handles.se);
        % Isolate this portion of the image
        I2 = I;
        I2(~repmat(handles.BW5,[1 1 3])) = 0;
        % Convert image to a grayscale image
        handles.BW = rgb2gray(I2);
        
        % Update the viewer with the mask overlayed on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        set(blockView,'XTick',[],'YTick',[])
    end

%% Cube Grab Callback %%
    function cubeGrab_callback(~,~)
        % Grab background image
        I = handles.a;
        axes(blockView)
        handles.TH = roipoly;
        if ~isempty(handles.TH)
            % Identify largest connected component to separate from noise in bkgrd
            CC = bwconncomp(handles.TH,4);
            numPixels = cellfun(@numel,CC.PixelIdxList);
            [~,idx] = max(numPixels);
            BW = zeros(size(handles.TH,1),size(handles.TH,2));
            BW(CC.PixelIdxList{idx}) = 1;
            % Erode and dilate to eliminate spurs
            handles.se = strel('square',7);
            BW2 = imerode(BW,handles.se);
            BW3 = imdilate(BW2,handles.se);
            % Dilate and erode to close any gaps
            BW4 = imdilate(BW3,handles.se);
            handles.BW5 = imerode(BW4,handles.se);
            % Isolate this portion of the image
            I2 = I;
            I2(~repmat(handles.BW5,[1 1 3])) = 0;
            % Convert image to a grayscale image
            handles.BW = rgb2gray(I2);
            
            % Update the viewer with the mask overlayed on the backgroud image
            cla(blockView)
            axes(blockView)
            imagesc(handles.BW)
            set(blockView,'XTick',[],'YTick',[])
        end
    end

%% Grid Threshold Slider Callback %%
    function gridThreshSlider_callback(source,~)
        % Grab slider value
        handles.gridVal = double(round(get(source,'Value')));
        % Update slider position
        set(gridThreshEditTop,'String',num2str(handles.gridVal))
        % Identify largest connected component to separate from noise in bkgrd
        % Identify grid
        BLOCK = handles.BW > handles.gridVal;
        % se = strel('square',9);
        BLOCK = (BLOCK == 0).*imerode(handles.BW5,handles.se);
        CC = bwconncomp(BLOCK,4);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        handles.GRID = zeros(size(handles.TH,1),size(handles.TH,2));
        handles.GRID(CC.PixelIdxList{idx}) = 1;
        
        % Update the viewer with the mask overlayed on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        colormap('gray')
        set(overlayView,'Visible','on')
        axes(overlayView)
        imagesc(handles.GRID,'AlphaData',handles.GRID)
        colormap(overlayView,'jet')
        set(overlayView,'Color','none')
        set([blockView overlayView],'XTick',[],'YTick',[])
    end


%% Grid Threshold Edit Box Callback %%
    function gridThreshEditTop_callback(source,~)
        % Get the threshold value
        handles.gridVal = str2double(get(source,'String'));
        % Update slider position
        set(gridThreshSlider,'Value',handles.gridVal)
        % Identify grid
        BLOCK = (handles.BW <= handles.gridVal).*imerode(handles.BW5,handles.se);
        % Identify largest connected component to separate from noise in bkgrd
        CC = bwconncomp(BLOCK,4);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        handles.GRID = zeros(size(handles.TH,1),size(handles.TH,2));
        handles.GRID(CC.PixelIdxList{idx}) = 1;
        
        % Update the viewer with the mask overlayed on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        colormap('gray')
        set(overlayView,'Visible','on')
        axes(overlayView)
        imagesc(handles.GRID,'AlphaData',handles.GRID)
        colormap(overlayView,'jet')
        set(overlayView,'Color','none')
        set([blockView overlayView],'XTick',[],'YTick',[])
    end

%% Skeletonization Run Button Callback %%
    function skeletonRun_callback(~,~)
        h = msgbox('Running Skeletonization....');
        if handles.skelRunPress == 0
            % Get the connectivity
            k = get(skeletonConnDrop,'Value')*4;
            % Perform skeletonization
            handles.skel = skeletonization(handles.GRID,k);
            
            % Update the viewer with the skeleton overlayed on the bkgrnd image
            cla(blockView)
            axes(blockView)
            imagesc(handles.BW)
            colormap('gray')
            set(overlayView,'Visible','on')
            axes(overlayView)
            imagesc(handles.skel,'AlphaData',handles.skel)
            colormap(overlayView,'jet')
            set(overlayView,'Color','none')
            set([blockView overlayView],'XTick',[],'YTick',[])
            
            % Make the junction thresholding tools available
            set([junkNbrEdit,junkThreshEditBot,junkThreshSlider,...
                junkThreshLock],'Enable','on')
            % Initialize junction thresholding
            handles.nbrKernelSize = str2double(get(junkNbrEdit,'String'));
            % Grab neighbhorhood kernel size
            kSize = handles.nbrKernelSize;
            % Create neighborhood kernel
            kernel = makeSquareKernel2D(handles.skel,kSize);
            % Grab index values of skeleton
            handles.ind = find(handles.skel);
            % Variable for the indices of the neighbors around each pixel
            pixNbrhd = repmat(reshape(handles.ind,...
                [1 1 length(handles.ind)]),[kSize kSize])...
                +repmat(kernel,[1 1 length(handles.ind)]);
            % Grab the neighbor values
            pixNbrhd = handles.skel(pixNbrhd);
            % Sum and apply threshold for neighborhood size to keep
            pixNbrhdCnt = reshape(sum(sum(pixNbrhd,1),2),[size(pixNbrhd,3) 1]);
            handles.pixNbrhdCnt = pixNbrhdCnt;
            % Provide a starting value for the neighborhood count threshhold
            handles.startNbrhdCnt = 0;
            % Update neighborhood threshold tools
            set(junkThreshEditBot,'String',num2str(handles.startNbrhdCnt))
            set(junkThreshEditTop,'String',num2str(max(pixNbrhdCnt)))
            set(junkThreshSlider','Value',handles.startNbrhdCnt,'Min',0,...
                'Max',max(pixNbrhdCnt),'SliderStep',...
                [1/max(pixNbrhdCnt) 10/max(pixNbrhdCnt)])
            
            % Make thresholding tools unavailable
            set([cubeThreshEditBot,cubeThreshSlider,gridThreshSlider,...
                gridThreshEditTop,skeletonConnDrop,cubeGrab],'Enable','off')
            % Switch string to return
            set(skeletonRun,'String','Return')
            % Switch press tracker
            handles.skelRunPress = 1;
        else
            % Update the viewer with the mask overlayed on the backgroud image
            cla(blockView)
            axes(blockView)
            imagesc(handles.BW)
            colormap('gray')
            set(overlayView,'Visible','on')
            axes(overlayView)
            imagesc(handles.GRID,'AlphaData',handles.GRID)
            colormap(overlayView,'jet')
            set(overlayView,'Color','none')
            set([blockView overlayView],'XTick',[],'YTick',[])
            % Make neighborhood tools unavailable
            set([junkNbrEdit,junkThreshEditBot,junkThreshSlider,...
                junkThreshLock,cubeGrab],'Enable','off')
            % Make thresholding tools available
            set([cubeThreshEditBot,cubeThreshSlider,gridThreshSlider,...
                gridThreshEditTop,skeletonConnDrop],'Enable','on')
            % Switch string to run
            set(skeletonRun,'String','Run')
            % Switch press tracker
            handles.skelRunPress = 0;
        end
        delete(h);
    end

%% Junction Neighborhood Edit Callback %%
    function junkNbrEdit_callback(source,~)
        % Update neighborhood kernel size
        handles.nbrKernelSize = str2double(get(source,'String'));
        % Grab neighbhorhood kernel size
        kSize = handles.nbrKernelSize;
        % Create neighborhood kernel
        kernel = makeSquareKernel2D(handles.skel,kSize);
        % Grab index values of skeleton
        handles.ind = find(handles.skel);
        % Variable for the indices of the neighbors around each pixel
        pixNbrhd = repmat(reshape(handles.ind,...
            [1 1 length(handles.ind)]),[kSize kSize])...
            +repmat(kernel,[1 1 length(handles.ind)]);
        % Grab the neighbor values
        pixNbrhd = handles.skel(pixNbrhd);
        % Sum and apply threshold for neighborhood size to keep
        pixNbrhdCnt = reshape(sum(sum(pixNbrhd,1),2),[size(pixNbrhd,3) 1]);
        handles.pixNbrhdCnt = pixNbrhdCnt;
        % Provide a starting value for the neighborhood count threshhold
        handles.startNbrhdCnt = 0;
        % Update neighborhood threshold tools
        set(junkThreshEditBot,'String',num2str(handles.startNbrhdCnt))
        set(junkThreshEditTop,'String',num2str(max(pixNbrhdCnt)))
        set(junkThreshSlider','Value',handles.startNbrhdCnt,'Min',0,...
            'Max',max(pixNbrhdCnt),'SliderStep',...
            [1/max(pixNbrhdCnt) 10/max(pixNbrhdCnt)])
    end

%% Junction Threshold Edit Box Callback %%
    function junkThreshEditBot_callback(source,~)
        % Get the junctions that have more than the specified # of neighbors
        junk = handles.pixNbrhdCnt > str2double(get(source,'String'));
        % Create a new skeleton variable to visualize neighborhoods
        handles.skelJunk = handles.skel;
        handles.skelJunk(handles.ind(junk)) = 0.3;
        
        junk = handles.skelJunk == 0.3;
        junkCC = bwconncomp(junk,8);
        junkNumPixels = cellfun(@numel,junkCC.PixelIdxList);
        junkNumPixels = find(junkNumPixels >= 8);
        junkClusters = cell(1,length(junkNumPixels));
        junkPts = [];
        junkRow = cell(1,length(junkNumPixels));
        junkCol = cell(1,length(junkNumPixels));
        junkCenter = zeros(length(junkNumPixels),2);
        
        for n = 1:length(junkNumPixels)
            junkClusters{n} = junkCC.PixelIdxList{junkNumPixels(n)};
            junkPts = [junkPts;junkCC.PixelIdxList{junkNumPixels(n)}];
            [junkRow{n}, junkCol{n}] = ind2sub(size(handles.skel),...
                junkCC.PixelIdxList{junkNumPixels(n)});
            junkCenter(n,1) = mean(junkRow{n});
            junkCenter(n,2) = mean(junkCol{n});
        end
        % save the value of the centers of each junction to handles
        handles.junkCenter = junkCenter;
        
        % Update the viewer with the junctions on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        colormap('gray')
        hold on
        scatter(junkCenter(:,2),junkCenter(:,1),'ro','SizeData',96)
        set(blockView,'XTick',[],'YTick',[])
        
        % Update the slider with the edit box value
        set(junkThreshSlider,'Value',str2double(get(source,'String')))
    end

%% Junction Threshold Slider Callback %%
    function junkThreshSlider_callback(source,~)
        % Get the value of the slider
        nbrhdThresh = get(source,'Value');
        junk = handles.pixNbrhdCnt > nbrhdThresh;
        % Create a new skeleton variable to visualize neighborhoods
        handles.skelJunk = handles.skel;
        handles.skelJunk(handles.ind(junk)) = 0.3;
        
        junk = handles.skelJunk == 0.3;
        junkCC = bwconncomp(junk,8);
        junkNumPixels = cellfun(@numel,junkCC.PixelIdxList);
        junkNumPixels = find(junkNumPixels >= 8);
        junkClusters = cell(1,length(junkNumPixels));
        junkPts = [];
        junkRow = cell(1,length(junkNumPixels));
        junkCol = cell(1,length(junkNumPixels));
        junkCenter = zeros(length(junkNumPixels),2);
        for n = 1:length(junkNumPixels)
            junkClusters{n} = junkCC.PixelIdxList{junkNumPixels(n)};
            junkPts = [junkPts;junkCC.PixelIdxList{junkNumPixels(n)}];
            [junkRow{n}, junkCol{n}] = ind2sub(size(handles.skel),...
                junkCC.PixelIdxList{junkNumPixels(n)});
            junkCenter(n,1) = mean(junkRow{n});
            junkCenter(n,2) = mean(junkCol{n});
        end
        % save the value of the centers of each junction to handles
        handles.junkCenter = junkCenter;
        
        % Update the viewer with the junctions on the backgroud image
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        colormap('gray')
        hold on
        scatter(junkCenter(:,2),junkCenter(:,1),'ro','SizeData',96)
        set(blockView,'XTick',[],'YTick',[])
        
        % Update the edit box with the slider value
        set(junkThreshEditBot,'String',num2str(nbrhdThresh))
        
    end

%% Junction Threshold Lock Button Callback %%
    function junkThreshLock_callback(~,~)
        if handles.junkLockPress == 0
            % Update string on lock button
            set(junkThreshLock,'String','Unlock')
            % Make junction thresholding tools unavailable
            set([junkThreshSlider,junkThreshEditBot,junkNbrEdit],...
                'Enable','off')
            % Make point tools available
            set([junkAddPt,junkRemovePt,junkAssign,junkCalibrate],...
                'Enable','on')
            % Make button press tracker equal to 1
            handles.junkLockPress = 1;
            h = msgbox('Press Enter to uncheck toggles after use!');
        else
            % Update string on lock button
            set(junkThreshLock,'String','Lock')
            % Make junction thresholding tools available
            set([junkThreshSlider,junkThreshEditBot,junkNbrEdit],...
                'Enable','on')
            % Make point tools unavailable
            set([junkAddPt,junkRemovePt,junkAssign,junkCalibrate],...
                'Enable','off')
            % Make button press tracker equal to 0
            handles.junkLockPress = 0;
        end
    end

%% Add Missing Junction Point %%
    function junkAddPt_callback(~,~)
        flag = get(junkAddPt, 'Value');
        if(flag == 1)
            set(junkAddPt, 'BackgroundColor', 'green');
            set([junkRemovePt,junkAssign,junkCalibrate],...
                'Enable','off')
        else
            set(junkAddPt, 'BackgroundColor', [0.94 0.94 0.94]);
            set([junkRemovePt,junkAssign,junkCalibrate],...
                'Enable','on')
        end
        imageWidth = size(handles.a, 2);
        imageHeight = size(handles.a, 1);
        set(junkRemovePt, 'Value', 0, 'BackgroundColor', [0.94 0.94 0.94]);
        while(flag == 1)
            set([junkRemovePt,junkAssign,junkCalibrate],...
                'Enable','off')
            % Allow the user to select a location on the image
            [col,row] = myginput(1,'crosshair');
            if(isequal(col, []) && isequal(row, [])) % Return key is pressed
                datacursormode off;
                set(junkAddPt, 'Value', 0, 'BackgroundColor', [0.94 0.94 0.94]);
                set([junkRemovePt,junkAssign,junkCalibrate],...
                    'Enable','on')
                break;
            elseif(col <= imageWidth && row <= imageHeight)
                % Save point to junction variable
                handles.junkCenter = [handles.junkCenter; [row col]];
                
                % Update the viewer with the junctions on the backgroud image
                cla(blockView)
                axes(blockView)
                imagesc(handles.BW)
                colormap('gray')
                hold on
                scatter(handles.junkCenter(:,2),handles.junkCenter(:,1),'ro','SizeData',96)
                set(blockView,'XTick',[],'YTick',[])
            end
        end
    end

%% Remove Bad Junction Point %%
    function junkRemovePt_callback(~,~)
        imageWidth = size(handles.a, 2);
        imageHeight = size(handles.a, 1);
        flag = get(junkRemovePt, 'Value');
        if(flag == 1)
            set(junkRemovePt, 'BackgroundColor', 'red');
            set([junkAddPt,junkAssign,junkCalibrate],...
                'Enable','off')
        else
            set(junkRemovePt, 'BackgroundColor', [0.94 0.94 0.94]);
            set([junkAddPt,junkAssign,junkCalibrate],...
                'Enable','on')
        end
        set(junkAddPt, 'Value', 0, 'BackgroundColor', [0.94 0.94 0.94]);
        while(flag == 1)
            set([junkAddPt,junkAssign,junkCalibrate],...
                'Enable','off')
            % Allow the user to select a location on the image
            [col,row] = myginput(1,'crosshair');
            if(isequal(col, []) && isequal(row, [])) % Return key is pressed
                datacursormode off;
                set(junkRemovePt, 'Value', 0, 'BackgroundColor', [0.94 0.94 0.94]);
                set([junkAddPt,junkAssign,junkCalibrate],...
                    'Enable','on')
                break;
            elseif(col <= imageWidth && row <= imageHeight)
                userPt = repmat([row,col],[length(handles.junkCenter) 1]);
                % Find the nearest junction center to this location
                dist = sqrt(sum((handles.junkCenter-userPt).^2,2));
                [~,I] = min(dist);
                % Remove the point from the junction variable
                handles.junkCenter(I,:) = [];
                
                % Update the viewer with the junctions on the backgroud image
                cla(blockView)
                axes(blockView)
                imagesc(handles.BW)
                colormap('gray')
                hold on
                scatter(handles.junkCenter(:,2),handles.junkCenter(:,1),'ro','SizeData',96)
                set(blockView,'XTick',[],'YTick',[])
            end
        end
    end
%% Assign Calibration Number %%
    function junkAssign_callback(~,~)
        set(junkAddPt, 'Value', 0);
        set(junkRemovePt, 'Value', 0);
        
        % Find top-left point (shortest distance from origin)
        [~,topLeftInd] = min(sqrt(handles.junkCenter(:,1).^2+...
            handles.junkCenter(:,2).^2));
        % Find bottom-right point (largest distance from origin)
        [~,botRightInd] = max(sqrt(handles.junkCenter(:,1).^2+...-
            handles.junkCenter(:,2).^2));
        % Find bottom-left point (max normal distance from diagonal)
        A = handles.junkCenter(botRightInd,2)-...
            handles.junkCenter(topLeftInd,2);
        B = handles.junkCenter(topLeftInd,1)-...
            handles.junkCenter(botRightInd,1);
        C = -B*handles.junkCenter(topLeftInd,2)-...
            A*handles.junkCenter(topLeftInd,1);
        normDistance = [handles.junkCenter(:, 1) handles.junkCenter(:, 2)...
            abs(A*handles.junkCenter(:,1)+B*handles.junkCenter(:,2)+C)/sqrt(A^2+B^2)];
        normDistance = sortrows(normDistance, -3);
        if(normDistance(1,2) < normDistance(2,2))
            botLeft = [normDistance(1, :)];
        else
            botLeft = [normDistance(2, :)];
        end
        % Sort based on distance from left side
        A = botLeft(2)-handles.junkCenter(topLeftInd,2);
        B = handles.junkCenter(topLeftInd,1)-botLeft(1);
        C = -B*handles.junkCenter(topLeftInd,2)-A*handles.junkCenter(topLeftInd,1);
        leftDist = [handles.junkCenter(:,1) handles.junkCenter(:,2) abs(A*handles.junkCenter(:,1)+B*...
            handles.junkCenter(:,2)+C)/sqrt(A^2+B^2)];
        leftDist = sortrows(leftDist, 3);
        referenceGrid = [];
        for x=61:-4:33
            referenceGrid = [referenceGrid; x x+1 x+2 x+3 x-32 x-31 x-30 x-29];
        end
        sortedFinal = [];
        indices = [];
        % If the entire cube can be seen clearly
        if(size(handles.junkCenter, 1) == 64)
            for(n=1:8:64)
                temp = sortrows(leftDist(n:n+7,:), 1);
                sortedFinal = [sortedFinal; temp];
            end
            for(column = 1:1:8)
                for(row = 1:1:8)
                    indices = [indices; referenceGrid(row,column)];
                end
            end
        else
            fullCalibration = imread('fullCalibration.tif');
            fig = figure;
            imshow(fullCalibration);
            bottomRightNum = str2double(inputdlg('Assignment for visible bottom-right point'));
            topLeftNum = str2double(inputdlg('Assignment for visible top-left point'));
            close(fig);
            [rowBottom, colBottom] = find(referenceGrid == bottomRightNum);
            [rowTop, colTop] = find(referenceGrid == topLeftNum);
            for n=1:(rowBottom - rowTop)+1:size(leftDist)
                temp = sortrows(leftDist(n:n+(rowBottom - rowTop),:), 1);
                sortedFinal = [sortedFinal; temp];
            end
            for column = colTop:1:colBottom
                for row = rowTop:1:rowBottom
                    indices = [indices; referenceGrid(row,column)];
                end
            end
        end
        assignments = [sortedFinal(:,1) sortedFinal(:,2) indices(:)];
        sortedAssignments = sortrows(assignments, 3);
        
        % Save to comprehensive calibration variable
        fullData = [];
        for n = 1:1:size(sortedAssignments,1)
            index = sortedAssignments(n, 3);
            fullData = [fullData; handles.calpts_nd(index,4:6) ...
                sortedAssignments(n,2) sortedAssignments(n,1) handles.calpts_nd(index,1:3)];
        end
        handles.data = fullData;
        
        % Post order to viewer for verification
        cla(blockView)
        axes(blockView)
        imagesc(handles.BW)
        colormap('gray')
        hold on
        scatter(handles.junkCenter(:,2),handles.junkCenter(:,1),'ro','SizeData',96)
        for n = 1:size(assignments,1)
            text(assignments(n,2),assignments(n,1),num2str(assignments(n,3)),...
                'Color','c')
        end
        set(blockView,'XTick',[],'YTick',[])
    end

%% Run Calibration Using Junction Values %%
    function junkCalibrate_callback(~,~)
        % ensure current directory is as specified by select directory
        cd(handles.geoDir)
        % check for calibration directory
        check = isdir('Calibration');
        if check == 0
            % if does not exist create
            mkdir('Calibration')
            % move to new directory
            cd('Calibration')
        else
            % move to calibration directory
            cd('Calibration')
        end
        
        % Remove zeros from data
        tmp = handles.data(:,4) ~= 0;
        tmp = tmp.*(1:size(handles.data,1))';
        tmp = unique(tmp);
        if tmp(1) == 0
            tmp = tmp(2:end);
        end
        handles.data = handles.data(tmp,:);
        
        dataAll = handles.data;
        
        % preallocate variables
        par = [];
        pos = [];
        iter = [];
        res = [];
        er = [];
        C = [];
        
        % grab the camera calibration spacing
        calselect = get(calibAnimalandBlock,'Value');
        % conversion of units to mm
        if calselect == 2
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*1/4);
        elseif calselect == 3
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*1/8);
        elseif calselect == 4
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*3/8);
        elseif calselect == 5
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*0.6);
        end
        
        % save out calibration
        camNum = get(calibCameraType,'Value');
        camera = get(calibCameraType,'String');
        camera = camera{camNum};
        a = handles.a;
        calibVal = get(calibType,'Value');
        ang = handles.angle(calibVal);
        cwtxt = handles.calibDirect;
        
        calpts_nondim = handles.calpts_nd;
        data = dataAll;
        % calculate calibration
        [par,pos,iter,res,er,C,~]=cacal(camera,dataAll);
        % camera parameters
        pr = par;
        ps = pos;
        % save out parameters
        if get(calibType,'Value') == 1
            savecommand = 'save calGeo_%1.3d a calpts_nondim par pos iter res er C data camera ang cwtxt';
            savecommand = sprintf(savecommand,ang);
        else
            savecommand = 'save cal%s_%1.3d a calpts_nondim par pos iter res er C data camera ang cwtxt';
            savecommand = sprintf(savecommand,handles.CMOScams(calibVal-1),ang);
        end
        eval(savecommand)
        
        %-----------------------------------------
        % Calibrate
        [Xi,Yi]=pred(dataAll(:,1:3),pr,ps,camera);
        
        % Save calibration parameters
        if calibVal == 1
            posparfname = sprintf('calGeo_%1.3d.pospar',ang);
        else
            posparfname = sprintf('cal%s_%1.3d.pospar',handles.CMOScams(calibVal-1),ang);
        end
        posparfid=fopen(posparfname,'w');
        for i=1:6
            fprintf(posparfid,'%15e\n',pos(i));
        end
        for i=1:8
            fprintf(posparfid,'%15e\n',par(i));
        end
        fclose(posparfid);
        
        % Display calibrated points
        cla(blockView)
        axes(blockView)
        image(handles.a)
        set(blockView,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        colormap('gray')
        hold on
        xi=handles.data(:,4);
        yi=handles.data(:,5);
        plot(xi,yi,'go','MarkerFaceColor','g');         % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
        plot(Xi,Yi,'ro','MarkerFaceColor','r');
        
        % return to original directory
        cd(handles.geoDir)
        
    end
end

