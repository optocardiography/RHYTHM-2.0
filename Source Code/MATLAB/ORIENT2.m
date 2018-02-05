%% ORIENT2
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Description: Matlab software for processing and analyzing panoramic
% optical mapping data sets. Built on the foundation of original rhythm
% software package devloped by Laughner et al (2012).

function ORIENT2
%% Create GUI structure
scrn_size = get(0,'ScreenSize');
f = figure('Name','ORIENT 2.0','Visible','off','Position',[scrn_size(3),scrn_size(4),1765,750],'NumberTitle','Off','KeyPressFcn',@keyPressed);
%set(f,'Visible','off')

% Mouse Listening Function
set(f,'WindowButtonDownFcn',{@button_down_function});
set(f,'WindowButtonUpFcn',{@button_up_function});
set(f,'WindowButtonMotionFcn',{@button_motion_function});

% Load Data
p1 = uipanel('Title','Display Data','FontSize',12,'Position',[.01 .01 .98 .98]);
filelist = uicontrol('Parent',p1,'Style','listbox','String','Files','Position',[10 260 150 450],'Callback',{@filelist_callback});
selectdir = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Select Directory','Position',[10 225 150 30],'Callback',{@selectdir_callback});
loadfile = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Load','Position',[10 195 150 30],'Callback',{@loadfile_callback});
refreshdir = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Refresh','Position',[10 165 150 30],'Callback',{@refreshdir_callback});

% Screens for 2D Optical Data
camA_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],'Position',[180 465 243 243]);
camB_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],'Position',[435 465 243 243]);
camC_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],'Position',[180 210 243 243]);
camD_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],'Position',[435 210 243 243]);

% 2D Active Camera Selection Button Group
activeCam = uibuttongroup('Parent',p1,'Title','Active Camera','FontSize',12,'Position',[0.103 0.23 0.29 0.07]);
camATog = uicontrol('Parent',activeCam,'Style','radiobutton','String','A',...
    'FontUnits','normalized','pos',[13 5 80 30],'Callback',{@camATog_callback});
camBTog = uicontrol('Parent',activeCam,'Style','radiobutton','String','B',...
    'FontUnits','normalized','pos',[108 5 80 30],'Callback',{@camBTog_callback});
camCTog = uicontrol('Parent',activeCam,'Style','radiobutton','String','C',...
    'FontUnits','normalized','pos',[203 5 80 30],'Callback',{@camCTog_callback});
camDTog = uicontrol('Parent',activeCam,'Style','radiobutton','String','D',...
    'FontUnits','normalized','pos',[298 5 80 30],'Callback',{@camDTog_callback});
camGTog = uicontrol('Parent',activeCam,'Style','radiobutton','String','Geo',...
    'FontUnits','normalized','pos',[393 5 100 30],'Callback',{@camGTog_callback});

% Screen for 3D Optical Data
camG_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],...
    'Visible','on','Position',[695 210 500 500]);

% Movie Slider for Controling Current Frame
movie_slider = uicontrol('Parent',f, 'Style', 'slider','Position', [713, 190, 410, 20],'SliderStep',[1 10],'Callback',{@movieslider_callback});
addlistener(movie_slider,'ContinuousValueChange',@movieslider_callback);
timeEdit = uicontrol('Parent',p1,'Style','edit','FontUnits','normalized','Position',[1110 182 60 23],'Callback',{@timeEdit_callback});
set(timeEdit,'Value',get(movie_slider,'Value'))
timeText = uicontrol('Parent',p1,'Style','text','FontUnits','normalized','String','ms','Position',[1165 178 40 25]);

% Video Control Buttons and Optical Action Potential Display
play_button = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Play Movie','Position',[710 151 120 30],'Callback',{@play_button_callback});
stop_button = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Stop Movie','Position',[830 151 120 30],'Callback',{@stop_button_callback});
dispwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Display Wave','Position',[950 151 120 30],'Callback',{@dispwave_button_callback});
expmov_button = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Export Movie','Position',[1070 151 120 30],'Callback',{@expmov_button_callback});

% Signal Display Screens for Optical Action Potentials
signal_scrn1 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[1250,592,468,120]);
signal_scrn2 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[1250,464,468,120]);
signal_scrn3 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[1250,336,468,120]);
signal_scrn4 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[1250,208,468,120]);
signal_scrn5 = axes('Parent',p1,'Units','Pixels','Color','w','Position',[1250,80,468,120]);
xlabel('Time (sec)')

% Sweep Bar Display for Optical Action Potentials
sweep_bar = axes ('Parent',p1,'Units','Pixels','Layer','top','Position',[1250,80,468,631]);
set(sweep_bar,'NextPlot','replacechildren','Visible','off')

% Windowing tools
expwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontUnits','normalized','String','Export OAPs','Position',[1600 5 120 30],'Callback',{@expwave_button_callback});
starttimesig_text = uicontrol('Parent',p1,'Style','text','FontUnits','normalized','String','Start','Position',[1367 0 50 30]);
starttimesig_edit = uicontrol('Parent',p1,'Style','edit','FontUnits','normalized','Position',[1420 5 55 23],'Callback',{@starttimesig_edit_callback});
endtimesig_text = uicontrol('Parent',p1,'Style','text','FontUnits','normalized','String','End','Position',[1487 0 40 30]);
endtimesig_edit = uicontrol('Parent',p1,'Style','edit','FontUnits','normalized','Position',[1535 5 55 23],'Callback',{@endtimesig_edit_callback});
pacingTrace = uicontrol('Parent',p1,'Style','checkbox','FontUnits','normalized','String','Pacing Trace','Position',[1220 5 140 30],'Callback',{@pacingTrace_callback});

% Signal Conditioning Button Group and Buttons
cond_sig = uibuttongroup('Parent',p1,'Title','Condition Signals','FontSize',12,'Position',[0.005 0.015 .22 .18]);
removeBG_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontUnits','normalized','String','Remove Background','Position',[5 92 170 25]);
bg_thresh_label = uicontrol('Parent',cond_sig,'Style','text','FontUnits','normalized','String','BG Threshold','Position',[32 67 100 25]);
perc_ex_label = uicontrol('Parent',cond_sig,'Style','text','FontUnits','normalized','String','EX Threshold','Position',[33 47 100 25]);
bg_thresh_edit = uicontrol('Parent',cond_sig,'Style','edit','FontUnits','normalized','String','0.3','Position',[140 75 35 18]);
perc_ex_edit = uicontrol('Parent',cond_sig,'Style','edit','FontUnits','normalized','String','0.5','Position',[140 55 35 18]);
bin_button  = uicontrol('Parent',cond_sig,'Style','checkbox','FontUnits','normalized','String','Bin','Position',[200 92 150 25]);
filt_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontUnits','normalized','String','Filter','Position',[200 64 150 25]);
removeDrift_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontUnits','normalized','String','Drift','Position',[200 36 150 25]);
norm_button  = uicontrol('Parent',cond_sig,'Style','checkbox','FontUnits','normalized','String','Normalize','Position',[5 32 125 25]);

%Pop-up menu options
bin_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontUnits','normalized',...
    'String',{'3 x 3', '5 x 5', '7 x 7'},'Position',[260 88 75 25]);
filt_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontUnits','normalized',...
    'String',{'[0 50]','[0 75]','[0 100]','[0 150]'},'Position',[260 61 90 25]);
drift_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontUnits','normalized',...
    'String',{'1st Order','2nd Order', '3rd Order', '4th Order'},'Position',[260 34 99 25]);
apply_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontUnits','normalized',...
    'String','Apply','Position',[5 2 65 30],'Callback',{@cond_sig_callback});
removeAtria_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontUnits','normalized',...
    'String','Remove','Position',[85 2 80 30],'Callback',{@removeAtria_button_callback});
export_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontUnits','normalized',...
    'String','Export Data','Position',[180 2 105 30],'Callback',{@exportData_callback});
align_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontUnits','normalized',...
    'String','ALIGN','Position',[300 2 80 30],'Callback',{@align_button_callback});
set(filt_popup,'Value',3)

% Alignment Adjust Button Group
aa = uipanel('Title','User Alignment','FontSize',12,'Position',[0.235 0.108 .17 .125]);
yShift = uicontrol('Parent',aa,'Style','text','FontUnits','normalized',...
    'String','Y-Shift:','Position',[5 50 55 25]);
yShiftEdit = uicontrol('Parent',aa,'Style','edit','FontUnits','normalized','String','0',...
    'Position',[60 57 40 20],'Callback',{@yShiftEdit_callback});
shift_up = uicontrol('Parent',aa,'Style','pushbutton','String','Up',...
    'FontUnits','normalized','Position',[105 54 50 25],'Callback',{@shift_up_callback});
shift_down = uicontrol('Parent',aa,'Style','pushbutton','String','Down',...
    'FontUnits','normalized','Position',[158 54 50 25],'Callback',{@shift_down_callback});
xShift = uicontrol('Parent',aa,'Style','text','FontUnits','normalized','String','X-Shift:',...
    'Position',[5 27 55 25]);
xShiftEdit = uicontrol('Parent',aa,'Style','edit','FontUnits','normalized','String','0',...
    'Position',[60 32 40 20],'Callback',{@xShiftEdit_callback});
shift_left = uicontrol('Parent',aa,'Style','pushbutton','String','Left',...
    'FontUnits','normalized','Position',[105 28 50 25],'Callback',{@shift_left_callback});
shift_right = uicontrol('Parent',aa,'Style','pushbutton','String','Right',...
    'FontUnits','normalized','Position',[158 28 50 25],'Callback',{@shift_right_callback});
project = uicontrol('Parent',aa,'Style','pushbutton','FontUnits','normalized',...
    'String','PROJECT','Position',[212 27 80 25],'Callback',{@project_callback});
exportProj = uicontrol('Parent',aa,'Style','pushbutton','FontUnits','normalized',...
    'String','Export','Position',[212 53 80 25],'Callback',{@export_callback});
scale = uicontrol('Parent',aa,'Style','pushbutton','FontUnits','normalized',...
    'String','Scale','Position',[20 1 70 25],'Callback',{@scale_callback});
scaleEdit = uicontrol('Parent',aa,'Style','edit','FontUnits','normalized',...
    'String','1','Position',[95 1 40 25]);
rotate = uicontrol('Parent',aa,'Style','pushbutton','FontUnits','normalized',...
    'String','Rotate','Position',[160 1 70 25],'Callback',{@rotate_callback});
rotateEdit = uicontrol('Parent',aa,'Style','edit','FontUnits','normalized',...
    'String','0','Position',[235 1 40 25]);

% 3D visualization type
viewType = uibuttongroup('Parent',p1,'Title','Surface Visualization',...
    'FontSize',12,'Position',[.228 .016 .175 .08]);
triMesh = uicontrol('Parent',viewType,'Style','pushbutton','String',...
    'Mesh','FontUnits','normalized','Position',[8 10 60 30],'Callback',...
    {@triMesh_callback});
camOverlay = uicontrol('Parent',viewType,'Style','pushbutton','String',...
    'Overlay','FontUnits','normalized','Position',[73 10 75 30],'Callback',...
    {@camOverlay_callback});
projTexture = uicontrol('Parent',viewType,'Style','pushbutton','String',...
    'Texture','FontUnits','normalized','Position',[153 10 75 30],'Callback',...
    {@projTexture_callback});
projData = uicontrol('Parent',viewType,'Style','pushbutton','String',...
    'Data','FontUnits','normalized','Position',[233 10 50 30],'Callback',...
    {@projData_callback});

% 3D visualization button group
view_sig = uibuttongroup('Parent',p1,'Title','Camera Angle','FontSize',12,...
    'Position',[.405 .015 .092 .18]);
az_txt = uicontrol('Parent',view_sig,'Style','text','String','Azimuth:',...
    'FontUnits','normalized','Position',[13 80 85 30]);
az_edit = uicontrol('Parent',view_sig,'Style','edit','FontUnits','normalized',...
    'String','0','Position',[100 86 50 25],'Callback',{@az_edit_callback});
el_txt = uicontrol('Parent',view_sig,'Style','text','String','Elevation:',...
    'FontUnits','normalized','Position',[5 52 95 30]);
el_edit = uicontrol('Parent',view_sig,'Style','edit','FontUnits','normalized',...
    'String','0','Position',[100 58 50 25],'Callback',{@el_edit_callback});
camAview_button = uicontrol('Parent',view_sig,'Style','pushbutton',...
    'String','Cam A','FontUnits','normalized','Position',[5 28 70 25],'Callback',{@camAview_button_callback});
camBview_button = uicontrol('Parent',view_sig,'Style','pushbutton',...
    'String','Cam B','FontUnits','normalized','Position',[80 28 70 25],'Callback',{@camBview_button_callback});
camCview_button = uicontrol('Parent',view_sig,'Style','pushbutton',...
    'String','Cam C','FontUnits','normalized','Position',[5 2 70 25],'Callback',{@camCview_button_callback});
camDview_button = uicontrol('Parent',view_sig,'Style','pushbutton',...
    'String','Cam D','FontUnits','normalized','Position',[80 2 70 25],'Callback',{@camDview_button_callback});

% Analysis Button Group
anal_data = uibuttongroup('Parent',p1,'Title','Analyze Data','FontSize',12,'Position',[0.5 0.015 .192 .180]);

% Popup menu for selecting type of analysis
%anal_select = uicontrol('Parent',anal_data,'Style','popupmenu','FontUnits','normalized','String',{'Membrane Potential','Activation','Conduction','APD','Phase','Dominant Frequency'},'Position',[5 85 165 25],'Callback',{@anal_select_callback});
anal_select = uicontrol('Parent',anal_data,'Style','popupmenu','FontUnits','normalized','String',{'Membrane Potential','Activation','-------','APD','Phase','Dominant Frequency'},'Position',[5 85 165 25],'Callback',{@anal_select_callback});

% Invert Color Map Option
invert_cmap = uicontrol('Parent',anal_data,'Style','checkbox','FontUnits','normalized','String','Invert Colormaps','Position',[175 88 150 25],'Visible','on','Callback',{@invert_cmap_callback});

% Mapping buttons
starttimemap_text = uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','Start','Position',[12 57 57 25],'Visible','on');
starttimemap_edit = uicontrol('Parent',anal_data,'Style','edit','FontUnits','normalized','Position',[65 62 45 22],'Visible','on','Callback',{@maptime_edit_callback});
endtimemap_text = uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','End','Position',[12 30 54 25],'Visible','on');
endtimemap_edit = uicontrol('Parent',anal_data,'Style','edit','FontUnits','normalized','Position',[65 35 45 22],'Visible','on','Callback',{@maptime_edit_callback});
createmap_button = uicontrol('Parent',anal_data,'Style','pushbutton','FontUnits','normalized','String','Calculate','Position',[10 2 110 30],'Visible','on','Callback',{@createmap_button_callback});

% APD specific buttons
minMap_text = uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','Min Map','Visible','on','Position',[120 57 57 25]);
minMap_edit = uicontrol('Parent',anal_data,'Style','edit','FontUnits','normalized','String','','Visible','on','Position',[180 62 45 22],'Callback',{@minMap_edit_callback});
maxMap_text = uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','Max Map','Visible','on','Position',[120 30 59 25]);
maxMap_edit = uicontrol('Parent',anal_data,'Style','edit','FontUnits','normalized','String','','Visible','on','Position',[180 35 45 22],'Callback',{@maxMap_edit_callback});
percentapd_text= uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','%APD','Visible','on','Position',[230 57 45 25]);
percentapd_edit= uicontrol('Parent',anal_data,'Style','edit','FontUnits','normalized','String','0.8','Visible','on','Position',[275 62 45 22],'callback',{@percentapd_edit_callback});
remove_motion_click = uicontrol('Parent',anal_data,'Style','checkbox','FontUnits','normalized','String','Remove','Visible','on','Position',[230 35 100 25]);
remove_motion_click_txt = uicontrol('Parent',anal_data,'Style','text','FontUnits','normalized','String','Motion','Visible','on','Position',[248 15 50 25]);
map2D_button = uicontrol('Parent',anal_data,'Style','pushbutton','FontUnits','normalized','String','2D Map','Position',[125 2 103 30],'Callback',{@map2D_callback});

% Allow all GUI structures to be scaled when window is dragged
set([f,p1,filelist,selectdir,loadfile,refreshdir,camA_scrn,camB_scrn,...
    camC_scrn,camD_scrn,activeCam,camATog,camBTog,camCTog,camDTog,...
    camG_scrn,movie_slider,sweep_bar,play_button,stop_button,...
    dispwave_button,expmov_button,signal_scrn1,signal_scrn2,...
    signal_scrn3,signal_scrn4,signal_scrn5,expwave_button,...
    starttimesig_text,starttimesig_edit,endtimesig_text,endtimesig_edit,...
    cond_sig,removeBG_button,bg_thresh_label,perc_ex_label,...
    bg_thresh_edit,perc_ex_edit,bin_button,filt_button,camGTog,...
    removeDrift_button,norm_button,bin_popup,filt_popup,drift_popup,...
    apply_button,removeAtria_button,export_button,align_button,aa,...
    yShift,yShiftEdit,shift_up,shift_down,xShift,xShiftEdit,shift_left,...
    shift_right,project,viewType,camOverlay,triMesh,projTexture,projData,...
    view_sig,az_txt,az_edit,el_txt,el_edit,camAview_button,...
    camBview_button,camCview_button,camDview_button,anal_data,...
    anal_select,invert_cmap,starttimemap_text,starttimemap_edit,...
    endtimemap_text,endtimemap_edit,createmap_button,minMap_text,...
    minMap_edit,maxMap_text,maxMap_edit,percentapd_text,percentapd_edit,...
    remove_motion_click,remove_motion_click_txt,map2D_button,...
    pacingTrace,exportProj,scale,scaleEdit,rotate,rotateEdit,timeEdit,timeText],'Units','normalized')

% Disable buttons that will not be needed until data is loaded
set([loadfile,refreshdir,camATog,camBTog,camCTog,camDTog,movie_slider,...
    play_button,stop_button,dispwave_button,expmov_button,...
    expwave_button,starttimesig_edit,endtimesig_edit,removeBG_button,...
    bg_thresh_label,perc_ex_label,bg_thresh_edit,perc_ex_edit,...
    bin_button,filt_button,removeDrift_button,norm_button,bin_popup,...
    filt_popup,drift_popup,apply_button,removeAtria_button,export_button,...
    align_button,yShift,yShiftEdit,shift_up,shift_down,xShift,...
    xShiftEdit,shift_left,shift_right,project,camOverlay,triMesh,...
    projTexture,projData,az_txt,az_edit,el_txt,el_edit,camAview_button,...
    camBview_button,camCview_button,camDview_button,anal_select,...
    invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
    endtimemap_edit,createmap_button,minMap_text,minMap_edit,...
    maxMap_text,maxMap_edit,percentapd_text,percentapd_edit,...
    remove_motion_click,remove_motion_click_txt,map2D_button,...
    camGTog,pacingTrace,exportProj,rotateEdit,scaleEdit,timeEdit],'Enable','off')

% Hide all analysis buttons
set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
    endtimemap_edit,createmap_button,minMap_text,minMap_edit,maxMap_text,...
    maxMap_edit,percentapd_text,percentapd_edit,remove_motion_click,...
    remove_motion_click_txt],'Visible','off')

% Center GUI on screen
movegui(f,'center')
set(f,'Visible','on')

%% Create handles
handles.val2D = [];
handles.currentfile = [];
handles.cmosData = cell(1,4);
handles.cmosRawData = cell(1,4);
handles.dataProj = [];
handles.M = cell(1,5);
handles.pointCloudIndex = zeros(5,1);
handles.activeCam = 1;
handles.camLabels = 'ABCDG';
handles.camAng = [45 315 225 135 45];
handles.time = [];
handles.wave_window = ones(1,4);
handles.normflag = 0;
handles.ventMask = cell(1,4);
handles.starttime = 0;
handles.fileLength = 1;
handles.endtime = 1;
handles.grabbed = -1;
handles.slide=-1; % parameter for recognize clicking location
%%minimum values pixels require to be drawn
handles.minVisible = 6;
handles.normalizeMinVisible = .3;
handles.cmap = colormap('jet'); %saves the default colormap values
handles.apdC = [];  % variable for storing apd calculations
handles.az = str2double(get(az_edit,'String'));
handles.el = str2double(get(el_edit,'String'));
% Calibration handles
handles.Rcmap=NaN.*ones(4,4,4);
handles.Parmap=NaN.*ones(8,4);
handles.Posmap=NaN.*ones(6,4);
handles.xyzmap=NaN.*ones(4,4);
% Geometry handles
handles.centroids = [];
handles.norms = [];
handles.neighs = [];
handles.neighnum = [];
handles.pts = [];
handles.numparams = [];
handles.txtparams = [];
handles.cells = [];
handles.X = [];
handles.newX = [];
handles.xShift = zeros(1,4);
handles.Y = [];
handles.newY = [];
handles.yShift = zeros(1,4);
% % % handles.shift = [];
handles.geommasks = [];
handles.cameraClick = 0;
handles.textureClick = 0;
handles.meshClick = 0;
handles.dataClick = 0;
handles.rot3d = [];
handles.phaseClick = 0;
handles.snr = cell(1,4);
handles.phaseFlag = 0;
% Axes positions
handles.camPos = cell(5,1);
handles.camPos{1} = get(camA_scrn,'Position');
handles.camPos{2} = get(camB_scrn,'Position');
handles.camPos{3} = get(camC_scrn,'Position');
handles.camPos{4} = get(camD_scrn,'Position');
handles.camPos{5} = get(camG_scrn,'Position');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL CALLBACK FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USER FUNCTIONALITY %%
%% Listen for mouse clicks for the point-dragger
% When mouse button is clicked and held find associated marker
    function button_down_function(obj,~)
        if(handles.activeCam ~= 0)
            ac = handles.activeCam;
            tmp = sprintf('set(obj,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
            eval(tmp)
            ps = get(gca,'CurrentPoint');
            i_temp = round(ps(1,1));
            j_temp = round(ps(2,2));
            % if one of the markers on the movie screen is clicked
            if ac > 0 && ac < 5
                if i_temp<=size(handles.cmosData{ac},1) || j_temp<size(handles.cmosData{ac},2) || i_temp>1 || j_temp>1
                    if size(handles.M{ac},1) > 0
                        for i=1:size(handles.M{ac},1)
                            if abs(i_temp - handles.M{ac}(i,1)) < 5 && abs(handles.M{ac}(i,2) - j_temp) < 5
                                handles.grabbed = i;
                                break
                            end
                        end
                    end
                end
            end
            % Change axis border
            tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
            eval(tmp)
            
            % 3D Rotation update
            if ac == 5
                % Grab the new location of the camera
                [az,el] = view;
                handles.az = az;
                handles.el = el;
                % Place these values in the edit boxes
                set(az_edit,'String',num2str(az))
                set(el_edit,'String',num2str(el))
            end
        end
    end
%% When mouse button is released
    function button_up_function(~,~)
        handles.grabbed = -1;
    end

%% Update appropriate screens or slider when mouse is moved
    function button_motion_function(obj,~)
        ac = handles.activeCam;
        % Update movie screen marker location
        if handles.grabbed > -1 && handles.grabbed < 5
            % Set active axes to one specified in the Active Camera menu
            tmp = sprintf('set(obj,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
            eval(tmp)
            ps = get(gca,'CurrentPoint');
            i_temp = round(ps(1,1));
            j_temp = round(ps(2,2));
            if i_temp<=size(handles.cmosData{ac},1) && j_temp<=size(handles.cmosData{ac},2) && i_temp>1 && j_temp>1
                handles.M{ac}(handles.grabbed,:) = [i_temp j_temp];
                i = i_temp;
                j = j_temp;
                switch handles.grabbed
                    case 1
                        plot(handles.time,squeeze(handles.cmosData{ac}(j,i,:)),'b','LineWidth',2,'Parent',signal_scrn1)
                        handles.M{ac}(1,:) = [i j];
                    case 2
                        plot(handles.time,squeeze(handles.cmosData{ac}(j,i,:)),'g','LineWidth',2,'Parent',signal_scrn2)
                        handles.M{ac}(2,:) = [i j];
                    case 3
                        plot(handles.time,squeeze(handles.cmosData{ac}(j,i,:)),'m','LineWidth',2,'Parent',signal_scrn3)
                        handles.M{ac}(3,:) = [i j];
                    case 4
                        plot(handles.time,squeeze(handles.cmosData{ac}(j,i,:)),'k','LineWidth',2,'Parent',signal_scrn4)
                        handles.M{ac}(4,:) = [i j];
                    case 5
                        plot(handles.time,squeeze(handles.cmosData{ac}(j,i,:)),'y','LineWidth',2,'Parent',signal_scrn5)
                        handles.M{ac}(5,:) = [i j];
                end
                
                % Overlay with pacing spike
                if get(pacingTrace,'Value') == 1
                    % Place a hold on the current signal axes
                    tmp = sprintf('hold(signal_scrn%d,''on'')',handles.grabbed);
                    eval(tmp)
                    % Overlay this axes with the pacing spike
                    tmp = sprintf('plot(handles.pacingTime,handles.pacedSignal,''Color'',[169/255 169/255 169/255],''LineWidth'',2,''Parent'',signal_scrn%d)',handles.grabbed);
                    eval(tmp)
                    % Place a hold on the current signal axes
                    tmp = sprintf('hold(signal_scrn%d,''off'')',handles.grabbed);
                    eval(tmp)
                    if handles.grabbed < 5
                        tmp = sprintf('set(signal_scrn%d,''XTick'',[])',handles.grabbed);
                        eval(tmp)
                    end
                end
                
                % Update the axes
                cla
                currentframe = handles.frame;
                drawFrame(handles.cmosData,handles.dataProj,currentframe);
                tmp = sprintf('axes(cam%s_scrn);',handles.camLabels(ac));
                eval(tmp)
                M = handles.M{ac}; colax='bgmkc'; [a,~]=size(M);
                hold on
                for x=1:a
                    tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
                    eval(tmp)
                    tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[],''ZTick'',[]);',handles.camLabels(ac));% Hide tick markers
                    eval(tmp)
                end
                hold off
            end
            
            % Change axis border
            tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
            eval(tmp)
            
            % 3D Rotation update
            if ~isempty(handles.rot3d)
                % Grab the new location of the camera
                [az,el] = view;
                handles.az = az;
                handles.el = el;
                % Place these values in the edit boxes
                set(az_edit,'String',num2str(az))
                set(el_edit,'String',num2str(el))
            end
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD DATA
%% List that contains all files in directory
    function filelist_callback(source,~)
        str = get(source, 'String');
        val = get(source,'Value');
        file = char(str(val));
        handles.currentfile = file;
    end

%% Select directory for optical files
    function selectdir_callback(~,~)
        % Select the directory of the files to analyze
        dir_name = uigetdir;
        if dir_name ~= 0
            % Save directory name to handles
            handles.dir = dir_name;
            % Check directory for rsh and gsh files
            search_nameR = [dir_name,'/*.rsh'];
            search_nameG = [dir_name,'/*.gsh'];
            % Create variable with associated file names
            files = struct2cell(dir(search_nameR));
            type = repmat('rsh',[size(files,2) 1]);
            files = [files struct2cell(dir(search_nameG))];
            type = [type; repmat('gsh',[size(files,2)-length(type),1])];
            files = files(1,:)';
            % Remove the ending and camera label from names
            labels = handles.camLabels;
            n = 1;
            while n <= size(files,1);
                c = files{n}(length(files{n})-4);
                if strcmp(labels(1),c) || strcmp(labels(2),c) || strcmp(labels(3),c) || strcmp(labels(4),c)
                    % Remove file type and camera label from file name
                    files{n} = files{n}(1:length(files{n})-5);
                else
                    % Remove non-Panoramic file
                    files(n,:) = [];
                    % Remove type
                    type(n,:) = [];
                    % Update counter to reflect new files variable size
                    n = n-1;
                end
                % Update counter
                n = n+1;
            end
            % Identify all unique file names
            [filenames,ia,~] = unique(files);
            % Grab associated types
            type = type(ia,:);

            % Remove all file names without 4 associated *.gsd or *.rsh
            rm = [];
            for n = 1:size(filenames,1)
                % Use string comparison to verify 4 camera files
                tmp =  repmat(filenames{n},[size(files,1) 1]);
                % Sum logical result, remove values not equal to 4
                tmp = sum(strcmp(tmp,files));
                if tmp ~= 4
                    rm = [rm n];
                end
            end
            filenames(rm,:) = [];
            % Save to handles variable
            handles.file_list = filenames;
            handles.type = type;
            % Assign file names to the file list structure
            set(filelist,'String',handles.file_list)
            % Save current file to handles
            handles.currentfile = char(handles.file_list(1));
            % Enable the refresh directory and load file buttons
            set([loadfile,refreshdir],'Enable','on')
            % Reset analysis window
            set(anal_select,'Value',1)
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,createmap_button,minMap_text,minMap_edit,maxMap_text,...
                maxMap_edit,percentapd_text,percentapd_edit,remove_motion_click,...
                remove_motion_click_txt],'Visible','off','Enable','on')
            % Turn off all other buttons
            set([anal_select,starttimemap_edit,starttimemap_text,endtimemap_edit,...
                endtimemap_text,createmap_button,minMap_edit,minMap_text,...
                maxMap_edit,maxMap_text,percentapd_edit,percentapd_text,...
                remove_motion_click,remove_motion_click_txt,play_button,...
                stop_button,dispwave_button,expmov_button,starttimesig_edit,...
                endtimesig_edit,expwave_button,invert_cmap,],'Enable','off')
            
            % Create names of other important directories
            handles.opt_dir = dir_name;
            handles.exp_dir = dir_name(1:end-7);
            handles.geo_dir = [handles.exp_dir 'Geometry/'];
            handles.cal_dir = [handles.geo_dir 'Calibration/'];
            handles.vtk_dir = [handles.geo_dir 'VTK_Outputs/'];
        end
    end

%% Load selected files in filelist
    function loadfile_callback(~,~)
        if isempty(handles.currentfile)
            msgbox('Warning: No data selected','Title','warn')
        else            
            h = msgbox('Loading File, please wait.....');
            % Clear all images from previous set of data
            cla(camG_scrn); cla(camA_scrn); cla(camB_scrn); cla(camC_scrn);
            cla(camD_scrn); cla(signal_scrn1); cla(signal_scrn2);
            cla(signal_scrn3); cla(signal_scrn4); cla(signal_scrn5);
            cla(sweep_bar);
            % Reset pacing trace button
            set(pacingTrace,'Enable','off','Value',0)
            % Initialize handles
            handles.cmosData = cell(1,4);
            handles.cmosRawData = cell(1,4);
            handles.data = cell(1,4);
            handles.dataProj = [];
            handles.M = cell(1,5); % this handle stores the locations of the markers
            handles.wave_window = ones(1,5);
            handles.normflag = 0;% this handle indicate if normalize is clicked
            handles.frame = 1;% this handles indicate the current frame being displayed by the movie screen
            handles.slide=-1;% this handle indicate if the movie slider is clicked
            
            % Check for *.mat file, if none convert
            whichFile = get(filelist,'Value');
            filename = [handles.dir,'/',handles.currentfile,'.',handles.type(whichFile,:)];
            
            % Check for exising *_proj.mat file or *_data.mat
            cd(handles.dir);
            loadflag = 0;
            fid=fopen(strcat(handles.currentfile,'_proj.mat'));
            if fid ~= -1
                fclose(fid);
                loadOption = questdlg('Projection data found. Load?','Projection Found',...
                    'Yes','No','Yes');
                switch loadOption
                    case 'Yes'
                        loadflag = 1;
                    case 'No'
                        loadflag = 0;
                end
            end
            if loadflag == 0
                fid2=fopen(strcat(handles.currentfile,'_data.mat'));
                if fid2 ~= -1
                    fclose(fid2);
                    loadOption2 = questdlg('Filtered data found. Load?','Filtered Data Found',...
                        'Yes','No','Yes');
                    switch loadOption2
                        case 'Yes'
                            loadflag = 2;
                        case 'No'
                            loadflag = 0;
                    end
                end
            end
            if loadflag ~= 0
                loadData(loadflag);
            else
                % Check for existence of already converted *.mat file
                
                if ~exist([filename(1:end-4),'A.mat'],'file')
                    for n = 1:length(handles.camLabels)-1
                        % Convert data and save out *.mat file
                        CMOSconverter(handles.dir,[handles.currentfile,...
                            handles.camLabels(n),'.',handles.type(whichFile,:)]);
                    end
                end
                
                Data = cell(1,4);
                handles.matrixMax = cell(1,4);
                handles.bg = cell(1,4);
                handles.bgRGB = cell(1,4);
                handles.ecg = [];
                handles.Fs = [];
                handles.nRate = [];
                for n = 1:4
                    % Load data from *.mat file
                    Data{n} = load([filename(1:end-4) handles.camLabels(n) '.mat']);
                    % Load cmos data

                    handles.cmosData{n} = double(Data{n}.cmosData(:,:,:));
                    % ?????
                    handles.matrixMax{n} = .9 * max(handles.cmosData{n}(:));
                    % Load background image
                    handles.bg{n} = double(Data{n}.bgimage);
                    % Convert background to grayscale
                    handles.bgRGB{n} = real2rgb(handles.bg{n}, 'gray');
                    % % %                 % Save out pacing spike
                    % % %                 handles.ecg{n} = Data{n}.channel{1}(2:end)*-1;
                    
                end
                
                % Save out pacing spike
                handles.ecg = Data{n}.channel{1}(2:end)*-1;
                % Save out frequency
                handles.Fs = double(Data{n}.frequency);
                % Save out added analog temporal resolution
                handles.nRate = Data{n}.nRate;
                
                % Save a variable to preserve the raw fluorescence data
                handles.cmosRawData = handles.cmosData;
                
                
                %%%%%%%%% WINDOWED DATA %%%%%%%%%%
                % Initialize movie screen to the first frame
                %             set(f,'CurrentAxes',movie_scrn)
                
                % % %             G = real2rgb(handles.bg, 'gray');
                % % %             Mframe = handles.cmosData(:,:,handles.frame);
                % % %             J = real2rgb(Mframe, 'jet');
                % % %             A = real2rgb(Mframe >= handles.minVisible, 'gray');
                % % %             I = J .* A + G .* (1-A);
                % % %             handles.movie_img = image(I,'Parent',movie_scrn);
                % % %             set(movie_scrn,'NextPlot','replacechildren','YLim',[0.5 size(I,1)+0.5],...
                % % %                 'YTick',[],'XLim',[0.5 size(I,2)+0.5],'XTick',[])
                % Plot background images
                drawFrame(handles.cmosData,[],1)
                
                % Scale signal screens and sweep bar to appropriate time scale
                timeStep = 1/handles.Fs;
                handles.time = 0:timeStep:size(handles.cmosData{1},3)*timeStep-timeStep;
            end
            set(signal_scrn1,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn1,'NextPlot','replacechildren')
            set(signal_scrn2,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn2,'NextPlot','replacechildren')
            set(signal_scrn3,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn3,'NextPlot','replacechildren')
            set(signal_scrn4,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn4,'NextPlot','replacechildren')
            set(signal_scrn5,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn5,'NextPlot','replacechildren')
            set(sweep_bar,'XLim',[min(handles.time) max(handles.time)])
            set(sweep_bar,'NextPlot','replacechildren')
           
            % Fill times into activation map editable textboxes
            handles.starttime = 0;
            handles.endtime = max(handles.time);
            set(starttimesig_edit,'String',num2str(handles.starttime))
            set(endtimesig_edit,'String',num2str(handles.endtime))
            set(starttimemap_edit,'String',num2str(handles.starttime))
            set(endtimemap_edit,'String',num2str(handles.endtime))
            % Initialize movie slider to the first frame
            set(movie_slider,'Value',1,'Min',1,...
                'Max',size(handles.cmosData{1},3),'SliderStep',...
                [1/(size(handles.cmosData{1},3)) 10/(size(handles.cmosData{1},3))],...
                'Enable','on')
            % % %             drawFrame(1);
            if loadflag == 1
                set([camOverlay,triMesh,projTexture,projData],'Enable','On')
                set(projData,'BackgroundColor',[0.8 0.8 0.8])
                handles.projDataClick = 1;
                % Turn on Camera Angle tools
                set([az_txt,az_edit,el_txt,el_edit,camAview_button,...
                    camBview_button,camCview_button,camDview_button,...
                    anal_select, map2D_button],'Enable','On')
                handles.az = str2double(get(az_edit,'String'));
                handles.el = str2double(get(el_edit,'String'));
                
                set(camGTog,'Enable','on')
                set(camG_scrn,'Visible','off')
                
                % Disable all other alignment tools
                set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                    xShiftEdit,shift_left,shift_right],'Enable','off')
                % Disable return to conditioning button
                set(align_button,'Enable','off')
                makeActiveAxis(1,handles.activeCam);
                set([camOverlay,triMesh,projTexture,projData,project],'Enable','On')
                set(projData,'BackgroundColor',[0.8 0.8 0.8])
                set([az_txt,az_edit,el_txt,el_edit,camAview_button,...
                    camBview_button,camCview_button,camDview_button,...
                    anal_select,map2D_button,movie_slider,...
                    play_button,stop_button,dispwave_button,expmov_button,...
                    expwave_button,starttimesig_edit,endtimesig_edit,loadfile,...
                    refreshdir,camATog,camBTog,camCTog,camDTog],'Enable','On')
                set(align_button,'String','CANCEL')
            elseif loadflag == 2
                set([removeBG_button,bg_thresh_label,perc_ex_label,...
                    bg_thresh_edit,perc_ex_edit,bin_button,filt_button,...
                    removeDrift_button,norm_button,bin_popup,filt_popup,export_button,...
                    drift_popup,apply_button,export_button,align_button,dispwave_button,removeAtria_button],'Enable','on')
                % Deactivate alignment options
                set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                    xShiftEdit,shift_left,shift_right,project],'Enable','off')
                set([camATog,camBTog,camCTog,camDTog,camGTog],'Enable','on')
                % Disable all tools but signal conditioning tools
                set([yShift,yShiftEdit,shift_up,shift_down,xShift,xShiftEdit,shift_left,...
                    shift_right,project,camOverlay,triMesh,projTexture,projData,az_txt,az_edit,...
                    el_txt,el_edit,camAview_button,camBview_button,camCview_button,...
                    camDview_button,anal_select,invert_cmap,starttimemap_text,...
                    starttimemap_edit,endtimemap_text,endtimemap_edit,createmap_button,...
                    minMap_text,minMap_edit,maxMap_text,maxMap_edit,percentapd_text,...
                    percentapd_edit,remove_motion_click,remove_motion_click_txt,...
                    map2D_button],'Enable','off')
            else
                % Enable signal processing and analysis tools
                set([removeBG_button,bg_thresh_edit,bg_thresh_label,perc_ex_edit,...
                    perc_ex_label,bin_button,filt_button,removeDrift_button,norm_button,...
                    apply_button,bin_popup,filt_popup,drift_popup,play_button,anal_select,...
                    stop_button,dispwave_button,expmov_button,starttimesig_edit,...
                    starttimesig_text,endtimesig_edit,endtimesig_text,...
                    expwave_button,camATog,camBTog,camCTog,...
                    camDTog,align_button,removeAtria_button,map2D_button],'Enable','on')
                % Disable all tools but signal conditioning tools
                set([yShift,yShiftEdit,shift_up,shift_down,xShift,xShiftEdit,shift_left,...
                    shift_right,project,camOverlay,triMesh,projTexture,projData,az_txt,az_edit,...
                    el_txt,el_edit,camAview_button,camBview_button,camCview_button,...
                    camDview_button,anal_select,invert_cmap,starttimemap_text,...
                    starttimemap_edit,endtimemap_text,endtimemap_edit,createmap_button,...
                    minMap_text,minMap_edit,maxMap_text,maxMap_edit,percentapd_text,...
                    percentapd_edit,remove_motion_click,remove_motion_click_txt,...
                    map2D_button,export_button],'Enable','off')
                
                % Reset tools strings
                set(align_button,'String','ALIGN')
                set(xShiftEdit,'String',0)
                set(yShiftEdit,'String',0)
                set(removeBG_button,'Value',0)
                set(bg_thresh_edit,'String','0.3')
                set(perc_ex_edit,'String',0.5)
                set(bin_button,'Value',0)
                set(filt_button,'Value',0)
                set(removeDrift_button,'Value',0)
                set(norm_button,'Value',0)
                
                %Pop-up menu options
                set(bin_popup,'Value',1)
                set(filt_popup,'Value',3)
                set(drift_popup,'Value',1)
                set(apply_button,'Value',1)
                
                % Outline active camera
                set(camA_scrn,'XColor','m','YColor','m','LineWidth',4)
                
                % Reset active camera toggle
                handles.activeCam = 1;
                set(camATog,'Value',1)
                set(camBTog,'Value',0)
                set(camCTog,'Value',0)
                set(camDTog,'Value',0)
            end
            delete(h);
        end        
    end

%% Refresh file list (in case more files are open after directory is selected)
    function refreshdir_callback(~,~)
        % Select the directory of the files to analyze
        dir_name = uigetdir;
        if dir_name ~= 0
            % Save directory name to handles
            handles.dir = dir_name;
            % Check directory for rsh and gsh files
            search_nameR = [dir_name,'/*.rsh'];
            search_nameG = [dir_name,'/*.gsh'];
            % Create variable with associated file names
            files = struct2cell(dir(search_nameR));
            files = [files struct2cell(dir(search_nameG))];
            files = files(1,:)';
            % Remove the ending and camera label from names
            for n = 1:size(files,1)
                files{n} = files{n}(1:length(files{n})-5);
            end
            % Identify all unique file names
            filenames = unique(files);
            % Remove all file names without 4 associated *.gsd or *.rsh
            rm = [];
            for n = 1:size(filenames,1)
                % Use string comparison to verify 4 camera files
                tmp =  repmat(filenames{n},[size(files,1) 1]);
                % Sum logical result, remove values not equal to 4
                tmp = sum(strcmp(tmp,files));
                if tmp ~= 4
                    rm = [rm n];
                end
            end
            filenames(rm,:) = [];
            % Save to handles variable
            handles.file_list = filenames;
            % Assign file names to the file list structure
            set(filelist,'String',handles.file_list)
            % Save current file to handles
            handles.currentfile = char(handles.file_list(1));
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MOVIE SCREEN
%% Movie Slider Functionality
    function movieslider_callback(source,~)
        % Get the movie slider value
        val = get(source,'Value');
        % Round it to an integer
        i = round(val);
        % Save it to the handles
        handles.frame = i;
        % Update all screens with current movie slider value
        if handles.phaseFlag == 1
            data = handles.phaseMap;
            dataProj = handles.phaseMapGeo;
        else
            data = handles.cmosData;
            dataProj = handles.dataProj;
        end
        screenUpdate(data,dataProj,i)
        set(timeEdit,'String',num2str(i));
    end

%% Show/Change Current Time
    function timeEdit_callback(~,~)
        time = str2num(get(timeEdit, 'String'));
        time = round(time);
        set(timeEdit,'String',num2str(time))
        set(movie_slider, 'Value', time);
        movieslider_callback(movie_slider);
    end

%% Draw
    function drawFrame(data,dataGeo,frame)
        for n = 1:4;
            G = handles.bgRGB{n};
            if handles.phaseClick == 1
                Mframe = handles.phase{n}(:,:,frame);
            else
                Mframe = data{n}(:,:,frame);
            end
            if handles.normflag == 0
                Mmax = handles.matrixMax{n};
                Mmin = handles.minVisible;
                numcol = size(jet,1);
                J = ind2rgb(round((Mframe - Mmin) ./ (Mmax - Mmin) * (numcol - 1)), 'jet');
                A = real2rgb(Mframe >= handles.minVisible, 'gray');
            else
                J = real2rgb(Mframe, 'jet');
                A = real2rgb(Mframe >= handles.normalizeMinVisible, 'gray');
            end
            tmp = sprintf('image(G,''Parent'',cam%s_scrn)',handles.camLabels(n));
            eval(tmp)
            tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
            eval(tmp)
            hold on
            image(J,'AlphaData',A(:,:,1));
            hold off
            tmp = sprintf('set(cam%s_scrn,''NextPlot'',''replacechildren'',''YLim'',[0.5 size(J,1)+0.5],''YTick'',[],''XLim'',[0.5 size(J,2)+0.5],''XTick'',[])',handles.camLabels(n));
            eval(tmp)
        end
        
        % Update the 3D geometry view if visualized already
        if strcmp(get(project,'String'),'RESET') && ~isempty(dataGeo)
            axes(camG_scrn)
            view([handles.az handles.el])
            axis equal
            colormap jet
            skel = find(dataGeo(:,1) == 0);
            [skel,~] = ind2sub(size(dataGeo),skel(:));
            skel = unique(skel);
            rows = find(dataGeo(:,1) ~= 0);
            [rows,~] = ind2sub(size(dataGeo),rows(:));
            rows = unique(rows);
            cells = handles.cells(rows(:),:);
            %         figure,trisurf(handles.cells(val,:),tri(:,1),tri(:,2),tri(:,3),zeros(sum(val),1))
            trisurf(cells,handles.pts(:,1),...
                handles.pts(:,2),handles.pts(:,3),dataGeo(rows(:),frame),...
                'LineStyle','none','Parent',camG_scrn);
            hold all
            trisurf(handles.cells(skel,:),handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),'FaceColor','none','LineWidth',0.5,'Parent',camG_scrn);
            hold off
            [mini,~] = min(dataGeo(rows(:),frame));
            [maxi,~] = max(dataGeo(rows(:),frame));
            caxis([mini maxi])
            set(camG_scrn,'Visible','off')
            %Turn on 3D rotation for the 3d screen
            handles.r3 = rotate3d;
            handles.r3.Enable = 'on';
            handles.r3.ActionPostCallback = @newView_callback;
            setAllowAxesRotate(handles.r3,camA_scrn,false);
            setAllowAxesRotate(handles.r3,camB_scrn,false);
            setAllowAxesRotate(handles.r3,camC_scrn,false);
            setAllowAxesRotate(handles.r3,camD_scrn,false);
            setAllowAxesRotate(handles.r3,signal_scrn1,false);
            setAllowAxesRotate(handles.r3,signal_scrn2,false);
            setAllowAxesRotate(handles.r3,signal_scrn3,false);
            setAllowAxesRotate(handles.r3,signal_scrn4,false);
            setAllowAxesRotate(handles.r3,signal_scrn5,false);
            setAllowAxesRotate(handles.r3,sweep_bar,false);            
        end
        
    end

%% Screen update
    function screenUpdate(data,dataGeo,frame)
        % Update mapping screens
        ac = handles.activeCam;
        % Update movie screen with the conditioned data
        cla(camA_scrn),cla(camB_scrn),cla(camC_scrn),cla(camD_scrn)
        drawFrame(data,dataGeo,frame)
        % Set active axes as current axes
        tmp = sprintf('set(f,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        % Update markers on active axes
        M = handles.M{ac};colax='bgmkc';[a,~]=size(M);
        hold on
        for x=1:a
            tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
            eval(tmp)
            tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[]);',handles.camLabels(ac));% Hide tick markes
            eval(tmp)
        end
        % Change axis border
        tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
        eval(tmp)
        hold off
        
        % Update geometry screen
        if ~strcmp(get(align_button,'String'),'ALIGN')
            set(camG_scrn,'NextPlot','replacechildren','YTick',[],'XTick',[]);
            set(f,'CurrentAxes',camG_scrn)
            skel = find(dataGeo(:,1) == 0);
            [skel,~] = ind2sub(size(dataGeo),skel(:));
            skel = unique(skel);
            rows = find(dataGeo(:,1) ~= 0);
            [rows,~] = ind2sub(size(dataGeo),rows(:));
            rows = unique(rows);
            cells = handles.cells(rows(:),:);
            %         figure,trisurf(handles.cells(val,:),tri(:,1),tri(:,2),tri(:,3),zeros(sum(val),1))
            handles.movie_img = trisurf(cells,handles.pts(:,1),...
                handles.pts(:,2),handles.pts(:,3),dataGeo(rows(:),frame),...
                'LineStyle','none','Parent',camG_scrn);
            hold all
            trisurf(handles.cells(skel,:),handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),'FaceColor','none','LineWidth',0.5,'Parent',camG_scrn);
            hold off
            [mini,~] = min(dataGeo(rows(:),frame));
            [maxi,~] = max(dataGeo(rows(:),frame));
            caxis([mini maxi])
            set(camG_scrn,'Visible','off')
            view([handles.az handles.el])
            axis equal
            colormap jet
        end
        
        %Update sweep bar
        set(f,'CurrentAxes',sweep_bar)
        a = [handles.time(frame) handles.time(frame)];b = [0 1]; cla
        plot(a,b,'r','Parent',sweep_bar)
        axis([handles.starttime handles.endtime 0 1])
        hold off; axis off
        
        % Update min and max colormap values
        minCM = min([min(data{1}(:)) min(data{2}(:)) min(data{3}(:)) min(data{4}(:)) min(dataGeo(:))]);
        set(minMap_edit,'String',num2str(minCM))
        maxCM = max([max(data{1}(:)) max(data{2}(:)) max(data{3}(:)) max(data{4}(:)) max(dataGeo(:))]);
        set(maxMap_edit,'String',num2str(maxCM))
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY CONTROL %%
%% Play button functionality
    function play_button_callback(~,~)
        if isempty(handles.cmosData)
            msgbox('Warning: No data selected','Title','warn')
        else
            if handles.phaseFlag == 1
                data = handles.phaseMap;
                dataProj = handles.phaseMapGeo;
            else
                data = handles.cmosData;
                dataProj = handles.dataProj;
            end
            set([camATog,camBTog,camCTog,camDTog,camGTog],'Enable','off')
            handles.playback = 1; % if the PLAY button is clicked
            startframe = handles.frame;
            % Update movie screen with new frames
            for i = startframe:5:size(data{1},3)
                if handles.playback == 1 % recheck if the PLAY button is clicked
                    set(movie_slider,'Value',i)
                    screenUpdate(data,dataProj,i)
                    pause(0.05)
                else
                    break
                end
            end
            set(movie_slider,'Value',i)
            handles.frame = i;
            screenUpdate(data,dataProj,i)
        end
        set([camATog,camBTog,camCTog,camDTog,camGTog],'Enable','on')
    end

%% Stop button functionality
    function stop_button_callback(~,~)
        set([camATog,camBTog,camCTog,camDTog,camGTog],'Enable','on')
        handles.playback = 0;
    end

%% Display Wave Button Functionality
    function dispwave_button_callback(~,~)
        % Grab the active axis value
        ac = handles.activeCam;
        if handles.phaseFlag == 1
            data = handles.phaseMap;
            dataProj = handles.phaseMapGeo;
        else
            data = handles.cmosData;
            dataProj = handles.dataProj;
        end
        % Set Current Axes to one specified by Active Camera menu
        tmp = sprintf('set(f,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        if ac == 5
            % Select a point on the axes and grab x and y coordinates
            [i_temp,j_temp,k_temp] = myginput(1,'circle');
        else
            % Select a point on the axes and grab x and y coordinates
            [i_temp,j_temp] = myginput(1,'circle');
        end
        
        if isempty(i_temp)
            % Tell user they have selected a point outside the active axis
            msgbox('Warning: Selected Pixel not on Acive Axes','Title','help')
            % Flag to skip display update
            check = 0;
        elseif ac ~= 5
            if i_temp>size(data{ac},1) || j_temp>size(data{ac},2) || i_temp<=1 || j_temp<=1
                % tell user to pick new pixel
                msgbox('Warning: Pixel Selection out of Boundary','Title','help')
                % Flag to skip display update
                check = 0;
            else
                % Round values to make assignment to pixel
                i = round(i_temp); j = round(j_temp);
                % Flag to update display
                check = 1;
            end
        else
            % Round values to make assignment to pixel
            i = round(i_temp); j = round(j_temp); k = round(k_temp);
            % Flag to update display
            check = 1;
        end
        
        % If the point selected was on the active axis plot the point
        if check == 1;
            % Find the correct wave window
            if handles.wave_window(ac) == 6
                handles.wave_window(ac) = 1;
            end
            
            wave_window = handles.wave_window(ac);
            % If the point was selected on the 3D geometry find its index value
            if ac == 5
                % Find point cloud index value
                [pointCloudIndex,nearestPt] = callbackClickA3DPoint(handles.centroids,...
                    [i,j,k],handles.norms);
                % Save index point cloud index and 3d location
                handles.pointCloudIndex(wave_window) = pointCloudIndex;
                handles.M{ac}(wave_window,:) = nearestPt;
                % Grab signal data
                signalData = dataProj(pointCloudIndex,:);
            else
                % Grab signal data
                signalData = squeeze(data{ac}(j,i,:));
                % Save index location
                handles.M{ac}(handles.wave_window(ac),:) = [i,j];
            end
            
            % If the point selected was on the active axis plot the point
            if check == 1;
                % Find the correct wave window
                if handles.wave_window(ac) == 6
                    handles.wave_window(ac) = 1;
                end
                wave_window = handles.wave_window(ac);
                % Colors for plotting
                colax = 'bgmkc';
                
                tmp = sprintf('plot(handles.time,signalData,''%s'',''LineWidth'',2,''Parent'',signal_scrn%d)',...
                    colax(wave_window),wave_window);
                eval(tmp)
                
                handles.wave_window(ac) = wave_window + 1; % Dial up the wave window count
                
                % Update movie screen with new markers
                cla
                currentframe = handles.frame;
                drawFrame(data,dataProj,currentframe);
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(ac));
                eval(tmp)
                M = handles.M{ac}; [a,~]=size(M);
                hold on
                for x=1:a
                    if ac == 5
                        tmp = sprintf('plot3(M(x,1),M(x,2),M(x,3),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
                        eval(tmp)
                    else
                        tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
                        eval(tmp)
                    end
                    tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[]);',handles.camLabels(ac));% Hide tick markes
                    eval(tmp)
                end
                hold off
                % Change axis border
                tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
                eval(tmp)
            end
        end
        frame = handles.frame;
        set(f,'CurrentAxes',sweep_bar)
        a = [handles.time(frame) handles.time(frame)];b = [0 1]; cla
        plot(a,b,'r','Parent',sweep_bar)
        axis([handles.starttime handles.endtime 0 1])
        hold off; axis off
    end


%% Export movie to .avi file
%Construct a VideoWriter object and view its properties. Set the frame rate to 60 frames per second:
    function expmov_button_callback(~,~)
        % Request the directory for saving the file
        dir = uigetdir;
        % If the cancel button is selected cancel the function
        if dir == 0
            return
        end
        % Request the desired name for the movie file
        filename = inputdlg('Enter Filename:');
        filename = char(filename);
        % Check to make sure a value was entered
        if isempty(filename)
            error = 'A filename must be entered! Function cancelled.';
            msgbox(error,'Incorrect Input','Error');
            return
        end
        filename = char(filename);
        % Create path to file
        movname = [dir,'/',filename,'.avi'];
        
        % Start writing the video
        
        vidObj = VideoWriter(movname,'Motion JPEG AVI');
        open(vidObj);
        
        % Designate the step of based on the frequency
        
        % Creat pop up screen; the start time and end time are determined
        % by the windowing of the signals on the Rhythm GUI interface
        
        % Grab start and stop time times and convert to index values by
        % multiplying by frequency, add one to shift from zero
        start = str2double(get(starttimesig_edit,'String'))*handles.Fs+1;
        fin = str2double(get(endtimesig_edit,'String'))*handles.Fs+1;
        % Designate the resolution of the video: ex. 5 = every fifth frame
        % % %         step = 5;
        rotStep = 360/(fin-686);
        step = 1;
        % Ask when to stop video for rotation
        inputTime = str2double(inputdlg('At what time would you like to stop video for rotation?'));
        for i = start:step:fin
            
            axis vis3d
            % Update the screen
            screenUpdate(handles.cmosData,handles.dataProj,i)
            % Grab frame from the 3D geometry screen
            set(camG_scrn,'units','pixel')
            pos = get(camG_scrn,'position');
            F = getframe(f, [pos(1) + 5 pos(2) + 5 pos(3) pos(4) + 20]);
            % Write each frame to the file
            writeVideo(vidObj,F);            
            % Rotate heart while stopping time
            if i == inputTime*handles.Fs+1
                for angle = 0:5:360  % Rotate every 5 degrees
                    handles.az = angle;                                                            
                    set(az_edit, 'String', num2str(angle));
                    set(f,'CurrentAxes',camG_scrn)
                    axis vis3d
                    view(camG_scrn, handles.az, handles.el)
                    % Grab frame from the 3D geometry screen
                    F = getframe(f, [pos(1) + 5 pos(2) + 5 pos(3) pos(4) + 20]);
                    % Write each frame to the file
                    writeVideo(vidObj,F);
                    writeVideo(vidObj,F);
                    writeVideo(vidObj,F);
                    writeVideo(vidObj,F);
                    writeVideo(vidObj,F);
                end
            end
        end
        close(vidObj); % Close the file.
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SIGNAL SCREENS
%% Start Time Editable Textbox for Signal Screens
    function starttimesig_edit_callback(source,~)
        %get the val01 (lower limit) and val02 (upper limit) plot values
        val01 = str2double(get(source,'String'));
        val02 = str2double(get(endtimesig_edit,'String'));
        if val01 >= 0 && ...
                val02 <= (size(handles.cmosData{1},3)-1)*...
                handles.Fs
            set(signal_scrn1,'XLim',[val01 val02]);
            set(signal_scrn2,'XLim',[val01 val02]);
            set(signal_scrn3,'XLim',[val01 val02]);
            set(signal_scrn4,'XLim',[val01 val02]);
            set(signal_scrn5,'XLim',[val01 val02]);
            set(sweep_bar,'XLim',[val01 val02]);
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',0)
        end
        % Update the start time value
        handles.starttime = val01;
    end

%% End Time Editable Textbox for Signal Screens
    function endtimesig_edit_callback(source,~)
        val01 = str2double(get(starttimesig_edit,'String'));
        val02 = str2double(get(source,'String'));
        if val01 >= 0 && ...
                val02 <= (size(handles.cmosData{1},3)-1)*...
                handles.Fs
            set(signal_scrn1,'XLim',[val01 val02]);
            set(signal_scrn2,'XLim',[val01 val02]);
            set(signal_scrn3,'XLim',[val01 val02]);
            set(signal_scrn4,'XLim',[val01 val02]);
            set(signal_scrn5,'XLim',[val01 val02]);
            set(sweep_bar,'XLim',[val01 val02]);
        else
            error = 'The END TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',max(handles.time))
        end
        % Update the end time value
        handles.endtime = val02;
    end

%% Export signal waves to new screen
    function expwave_button_callback(~,~)
        
        figure
        trisurf(handles.cells,handles.pts(:,1),handles.pts(:,2),...
            handles.pts(:,3),handles.dataProj(:,133),'LineStyle','none')
        set(gca,'XTick',[],'YTick',[],'ZTick',[],'Visible','off')
        colormap('jet')
        colorbar('off')
        % Get angles and set view
        az1 = 345;
        az2 = 120;
        el = str2double(get(el_edit,'String'));
        view(az1,el)
        axis vis3d
        view(az2,el)
       
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONDITION SIGNALS %%
%% Condition Signals on Click of Apply Button
    function cond_sig_callback(~,~)
        % Read check box
        removeBG_state =get(removeBG_button,'Value');
        bin_state = get(bin_button,'Value');
        filt_state = get(filt_button,'Value');
        drift_state = get(removeDrift_button,'Value');
        norm_state = get(norm_button,'Value');
        % Grab pop up box values
        bin_pop_state = get(bin_popup,'Value');
        % Create variable for tracking conditioning progress
        trackProg = [removeBG_state filt_state bin_state drift_state norm_state];
        trackProg = sum(trackProg)*4;
        counter = 0;
        g1 = waitbar(counter,'Get Comfortable...');
        for n = 1:4
            % Return to raw unfiltered cmos data
            cmosData = handles.cmosRawData{n};
            handles.normflag = 0; % Initialize normflag
            % Condition Signals
            % Remove Background
            if removeBG_state == 1
                % Update counter % progress bar
                counter = counter + 1;
                tmp = sprintf('waitbar(counter/trackProg,g1,''Conditioning Camera %s: Removing Background'');',handles.camLabels(n));
                eval(tmp)
                bg_thresh = str2double(get(bg_thresh_edit,'String'));
                perc_ex = str2double(get(perc_ex_edit,'String'));
                cmosData = remove_BKGRD(cmosData,handles.bg{n},bg_thresh,perc_ex);
            end
                       
            % Bin Data
            if bin_state == 1
                % Update counter % progress bar
                counter = counter + 1;
                tmp = sprintf('waitbar(counter/trackProg,g1,''Conditioning Camera %s: Binning Data'');',handles.camLabels(n));
                eval(tmp)
                if bin_pop_state == 3
                    bin_size = 7;
                elseif bin_pop_state == 2
                    bin_size = 5;
                else
                    bin_size = 3;
                end
                cmosData = binning(cmosData,bin_size);
            end
            % Filter Data
            if filt_state == 1
                % Update counter % progress bar
                counter = counter + 1;
                tmp = sprintf('waitbar(counter/trackProg,g1,''Conditioning Camera %s: Filtering Data'');',handles.camLabels(n));
                eval(tmp)
                filt_pop_state = get(filt_popup,'Value');
                or = 100;
                lb = 0.5;
                if filt_pop_state == 4
                    hb = 150;
                elseif filt_pop_state == 3
                    hb = 100;
                elseif filt_pop_state == 2
                    hb = 75;
                else
                    hb = 50;
                end
                cmosData = filter_data(cmosData,handles.Fs, or, lb, hb);
            end
            % Remove Drift
            if drift_state == 1
                % Update counter % progress bar
                counter = counter + 1;
                tmp = sprintf('waitbar(counter/trackProg,g1,''Conditioning Camera %s: Removing Drift'');',handles.camLabels(n));
                eval(tmp)
                % Gather drift values and adjust for drift
                ord_val = get(drift_popup,'Value');
                ord_str = get(drift_popup,'String');
                cmosData = remove_Drift(cmosData,ord_str(ord_val));
            end
            % Normalize Data
            if norm_state == 1
                % Update counter % progress bar
                counter = counter + 1;
                tmp = sprintf('waitbar(counter/trackProg,g1,''Conditioning Camera %s: Normalizing Data'');',handles.camLabels(n));
                eval(tmp)
                % Normalize data
                cmosData = normalize_data(cmosData);
                handles.normflag = 1;
                % Make paced trace overlay button available
                set(pacingTrace,'Enable','on')
            else
                % Make pacing trace overlay button value 0
                set(pacingTrace,'Value',0)
                % Make pacing trace unavailable
                set(pacingTrace,'Enable','off')
            end
            % Save conditioned signal
            handles.cmosData{n} = cmosData;
            % Update matrixMax value
            handles.matrixMax{n} = .9 * max(handles.cmosData{n}(:));
            
            % Remove atria if is mask exists
            if ~isempty(handles.ventMask{n})
                % Remove the selected points from the data matrix
                handles.cmosData{n}(repmat(handles.ventMask{n},[1 1 ...
                    size(handles.cmosData{n},3)])) = nan;
            end
        end
        % Delete the progress bar
        delete(g1)
        
        ac = handles.activeCam;
        % Update movie screen with the conditioned data
        cla(camA_scrn),cla(camB_scrn),cla(camC_scrn),cla(camD_scrn)
        currentframe = handles.frame;
        drawFrame(handles.cmosData,handles.dataProj,currentframe)

        % Set active axes as current axes
        tmp = sprintf('set(f,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        % Update markers on active axes
        M = handles.M{ac};colax='bgmkc';[a,~]=size(M);
        hold on
        for x=1:a
            tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
            eval(tmp)
            tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[]);',handles.camLabels(ac));% Hide tick markes
            eval(tmp)
        end
        % Change axis border
        tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
        eval(tmp)
        hold off
        
        % Update signal waves (yes this is ugly.  if you find a better way, please change)
        if a>=1
            plot(handles.time,squeeze(handles.cmosData{ac}(M(1,2),M(1,1),:)),'b','LineWidth',2,'Parent',signal_scrn1)
            if a>=2
                plot(handles.time,squeeze(handles.cmosData{ac}(M(2,2),M(2,1),:)),'g','LineWidth',2,'Parent',signal_scrn2)
                if a>=3
                    plot(handles.time,squeeze(handles.cmosData{ac}(M(3,2),M(3,1),:)),'m','LineWidth',2,'Parent',signal_scrn3)
                    if a>=4
                        plot(handles.time,squeeze(handles.cmosData{ac}(M(4,2),M(4,1),:)),'k','LineWidth',2,'Parent',signal_scrn4)
                        if a>=5
                            plot(handles.time,squeeze(handles.cmosData{ac}(M(5,2),M(5,1),:)),'c','LineWidth',2,'Parent',signal_scrn5)
                        end
                    end
                end
            end
        end
        set(export_button,'Enable','On');
    end

%% Callback for exporting data
    function exportData_callback(~,~)
        h=msgbox('Saving....');
        % Choose location to save file and name of file
        dir = handles.dir;
        % If the cancel button is selected cancel the function
        if dir == 0
            return
        end
        
        % Convert filename to a character string
        filename = char(strcat(handles.currentfile,'_data'));
        % Create path to file
        movname = [dir,'/',filename];
        % Save data
        cmosRawData = handles.cmosRawData;
        cmosData = handles.cmosData;
        M = handles.M;
        frame = handles.frame;
        bgRGB = handles.bgRGB;
        phaseClick = handles.phaseClick;
        %phase = handles.phase;
        normflag = handles.normflag;
        matrixMax = handles.matrixMax;
        time = handles.time;
        bg = handles.bg;
        Fs = handles.Fs;
        ecg = handles.ecg;
        save(movname,'cmosRawData','cmosData','M','frame',...
            'bgRGB','phaseClick','normflag','matrixMax','time','bg','Fs','ecg');
        delete(h);
        h=msgbox(strcat('Data saved in same directory as data files'));
    end

%% Scale Callback %%
    function scale_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        scale_factor = str2double(get(scaleEdit,'String'));
        X = handles.X{ac};
        Y = handles.Y{ac};
        
        %find the center around which to scale the projection
        find_center(X,Y);
        c_x = handles.center_x;
        c_y = handles.center_y;
        center_x = repmat(c_x,1,length(X));
        center_y = repmat(c_y,1,length(Y));
        
        %shift the points so that the center of the scale is the new origin
        X_shifted = X - center_x';
        Y_shifted = Y - center_y';
        
        %scale the projection about the new origin
        X_scaled = X_shifted*scale_factor;
        Y_scaled = Y_shifted*scale_factor;
        
        %shift again so the origin goes back the old origin
        handles.newX{ac} = X_scaled + center_x';
        handles.newY{ac} = Y_scaled + center_y';
        
        handles.X{ac} = handles.newX{ac};
        handles.Y{ac} = handles.newY{ac};
        
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Rotate Callback %%
    function rotate_callback(~,~)
       % Get active camera value
        ac = handles.activeCam;
        theta = str2double(get(rotateEdit,'String'));
        
        X = handles.X{ac};
        Y = handles.Y{ac};
        
        %find the center around which to rotate the projection
        find_center(X,Y);
        c_x = handles.center_x;
        c_y = handles.center_y;
        center_x = repmat(c_x,1,length(X));
        center_y = repmat(c_y,1,length(Y));
        
        %shift the points so that the center of the rotation is the new origin
        X_shifted = X - center_x';
        Y_shifted = Y - center_y';
       
        %rotate the projection about the new origin
        X_rotated = X_shifted*cosd(theta) - Y_shifted*sind(theta);
        Y_rotated = X_shifted*sind(theta) + Y_shifted*cosd(theta);
        
        %shift again so the origin goes back the old origin
        handles.newX{ac} = X_rotated + center_x';
        handles.newY{ac} = Y_rotated + center_y';
        
        handles.X{ac} = handles.newX{ac};
        handles.Y{ac} = handles.newY{ac};
        
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end


 %Find the center of X,Y projection
    function find_center(X,Y)
        minx = min(X);
        maxx = max(X);
        centx = (minx + maxx) / 2;
        miny = min(Y);
        maxy = max(Y);
        centy = (miny + maxy) / 2;
        dist2 = (X - centx).^2 + (Y - centy).^2;
        [~, idx] = min(dist2);
        bestx = X(idx);
        besty = Y(idx);
        handles.center_x = bestx;
        handles.center_y = besty;
    end

%% Callback for exporting projections
    function export_callback(~,~)
        h=msgbox('Saving....');
        % Choose location to save file and name of file
        dir = handles.dir;
        % If the cancel button is selected cancel the function
        if dir == 0
            return
        end
        
        % Convert filename to a character string
        filename = char(strcat(handles.currentfile,'_proj'));
        % Create path to file
        movname = [dir,'/',filename];
        % Save data
        cmosRawData = handles.cmosRawData;
        cmosData = handles.cmosData;
        bgMask = cell(1,4);
        M = handles.M;
        Rcmap = handles.Rcmap;
        xyzmap = handles.xyzmap;
        Parmap = handles.Parmap;
        Posmap = handles.Posmap;
        looknmap = handles.looknmap;
        pts = handles.pts;
        numparams = handles.numparams;
        txtparams = handles.txtparams;
        cells = handles.cells;
        centroids = handles.centroids;
        norms = handles.norms;
        neighs = handles.neighs;
        neighnum = handles.neighnum;
        X = handles.X;
        Y = handles.Y;
        shift = handles.shift;
        geommask = handles.geommask;
        mapCam = handles.mapCam;
        dataProj = handles.dataProj;
        textProj = handles.textProj;
        viewi = handles.viewi;
        mask = handles.mask;
        frame = handles.frame;
        bgRGB = handles.bgRGB;
        phaseClick = handles.phaseClick;
        %phase = handles.phase;
        normflag = handles.normflag;
        matrixMax = handles.matrixMax;
        time = handles.time;
        newX = handles.newX;
        newY = handles.newY;
        bg = handles.bg;
        Fs = handles.Fs;
        
        for n = 1:4
            bgMask{n} = handles.cmosData{n}(:,:,1)>0;
        end
        bgMask = handles.bgMask;
        save(movname,'cmosRawData','cmosData','bgMask','M','Rcmap'...
            ,'xyzmap','Parmap','Posmap','looknmap','pts','numparams'...
            ,'txtparams','cells','centroids','norms','neighs','neighnum',...
            'X','Y','shift','geommask','mapCam','dataProj','textProj'...
            ,'viewi','mask','frame','bgRGB','phaseClick','normflag','matrixMax','time'...
            ,'newX','newY','bg','Fs','-v7.3');
        delete(h);
        h=msgbox(strcat('Data saved in same directory as data files'));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYZE DATA %%
%% Selection of Analysis Type
    function anal_select_callback(~,~)        
        % Get the type of analysis
        anal_state = get(anal_select,'Value');
        % Adjustment of buttons based on analysis
        if anal_state == 1
            % Turn all buttons off and hide
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,minMap_text,minMap_edit,...
                maxMap_text,maxMap_edit,percentapd_text,percentapd_edit,...
                remove_motion_click,remove_motion_click_txt],'Visible','off','Enable','off')
        elseif anal_state == 2
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,createmap_button,...
                minMap_text,minMap_edit,maxMap_text,maxMap_edit],...
                'Visible','on','Enable','on')
            % Turn unneeded buttons off
            set([percentapd_text,percentapd_edit,remove_motion_click,...
                remove_motion_click_txt],'Visible',...
                'off','Enable','off')
        elseif anal_state == 3
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,createmap_button],...
                'Visible','on','Enable','on')
            % Turn unneeded buttons off
            set([minMap_text,minMap_edit,maxMap_text,maxMap_edit,...
                percentapd_text,percentapd_edit,remove_motion_click,...
                remove_motion_click_txt],'Visible',...
                'off','Enable','off')
        elseif anal_state == 4
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,createmap_button,...
                minMap_text,minMap_edit,maxMap_text,maxMap_edit,...
                percentapd_text,percentapd_edit,remove_motion_click,...
                map2D_button,remove_motion_click_txt],'Visible',...
                'on','Enable','on')
        elseif anal_state == 5
            % Turn on create map button
            set(createmap_button,'Visible','on','Enable','on')
            % Turn all buttons off except the create map button
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,minMap_text,minMap_edit,...
                maxMap_text,maxMap_edit,percentapd_text,percentapd_edit,...
                remove_motion_click,remove_motion_click_txt],'Visible','off','Enable','off')
        elseif anal_state == 6
            % Turn on create map button
            set(createmap_button,'Visible','on','Enable','on')
            % Turn all buttons off except the create map button
            set([invert_cmap,starttimemap_text,starttimemap_edit,...
                endtimemap_text,endtimemap_edit,minMap_text,minMap_edit,...
                maxMap_text,maxMap_edit,percentapd_text,percentapd_edit,...
                remove_motion_click,remove_motion_click_txt],'Visible','off','Enable','off')
        end
    end

%% Regional APD Calculation
    function calc_apd_button_callback(~,~)
        % Read APD Parameters
        handles.percentAPD = str2double(get(percentapd_edit,'String'));
        handles.maxapd = str2double(get(maxMap_edit,'String'));
        handles.minapd = str2double(get(minMap_edit,'String'));
        % Read remove motion check box
        remove_motion_state =get(remove_motion_click,'Value');
        axes(camG_scrn)
        coordinate=getrect(camG_scrn);
        gg=msgbox('Creating Regional APD...');
        apdCalc(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,...
            handles.percentAPD,handles.maxapd,handles.minapd,remove_motion_state,...
            coordinate,handles.bg,handles.cmap);
        close(gg)
    end

%% INVERT COLORMAP: inverts the colormaps for all isochrone maps
    function invert_cmap_callback(~,~)
        % Function Description: The checkbox function like toggle button.
        % There are only 2 options and since the box starts unchecked,
        % checking it will invert the map, uncheckecking it will invert it
        % back to its original state. As such no additional code is needed.
        
        % grab the current value of the colormap
        cmap = handles.cmap;
        % invert the existing colormap values
        handles.cmap = flipud(cmap);
    end

%% Callback for Start and End Time for Analysis
    function maptime_edit_callback(~,~)
        % get the bounds of the viewing window
        vw_start = str2double(get(starttimesig_edit,'String'));
        vw_end = str2double(get(endtimesig_edit,'String'));
        % get the bounds of the activation window
        a_start = str2double(get(starttimemap_edit,'String'));
        a_end = str2double(get(endtimemap_edit,'String'));
        if a_start >= 0 && a_start <= max(handles.time)
            if a_end >= 0 && a_end <= max(handles.time)
                set(f,'CurrentAxes',sweep_bar)
                a = [a_start a_start];b = [0 1];cla
                plot(a,b,'g','Parent',sweep_bar)
                hold on
                a = [a_end a_end];b = [0 1];
                plot(a,b,'-g','Parent',sweep_bar)
                axis([vw_start vw_end 0 1])
                hold off; axis off
                hold off
                handles.a_start = a_start;
                handles.a_end = a_end;
            else
                error = 'The END TIME must be greater than %d and less than %.3f.';
                msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
                set(endtimemap_edit,'String',max(handles.time))
            end
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(starttimemap_edit,'String',0)
        end
    end

%% Button to create analysis maps
    function createmap_button_callback(~,~)
        handles.a_start = str2double(get(starttimemap_edit,'String'));
        handles.a_end = str2double(get(endtimemap_edit,'String'));        
        % Clear signal axes and saved points
        for n = 1:5
            tmp = sprintf('cla(signal_scrn%d)',n);
            eval(tmp)
        end
        handles.M = cell(1,5);
        handles.wave_window(:) = 1;
        % Get the movie slider value
        val = get(movie_slider,'Value');
        % Round it to an integer
        i = round(val);
        % Save it to the handles
        handles.frame = i;
        % CHECK ANALYSIS MODE
        check = get(anal_select,'Value');
        % FOR MEMBRANE POTENTIAL
        if check == 1
            handles.phaseFlag = 0;
            screenUpdate(handles.cmosData,handles.dataProj,handles.frame)
            handles.val2D = handles.dataProj;
        end
        % FOR ACTIVATION
        if check == 2
            gg=msgbox('Building  Activation Map...');
            % Attach the 3D data to the 2D cell data
            data = handles.cmosData;
            data{5} = handles.dataProj;
            handles.a_start = str2double(get(starttimemap_edit,'String'));
            handles.a_end = str2double(get(endtimemap_edit,'String'));
            % Activation map function
            [actMap] = aMapPano(data,handles.a_start,...
                handles.a_end,handles.Fs);
            % Extract 3D data
            actMapGeo = actMap{5};
            % Remove from the 2D data variable
            actMap(5) = [];
            % Save data to handles
            handles.actMap = actMap;
            handles.actMapGeo = actMapGeo;
            % Close progress bar
            close(gg)
            
            %Update screens with activation data
            handles.frame = 1;
            screenUpdate(actMap,actMapGeo,handles.frame)
            handles.val2D = handles.actMapGeo;
            % FOR CONDUCTION VELOCITY
% % %         elseif check == 3
% % %             %             return
% % %             rect = getrect(camG_scrn);
% % %             gg=msgbox('Building Conduction Velocity Map...');
% % %             cMap(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,handles.bg,rect);
% % %             close(gg)
            % FOR ACTION POTENTIAL DURATION
        elseif check == 4
            gg=msgbox('Creating Global APD Map...');
            handles.percentAPD = str2double(get(percentapd_edit,'String'));
            data = handles.cmosData;
            data{5} = handles.dataProj;
            [apdMap] = apdMapPano(data,handles.a_start,handles.a_end,handles.Fs,handles.percentAPD);
            apdMapGeo = apdMap{5};
            apdMap(5) = [];
            close(gg)
           % Save to handles variable
            handles.apdMapGeo = apdMapGeo;
            % Update screens with activation data
            handles.val2D = apdMapGeo;
            handles.frame = 1;
            screenUpdate(apdMap,apdMapGeo,handles.frame)
            % FOR PHASE MAP CALCULATION
        elseif check == 5
            handles.phaseFlag = 1;
            h = msgbox('Building Phases....');
            % Check if phase calculation has already been clicked
            [phaseMap,phaseMapGeo] = phaseMapPano(handles.cmosData,handles.dataProj,handles.starttime,handles.endtime,handles.Fs);
            % Save to handles variable
            handles.phaseMap = phaseMap;
            handles.phaseMapGeo = phaseMapGeo;
            % Update screens with activation data
            screenUpdate(phaseMap,phaseMapGeo,handles.frame)
            handles.val2D = handles.phaseMapGeo;
            delete(h);
        elseif check == 6
            gg=msgbox('Calculating Dominant Frequency Map...');
            maxFreq = calDomFreqPano(handles.cmosData,handles.Fs);
            % Project activation maps onto geometry
            nr = size(handles.geommask,1);
            nc = size(handles.geommask,2);
            [maxFreqGeo,~,~,~,~] = dataProjection02(...
                handles.newX,handles.newY,handles.shift,handles.norms,...
                handles.centroids,handles.cells,handles.pts,...
                handles.neighs,handles.neighnum,handles.Parmap,...
                handles.Posmap,handles.mapCam,handles.bgMask,handles.bg,...
                handles.geommask,nr,nc,handles.looknmap,...
                maxFreq,handles.Fs,handles.opt_dir,handles.currentfile);
            % Save to handles variable
            handles.maxFreqGeo = maxFreqGeo;
            % Update screens with activation data
            handles.frame = 1;
            screenUpdate(maxFreq,maxFreqGeo,handles.frame)
            handles.val2D = handles.maxFreqGeo;
            close(gg)
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CAMERA ANGLE %%
%% Azimuth Angle Callback %%
    function az_edit_callback(source,~)
        % Grab angle value from edit box
        az = str2double(source.String);
        % Verify that the angle lies between -360 and 360
        if az > 360
            set(az_edit,'String',num2str(handles.az))
        elseif az < -360
            set(az_edit,'String',num2str(handles.az))
        elseif isnan(az)
            set(az_edit,'String',num2str(handles.az))
        else
            % Adjust view according to new azimuth value
            set(f,'CurrentAxes',camG_scrn)
            view([az handles.el])
            axis vis3d
            % Save new azimuth value to handles
            handles.az = az;
        end
        axis equal
    end

%% Elevation Angle Callback %%
    function el_edit_callback(source,~)
        % Grab angle value from edit box
        el = str2double(source.String);
        % Verify that the angle lies between -360 and 360
        if el > 360
            set(el_edit,'String',num2str(handles.el))
        elseif el < -360
            set(el_edit,'String',num2str(handles.el))
        elseif isnan(el)
            set(el_edit,'String',num2str(handles.el))
        else
            % Adjust view according to new azimuth value
            set(f,'CurrentAxes',camG_scrn)
            view([handles.az el])
            axis vis3d
            % Save new elevation value to handles
            handles.el = el;
        end
        axis equal
    end

%% Camera View A Button Callback %%
    function camAview_button_callback(~,~)
        % Adjust view according to camera 1 position
        set(f,'CurrentAxes',camG_scrn)
        % Adjust azimuth and elevation values
        handles.az = -45;
        set(az_edit,'String',num2str(handles.az))
        handles.el = 0;
        set(el_edit,'String',num2str(handles.el))
        % Adjust the view
        view([handles.az handles.el])
        axis equal
    end

%% Camera View B Button Callback %%
    function camBview_button_callback(~,~)
        % Adjust view according to camera 1 position
        set(f,'CurrentAxes',camG_scrn)
        % Adjust azimuth and elevation values
        handles.az = -135;
        set(az_edit,'String',num2str(handles.az))
        handles.el = 0;
        set(el_edit,'String',num2str(handles.el))
        % Adjust the view
        view([handles.az handles.el])
        axis vis3d
    end

%% Camera View C Button Callback %%
    function camCview_button_callback(~,~)
        % Adjust view according to camera 1 position
        set(f,'CurrentAxes',camG_scrn)
        % Adjust azimuth and elevation values
        handles.az = -225;
        set(az_edit,'String',num2str(handles.az))
        handles.el = 0;
        set(el_edit,'String',num2str(handles.el))
        % Adjust the view
        view([handles.az handles.el])
        axis equal
    end

%% Camera View D Button Callback %%
    function camDview_button_callback(~,~)
        % Adjust view according to camera 1 position
        set(f,'CurrentAxes',camG_scrn)
        % Adjust azimuth and elevation values
        handles.az = 45;
        set(az_edit,'String',num2str(handles.az))
        handles.el = 0;
        set(el_edit,'String',num2str(handles.el))
        % Adjust the view
        view([handles.az handles.el])
        axis equal
    end

%% Make Camera A Active Toggle Callback %%
    function camATog_callback(~,~)
        oldac = handles.activeCam;
        % Grab index for this axis
        ac = 1;
        % Save new active axis value to handles
        handles.activeCam = ac;
        % Feed to function for changing active axis
        makeActiveAxis(oldac, ac)
    end

%% Make Camera B Active Toggle Callback %%
    function camBTog_callback(~,~)
        oldac = handles.activeCam;
        % Grab index for this axis
        ac = 2;
        % Save new active axis value to handles
        handles.activeCam = ac;
        % Feed to function for changing active axis
        makeActiveAxis(oldac, ac)
    end

%% Make Camera C Active Toggle Callback %%
    function camCTog_callback(~,~)
        oldac = handles.activeCam;
        % Grab index for this axis
        ac = 3;
        % Save new active axis value to handles
        handles.activeCam = ac;
        % Feed to function for changing active axis
        makeActiveAxis(oldac, ac)
    end

%% Make Camera D Active Toggle Callback %%
    function camDTog_callback(~,~)
        oldac = handles.activeCam;
        % Grab index for this axis
        ac = 4;
        % Save new active axis value to handles
        handles.activeCam = ac;
        % Feed to function for changing active axis
        makeActiveAxis(oldac, ac)
    end

%% Make Camera Geo Active Toggle Callback %%
    function camGTog_callback(~,~)
        oldac = handles.activeCam;
        % Grab index for this axis
        ac = 5;
        % Save new active axis value to handles
        handles.activeCam = ac;
        % Feed to function for changing active axis
        makeActiveAxis(oldac, ac)
    end

%% Function to make an axis the active axis
    function makeActiveAxis(oldac, ac)
        % Remove axis outline from old active axis
        tmp = sprintf('set(cam%s_scrn,''XColor'',''k'',''YColor'',''k'',''LineWidth'',2)',handles.camLabels(oldac));
        eval(tmp)
        % Set old active axis toggle to off
        tmp = sprintf('set(cam%sTog,''Value'',0)',handles.camLabels(oldac));
        eval(tmp)
        if strcmp(get(project,'String'),'RESET') || strcmp(get(align_button,'String'),'ALIGN')
            % Update movie screen with new markers
            tmp = sprintf('cla(cam%s_scrn)',handles.camLabels(handles.activeCam));
            eval(tmp)
            
            currentframe = handles.frame;
            if handles.phaseFlag == 0
                drawFrame(handles.cmosData,handles.dataProj,currentframe);
            else
                drawFrame(handles.phaseMap,handles.phaseMapGeo,currentframe);
            end
            % Clear signal axes
            for n = 1:5
                tmp = sprintf('cla(signal_scrn%d)',n);
                eval(tmp)
            end
            % Add signals from current axes display points
            M = handles.M{ac}; colax='bgmkc'; [a,~]=size(M);
            tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(ac));
            eval(tmp)
            hold on
            for x=1:a
                if ac == 5
                    % Display 3D points
                    tmp = sprintf('plot3(M(x,1),M(x,2),M(x,3),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn)',handles.camLabels(ac));
                    eval(tmp)
                else
                    % Display 2D points
                    tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn)',handles.camLabels(ac));
                    eval(tmp)
                end
                tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[]);',handles.camLabels(ac));% Hide tick markes
                eval(tmp)
            end
            pacingTraceFunction(get(pacingTrace,'Value'))
            hold off
        else
            projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
            % Update xShift edit box values
            set(xShiftEdit,'String',num2str(handles.shift(ac,1)))
            set(yShiftEdit,'String',num2str(handles.shift(ac,2)))
        end
        
        % Change axis border
        tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
        eval(tmp)
        % Change Toggle value to on
        tmp = sprintf('set(cam%sTog,''Value'',1)',handles.camLabels(ac));
        eval(tmp)
    end

%% Align With User Input %%
    function align_button_callback(~,~)
        % Check button state
        check = get(align_button,'String');
        check = strcmp(check,'ALIGN');
        if check
            % Deactivate conditioning options
            set([removeBG_button,bg_thresh_label,perc_ex_label,...
                bg_thresh_edit,perc_ex_edit,bin_button,filt_button,...
                removeDrift_button,norm_button,bin_popup,filt_popup,...
                drift_popup,apply_button],'Enable','off')
            % Activate alignment options
            set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                xShiftEdit,shift_left,shift_right,project,rotateEdit,scaleEdit],'Enable','on')
            % Change button
            set(align_button,'String','CANCEL')
            
            % % %             % CAMERA RESOLUTIONS
            % % %             [handles.camRes,handles.camResMicro] = resolutionCalc(1);
            % % %
            % CALIBRATION
            nviews = 1:4;
            [handles.Rcmap,handles.xyzmap,handles.Parmap,handles.Posmap,...
                handles.lookmap,handles.looknmap] = loadCameraCalibration(...
                nviews);
            
            % GEOMETRY
            % Have user select geometry file to use
            [handles.pts,handles.numparams,handles.txtparams,...
                handles.cells,handles.centroids,handles.norms,...
                handles.neighs,handles.neighnum] = loadVTKmesh();
            
            % Project points onto 2D camera masks
            handles.X = cell(4,1);
            handles.newX = handles.X;
            handles.Xshift = handles.X;
            handles.Y = cell(4,1);
            handles.newY = handles.Y;
            handles.Yshift = handles.Y;
            handles.shift = zeros(4,2);
            handles.geommasks = zeros(size(handles.cmosData{1},1),...
                size(handles.cmosData{1},2),4);
            
            % FIGURE OUT HOW TO GET THIS INFORMATION FROM FIT2 TO HERE !!!!
            handles.mapCam = 'brainvision_ultimaL';
            % handles.geoCam = 'iDS_UI_3220CP-M-GL_with_f1.2';
            
            % Perform
            
            
            % Map 3D points to 2D mapping cameras
            for n = nviews
                [handles.X{n},handles.Y{n}] = pred(handles.pts,...
                    handles.Parmap(:,n),handles.Posmap(:,n),handles.mapCam);
                handles.newX{n} = handles.X{n};
                handles.newY{n} = handles.Y{n};
            end
            % Visualize
            bgMask = cell(1,4);
            for n = 1:4
                % Clear axes
                tmp = sprintf('cla(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                % Visualize binary silhouette
                bgMask{n} = ~isnan(handles.cmosData{n}(:,:,n));
                tmp = sprintf('imagesc(bgMask{n},''Parent'',cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                colormap('gray')
                % Remove tick marks
                tmp = sprintf('set(cam%s_scrn,''NextPlot'',''replacechildren'',''YLim'',[0.5 size(bgMask{n},1)+0.5],''YTick'',[],''XLim'',[0.5 size(bgMask{n},2)+0.5],''XTick'',[])',handles.camLabels(n));
                eval(tmp)
                % Set appropriate axes as active axes
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                hold on
                % Overlay projected points
                scatter(handles.X{n},handles.Y{n},'ro')
                hold off
            end
            handles.bgMask = bgMask;
            % Change axis border
            tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(handles.activeCam));
            eval(tmp)
        else
            % Return image screens to background and fluorescence
            drawFrame(handles.cmosData,handles.dataProj,handles.frame)
            % Change axis border
            tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(handles.activeCam));
            eval(tmp)
            % Update signal screens
            signalUpdate(handles.activeCam)
            % Activate conditioning options
            set([removeBG_button,bg_thresh_label,perc_ex_label,...
                bg_thresh_edit,perc_ex_edit,bin_button,filt_button,...
                removeDrift_button,norm_button,bin_popup,filt_popup,...
                drift_popup,apply_button,export_button],'Enable','on')
            % Deactivate alignment options
            set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                xShiftEdit,shift_left,shift_right,project,exportProj],'Enable','off')
            % Change button
            set(align_button,'String','ALIGN')
            % Reset geometry handles
            handles.centroids = [];
            handles.norms = [];
            handles.neighs = [];
            handles.neighnum = [];
            handles.pts = [];
            handles.numparams = [];
            handles.txtparams = [];
            handles.cells = [];
        end
    end

%% Shift Y Edit %%
    function yShiftEdit_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the y shift value in the handles
        handles.shift(ac,2) = str2double(get(yShiftEdit,'String'));
        handles.newY{ac} = handles.Y{ac}+handles.shift(ac,2);
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Shift Up Callback %%
    function shift_up_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the y shift value in the handles
        handles.shift(ac,2) = handles.shift(ac,2)-1;
        handles.newY{ac} = handles.Y{ac}+handles.shift(ac,2);
        % Update the y shift edit value
        set(yShiftEdit,'String',num2str(handles.shift(ac,2)))
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Shift Down Callback %%
    function shift_down_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the y shift value in the handles
        handles.shift(ac,2) = handles.shift(ac,2)+1;
        handles.newY{ac} = handles.Y{ac}+handles.shift(ac,2);
        % Update the y shift edit value
        set(yShiftEdit,'String',num2str(handles.shift(ac,2)))
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Shift X Edit %%
    function xShiftEdit_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the y shift value in the handles
        handles.shift(ac,1) = str2double(get(xShiftEdit,'String'));
        handles.newX{ac} = handles.X{ac}+handles.shift(ac,1);
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Shift Left Callback %%
    function shift_left_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the x shift value in the handles
        handles.shift(ac,1) = handles.shift(ac,1)-1;
        handles.newX{ac} = handles.X{ac}+handles.shift(ac,1);
        % Update the x shift edit value
        set(xShiftEdit,'String',num2str(handles.shift(ac,1)))
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end

%% Shift Right Callback %%
    function shift_right_callback(~,~)
        % Get active camera value
        ac = handles.activeCam;
        % Update the x shift value in the handles
        handles.shift(ac,1) = handles.shift(ac,1)+1;
        handles.newX{ac} = handles.X{ac}+handles.shift(ac,1);
        % Update the x shift edit value
        set(xShiftEdit,'String',num2str(handles.shift(ac,1)))
        % Update visualization
        projectionOverlay(ac,handles.newX{ac},handles.newY{ac})
    end
%% Overlay of projected points onto silhouettes %%
    function projectionOverlay(ac,X,Y)
        % Clear axes
        tmp = sprintf('cla(cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        % Visualize binary silhouette
        bgMask = ~isnan(handles.cmosData{ac}(:,:,1));
        tmp = sprintf('imagesc(bgMask,''Parent'',cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        colormap('gray')
        % Remove tick marks
        tmp = sprintf('set(cam%s_scrn,''NextPlot'',''replacechildren'',''YLim'',[0.5 size(bgMask,1)+0.5],''YTick'',[],''XLim'',[0.5 size(bgMask,2)+0.5],''XTick'',[])',handles.camLabels(ac));
        eval(tmp)
        % Set appropriate axes as active axes
        tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        hold on
        % Overlay projected points
        scatter(X,Y,'ro')
        %         tmp = sprintf('scatter(cam%s_scrn,X(:,ac),Y(:,ac),''ro'')',handles.camLabels(ac));
        %         eval(tmp)
        hold off
        handles.bgMask{ac} = bgMask;
        % Change axis border
        tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(ac));
        eval(tmp)
    end

%% Update signal markers and screens %%
    function signalUpdate(ac)
        % Clear signal axes
        for n = 1:5
            tmp = sprintf('cla(signal_scrn%d)',n);
            eval(tmp)
        end
        % Add signals from current axes display points
        M = handles.M{ac}; colax='bgmkc'; [a,~]=size(M);
        tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        hold on
        for x=1:a
            % Display point
            tmp = sprintf('plot(M(x,1),M(x,2),''cs'',''MarkerSize'',8,''MarkerFaceColor'',colax(x),''MarkerEdgeColor'',''w'',''Parent'',cam%s_scrn);',handles.camLabels(ac));
            eval(tmp)
            tmp = sprintf('set(cam%s_scrn,''YTick'',[],''XTick'',[]);',handles.camLabels(ac)); % Hide tick markes
            eval(tmp)
            % Display signal
            tmp = sprintf('plot(handles.time,squeeze(handles.cmosData{ac}(M(x,1),M(x,2),:)),colax(x),''LineWidth'',2,''Parent'',%d)',x);
            eval(tmp)
        end
        hold off
    end

%% Load Projection %%
    function loadData(loadflag)
        if loadflag == 1
            cd(handles.dir)
            vars = load(strcat(handles.currentfile,'_proj.mat'));
            
            set(project,'String','RESET')
            handles.cmosData = vars.cmosData;
            handles.dataProj = vars.dataProj;
            handles.val2D = handles.dataProj;
            handles.textProj = vars.textProj;
            handles.viewi = vars.viewi;
            handles.geommask = vars.geommask;
            handles.mask = vars.mask;
            handles.frame = vars.frame;
            handles.bgRGB = vars.bgRGB;
            handles.phaseClick = vars.phaseClick;
            handles.normflag = vars.normflag;
            handles.matrixMax = vars.matrixMax;
            handles.cells = vars.cells;
            handles.time = vars.time;
            handles.pts = vars.pts;
            handles.X = vars.X;
            handles.Y = vars.Y;
            handles.shift = vars.shift;
            handles.newX = vars.newX;
            handles.newY = vars.newY;
            handles.mapCam = vars.mapCam;
            handles.bg = vars.bg;
            handles.looknmap = vars.looknmap;
            handles.Fs = vars.Fs;
            handles.norms = vars.norms;
            handles.xyzmap = vars.xyzmap;
            handles.Parmap = vars.Parmap;
            handles.Posmap = vars.Posmap;
            handles.centroids = vars.centroids;
            handles.neighs = vars.neighs;
            handles.neighnum = vars.neighnum;
            handles.bgMask = vars.bgMask;
            
            screenUpdate(handles.cmosData,handles.dataProj,handles.frame)
            % Get angles and set view
            az = str2double(get(el_edit,'String'));
            el = str2double(get(az_edit,'String'));
            view(az,el)
            axis vis3d
        elseif loadflag == 2
            cd(handles.dir)
            vars = load(strcat(handles.currentfile,'_data.mat'));
            
            handles.cmosData = vars.cmosData;
            handles.frame = vars.frame;
            handles.bgRGB = vars.bgRGB;
            handles.phaseClick = vars.phaseClick;
            handles.normflag = vars.normflag;
            handles.matrixMax = vars.matrixMax;
            handles.time = vars.time;
            handles.bg = vars.bg;
            handles.Fs = vars.Fs;
            handles.ecg = vars.ecg;
            drawFrame(handles.cmosData,[],1)
        end
    end

%% Projection callback %%
    function project_callback(~,~)
        if strcmp(get(project,'String'),'PROJECT')
            % Set string of button to reset
            set(project,'String','RESET')
            % Create variable for geometric mask creation
            handles.geommask = zeros(size(handles.cmosData{1},1),...
                size(handles.cmosData{1},2),4);
            nr = size(handles.geommask,1);
            nc = size(handles.geommask,2);
            % Perform projection
            [dataProj,textProj,viewi,geommask,mask] = dataProjection02(...
                handles.newX,handles.newY,handles.shift,handles.norms,...
                handles.centroids,handles.cells,handles.pts,...
                handles.neighs,handles.neighnum,handles.Parmap,...
                handles.Posmap,handles.mapCam,handles.bgMask,handles.bg,...
                handles.geommask,nr,nc,handles.looknmap,...
                handles.cmosData,handles.Fs,handles.opt_dir,...
                handles.currentfile);
            % Save results to handles variable
            handles.dataProj = dataProj;
            handles.textProj = textProj;
            handles.viewi = viewi;
            handles.geommask = geommask;
            handles.mask = mask;
            
            screenUpdate(handles.cmosData,dataProj,handles.frame)
            % Get angles and set view
            az = str2double(get(el_edit,'String'));
            el = str2double(get(az_edit,'String'));
            view(az,el)
            axis vis3d
            % Turn on Visualization options
            set([camOverlay,triMesh,projTexture,projData],'Enable','On')
            set(projData,'BackgroundColor',[0.8 0.8 0.8])
            handles.projDataClick = 1;
            % Turn on Camera Angle tools
            set([az_txt,az_edit,el_txt,el_edit,camAview_button,...
                camBview_button,camCview_button,camDview_button,...
                anal_select,map2D_button,exportProj,timeEdit],'Enable','On')
            handles.az = str2double(get(az_edit,'String'));
            handles.el = str2double(get(el_edit,'String'));
            set(camGTog,'Enable','on')
            set(camG_scrn,'Visible','off')
            
            % Disable all other alignment tools
            set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                xShiftEdit,shift_left,shift_right],'Enable','off')
            set([yShift,yShiftEdit,shift_up,shift_down,xShift,xShiftEdit,shift_left,...
                shift_right,project,camOverlay,triMesh,projTexture,projData,az_txt,az_edit,...
                el_txt,el_edit,camAview_button,camBview_button,camCview_button,...
                camDview_button,anal_select,invert_cmap,starttimemap_text,...
                starttimemap_edit,endtimemap_text,endtimemap_edit,createmap_button,...
                minMap_text,minMap_edit,maxMap_text,maxMap_edit,percentapd_text,...
                percentapd_edit,remove_motion_click,remove_motion_click_txt,...
                map2D_button],'Enable','on')
            set([camATog,camBTog,camCTog,camDTog,camGTog,dispwave_button,...
                play_button,stop_button,expmov_button],'Enable','on')
            % Disable return to conditioning button
            set(align_button,'Enable','off')
            makeActiveAxis(1,handles.activeCam);
        else
            % Set string of button to project
            set(project,'String','PROJECT')
            % Enable alignment tools
            set([yShift,yShiftEdit,shift_up,shift_down,xShift,...
                xShiftEdit,shift_left,shift_right],'Enable','on')
            % Enable return to conditioning button
            set([align_button,camATog,camBTog,camCTog,camDTog],'Enable','on')
            handles.activeCam = find([get(camATog,'Value')...
                get(camBTog,'Value') get(camCTog,'Value') get(camDTog,'Value')]);
            % Disable buttons for types of visualization
            set([camOverlay,triMesh,projTexture,projData],'Enable','off',...
                'BackgroundColor',[0.94 0.94 0.94])
            % Reset 2D windows
            bgMask = cell(1,4);
            for n = 1:4
                % Clear axes
                tmp = sprintf('cla(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                % Visualize binary silhouette
                bgMask{n} = ~isnan(handles.cmosData{n}(:,:,n));
                tmp = sprintf('imagesc(bgMask{n},''Parent'',cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                colormap('gray')
                % Remove tick marks
                tmp = sprintf('set(cam%s_scrn,''NextPlot'',''replacechildren'',''YLim'',[0.5 size(bgMask{n},1)+0.5],''YTick'',[],''XLim'',[0.5 size(bgMask{n},2)+0.5],''XTick'',[])',handles.camLabels(n));
                eval(tmp)
                % Set appropriate axes as active axes
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                hold on
                % Overlay projected points
                scatter(handles.X{n}+handles.shift(n,1),...
                    handles.Y{n}+handles.shift(n,2),'ro')
                hold off
            end
            handles.bgMask = bgMask;
            % Clear 3D axis
            cla(camG_scrn)
            % Turn 3D rotation off
            rotate3d(camG_scrn)
            handles.rot3 = 0;
            set(camGTog,'Enable','off','Value',0)
            % Change axis border
            tmp = sprintf('set(cam%s_scrn,''XColor'',''m'',''YColor'',''m'',''LineWidth'',4)',handles.camLabels(handles.activeCam));
            eval(tmp)
            cla(signal_scrn1);
            cla(signal_scrn2);
            cla(signal_scrn3);
            cla(signal_scrn4);
            cla(signal_scrn5);
            handles.val2D = handles.dataProj;
        end
    end

%% Camera Overlay Visualization Callback %%
    function camOverlay_callback(~,~)
        if handles.cameraClick == 0
            % Visualize camera overlay in 3D window
            axes(camG_scrn)
            trisurf(handles.cells,handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),handles.viewi(:,5),'LineStyle','none')
            set(camG_scrn,'Visible','off')
            colormap('jet')
            colorbar('Ticks',0:6,'TickLabels',{'None','Cam A','Cam B',...
                'Cam C','Cam D','Overlap','Edge'})
            az = str2double(get(az_edit,'String'));
            el = str2double(get(el_edit,'String'));
            view(az,el)
            axis equal
            
            % Make 2D screens just background
            cla(camA_scrn),cla(camB_scrn),cla(camC_scrn),cla(camD_scrn)
            for n = 1:4
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                image(handles.bgRGB{n})
                tmp = sprintf('set(cam%s_scrn,''XTick'',[],''YTick'',[],''ZTick'',[])',...
                    handles.camLabels(n));
                eval(tmp)
            end
            
            % Update handles
            handles.cameraClick = 1;
            set(camOverlay,'BackgroundColor',[0.8 0.8 0.8])
            handles.meshClick = 0;
            handles.dataClick = 0;
            handles.textureClick = 0;
            set([triMesh,projTexture,projData],'BackgroundColor',[0.94 0.94 0.94])
            
            % Disable the active camera buttons
            set([camATog,camBTog,camCTog,camDTog,camGTog,dispwave_button,...
                play_button,stop_button,expmov_button],'Enable','off')
        end
    end

%% Trimesh Visualization Callback %%
    function triMesh_callback(~,~)
        if handles.meshClick == 0
            axes(camG_scrn)
            trisurf(handles.cells,handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),zeros(size(handles.pts,1),1))
           % set(camG_scrn,'Visible','off')
            colorbar('off')
            % Get angles and set view
            az = str2double(get(az_edit,'String'));
            el = str2double(get(el_edit,'String'));
            view(az,el)
            axis equal
            
            % Make 2D screens just background
            cla(camA_scrn),cla(camB_scrn),cla(camC_scrn),cla(camD_scrn)
            for n = 1:4
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                image(handles.bgRGB{n})
                tmp = sprintf('set(cam%s_scrn,''XTick'',[],''YTick'',[],''ZTick'',[])',...
                    handles.camLabels(n));
                eval(tmp)
            end
            
            % Update handles
            handles.meshClick = 1;
            set(triMesh,'BackgroundColor',[0.8 0.8 0.8])
            handles.dataClick = 0;
            handles.cameraClick = 0;
            handles.textureClick = 0;
            set([projData,camOverlay,projTexture],'BackgroundColor',[0.94 0.94 0.94])
            
            % Disable the active camera buttons
            set([camATog,camBTog,camCTog,camDTog,camGTog,dispwave_button,...
                play_button,stop_button,expmov_button],'Enable','off')
        end
    end

%% Texture Visualization Callback %%
    function projTexture_callback(~,~)
        if handles.textureClick == 0
            % Visualize membrane potential in 3D window
            axes(camG_scrn)
            trisurf(handles.cells,handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),handles.textProj,'LineStyle','none')
            set(camG_scrn,'Visible','off')
            colormap('gray')
            colorbar('off')
            % Get angles and set view
            az = str2double(get(az_edit,'String'));
            el = str2double(get(el_edit,'String'));
            view(az,el)
            axis equal
            
            % Make 2D screens just background
            cla(camA_scrn),cla(camB_scrn),cla(camC_scrn),cla(camD_scrn)
            for n = 1:4
                tmp = sprintf('axes(cam%s_scrn)',handles.camLabels(n));
                eval(tmp)
                image(handles.bgRGB{n})
                tmp = sprintf('set(cam%s_scrn,''XTick'',[],''YTick'',[],''ZTick'',[])',...
                    handles.camLabels(n));
                eval(tmp)
            end
            
            % Update handles
            handles.textureClick = 1;
            set(projTexture,'BackgroundColor',[0.8 0.8 0.8])
            handles.meshClick = 0;
            handles.cameraClick = 0;
            handles.dataClick = 0;
            set([triMesh,camOverlay,projData],'BackgroundColor',[0.94 0.94 0.94])
            
            % Disable the active camera buttons
            set([camATog,camBTog,camCTog,camDTog,camGTog,dispwave_button,...
                play_button,stop_button,expmov_button],'Enable','off')
            
            
        end
    end

%% Data Visualization Callback %%
    function projData_callback(~,~)
        if handles.dataClick == 0
            % Visualize membrane potential in 3D window
            axes(camG_scrn)
            if handles.phaseFlag == 1
                dataProj = handles.phaseMapGeo;
            else
                dataProj = handles.dataProj;
            end
            skel = find(dataProj(:,1) == 0);
            [skel,~] = ind2sub(size(dataProj),skel(:));
            skel = unique(skel);
            rows = find(dataProj(:,1) ~= 0);
            [rows,~] = ind2sub(size(dataProj),rows(:));
            rows = unique(rows);
            cells = handles.cells(rows(:),:);
            %         figure,trisurf(handles.cells(val,:),tri(:,1),tri(:,2),tri(:,3),zeros(sum(val),1))
            trisurf(cells,handles.pts(:,1),...
                handles.pts(:,2),handles.pts(:,3),dataProj(rows(:),handles.frame),...
                'LineStyle','none','Parent',camG_scrn);
            hold all
            trisurf(handles.cells(skel,:),handles.pts(:,1),handles.pts(:,2),...
                handles.pts(:,3),'FaceColor','none','LineWidth',0.5,'Parent',camG_scrn);
            hold off
            [mini,~] = min(dataProj(rows(:),handles.frame));
            [maxi,~] = max(dataProj(rows(:),handles.frame));
            caxis([mini maxi])
            %             trisurf(handles.cells,handles.pts(:,1),handles.pts(:,2),...
            %                 handles.pts(:,3),handles.dataProj(:,handles.frame),'LineStyle','none')
            set(camG_scrn,'Visible','off')
            colormap('jet')
            colorbar('off')
            % Get angles and set view
            az = str2double(get(az_edit,'String'));
            el = str2double(get(el_edit,'String'));
            view(az,el)
            axis equal
            
            % Set 2D screens with fluorescense data
            drawFrame(handles.cmosData,[],handles.frame)
            
            % Update handles
            handles.dataClick = 1;
            set(projData,'BackgroundColor',[0.8 0.8 0.8])
            handles.meshClick = 0;
            handles.cameraClick = 0;
            handles.textureClick = 0;
            set([triMesh,camOverlay,projTexture],'BackgroundColor',[0.94 0.94 0.94])
            
            % Enable the active camera buttons
            set([camATog,camBTog,camCTog,camDTog,camGTog,dispwave_button,...
                play_button,stop_button,expmov_button],'Enable','on')
        end
    end

%% 2D Mapping Functions %%
    function map2D_callback(~,~)
        h = msgbox('Preparing handles...');
        xyz = handles.centroids;
        tri = handles.pts;
        cells = handles.cells;
        val = handles.val2D;
        % val = apdMapGeo;
        %         pot = handles.dataProj;
        %         norm = handles.norms;
        
        % Create a z-axis rotation matrix for a 180 degree rotation
        Rz = [cos(pi) -sin(pi) 0;
            sin(pi) cos(pi) 0;
            0 0 1];
        % Apply to centroids and vertices
        xyz = (Rz*xyz')';
        tri = (Rz*tri')';
        
        % Remove 0's
        rm = find(val ~= 0);
        [rows,~] = ind2sub(size(val),rm(:));
        rows = unique(rows);
        %        skel = cells(row,:);
        val = val(rows(:),:);
        xyz = xyz(rows(:),:);
        cells = cells(rows(:),:);
        %        norm = norm(rm,:);
        
        
        % Remove all cells not part of the largest connected component
        delete(h);
        %         cd(handles.dir)
        %         fid=fopen(strcat(handles.currentfile,'_rmislands.mat'));
        %         if fid ~= -1
        %             fclose(fid);
        %             h = msgbox('Removed Islands Data Found! Loading Data...');
        %             vars = load(strcat(handles.currentfile,'_rmislands.mat'));
        %             rm = vars.rm;
        %             pause(2);
        %         else
        h = msgbox('Removing Islands...')
      % rm = removeIslands(cells);
        %             filename = char(strcat(handles.currentfile,'_rmislands'));
        %             % Create path to file
        %             movname = [handles.dir,'/',filename];
        %             % Save data
        %             save(movname,'rm');
        %             delete(h);
        %             h = msgbox('Islands removed. Results saved to file in data directory');
        %             pause(2);
        %         end
        %        skel = [skel; cells(rm(:,2)~=1,:)];
%         rows = find(rm(:,2) == 1);
%         [rows,~] = ind2sub(size(rows),rows(:));
%         rows = unique(rows);
%         rm = rm(rows(:),1);
%         val = val(rm(:),handles.frame);
%         xyz = xyz(rm(:),:);
%         cells = cells(rm(:),:);
        %       norm = norm(rm,:);
        maxCoord = max(max(xyz));
        xyz = xyz/maxCoord;
        
        maxPts = max(max(tri));
        tri = tri/maxPts;
        
        % Convert to spherical from cartesian
        r = sqrt(tri(:,1).^2+tri(:,2).^2+tri(:,3).^2);
        phi = atan2(tri(:,2),tri(:,1));
        theta = -1*(acos(tri(:,3)./r)-pi/2);
        
        % Convert to spherical from cartesian
        xyzR = sqrt(xyz(:,1).^2+xyz(:,2).^2+xyz(:,3).^2);
        xyzP = atan2(xyz(:,2),xyz(:,1));
        xyzT = -1*(acos(xyz(:,3)./xyzR)-pi/2);
        
        % Identify cells that have vertices that cross the map
        cellX = phi(cells);
        cellXDist = cellX(:,2)-cellX(:,1);
        cellXDist(:,2) = cellX(:,3)-cellX(:,1);
        cellXDist(:,3) = cellX(:,2)-cellX(:,3);
        cellXRemove = abs(cellXDist) > 4;
        cellXRemove = cellXRemove.*repmat((1:size(cellXRemove,1))',[1 3]);
        cellXRemove = unique(cellXRemove);
        cellXRemove = cellXRemove(2:end);
        
        cellM = cells;
        cellM(cellXRemove,:) = [];
        valM = val;
        valM(cellXRemove,:) = [];
        % % % cellThetaDistAve = mean(reshape(cellThetaDist,[size(cellThetaDist,1)*3 1]));
        % % % cellThetaDistStd = std(reshape(cellThetaDist,[size(cellThetaDist,1)*3 1]));
        [gridP,gridT] = meshgrid(-pi:pi/72:pi,-pi/2:pi/72:pi/2);
        V = griddata(xyzP,xyzT,val,gridP,gridT);
        gridR = griddata(xyzP,xyzT,xyzR,gridP,gridT);
        intX = gridR.*sin(gridT+pi/2).*cos(gridP+pi);
        delete(h);
        projOption = questdlg('Which projection would you like to use?','Projection Found',...
            'Hammer','Mercator','Hammer');
        switch projOption
            case 'Hammer'
                hammer(gridP,gridT,gridR,intX,V);
            case 'Mercator'
                mercator(phi,theta,cellM,valM,V)
        end
    end
%% Hammer Projection %%
    function hammer(gridP,gridT,gridR,intX,V)
        [hammerX,hammerY]=pr_hammer(gridP,gridT,gridR);
        figure
        surf(hammerX,hammerY,zeros(size(hammerX,1),size(hammerX,2)),V,'EdgeColor','none')
        view(0,90)
        colormap('jet')
        axis equal
        [value,~] = max(V(:));
        caxis([0 value])
        hold on
        for n = 1:4*3:size(intX,2)
            plot(hammerX(:,n),hammerY(:,n),'k')
        end
        for m = 1:4*3:size(intX,1)
            plot(hammerX(m,:),hammerY(m,:),'k')
        end
    end
%% Mercator Projection %%
    function mercator(phi,theta,cellM,valM,V)
        figure
        p = patch('Faces',cellM,'Vertices',[phi theta]);
        [value,~] = max(valM(:));
        caxis([0 value])
        set(gca,'CLim',[0 value])
        set(p,'FaceColor','flat',...
            'FaceVertexCData',valM,...
            'EdgeColor','none',...
            'CDataMapping','scaled')
        axis equal
        colormap('jet')
        set(gca,'TickDir','out','XLim',[-pi,pi],'XTick',[-pi -pi/2 0 pi/2 pi],...
            'YLim',[-pi/2,pi/2],'YTick',[-pi/2 0 pi/2])
    end
%% 3D View Updating Function %%
    function newView_callback(~,evd)
        % Grab the new view
        newView = round(evd.Axes.View);
        % Update handles
        handles.az = newView(1);
        handles.el = newView(2);
        % Update edit boxes
        set(az_edit,'String',num2str(newView(1)))
        set(el_edit,'String',num2str(newView(2)))
    end

%% Remove user specified region from mask %%
    function removeAtria_button_callback(~,~)
        ac = handles.activeCam;
        % Set Current Axes to one specified by Active Camera menu
        tmp = sprintf('set(f,''CurrentAxes'',cam%s_scrn)',handles.camLabels(ac));
        eval(tmp)
        %         % Select a point on the axes and grab x and y coordinates
        %         [i_temp,j_temp] = myginput(handles,1,'circle');
        BW = roipoly;
        % Save the mask
        if isempty(handles.ventMask{ac})
            handles.ventMask{ac} = BW;
        else
            handles.ventMask{ac} = (handles.ventMask{ac}+BW) ~= 0;
        end
        % Remove the selected points from the data matrix
        handles.cmosData{ac}(repmat(BW,[1 1 size(handles.cmosData{ac},3)])) = nan;
        currentframe = handles.frame;
        drawFrame(handles.cmosData,handles.dataProj,currentframe)
    end

%% Callback for overlaying the pacing spike onto the data %%
    function pacingTrace_callback(~,~)
        pt = get(pacingTrace,'Value');
        % Run function
        pacingTraceFunction(pt)
    end

%% Callback for overlaying the pacing spike onto the data %%
    function pacingTraceFunction(pt)
        if handles.phaseFlag == 1
            data = handles.phaseMap;
            dataProj = handles.phaseMapGeo;
        else
            data = handles.cmosData;
            dataProj = handles.dataProj;
        end
        % Clear current signal axes
        for n = 1:5
            tmp = sprintf('cla(signal_scrn%d)',n);
            eval(tmp)
        end
        % Grab the optical action potential traces
        ac = handles.activeCam;
        M = handles.M{ac};
        colax = 'bgmkc';
        if pt == 1
            handles.pacingTime = 0:1/(handles.Fs*handles.nRate):...
                length(handles.ecg)/(handles.Fs*handles.nRate)-1/(handles.Fs*handles.nRate);
            handles.pacedSignal = handles.ecg-mean(handles.ecg);
            handles.pacedSignal = handles.pacedSignal/max(handles.pacedSignal);
            for n = 1:size(M,1)
                % Grab appropriate data signal
                if ac == 5
                    signalData = dataProj(handles.pointCloudIndex(n),:);
                else
                    signalData = squeeze(data{ac}(M(n,2),M(n,1),:));
                end
                % Clear the axes of each signal
                tmp = sprintf('cla(signal_scrn%d)',n);
                eval(tmp)
                % Replot optical action potentials
                tmp = sprintf('plot(handles.time,signalData,colax(n),''LineWidth'',2,''Parent'',signal_scrn%d)',n);
                eval(tmp)
                tmp = sprintf('hold(signal_scrn%d,''on'')',n);
                eval(tmp)
                % Overlay with pacing spike
                tmp = sprintf('plot(handles.pacingTime,handles.pacedSignal,''Color'',[169/255 169/255 169/255],''LineWidth'',2,''Parent'',signal_scrn%d)',n);
                eval(tmp)
                if n < 5
                    tmp = sprintf('set(signal_scrn%d,''XTick'',[])',n);
                    eval(tmp)
                end
            end
        else
            for n = 1:size(M,1)
                % Clear the axes of each signal
                tmp = sprintf('cla(signal_scrn%d)',n);
                eval(tmp)
                % Replot optical action potentials
                %                 disp(n)
                if ac == 5
                    signalData = dataProj(handles.pointCloudIndex(n),:);
                else
                    signalData = squeeze(data{ac}(M(n,2),M(n,1),:));
                end
                tmp = sprintf('plot(handles.time,signalData,colax(n),''LineWidth'',2,''Parent'',signal_scrn%d)',n);
                eval(tmp)
            end
        end
    end

%% Edit min box for colormap %%
    function minMap_edit_callback(~,~)
        
    end

%% Edit max box for colormap %%
    function maxMap_edit_callback(~,~)
        
    end

%% Get Keyboard Press %%
    function keyPressed(src, e)
        if(strcmp(get(shift_up, 'Enable'),'on') == 1)
            switch e.Key
                case 'rightarrow'
                    shift_right_callback(shift_right,e)
                case 'leftarrow'
                    shift_left_callback(shift_left,e)
                case 'uparrow'
                    shift_up_callback(shift_up,e)
                case 'downarrow'
                    shift_down_callback(shift_down,e)
            end
        end
    end
end
