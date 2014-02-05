function varargout = Universal_GR_12(varargin)
% UNIVERSAL_GR_12 M-file for Universal_GR_12.fig
%      UNIVERSAL_GR_12, by itself, creates a new UNIVERSAL_GR_12 or raises the existing
%      singleton*.
%
%      H = UNIVERSAL_GR_12 returns the handle to a new UNIVERSAL_GR_12 or the handle to
%      the existing singleton*.
%
%      UNIVERSAL_GR_12('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNIVERSAL_GR_12.M with the given input arguments.
%
%      UNIVERSAL_GR_12('Property','Value',...) creates a new UNIVERSAL_GR_12 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Universal_GR_12_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Universal_GR_12_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Universal_GR_12

% Last Modified by GUIDE v2.5 16-Jan-2014 10:27:47

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Universal_GR_12_OpeningFcn, ...
    'gui_OutputFcn',  @Universal_GR_12_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Universal_GR_12 is made visible.
function Universal_GR_12_OpeningFcn(hObject, eventdata, handles, varargin)
global CaSignal % ROIinfo ICA_ROIs
% Choose default command line output for Universal_GR_12
handles.output = hObject;
set (handles.primProc,'Value',1);
set (handles.secProc,'Value',0);

usrpth = '~/Documents/MATLAB'; usrpth = usrpth(1:end-1);
if exist([usrpth filesep 'gr_Universal.info'],'file')
    load([usrpth filesep 'gr_UNiversal.info'], '-mat');
    set(handles.DataPathEdit, 'String',info.DataPath);
    set(handles.AnimalNameEdit, 'String', info.AnimalName);
    set(handles.ExpDate,'String',info.ExpDate);
    set(handles.SessionName, 'String',info.SessionName);
    
    if isfield(info, 'SoloDataPath')
        set(handles.SoloDataPath, 'String', info.SoloDataPath);
        set(handles.SoloDataFileName, 'String', info.SoloDataFileName);
        set(handles.SoloSessionID, 'String', info.SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', info.SoloStartTrialNo);
        set(handles.SoloEndTrialNo, 'String', info.SoloEndTrialNo);
    end
    
    
else
    set(handles.DataPathEdit, 'String', '/Volumes/GR_Data_02/Data/');
    set(handles.SoloDataPath, 'String', '/Volumes/GR_Data_02/Data/');
    set(handles.baseDataPath, 'String', '/Volumes/GR_Data_02/Data/');
end
set(handles.ephusDataPath, 'String', '/Volumes/GR_Data_02/Data/');

% Open and Display section
set(handles.dispModeGreen, 'Value', 1);
set(handles.dispModeRed, 'Value', 0);
set(handles.dispModeImageInfoButton, 'Value', 0);
set(handles.dispModeWithROI, 'Value', 1);
% set(handles.LUTminEdit, 'Value', 0);
% set(handles.LUTmaxEdit, 'Value', 500);
% set(handles.LUTminSlider, 'Value', 0);
% set(handles.LUTmaxSlider, 'Value', 0.5);
set(handles.CurrentImageFilenameText, 'String', 'Current Image Filename');
% ROI section
set(handles.nROIsText, 'String', '0');
set(handles.CurrentROINoEdit, 'String', '1');
set(handles.ROITypeMenu, 'Value', 1);
% Analysis mode
set(handles.AnalysisModeDeltaFF, 'Value', 1);
set(handles.AnalysisModeBGsub, 'Value', 0);
set(handles.batchStartTrial, 'String', '1');
set(handles.batchEndTrial, 'String', '1');
set(handles.ROI_modify_button, 'Value', 0);
set(handles.CurrentFrameNoEdit,'String',1);
set(handles.nogopos,'String','18');
set(handles.gopos,'String','0 1.5 3 4.5 6 7.5');
set(handles.SoloStartTrialNo,'Value',1);
set(handles.SoloEndTrialNo,'Value',1);
set(handles.CaSignalrois,'String','0');
set(handles.numblocks,'Value',2);


CaSignal.CaTrials = struct([]);
CaSignal.ROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'BGpos',[],...
    'BGmask', [], 'Method','');
% CaSignal.ICA_ROIs = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'Method','ICA');
CaSignal.ImageArray = [];
CaSignal.nFrames = 0;
% handles.userdata.CaTrials = [];
CaSignal.h_info_fig = NaN;
CaSignal.FrameNum = 1;
CaSignal.imSize = [];
CaSignal.h_img = NaN;
CaSignal.Scale = [0 500];
% ROIinfo = {};
% ICA_ROIs = struct;
CaSignal.ROIplot = NaN;
CaSignal.avgCorrCoef_trials = [];
CaSignal.CorrMapTrials = [];
CaSignal.CorrMapROINo = [];
CaSignal.AspectRatio_mode = 'Square';
CaSignal.ICA_figs = nan(1,2);
handles.SoloStartTrial=1;
handles.SoloEndTrial=1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Universal_GR_12 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Universal_GR_12_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function CaTrial = init_CaTrial(filename, TrialNo, header)
% Initialize the struct data for the current trial
CaTrial.DataPath = pwd;
CaTrial.FileName = filename;
CaTrial.FileName_prefix = filename(1:end-7);

CaTrial.TrialNo = TrialNo;
CaTrial.DaqInfo = header;
if isfield(header, 'acq')
    CaTrial.nFrames = header.acq.numberOfFrames;
    CaTrial.FrameTime = header.acq.msPerLine*header.acq.linesPerFrame;
else
    CaTrial.nFrames = header.n_frame;
    if(~isempty(header.SI4.fastZPeriod)&&(header.SI4.fastZPeriod<1))
        CaTrial.FrameTime = header.SI4.fastZPeriod;
    elseif(~isempty(header.SI4.scanFramePeriod)&&(header.SI4.scanFramePeriod<1))
        CaTrial.FrameTime = header.SI4.scanFramePeriod;
    end
end
% % % if   CaTrial.FrameTime< 1 % some earlier version of ScanImage use sec as unit for msPerLine
% % %     CaTrial.FrameTime = CaTrial.FrameTime*1000;
% % % end
CaTrial.nROIs = 0;
CaTrial.BGmask = []; % Logical matrix for background ROI
CaTrial.AnimalName = '';
CaTrial.ExpDate = '';
CaTrial.SessionName = '';
CaTrial.dff = [];
CaTrial.f_raw = [];
% CaTrial.meanImage = [];
CaTrial.RegTargetFrNo = [];
CaTrial.ROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'Method','');
CaTrial.SoloDataPath = '';
CaTrial.SoloFileName = '';
CaTrial.SoloSessionName = '';
CaTrial.SoloTrialNo = [];
CaTrial.SoloStartTrialNo = [];
CaTrial.SoloEndTrialNo = [];
CaTrial.behavTrial = [];
% CaTrial.ROIType = '';

% --- Executes on button press in open_image_file_button.
function open_image_file_button_Callback(hObject, eventdata, handles, filename)

global CaSignal % ROIinfo ICA_ROIs

datapath = get(handles.DataPathEdit,'String');
if exist(datapath, 'dir')
    cd(datapath);
else
    clear     warning([datapath ' not exist!'])
    if exist('/Volumes/GR_Data_01/Data','dir')
        cd('/Volumes/GR_Data_01/Data');
    end
end;
if ~exist('filename', 'var')
    [filename, pathName] = uigetfile('*.tif', 'Load Image File');
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    cd(pathName);
    FileName_prefix = filename(1:end-7);
    CaSignal.data_files = dir([FileName_prefix '*.tif']);
    CaSignal.data_file_names = {};
    for i = 1:length(CaSignal.data_files)
        CaSignal.data_file_names{i} = CaSignal.data_files(i).name;
    end;
end
datapath = pwd;
set(handles.DataPathEdit,'String',datapath);

FileName_prefix = filename(1:end-7);

TrialNo = find(strcmp(filename, CaSignal.data_file_names));
set(handles.CurrentTrialNo,'String', int2str(TrialNo));
disp(['Loading image file ' filename ' ...']);
set(handles.msgBox, 'String', ['Loading image file ' filename ' ...']);
[im, header] = imread_multi_GR(filename, 'g');
% t_elapsed = toc;
set(handles.msgBox, 'String', ['Loaded file ' filename]);
info = imfinfo(filename);
if isfield(info(1), 'ImageDescription')
    CaSignal.ImageDescription = info(1).ImageDescription; % used by Turboreg
else
    CaSignal.ImageDescription = '';
end
CaSignal.ImageArray = im;
CaSignal.imSize = size(im);
if ~isempty(CaSignal.CaTrials)
    if length(CaSignal.CaTrials)<TrialNo || isempty(CaSignal.CaTrials(TrialNo).FileName)
        CaSignal.CaTrials(TrialNo) = init_CaTrial(filename, TrialNo, header);
    end
    if ~strcmp(CaSignal.CaTrials(TrialNo).FileName_prefix, FileName_prefix)
        CaSignal.CaTrials_INIT = 1;
    else
        CaSignal.CaTrials_INIT = 0;
    end
else
    CaSignal.CaTrials_INIT = 1;
end

% Now we are in data file path. Since analysis results are saved in a separate
% folder, we need to find that folder in order to laod or save analysis
% results. If that folder does not exist, a new folder will be created.

CaSignal.results_path = strrep(datapath,[filesep 'data'],[filesep 'results']);
if ~exist(CaSignal.results_path,'dir')
    mkdir(CaSignal.results_path);
    disp('results dir not exists! A new folder created!');
    disp(CaSignal.results_path);
end

CaSignal.results_fn = [CaSignal.results_path filesep 'CaSignal_CaTrials_' FileName_prefix '.mat'];
CaSignal.results_roiinfo = [CaSignal.results_path filesep 'ROIinfo_', FileName_prefix '.mat'];

if CaSignal.CaTrials_INIT == 1
    CaSignal.CaTrials = []; % ROIinfo = {};
    if exist(CaSignal.results_fn,'file')
        load(CaSignal.results_fn, '-mat');
        CaSignal.CaTrials = CaTrials;
    else
        A = init_CaTrial(filename, TrialNo, header);
        A(TrialNo) = A;
        if TrialNo ~= 1
            names = fieldnames(A);
            for i = 1:length(names)
                A(1).(names{i})=[];
            end
        end
        CaSignal.CaTrials = A;
    end
    
    if exist(CaSignal.results_roiinfo,'file')
        load(CaSignal.results_roiinfo, '-mat');
        if iscell(ROIinfo)
            f1 = fieldnames(ROIinfo{TrialNo}); f2 = fieldnames(CaSignal.ROIinfo);
            for i = 1:length(ROIinfo)
                for j = 1:length(f1),
                    CaSignal.ROIinfo(i).(f2{strcmpi(f2,f1{j})}) = ROIinfo{i}.(f1{j});
                end
            end
        else
            CaSignal.ROIinfo = ROIinfo;
        end
    end
else
    
    notansferROIinfo =get(handles.donottransferROIinfo,'Value');
    if ((notansferROIinfo)&& ~isempty(CaSignal.ROIinfo))
        CaSignal.ROIinfo=CaSignal.ROIinfo;
    else
        import_ROIinfo_from_trial_Callback(handles.import_ROIinfo_from_trial, eventdata, handles);
    end
end

if exist([CaSignal.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat'],'file')
    load([CaSignal.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat']);
    CaSignal.dftreg_shift = shift;
else
    CaSignal.dftreg_shift = [];
end

% Collect info to be displayed in a separate figure

% if get(handles.dispModeImageInfoButton,'Value') == 1
if isfield(header,'acq')
    CaSignal.info_disp = {sprintf('numFramesPerTrial: %d', header.acq.numberOfFrames), ...
        ['Zoom: ' num2str(header.acq.zoomFactor)],...
        ['numOfChannels: ' num2str(header.acq.numberOfChannelsAcquire)],...
        sprintf('ImageDimXY: %d,  %d', header.acq.pixelsPerLine, header.acq.linesPerFrame),...
        sprintf('Frame Rate: %d', header.acq.frameRate), ...
        ['msPerLine: ' num2str(header.acq.msPerLine)],...
        ['fillFraction: ' num2str(header.acq.fillFraction)],...
        ['motor_absX: ' num2str(header.motor.absXPosition)],...
        ['motor_absY: ' num2str(header.motor.absYPosition)],...
        ['motor_absZ: ' num2str(header.motor.absZPosition)],...
        ['num_zSlice: ' num2str(header.acq.numberOfZSlices)],...
        ['zStep: ' num2str(header.acq.zStepSize)] ...
        ['triggerTime: ' header.internal.triggerTimeString]...
        };
else
    CaSignal.info_disp = [];
end
%     dispModeImageInfoButton_Callback(hObject, eventdata, handles)
% end;
%% Initialize UI values
set(handles.TotTrialNum, 'String', int2str(length(CaSignal.data_file_names)));
set(handles.CurrentImageFilenameText, 'String',  filename);
if CaSignal.CaTrials_INIT == 1
    set(handles.DataPathEdit, 'String', pwd);
    set(handles.AnimalNameEdit, 'String', CaSignal.CaTrials(TrialNo).AnimalName);
    set(handles.ExpDate,'String',CaSignal.CaTrials(TrialNo).ExpDate);
    set(handles.SessionName, 'String',CaSignal.CaTrials(TrialNo).SessionName);
    if isfield(CaSignal.CaTrials(TrialNo), 'SoloDataFileName')
        set(handles.SoloDataPath, 'String', CaSignal.CaTrials(TrialNo).SoloDataPath);
        set(handles.SoloDataFileName, 'String', CaSignal.CaTrials(TrialNo).SoloDataFileName);
        set(handles.SoloSessionID, 'String', CaSignal.CaTrials(TrialNo).SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', num2str(CaSignal.CaTrials(TrialNo).SoloStartTrialNo));
        set(handles.SoloEndTrialNo, 'String', num2str(CaSignal.CaTrials(TrialNo).SoloEndTrialNo));
    end
end

nFrames = size(im, 3);
set(handles.FrameSlider, 'SliderStep', [1/nFrames 1/nFrames]);
set(handles.FrameSlider, 'Value', 1/nFrames);
if ~isempty(CaSignal.ROIinfo)
    set(handles.nROIsText, 'String', int2str(length(CaSignal.ROIinfo(TrialNo).ROIpos)));
end
CaSignal.nFrames = nFrames;
set(handles.batchPrefixEdit, 'String', FileName_prefix);
%    handles = get_exp_info(hObject, eventdata, handles);
% CaSignal.CaTrials(TrialNo).meanImage = mean(im,3);

% update target info for TurboReg
% setTargetCurrentFrame_Callback(handles.setTargetCurrentFrame, eventdata, handles);
% setTargetMaxDelta_Callback(handles.setTargetMaxDelta, eventdata,handles);
% setTargetMean_Callback(handles.setTargetMaxDelta, eventdata, handles);

CaSignal.avgCorrCoef_trials = [];

% The trialNo to load ROIinfo from
notansferROIinfo =get(handles.donottransferROIinfo,'Value');
if ((notansferROIinfo)&& ~isempty(CaSignal.ROIinfo))
    TrialNo_load = TrialNo;
else
    TrialNo_load = str2double(get(handles.import_ROIinfo_from_trial,'String'));
end
if TrialNo_load > 0 && length(CaSignal.ROIinfo)>= TrialNo_load
    CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo(TrialNo_load);
    nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
    CaSignal.CaTrials(TrialNo).nROIs = nROIs;
    set(handles.nROIsText, 'String', num2str(nROIs));
end


handles = update_image_axes(handles,im);
update_projection_images(handles);
% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, handles.figure1, eventdata, handles});
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%% Start of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = get_exp_info(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
filename = CaSignal.data_file_names{TrialNo};

if ~isempty(CaSignal.CaTrials(TrialNo).ExpDate)
    ExpDate = CaSignal.CaTrials(TrialNo).ExpDate;
    set(handles.ExpDate, 'String', ExpDate);
else
    CaSignal.CaTrials(TrialNo).ExpDate = get(handles.ExpDate, 'String');
end;


if ~isempty(CaSignal.CaTrials(TrialNo).AnimalName)
    AnimalName = CaSignal.CaTrials(TrialNo).AnimalName;
    set(handles.AnimalNameEdit, 'String', AnimalName);
else
    CaSignal.CaTrials(TrialNo).AnimalName = get(handles.AnimalNameEdit, 'String');
end


if ~isempty(CaSignal.CaTrials(TrialNo).SessionName)
    SessionName = CaSignal.CaTrials(TrialNo).SessionName;
    set(handles.SessionName, 'String', SessionName);
else
    CaSignal.CaTrials(TrialNo).SessionName = get(handles.SessionName, 'String');
end



function handles = update_image_axes(handles,varargin)
% update image display, called by most of call back functions
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
LUTmin = str2double(get(handles.LUTminEdit,'String'));
LUTmax = str2double(get(handles.LUTmaxEdit,'String'));
sc = [LUTmin LUTmax];
cmap = 'gray';
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
if fr > CaSignal.nFrames && CaSignal.nFrames > 0
    fr = CaSignal.nFrames;
end
if ~isempty(varargin)
    CaSignal.ImageArray = varargin{1};
end
CaSignal.Scale = sc;
CaSignal.FrameNum = fr;

if get(handles.dispCorrMapTrials,'Value')==1
    im = CaSignal.CorrMapTrials;
    %     cmap = 'jet';
    sc = [0 max(im(:))];
else
    im = CaSignal.ImageArray;
end;
im_size = size(im);
switch CaSignal.AspectRatio_mode
    case 'Square'
        s1 = im_size(2)/max(im_size(1:2));
        s2 = im_size(1)/max(im_size(1:2));
        asp_ratio = [s1 s2 1];
    case 'Image'
        asp_ratio = [1 1 1];
end
axes(handles.Image_disp_axes);
% hold on;
% if (isfield(CaSignal, 'h_img')&& ishandle(CaSignal.h_img))
%     delete(CaSignal.h_img);
% end;
% CaSignal.h_img = imagesc(im(:,:,fr), sc);
CaSignal.h_img = imshow(im(:,:,fr), sc);
set(handles.Image_disp_axes, 'DataAspectRatio', asp_ratio);  %'XTickLabel','','YTickLabel','');
time_str = sprintf('%.3f  sec',CaSignal.CaTrials(1).FrameTime*fr/1000);
set(handles.frame_time_disp, 'String', time_str);
% colormap(gray);
if get(handles.dispModeWithROI,'Value') == 1 && length(CaSignal.ROIinfo) >= TrialNo && ~isempty(CaSignal.ROIinfo(TrialNo).ROIpos)
    update_ROI_plot(handles);
end

% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, hObject, eventdata, handles});

guidata(handles.figure1, handles);


function update_ROI_plot(handles)
global CaSignal % ROIinfo ICA_ROIs

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));

if get(handles.dispModeWithROI,'Value') == 1
    axes(handles.Image_disp_axes);
    % delete existing ROI plots
    if any(ishandle(CaSignal.ROIplot))
        try
            delete(CaSignal.ROIplot(ishandle(CaSignal.ROIplot)));
        end
    end
    CaSignal.ROIplot = plot_ROIs(handles);
end
if isfield(CaSignal.ROIinfo, 'BGpos') && ~isempty(CaSignal.ROIinfo(TrialNo).BGpos)
    BGpos = CaSignal.ROIinfo(TrialNo).BGpos;
    CaSignal.BGplot = line(BGpos(:,1),BGpos(:,2), 'Color', 'b', 'LineWidth', 2);
end
% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, handles.figure1, eventdata, handles});
guidata(handles.figure1,handles);

function h_roi_plots = plot_ROIs(handles)
%%
global CaSignal % ROIinfo ICA_ROIs
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
h_roi_plots = [];
roi_pos = {};
%     if get(handles.ICA_ROI_anal, 'Value') == 1 && isfield(ICA_ROIs, 'ROIpos');
%         roi_pos = ICA_ROIs.ROIpos;
%     elseif length(ROIinfo) >= TrialNo && ~isempty(ROIinfo{TrialNo})
%
%         roi_pos = ROIinfo{TrialNo}.ROIpos;
%     end
if length(CaSignal.ROIinfo) >= TrialNo
    roi_pos = CaSignal.ROIinfo(TrialNo).ROIpos;
end
for i = 1:length(roi_pos) % num ROIs
    if i == CurrentROINo
        lw = 1.2;
        col = [.6 .5 .1];
    else
        lw = .5;
        col = [0.8 0 0];
    end
    if ~isempty(roi_pos{i})
        %             if length(CaSignal.ROIplot)>=i & ~isempty(CaSignal.ROIplot(i))...
        %                     & ishandle(CaSignal.ROIplot(i))
        %                 delete(CaSignal.ROIplot(i));
        %             end
        h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', col, 'LineWidth', lw);
        text(median(roi_pos{i}(:,1)+5), median(roi_pos{i}(:,2)+5), num2str(i),'Color',[0 .7 0],'FontSize',12);
        set(h_roi_plots(i), 'LineWidth', lw);
    end
end

function handles = update_projection_images(handles)
global CaSignal % ROIinfo ICA_ROIs

if get(handles.dispMeanMode, 'Value')==1
    if ~isfield(CaSignal, 'h_mean_fig') || ~ishandle(CaSignal.h_mean_fig)
        CaSignal.h_mean_fig = figure('Name','Mean Image','Position',[960   500   480   480]);
    else
        figure(CaSignal.h_mean_fig)
    end
    if get(handles.dispCorrMapTrials,'Value')==1
        mean_im = CaSignal.CorrMapMean;
        sc = [0 max(mean_im(:))];
        colormap('jet');
    else
        im = CaSignal.ImageArray;
        sc = CaSignal.Scale;
        mean_im = mean(im,3);
        colormap(gray);
    end
    imagesc(mean_im, sc);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(handles);
end
if get(handles.dispMaxDelta,'Value')==1
    if ~isfield(CaSignal, 'h_maxDelta_fig') || ~ishandle(CaSignal.h_maxDelta_fig)
        CaSignal.h_maxDelta_fig = figure('Name','max Delta Image','Position',[960   40   480   480]);
    else
        figure(CaSignal.h_maxDelta_fig);
    end
    im = CaSignal.ImageArray;
    sc = CaSignal.Scale;
    mean_im = uint16(mean(im,3));
    im = im_mov_avg(im,5);
    max_im = max(im,[],3);
    CaSignal.MaxDelta = max_im - mean_im;
    imagesc(CaSignal.MaxDelta, sc);
    colormap(gray);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    
    update_projection_image_ROIs(handles);
end
if get(handles.dispMaxMode,'Value')==1
    if ~isfield(CaSignal, 'h_max_fig') || ~ishandle(CaSignal.h_max_fig)
        CaSignal.h_max_fig = figure('Name','Max Projection Image','Position',[960   180   480   480]);
    else
        figure(CaSignal.h_max_fig)
    end
    im = CaSignal.ImageArray;
    sc = CaSignal.Scale;
    im = im_mov_avg(im,5);
    max_im = max(im,[],3);
    imagesc(max_im, sc);
    colormap(gray);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(handles);
end
guidata(handles.figure1,handles);

% update ROI plotting in projecting image figure, called only by updata_projection image
function update_projection_image_ROIs(handles)
% global CaSignal ROIinfo ICA_ROIs
if get(handles.dispModeWithROI,'Value') == 1
    plot_ROIs(handles);
end

function figScroll(src,evnt, hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% callback function for mouse scroll
%
im = CaSignal.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit, 'String'));
sc = CaSignal.Scale;
nFrames = CaSignal.nFrames;
% axes(handles.Image_disp_axes);
if evnt.VerticalScrollCount > 0
    if fr < nFrames
        fr = fr + 1;
    end
    
elseif evnt.VerticalScrollCount < 0
    if fr > 1
        fr = fr - 1;
    end
end

set(handles.FrameSlider,'Value', fr/nFrames);

CaSignal.FrameNum = fr;
set(handles.CurrentFrameNoEdit, 'String', num2str(fr));

CaSignal.h_img = imagesc(im(:,:,fr), sc);
colormap(gray);

handles = update_image_axes(handles);

% Update handles structure
% guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% End of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%


function dispModeWithROI_Callback(hObject, eventdata, handles)
value = get(handles.dispModeWithROI,'Value');
handles = update_image_axes(handles);
handles = update_projection_images(handles);

function DataPathEdit_Callback(hObject, eventdata, handles)
handles.datapath = get(hObject, 'String');
guidata(hObject, handles);

function DataPathEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_add_Callback(hObject, eventdata, handles)

% global CaSignal % ROIinfo ICA_ROIs
nROIs = str2num(get(handles.nROIsText, 'String'));
nROIs = nROIs + 1;
set(handles.nROIsText, 'String', num2str(nROIs));

CurrentROINo = get(handles.CurrentROINoEdit,'String');
% if strcmp(CurrentROINo, '0')
%     set(handles.CurrentROINoEdit,'String', '1');
% end;
% Use this instead: automatically go to the last ROI added.
set(handles.CurrentROINoEdit,'String', num2str(nROIs));
guidata(hObject, handles);


function ROI_del_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
if CurrentROINo > 0
    if length(CaSignal.ROIplot) >= CurrentROINo && ishandle(CaSignal.ROIplot(CurrentROINo))
        try
            delete(CaSignal.ROIplot(CurrentROINo))
            CaSignal.ROIplot(CurrentROINo)=[];
        end
    end
    %     if get(handles.ICA_ROI_anal,'Value') ==1 &&  length(ICA_ROIs.ROIpos) >= CurrentROINo
    %         ICA_ROIs.ROIpos(CurrentROINo) = [];
    %         ICA_ROIs.ROIMask(CurrentROINo) = [];
    %         try
    %         ICA_ROIs.ROIType(CurrentROINo) = [];
    %         end
    %     elseif length(ROIinfo{TrialNo}.ROIpos(CurrentROINo)) >= CurrentROINo
    %         ROIinfo{TrialNo}.ROIpos(CurrentROINo) = [];
    %         ROIinfo{TrialNo}.ROIMask(CurrentROINo) = [];
    %         ROIinfo{TrialNo}.ROIType(CurrentROINo) = [];
    %         CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo).nROIs - 1;
    %         CaSignal.CaTrials(TrialNo).ROIinfo = ROIinfo{TrialNo};
    %     end
    CaSignal.ROIinfo(TrialNo).ROIpos(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).ROImask(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).ROItype(CurrentROINo) = [];
    CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo).nROIs - 1;
    CaSignal.CaTrials(TrialNo).ROIinfo = CaSignal.ROIinfo(TrialNo);
    set(handles.nROIsText, 'String', num2str(CaSignal.CaTrials(TrialNo).nROIs));
    set(handles.CurrentROINoEdit,'String', int2str(CurrentROINo - 1));
    % TotROI = get(handles.nROIsText, 'String');
    % if strcmp(TotROI, '0');
    %     set(handles.CurrentROINoEdit,'String', '0');
    % end
    update_ROI_plot(handles);
    update_ROI_numbers(handles);
end
guidata(hObject, handles);



function update_ROI_numbers(handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'string'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
% if get(handles.ICA_ROI_anal,'value') ==1
%     nd = cellfun(@(x) isempty(x), ICA_ROIs.ROIpos);
%     try
%         ICA_ROIs.ROIpos(nd) = [];
%         ICA_ROIs.ROIMask(nd) = [];
%         ICA_ROIs.ROIType(nd) = [];
%     end
%     nROIs = length(ICA_ROIs.ROIpos);
% else
%     for i = 1:length(ROIinfo{TrialNo}.ROIpos)
%         if isempty(ROIinfo{TrialNo}.ROIpos{i})
%             ROIinfo{TrialNo}.ROIpos(i) = [];
%             ROIinfo{TrialNo}.ROIMask(i) = [];
%             ROIinfo{TrialNo}.ROIType(i) = [];
%         end
%     end
%     nROIs = length(ROIinfo{TrialNo}.ROIpos);
% end
for i = 1:length(CaSignal.ROIinfo(TrialNo).ROIpos)
    if isempty(CaSignal.ROIinfo(TrialNo).ROIpos{i})
        CaSignal.ROIinfo(TrialNo).ROIpos(i) = [];
        CaSignal.ROIinfo(TrialNo).ROImask(i) = [];
        CaSignal.ROIinfo(TrialNo).ROItype(i) = [];
    end
end
nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
set(handles.nROIsText, 'String', num2str(nROIs));
if CurrentROINo > nROIs
    CurrentROINo = nROIs;
elseif CurrentROINo < 1
    CurrentROINo = 1;
end
set(handles.CurrentROINoEdit, 'String', num2str(CurrentROINo));



function ROI_pre_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% update_ROI_numbers(handles);
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo - 1;
if CurrentROINo <= 0
    CurrentROINo = 1;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
ROIType_str = CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo};
if ~isempty(ROIType_str)
    ROIType_num = find(strcmp(ROIType_str, str_menu));
    set(handles.ROITypeMenu,'Value', ROIType_num);
else
    ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
    CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType_str;
end
% axes(handles.Image_disp_axes);
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);



function ROI_next_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% update_ROI_numbers(handles);
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo + 1;
if CurrentROINo > str2double(get(handles.nROIsText,'String'))
    CurrentROINo = str2double(get(handles.nROIsText,'String')) ;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
if length(CaSignal.ROIinfo(TrialNo).ROItype)>= CurrentROINo
    % ~isempty(ROIinfo{TrialNo}.ROIType{CurrentROINo})
    
    ROIType_str = CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo};
    if ~isempty(ROIType_str)
        ROIType_num = find(strcmp(ROIType_str, str_menu));
        set(handles.ROITypeMenu,'Value', ROIType_num);
    else
        ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
        CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType_str;
    end
else
    CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = str_menu{get(handles.ROITypeMenu,'Value')};
end
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);


function ROI_del_all_Callback(hObject, eventdata, handles)


function CurrentROINoEdit_Callback(hObject, eventdata, handles)
update_ROI_plot(handles);
guidata(hObject, handles);


function CurrentROINoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_set_poly_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
str_menu = get(handles.ROITypeMenu,'String');
ROIType = str_menu{get(handles.ROITypeMenu,'Value')};
% ROI_updated_flag = 0; % to determine if update the trial No of ROI updating.
%% Draw an ROI after mouse press
waitforbuttonpress;
% define the way of drawing, freehand or ploygon
if get(handles.ROI_draw_freehand, 'Value') == 1
    draw = @imfreehand;
elseif get(handles.ROI_draw_poly, 'Value') == 1;
    draw = @impoly;
end
h_roi = feval(draw);
finish_drawing = 0;
while finish_drawing == 0
    choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
    switch choice
        case'Yes',
            pos = h_roi.getPosition;
            line(pos(:,1), pos(:,2),'color','g')
            BW = createMask(h_roi);
            delete(h_roi);
            finish_drawing = 1;
            %             ROI_updated_flag = 1;
        case'Re-draw'
            delete(h_roi);
            h_roi = feval(draw); finish_drawing = 0;
        case'Cancel',
            delete(h_roi); finish_drawing = 1;
            %             ROI_updated_flag = 0;
            return
    end
end

CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo} = pos;
CaSignal.ROIinfo(TrialNo).ROImask{CurrentROINo} = BW;
CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType;
CaSignal.CaTrials(TrialNo).nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);

set(handles.import_ROIinfo_from_trial, 'String', num2str(TrialNo));

if get(handles.ICA_ROI_anal,'Value') == 1
    CaSignal.ROIinfo(TrialNo).Method = 'ICA';
    CaSignal.rois_by_IC{CaSignal.currentIC} = [CaSignal.rois_by_IC{CaSignal.currentIC}  CurrentROINo];
    for jj = 1:length(CaSignal.ICA_figs)
        if ishandle(CaSignal.ICA_figs(jj))
            figure(CaSignal.ICA_figs(jj)),
            plot_ROIs(handles);
        end
    end
else
    
end
set(handles.nROIsText,'String', num2str(length(CaSignal.ROIinfo(TrialNo).ROIpos)));
axes(handles.Image_disp_axes);
if length(CaSignal.ROIplot) >= CurrentROINo
    if ishandle(CaSignal.ROIplot(CurrentROINo))
        delete(CaSignal.ROIplot(CurrentROINo));
    else
        CaSignal.ROIplot(CurrentROINo) = [];
    end
end
guidata(hObject, handles);
%CaSignal.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
update_ROI_plot(handles);
update_projection_images(handles);
ROITypeMenu_Callback(hObject, eventdata, handles);
guidata(hObject, handles);



function ROI_modify_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
pos = CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo};
h_axes = handles.Image_disp_axes;

if get(hObject, 'Value')==1
    CaSignal.current_poly_obj = impoly(h_axes, pos);
elseif get(hObject, 'Value')== 0
    if isa(CaSignal.current_poly_obj, 'imroi')
        pos = getPosition(CaSignal.current_poly_obj);
        BW = createMask(CaSignal.current_poly_obj);
        CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo} = pos;
        CaSignal.ROIinfo(TrialNo).ROImask{CurrentROINo} = BW;
        axes(h_axes);
        delete(CaSignal.current_poly_obj); % delete polygon object
        if ishandle(CaSignal.ROIplot(CurrentROINo))
            delete(CaSignal.ROIplot(CurrentROINo));
        end
        CaSignal.ROIplot(CurrentROINo) = [];
        % CaSignal.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
        update_ROI_plot(handles);
        handles = update_projection_images(handles);
    end;
end;
guidata(hObject, handles);

% --- Executes on button press in import_ROIinfo_from_file.
function import_ROIinfo_from_file_Callback(hObject, eventdata, handles)

choice = questdlg('Import ROIinfo from different file/session?', 'Import ROIs', 'Yes','No','No');
switch choice
    case 'Yes'
        [fn, pth] = uigetfile('*.mat');
        r = load([pth filesep fn]);
        ROIinfo = r.ROIinfo(1);
    case 'No'
        return
end
import_ROIinfo(ROIinfo, handles);


function import_ROIinfo_from_trial_Callback(hObject, eventdata, handles)
% get ROIinfo from the specified trial, and call import_ROIinfo function
global CaSignal

notansferROIinfo =get(handles.donottransferROIinfo,'Value');
if ((notansferROIinfo)&& ~isempty(CaSignal.ROIinfo))
    disp('Not transfering ROIinfo because donottranfer flag is on')
    return
end

% The trialNo to load ROIinfo from
TrialNo_load = str2double(get(handles.import_ROIinfo_from_trial,'String'));
if ~isempty(CaSignal.ROIinfo)
    ROIinfo = CaSignal.ROIinfo(TrialNo_load);
    import_ROIinfo(ROIinfo, handles);% getROIinfoButton_Callback(hObject, eventdata, handles)
else
    warning('No ROIs specified!');
end

function import_ROIinfo(ROIinfo, handles)
% update the ROIs of the current trial with the input "ROIinfo".
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));

FileName_prefix = CaSignal.CaTrials(TrialNo).FileName_prefix;

CaSignal.ROIinfo(TrialNo) = ROIinfo;
% elseif exist(['ROIinfo_' FileName_prefix '.mat'],'file')
%     load([FileName_prefix 'ROIinfo.mat'], '-mat');
%     if length(CaSignal.ROIinfo)>= TrialNo_load
%         CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo{TrialNo_load};
%     end
nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
CaSignal.CaTrials(TrialNo).nROIs = nROIs;
set(handles.nROIsText, 'String', num2str(nROIs));
update_ROI_plot(handles);
handles = update_projection_images(handles);



function import_ROIinfo_from_trial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROITypeMenu_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
Menu = get(handles.ROITypeMenu,'String');
% CaSignal.CaTrials(TrialNo).ROIType{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
guidata(hObject, handles);

function CalculatePlotButton_Callback(hObject, eventdata, handles, im, plot_flag)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% ROIMask = CaSignal.CaTrials(TrialNo).ROIMask;
% if get(handles.ICA_ROI_anal, 'Value') == 1
%     nROI_effective = length(ICA_ROIs.ROIMask);
%     ROImask = ICA_ROIs.ROIMask;
% else
%     nROI_effective = length(CaSignal.ROIinfo(TrialNo).ROIpos);
%     ROImask = CaSignal.ROIinfo(TrialNo).ROIMask;
% end
nROI_effective = length(CaSignal.ROIinfo(TrialNo).ROIpos);
ROImask = CaSignal.ROIinfo(TrialNo).ROImask;
if nargin < 4
    im = CaSignal.ImageArray;
end
if nargin < 5 %~exist('plot_flag','var')
    plot_flag = 1;
end
if ~isempty(CaSignal.ROIinfo(TrialNo).BGmask)
    BGmask = repmat(CaSignal.ROIinfo(TrialNo).BGmask,[1 1 size(im,3)]) ;
    BG_img = BGmask.*double(im);
    BG_img(BG_img==0) = NaN;
    BG = reshape(nanmean(nanmean(BG_img)),1,[]); % 1-by-nFrames array
else
    BG = 0;
end;

F = zeros(nROI_effective, size(im,3));
dff = zeros(size(F));

for i = 1: nROI_effective
    mask = repmat(ROImask{i}, [1 1 size(im,3)]); % reproduce masks for every frame
    % Using indexing and reshape function to increase speed
    nPix = sum(sum(ROImask{i}));
    % Using reshape to partition into different trials.
    roi_img = reshape(im(mask), nPix, []);
    % Raw intensity averaged from pixels of the ROI in each trial.
    if nPix == 0
        F(i,:) = 0;
    else
        F(i,:) = mean(roi_img, 1);
    end
    %%%%%%%%%%%%% Obsolete slower method to compute ROI pixel intensity %%%%%%%
    %     roi_img = mask .* double(im);                                       %
    %                                                                         %
    %     roi_img(roi_img<=0) = NaN;                                          %
    %    % F(:,i) = nanmean(nanmean(roi_img));                                %
    %     F(i,:) = nanmean(nanmean(roi_img));                                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if get(handles.AnalysisModeBGsub,'Value') == 1
        F(i,:) = F(i,:) - BG;
    end;
    if get(handles.AnalysisModeDeltaFF,'Value') == 1
        [N,X] = hist(F(i,:));
        F_mode = X(find(N==max(N)));
        baseline = mean(F_mode);
        dff(i,:) = (F(i,:)- baseline)./baseline*100;
    else
        %         CaTrace(i,:) = F(i,:);
    end
end;
CaSignal.CaTrials(TrialNo).dff = dff;
CaSignal.CaTrials(TrialNo).f_raw = F;
ts = (1:CaSignal.CaTrials(TrialNo).nFrames).*CaSignal.CaTrials(TrialNo).FrameTime;
if plot_flag == 1
    if get(handles.check_plotAllROIs, 'Value') == 1
        roiNos = [];
    else
        roiNos = str2num(get(handles.roiNo_to_plot, 'String'));
    end
    CaSignal.h_CaTrace_fig = plot_CaTraces_ROIs(dff, ts, roiNos);
    % % %     set(handles.Image_disp_axes,'Visible','Off');
    % % %     set(handles.Image_disp_axes1,'Visible','On');
    % % %     set(handles.Image_disp_axes2,'Visible','On');
    %     plot_CaTraces_ROIs(dff, ts, roiNos,handles.Image_disp_axes1,handles.Image_disp_axes2);
end
guidata(handles.figure1, handles);

function doBatchButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
batchPrefix = get(handles.batchPrefixEdit, 'String');
Start_trial = str2double(get(handles.batchStartTrial, 'String'));
End_trial = str2double(get(handles.batchEndTrial,'String'));
% CaSignal.CaTrials = [];
h = waitbar(0, 'Start Batch Analysis ...');
for TrialNo = Start_trial:End_trial
    fname = CaSignal.data_file_names{TrialNo};
    if ~exist(fname,'file')
        [fname, pathname] = uigetfile('*.tif', 'Select Image Data file');
        cd(pathname);
    end;
    msg_str1 = sprintf('Batch analyzing %d of total %d trials with %d ROIs...', ...
        TrialNo, End_trial-Start_trial+1, CaSignal.CaTrials(1).nROIs);
    %     disp(['Batch analyzing ' num2str(TrialNo) ' of total ' num2str(End_trial-Start_trial+1) ' trials...']);
    disp(msg_str1);
    waitbar((TrialNo-Start_trial+1)/(End_trial-Start_trial+1), h, msg_str1);
    set(handles.msgBox, 'String', msg_str1);
    % %     [im, header] = imread_multi(fname, 'g');
    [im, header] = imread_multi_GR(fname, 'g');
    if (length(CaSignal.CaTrials)<TrialNo || isempty(CaSignal.CaTrials(TrialNo).FileName))
        trial_init = init_CaTrial(fname,TrialNo,header);
        CaSignal.CaTrials(TrialNo) = trial_init;
    end
    set(handles.CurrentTrialNo,'String', int2str(TrialNo));
    
    notansferROIinfo =get(handles.donottransferROIinfo,'Value');
    
    if (notansferROIinfo)
        %###########################################################################
        % Make sure the ROIinfo of the first trial of the batch is up to date
        if TrialNo > Start_trial && ~isempty(CaSignal.ROIinfo(TrialNo-1).ROIpos)
            if( (size(CaSignal.ROIinfo,2)<TrialNo) || ( size(CaSignal.ROIinfo(TrialNo).ROIpos,2)~= size(CaSignal.ROIinfo(TrialNo-1).ROIpos,2)))
                CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo(TrialNo-1);
                CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo-1).nROIs;
                CaSignal.CaTrials.FrameTime(TrialNo)=CaSignal.CaTrials.FrameTime(TrialNo-1);
            else
                CaSignal.ROIinfo(TrialNo)= CaSignal.ROIinfo(TrialNo);
                CaSignal.CaTrials(TrialNo).nROIs=CaSignal.CaTrials(TrialNo).nROIs;
                
            end
        end
        
        %##########################################################################
    else
        if TrialNo > Start_trial && ~isempty(CaSignal.ROIinfo(TrialNo-1).ROIpos)
            CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo(TrialNo-1);
            CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo-1).nROIs;
        end
        
    end
    %     update_image_axes(handles,im);
    CalculatePlotButton_Callback(handles.figure1, eventdata, handles, im, 0);
    %     handles = update_projection_images(handles);
    handles = get_exp_info(hObject, eventdata, handles);
    %     CaSignal.CaTrials(TrialNo).meanImage = mean(im,3);
    %     close(CaSignal.h_CaTrace_fig);
    set(handles.CurrentTrialNo, 'String', int2str(TrialNo));
    set(handles.CurrentImageFilenameText,'String',fname);
    %     set(handles.nROIsText,'String',int2str(length(ROIinfo{TrialNo}.ROIpos)));
    guidata(hObject, handles);
end

SaveResultsButton_Callback(hObject, eventdata, handles);
close(h);
disp(['Batch analysis completed for ' CaSignal.CaTrials(1).FileName_prefix]);
set(handles.msgBox, 'String', ['Batch analysis completed for ' CaSignal.CaTrials(1).FileName_prefix]);

function SaveResultsButton_Callback(hObject, eventdata, handles)
%% Save Results
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
FileName_prefix = CaSignal.CaTrials(TrialNo).FileName_prefix;
datapath = get(handles.DataPathEdit,'String');
cd (datapath);
% CaSignal.CaTrials = CaSignal.CaTrials;
% ROIinfo = ROIinfo;
ICA_results.ROIinfo = [];
ICA_results.ICA_components = [];
ICA_results.rois_by_IC = [];
if get(handles.ICA_ROI_anal, 'Value') == 1
    ICA_results.ROIinfo = CaSignal.ROIinfo;
    ICA_results.ICA_components = CaSignal.ICA_components;
    ICA_results.rois_by_IC = CaSignal.rois_by_IC;
end
ROIinfo = CaSignal.ROIinfo;
for i = 1:length(CaSignal.CaTrials)
    if length(CaSignal.ROIinfo) >= i
        CaSignal.CaTrials(i).ROIinfo = CaSignal.ROIinfo(i);
    end
end
CaTrials = CaSignal.CaTrials;
save(CaSignal.results_fn, 'CaTrials','ICA_results','-v7.3');
save(CaSignal.results_roiinfo, 'ROIinfo','-v7.3');
% save(fullfile(CaSignal.results_path, ['ICA_ROIs_', FileName_prefix '.mat']), 'ICA_ROIs');
msg_str = sprintf('CaTrials Saved, with %d trials, %d ROIs', length(CaSignal.CaTrials), CaSignal.CaTrials(TrialNo).nROIs);
disp(msg_str);
set(handles.msgBox, 'String', msg_str);
current_dir = pwd;
separators = find(current_dir == filesep);
session_dir = current_dir(1:separators(length(separators)-3));
cd (session_dir);
sessObj_found = dir('sessObj.mat');
if isempty(sessObj_found)
    sessObj = {};
    sessObj.CaTrials = CaSignal.CaTrials;
    save('sessObj','sessObj','-v7.3');
else
    load('sessObj.mat');
    sessObj.CaTrials = CaSignal.CaTrials;
    save('sessObj','sessObj','-v7.3');
end
cd (current_dir);
save_gui_info(handles);


function batchStartTrial_Callback(hObject, eventdata, handles)

function batchStartTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function batchEndTrial_Callback(hObject, eventdata, handles)

function batchEndTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if CaSignal.CaTrials(TrialNo).DaqInfo.acq.numberOfChannelsAcquire == 1
    set(hObject,'Value',1);
end;

function dispModeImageInfoButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value') == 1
    CaSignal.h_info_fig = figure; set(gca, 'Visible', 'off');
    f_pos = get(CaSignal.h_info_fig, 'Position'); f_pos(3) = f_pos(3)/2;
    set(CaSignal.h_info_fig, 'Position', f_pos);
    info_disp = CaSignal.info_disp;
    for i = 1: length(info_disp),
        x = 0.01;
        y=1-i/length(info_disp);
        text(x,y,info_disp{i},'Interpreter','none');
    end
    guidata(hObject, handles);
else
    close(CaSignal.h_info_fig);
end


function nROIsText_CreateFcn(hObject, eventdata, handles)

function figure1_DeleteFcn(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
save_gui_info(handles);
clear CaSignal % ROIinfo ICA_ROIs
% close all;

function CurrentTrialNo_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>0
    filename = CaSignal.data_file_names{TrialNo};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end

function PrevTrialButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>1
    filename = CaSignal.data_file_names{TrialNo-1};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end

function NextTrialButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if  TrialNo+1 <= length(CaSignal.data_file_names) % exist(filename,'file')
    filename = CaSignal.data_file_names{TrialNo+1};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
end

function AnalysisModeBGsub_Callback(hObject, eventdata, handles)

function batchPrefixEdit_Callback(hObject, eventdata, handles)

function batchPrefixEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AnimalNameEdit_Callback(hObject, eventdata, handles)
% % % global CaSignal % ROIinfo ICA_ROIs
% % % TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% % % CaSignal.CaTrials(TrialNo).AnimalName = get(hObject, 'String');
% % % guidata(hObject, handles);
% % % save_gui_info(handles);

function AnimalNameEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpDate_Callback(hObject, eventdata, handles)
% % % global CaSignal % ROIinfo ICA_ROIs
% % % TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% % % CaSignal.CaTrials(TrialNo).ExpDate = get(hObject, 'String');
% % % guidata(hObject, handles);
% % % save_gui_info(handles);

function ExpDate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SessionName_Callback(hObject, eventdata, handles)
% % % global CaSignal % ROIinfo ICA_ROIs
% % % TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% % % CaSignal.CaTrials(TrialNo).SessionName = get(hObject, 'String');
% % % guidata(hObject, handles);
% % % save_gui_info(handles);

function SessionName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameSlider_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
slider_value = get(hObject,'Value');
nFrames = CaSignal.nFrames;
new_frameNum = ceil(nFrames*slider_value);
if new_frameNum == 0, new_frameNum = 1; end;
set(handles.CurrentFrameNoEdit, 'String', num2str(new_frameNum));
handles = update_image_axes(handles);
guidata(hObject, handles);

function FrameSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function CurrentFrameNoEdit_Callback(hObject, eventdata, handles)

handles = update_image_axes(handles);

function CurrentFrameNoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminEdit_Callback(hObject, eventdata, handles)

update_image_axes(handles);
update_projection_images(handles);

function LUTminEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTmaxEdit_Callback(hObject, eventdata, handles)

update_image_axes(handles);
update_projection_images(handles);


function LUTmaxEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_min = get(hObject,'Value');
value_max = get(handles.LUTmaxSlider,'Value');
if value_min >= value_max
    value_min = value_max - 0.01;
    set(hObject, 'Value', value_min);
end;
set(handles.LUTminEdit, 'String', num2str(value_min*1000));
update_image_axes(handles);
update_projection_images(handles);
% guidata(hObject, handles);


function LUTminSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function LUTmaxSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_max = get(hObject,'Value');
value_min = get(handles.LUTminSlider, 'Value');
if value_max <= value_min
    value_max = value_min + 0.01;
    set(hObject, 'Value', value_max);
end;
set(handles.LUTmaxEdit, 'String', num2str(value_max*1000));
update_image_axes(handles);
update_projection_images(handles);
% guidata(hObject, handles);


function dispMeanMode_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_mean_fig)
            delete(CaSignal.h_mean_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);


function dispMaxDelta_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_maxDelta_fig)
            delete(CaSignal.h_maxDelta_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);

function dispMaxMode_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_max_fig)
            delete(CaSignal.h_max_fig);
        end;
    catch ME
    end
end
guidata(hObject, handles);

function ROITypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_CreateFcn(hObject, eventdata, handles)

function LUTmaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SaveFrameButton.
function SaveFrameButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
im = CaSignal.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
dataFileName = get(handles.CurrentImageFilenameText, 'String');

[fname, pathName] = uiputfile([dataFileName(1:end-4) '_' int2str(fr) '.tif'], 'Save the current frame as');
if ~isequal(fname, 0)&& ~isequal(pathName, 0)
    imwrite(im(:,:,fr), [pathName fname], 'tif','WriteMode','overwrite','Compression','none');
end




% --- Executes on button press in BG_poly_set.
function BG_poly_set_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
%    if isempty(CaSignal.CaTrials(TrialNo).BGmask)
waitforbuttonpress;
[BW,xi,yi] = roipoly;
CaSignal.ROIinfo(TrialNo).BGmask = BW;
CaSignal.ROIinfo(TrialNo).BGpos = [xi yi];
% axes(CaSignal.image_disp_gui.Image_disp_axes);
% if isfield(CaSignal, 'BGplot')&& ishandle(CaSignal.BGplot)
%     delete(CaSignal.BGplot);
% end
% CaSignal.BGplot = line(xi, yi, 'Color','b', 'LineWidth',2);
update_ROI_plot(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AnalysisModeBGsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnalysisModeBGsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in RegMethodMenu.
function RegMethodMenu_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RegMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MotionEstmOptions.
function MotionEstmOptions_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns MotionEstmOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionEstmOptions
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
switch get(hObject,'Value')
    case 2 % plot cross correlation coef for the current trial
        img = CaSignal.ImageArray;
        xcoef = xcoef_img(img);
        figure('Name', ['xCorr. Coefficient for Trial ' num2str(TrialNo)], 'Position', [1200 300 480 300]);
        plot(xcoef); xlabel('Frame #'); ylabel('Corr. Coeff');
        disp(sprintf(['mean xCorr. Coefficient for trial ' num2str(TrialNo) ': %g'],mean(xcoef)));
    case 3 % Compute cross correlation across all trials
        n_trials = length(CaSignal.data_file_names);
        if isempty(CaSignal.avgCorrCoef_trials)
            xcoef_trials = zeros(n_trials,1);
            h_wait = waitbar(0, 'Calculating cross correlation coefficients for trial 0 ...');
            for i = 1:n_trials
                waitbar(i/n_trials, h_wait, ['Calculating cross correlation coefficients for trial ' num2str(i)]);
                img = imread_multi(CaSignal.data_file_names{i},'g');
                xcoef = xcoef_img(img);
                xcoef_trials(i) = mean(xcoef);
            end
            close(h_wait);
            CaSignal.avgCorrCoef_trials = xcoef_trials;
        else
            xcoef_trials = CaSignal.avgCorrCoef_trials;
        end
        figure('Name', 'xCorr. Coef across all trials', 'Position', [1200 300 480 300]);
        plot(xcoef_trials); xlabel('Trial #'); ylabel('mean Corr. Coeff');
    case 4
        
    case 5
        if ~isempty(CaSignal.dftreg_shift)
            for i = 1:str2num(get(handles.TotTrialNum, 'String'))
                avg_shifts(i) = max(mean(abs(CaSignal.dftreg_shift(:,:,i)),2));
            end
            figure;
            plot(avg_shifts,'LineWidth',2);
            title('Motion estimation of all trials','FontSize',18);
            xlabel('Trial #', 'FontSize', 15); ylabel('Mean shift of all frames', 'FontSize', 15);
        end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MotionEstmOptions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_gui_info(handles)
% global CaSignal ROIinfo ICA_ROIs
info.DataPath = pwd;
info.AnimalName = get(handles.AnimalNameEdit,'String');
info.ExpDate = get(handles.ExpDate,'String');
info.SessionName = get(handles.SessionName, 'String');
info.SoloDataPath = get(handles.SoloDataPath, 'String');
info.SoloDataFileName = get(handles.SoloDataFileName, 'String');
info.SoloSessionName = get(handles.SoloSessionID, 'String');
info.SoloStartTrialNo = get(handles.SoloStartTrialNo, 'String');
info.SoloEndTrialNo = get(handles.SoloEndTrialNo, 'String');

usrpth = '~/Documents/MATLAB'; %usrpth = usrpth(1:end-1);
save([usrpth filesep 'nx_CaSingal.info'], 'info');



function SoloStartTrialNo_Callback(hObject, eventdata, handles)
handles.SoloStartTrial=str2num(get(hObject,'String'));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function SoloStartTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solostarttrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloEndTrialNo_Callback(hObject, eventdata, handles)
%
handles.SoloEndTrial=str2num( get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SoloEndTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soloendtrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataPath_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function SoloDataPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataFileName_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SoloDataFileName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addBehavTrials.
function addBehavTrials_Callback(hObject, eventdata, handles)
global CaSignal %  ROIinfo ICA_ROIs

Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloDataFileName, 'String');
trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));
trailsToBeExcluded = str2num(get(handles.behavTrialNoToBeExcluded, 'String'));

[Solo_data, SoloFileName] = Solo.load_data_gr(mouseName, sessionName,trialStartEnd,Solopath);
set(handles.SoloDataFileName, 'String', SoloFileName);
behavTrialNums = trialStartEnd(1):trialStartEnd(2);
behavTrialNums(trailsToBeExcluded) = [];

if length(behavTrialNums) ~= str2num(get(handles.TotTrialNum, 'String'))
    error('Number of behavior trials NOT equal to Number of Ca Image Trials!')
end

for i = 1:length(behavTrialNums)
    behavTrials(i) = Solo.BehavTrial_gr(Solo_data,behavTrialNums(i),1);
    CaSignal.CaTrials(i).behavTrial = behavTrials(i);
end
disp([num2str(i) ' Behavior Trials added to CaSignal.CaTrials']);
set(handles.msgBox, 'String', [num2str(i) ' Behavior Trials added to CaSignal.CaTrials']);
guidata(hObject, handles)


function SoloSessionID_Callback(hObject, eventdata, handles)

% % % % Solopath = get(handles.SoloDataPath,'String');
% % % % mouseName = get(handles.AnimalNameEdit, 'String');
% % % % sessionID = get(handles.SoloSessionID, 'String');
% % % % sessionName = ['data_@pole_detect_gr_0obj_' mouseName '_' sessionID];
% % % % trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
% % % % trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));
% % % %
% % % % [Solo_data, SoloFileName] = Solo.load_data_gr(mouseName, sessionName,trialStartEnd,Solopath);
% % % % set(handles.SoloDataFileName, 'String', SoloFileName);


% --- Executes during object creation, after setting all properties.
function SoloSessionID_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function dispModeImageInfoButton_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in ROI_move_left.
function ROI_move_left_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
fine=get(handles.movefine,'Value');
if(fine)
    move_unit = 1* max(1/aspect_ratio,1);
else
    move_unit = 5* max(1/aspect_ratio,1);
end
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1)-move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);


% --- Executes on button press in ROI_move_right.
function ROI_move_right_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
fine=get(handles.movefine,'Value');
if(fine)
    move_unit = 1* max(1/aspect_ratio,1);
else
    move_unit = 5* max(1/aspect_ratio,1);
end
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1)+move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)

% --- Executes on button press in ROI_move_up.
function ROI_move_up_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
fine=get(handles.movefine,'Value');
if(fine)
    move_unit = 1* max(1/aspect_ratio,1);
else
    move_unit = 5* max(1/aspect_ratio,1);
end
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)-move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)


% --- Executes on button press in ROI_move_down.
function ROI_move_down_Callback(hObject, eventdata, handles)

global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
fine=get(handles.movefine,'Value');
if(fine)
    move_unit = 1* max(1/aspect_ratio,1);
else
    move_unit = 5* max(1/aspect_ratio,1);
end

if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)+move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
end

update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)



function behavTrialNoToBeExcluded_Callback(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of behavTrialNoToBeExcluded as text
%        str2double(get(hObject,'String')) returns contents of behavTrialNoToBeExcluded as a double


% --- Executes during object creation, after setting all properties.
function behavTrialNoToBeExcluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispCorrMapTrials.
function dispCorrMapTrials_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
currROI = str2num(get(handles.CurrentROINoEdit,'String'));
if get(handles.dispCorrMapTrials,'Value')==1
    if isempty(CaSignal.CorrMapTrials) || ~isequal(CaSignal.CorrMapROINo, currROI)
        [fn, pathname] = uigetfile([CaSignal.results_path filesep '*.tif'],'Select image file of correlation map');
        CaSignal.CorrMapTrials = imread_multi([pathname filesep fn]);
        CaSignal.CorrMapROINo = currROI;
        % get the mean correlation map from trials with variance > 70 percentile
        dFF = get_dFF_roi(CaSignal.CaTrials, currROI);
        v = var(dFF,0,2);
        ind = find(v > prctile(v,70));
        CaSignal.CorrMapMean = mean(CaSignal.CorrMapTrials(:,:,ind),3);
    end
    %     im = CaSignal.CorrMapTrials;
    CaSignal.nFrames = size(CaSignal.CorrMapTrials,3);
    set(handles.CurrentFrameNoEdit,'String',num2str(1));
    handles = update_image_axes(handles);
else
    CaSignal.nFrames = size(CaSignal.ImageArray,3);
    handles = update_image_axes(handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dispCorrMapTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispCorrMapTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function dFF_array = get_dFF_roi(CaSignal, roiNo)

nTrials = numel(CaSignal.CaTrials);
dFF_array = [];
for i = 1:nTrials
    if ~isempty(CaSignal.CaTrials(i).dff)
        if size(CaSignal.CaTrials(i).dff,1) < roiNo
            return;
        else
            dFF_array = [dFF_array; CaSignal.CaTrials(i).dff(roiNo,:)];
        end
    end
end

% --- Executes on button press in CorrMap_button.
function CorrMap_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
confirm = questdlg('Start computing spatial temporal correlation for all ROIs? It would take a long time!');
if ~strcmp(confirm, 'Yes')
    return
else
    savepath = CaSignal.results_path;
    roiNums = 1:CaSignal.CaTrials(1).nROIs;
    % fVar = var(dffROI,0,2);
    % ind = find(fVar > prctile(fVar,70)); % trNoROI; %  find(peakROI>80);
    nTr = length(CaSignal.CaTrials);
    width = CaSignal.CaTrials(1).DaqInfo.width;
    height = CaSignal.CaTrials(1).DaqInfo.height;
    
    for n = 1:numel(roiNums)
        crr_map = zeros(height,width,nTr);
        h = waitbar(0, sprintf('Analyzing %d of total %d ROIs',n,numel(roiNums)),... ) %['Analyzing ' num2str(n) ' of total ' num2str(numel(roiNums)) ' ROIs ...'],...
            'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
        setappdata(h,'canceling',0);
        for k = 1:nTr
            if getappdata(h,'canceling')
                break
            end
            %     tr = ind(k);
            %     disp(['Analyzing ' imobj(tr).FileName]);
            fname = CaSignal.data_file_names{k};
            im = imread_multi_GR(fname,'g'); %%GRchange
            f = CaSignal.CaTrials(k).f_raw(roiNums(n),:);
            for i=1:size(im,1)
                for j = 1:size(im,2)
                    p = double(im(i,j,:));
                    c = corrcoef(f,p);
                    crr_map(i,j,k) = c(2,1);
                end
            end
            
            waitbar(k/nTr,h, sprintf('Analyzing %d of total %d ROIs, in Trial %d...', n,numel(roiNums),k)); %  ['Analyzing ROI # ' num2str(roiNums(n)) ', Trial ' num2str(k) ' ...']);
            imwrite(crr_map(:,:,k),sprintf('%s%cCorrMapROI#%d.tif',savepath,filesep,roiNums(n)),'Compression','none','WriteMode','append');
        end
        delete(h);
        save(sprintf('%s%cCorr_Map_ROI_#%d.mat', savepath,filesep, roiNums(n)),'crr_map');
        %     axes(ax1); plot(dffROI(ind(k),:)); axes(ax2); imagesc(crr_im(:,:,k),[-0.1 1]);
    end
end




% --- Executes during object creation, after setting all properties.
function Image_disp_axes_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function msgBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msgBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in dispAspectRatio.
function dispAspectRatio_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
Str = get(hObject, 'String');
CaSignal.AspectRatio_mode = Str{get(hObject,'Value')};
guidata(hObject, handles);
handles = update_image_axes(handles);



% --- Executes during object creation, after setting all properties.
function dispAspectRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispAspectRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function frame_time_disp_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in export2avi_button.
function export2avi_button_Callback(hObject, eventdata, handles)

global CaSignal
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
fname = CaSignal.CaTrials(TrialNo).FileName;
[movieFileName, pathname] = uiputfile([fname(1:end-4) '.avi'], 'Export current trial to an avi movie');
movObj = VideoWriter([pathname filesep movieFileName]);
movObj.FrameRate = 15;

open(movObj);

for i = 1:CaSignal.CaTrials(TrialNo).nFrames
    set(handles.CurrentFrameNoEdit,'String',num2str(i));
    handles = update_image_axes(handles);
    F = getframe(handles.Image_disp_axes);
    writeVideo(movObj, F);
end
close(movObj);
% movie2avi(Mov,[pathname filesep movieFileName],'compression','none');


% --- Executes when selected object is changed in ROI_def.
function ROI_def_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ROI_def
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ICA_ROI_anal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ICA_ROI_anal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in ICA_ROI_anal.
function ICA_ROI_anal_Callback(hObject, eventdata, handles)

global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value') == 1
    
    %%****************
    
    % Display mean ICA map
    if isfield(CaSignal, 'ICA_components') && ~isempty(CaSignal.ICA_components)
        CaSignal.rois_by_IC = cell(1, size(CaSignal.ICA_components,1)) ;
        IC_to_remove = inputdlg('IC to remove', 'Remove bad ICs');
        if ~isempty(IC_to_remove)
            IC_to_remove = str2num(IC_to_remove{1});
            CaSignal.ICA_components(IC_to_remove,:) = NaN;
        end
        CaSignal.ICA_figs(3) = disp_mean_IC_map(CaSignal.ICA_components);
    end
    
    if isfield(CaSignal, 'ica_data') && isfield(CaSignal.ica_data,'Data')
        usr_confirm = questdlg('Display Max Projection of all data is slow and memory intensive. Continue?');
        if strcmpi(usr_confirm, 'Yes')
            %             Data = LoadData(pwd,CaSignal.CaTrials(1).FileName_prefix,1:50);
            [CaSignal.ICA_data_norm_max, CaSignal.ICA_figs(4)] = disp_maxDelta_rawData(CaSignal.ica_data.Data);
            [CaSignal.ICA_data_norm_max, CaSignal.ICA_figs(4)] = disp_maxDelta_rawData(CaSignal.ica_data.Data);
            set(gcf,'Name',sprintf('MaxDelta of raw Data (%d~%d)',CaSignal.ica_data.FileNums(1),CaSignal.ica_data.FileNums(end)));
        end
        
    end
    
    %**************
    
    % load_saved_data_SVD
    if isempty(CaSignal.ImageArray)
        error('No Imaging Data loaded. Do this before running ICA!');
    end
    
    if isfield(CaSignal, 'ica_data') && isfield(CaSignal.ica_data,'Data')%%~isempty(CaSignal.ica_data.Data)
        
        CaSignal. ica_data.FileBaseName = get(handles.batchPrefixEdit, 'String');
        CaSignal.ica_data.DataDir = pwd;
        CaSignal.ica_data.FileNums = [1:50];% using filenums [1:50] for now , need to put a text box
        usr_confirm = questdlg('ica_data.Data exists. Reload data from first 50 data .tif files.Continue? ');
        if strcmpi(usr_confirm, 'Yes')
            % Load the data files
            CaSignal.ica_data.Data = ICA_LoadData(CaSignal.ica_data.DataDir,CaSignal.ica_data.FileBaseName, CaSignal.ica_data.FileNums);
        end
        
    else
        
        %          h = msgbox('No ica_data.Data, Loading data from first 50 data .tif files.');
        
        CaSignal.ica_data.FileBaseName = get(handles.batchPrefixEdit, 'String');
        CaSignal.ica_data.DataDir = pwd;
        CaSignal.ica_data.FileNums = [1:50];% using filenums [1:50] for now , need to put a text box
        % Load the data files
        CaSignal.ica_data.Data = ICA_LoadData( CaSignal.ica_data.DataDir,  CaSignal.ica_data.FileBaseName,  CaSignal.ica_data.FileNums);
        
    end
    
    %if no svd data : compute svd & save it in same dir
    if ~exist(sprintf('ICA_data_%s.mat',  CaSignal.ica_data.FileBaseName), 'file')
        [U,S,V] = svd(CaSignal.ica_data.Data,'econ');
        save(sprintf('ICA_data_%s.mat',  CaSignal.ica_data.FileBaseName), 'U','S','V','-v7.3');
    end
    
    % % %     %now load the svd data to run_ICA callback
    % % %     [fn, pth] = uigetfile('*.mat', 'Load DATA SVD');
    % % %     if fn == 0
    % % %         return
    % % %     end
    usv = load(sprintf('ICA_data_%s.mat', CaSignal.ica_data.FileBaseName));
    
    CaSignal.ica_data.U = usv.U;
    CaSignal.ica_data.S = usv.S;
    CaSignal.ica_data.V = usv.V;
    
    CaSignal.currentIC = 1;
    %     handles.ica_data = ica_data;
    %     handles.ICA_datafile = fullfile(pth,fn);
    %     ICA_ROIs = struct;
    guidata(hObject, handles);
    runICA_button_Callback(handles.runICA_button, eventdata, handles);
    
    
    
end


% --- Executes on button press in prevIC_button.
function prevIC_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(handles.ICA_ROI_anal,'Value') == 1 && CaSignal.currentIC > 1
    CaSignal.currentIC = CaSignal.currentIC - 1;
    set(handles.current_ICnum_text, 'String', num2str(CaSignal.currentIC));
    %     guidata(hObject, handles);
    disp_ICA(handles);
end


% --- Executes on button press in nextIC_button.
function nextIC_button_Callback(hObject, eventdata, handles)
global CaSignal  % ROIinfo ICA_ROIs
if get(handles.ICA_ROI_anal,'Value') == 1 && CaSignal.currentIC < size(CaSignal.ICA_components,1)
    CaSignal.currentIC = CaSignal.currentIC + 1;
    set(handles.current_ICnum_text, 'String', num2str(CaSignal.currentIC));
    guidata(hObject, handles);
    disp_ICA(handles);
end

% --- Executes on button press in runICA_button.
function runICA_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% if ~(exist(CaSignal.ica_data.Data)
%
%
% end
data = CaSignal.ica_data.Data;
V = CaSignal.ica_data.V;
S = CaSignal.ica_data.S;
ICnum = str2num(get(handles.IC_num_edit,'String'));
% CaSignal.ICnum = str2num(get(handles.IC_num_edit,'String'));
CaSignal.ICA_components = run_ICA(CaSignal.ica_data.Data, {S, V, 30, ICnum});
CaSignal.rois_by_IC = cell(1,ICnum);
% CaSignal.ICnum_prev = ICnum;

guidata(handles.figure1, handles);
disp_ICA(handles);


function IC_num_edit_Callback(hObject, eventdata, handles)
runICA_button_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function IC_num_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function disp_ICA(handles)
global CaSignal % ROIinfo ICA_ROIs
RowNum = CaSignal.imSize(1);
ColNum = CaSignal.imSize(2);
if ~ishandle(CaSignal.ICA_figs)
    CaSignal.ICA_figs(1) = figure('Position', [123   460   512   512]);
    CaSignal.ICA_figs(2) = figure('Position',[115    28   512   512]);
end
disp_ICAcomponent_and_blobs(CaSignal.ICA_components(CaSignal.currentIC,:),RowNum, ColNum, CaSignal.ICA_figs);
for i = 1:length(CaSignal.ICA_figs)
    figure(CaSignal.ICA_figs(i)),
    plot_ROIs(handles);
    title(sprintf('IC #%d',CaSignal.currentIC),'FontSize',15);
end

function fig = disp_mean_IC_map(IC)
for i=1:size(IC,1),
    IC_norm(i,:) = (IC(i,:)- nanmean(IC(i,:)))./ nanstd(IC(i,:));
end
IC_norm_mean = nanmax(abs(IC),[],1); % mean(abs(IC_norm),1);
clim = [0  max(IC_norm_mean)*0.7];
fig = figure('Position', [123   372   512   512]);
imagesc(reshape(IC_norm_mean, 128, 512), clim);
axis square;

function [data_norm_max,fig] = disp_maxDelta_rawData(data)
% each image data has to be already transformed to 1D
% normalize
data_cell = mat2cell(data,ones(1,size(data,1)));
clear data
data_cell_norm = cellfun(@(x) (x-mean(x))./std(x), data_cell, 'UniformOutput',false);
clear data_cell
data_norm = cell2mat(data_cell_norm);
% for i = 1:size(data,1)
%     data_norm(i,:) = (data(i,:) - mean(data(i,:)))./std(data(i,:));
% end
data_norm_max = max(data_norm,[],1);
clim = [0  max(data_norm_max)*0.7];
fig = figure('Position', [100   100   512   512]);
imagesc(reshape(data_norm_max, 128, 512), clim);
axis square;
% --- Executes during object creation, after setting all properties.
function current_ICnum_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_ICnum_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ROI_load_button.
function ROI_load_button_Callback(hObject, eventdata, handles)
global CaSignal


% --------------------------------------------------------------------
function Load_Ca_results_Callback(hObject, eventdata, handles)
global CaSignal
[fn pathstr] = uigetfile('*.mat', 'Load Previous CaTrials results');
if ischar(fn)
    prev_results = load(fullfile(pathstr, fn));
    CaSignal.CaTrials = prev_results.CaTrials;
end


% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_ROIinfo_Callback(hObject, eventdata, handles)
global CaSignal
[fn pathstr] = uigetfile('*.mat', 'Load saved ROI info');
if ischar(fn)
    load(fullfile(pathstr, fn));
    if iscell(ROIinfo)
        f1 = fieldnames(ROIinfo{1}); f2 = fieldnames(CaSignal.ROIinfo);
        for i = 1:length(ROIinfo)
            for j = 1:length(f1),
                CaSignal.ROIinfo(i).(f2{strcmpi(f2,f1{j})}) = ROIinfo{i}.(f1{j});
            end
        end
    else
        CaSignal.ROIinfo = ROIinfo;
    end
end


% --------------------------------------------------------------------
function Load_ICA_results_Callback(hObject, eventdata, handles)
global CaSignal
[fn pathstr] = uigetfile('*.mat','Load saved ICA results');
if ischar(fn)
    load(fullfile(pathstr, fn)); % load ICA_results
    fprintf('ICA_results of %s loaded!\n', ICA_results.FileBaseName);
    CaSignal.ICA_components = ICA_results.ICA_components;
    CaSignal.currentIC = 1;
    disp_ICA(handles)
end



function current_ICnum_text_Callback(hObject, eventdata, handles)
global CaSignal
newIC_No = str2num(get(hObject, 'String'));
if newIC_No <= size(CaSignal.ICA_components,1)
    CaSignal.currentIC = newIC_No;
    guidata(hObject, handles);
    disp_ICA(handles);
end


% --- Executes on button press in maxDelta_only_button.
function maxDelta_only_button_Callback(hObject, eventdata, handles)
global CaSignal
% if get(hObject,'Value') == 1
%     [fn, pth] = uigetfile('*.mat','Load Max Delta Image Array');
%
%
% end


% --- Executes during object creation, after setting all properties.
function ROI_def_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ROI_modify_button.
function ROI_modify_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROI_modify_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function roiNo_to_plot_Callback(hObject, eventdata, handles)
% hObject    handle to roiNo_to_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roiNo_to_plot as text
%        str2double(get(hObject,'String')) returns contents of roiNo_to_plot as a double


% --- Executes during object creation, after setting all properties.
function roiNo_to_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiNo_to_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_plotAllROIs.
function check_plotAllROIs_Callback(hObject, eventdata, handles)
% hObject    handle to check_plotAllROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_plotAllROIs


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in whisker_batch_preprocess.
function whisker_batch_preprocess_Callback(hObject, eventdata, handles)

basedatapath= get(handles.baseDataPath,'String');
coordsatfirst= str2num(get(handles.coords1,'String'));
coordsatnext= str2num(get(handles.coords2,'String'));
barposatfirst= str2num(get(handles.barpos1,'String'));
barposatnext= str2num(get(handles.barpos2,'String'));
gopos = [];

barTimeWindow = str2num(get(handles.barTimeWindow,'String'));
[gopos,nogopos]=Batch_whiskers_preprocess(basedatapath,coordsatfirst,coordsatnext,barposatfirst,barposatnext,barTimeWindow);

set(handles.nogopos,'String',num2str(nogopos/10000));
set(handles.gopos,'String',num2str(gopos/10000));
% --- Executes on button press in whisker_batch_process.
function whisker_batch_process_Callback(hObject, eventdata, handles)
% hObject    handle to whisker_batch_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
basedatapath= get(handles.baseDataPath,'String');
Batch_process_multi_session_whisker_data_GR4(basedatapath);
contactdetect_Callback(hObject, eventdata, handles);

% --- Executes on button press in make_solo_obj.
function make_solo_obj_Callback(hObject, eventdata, handles)

Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloDataFileName, 'String');
sessionID = get(handles.SoloSessionID, 'String');
if((isempty(Solopath))||(isempty(mouseName))||(isempty(sessionName))||(isempty(sessionID)))
    msgbox('Fill in details');
    return;
end
% trialStartEnd = [get(handles.SoloStartTrialNo,'value'), get(handles.SoloEndTrialNo,'value')];
trialStartEnd = [handles.SoloStartTrial,handles.SoloEndTrial];
obj = Solo.BehavTrialArray_gr(mouseName, sessionName,trialStartEnd,Solopath);
obj.goPosition_mean=mean(obj.polePositions(obj.trialTypes))/10000;
solo_data = obj;
save(['solodata_' mouseName '_' sessionID],'solo_data');


%% adding solo data to sessObj
behavTrialNums=[handles.SoloStartTrial:handles.SoloEndTrial];
[Solo_data, SoloFileName] = Solo.load_data_gr(mouseName, sessionName,trialStartEnd,Solopath);
behavTrials = {};
for i = 1:length(behavTrialNums)
    behavTrials{i} = Solo.BehavTrial_gr(Solo_data,behavTrialNums(i),1);
end

current_dir = pwd;
separators = find(current_dir == filesep);
session_dir = current_dir(1:separators(length(separators)));
cd (session_dir);
sessObj_found = dir('sessObj.mat');
if isempty(sessObj_found)
    sessObj = {};
    sessObj.behavTrials = behavTrials;
    save('sessObj','sessObj','-v7.3');
else
    load('sessObj.mat');
    sessObj.behavTrials = behavTrials;
    save('sessObj','sessObj','-v7.3');
end
cd (current_dir);
'Done'


function baseDataPath_Callback(hObject, eventdata, handles)




% --- Executes during object creation, after setting all properties.
function baseDataPath_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nogopos_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function nogopos_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gopos_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function gopos_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [gopos,nogopos]=Batch_whiskers_preprocess(basedatapath,coordsatfirst,coordsatnext,barposatfirst,barposatnext,barTimeWindow)

d= basedatapath;
%%load solo_data
cd ([d '/solo_data']);
list = dir('solodata_*.mat');
load(list(1).name);
solo_obj=solo_data;
cd ..

%% make sessionInfo obj
sessionInfo = struct('pxPerMm', 31.25, 'mouseName', solo_obj.mouseName,'sessionName',solo_obj.sessionName(end-6:end),'SoloTrialStartEnd',solo_obj.trialStartEnd,'whiskerPadOrigin_nx',[375,70],'whiskerImageDim',[520,400],...
    'bar_coords',[],'bar_coordsall',[],'bar_time_window',barTimeWindow,'whisker_trajIDs',[0],'theta_kappa_roi',[0,20,140,170],'gotrials',[],'nogotrials',[],'gopos',[],'nogopos',[],'gopix',[],'nogopix',[],'goPosition_mean',[]);
%change when baseline is .5s
% % sessionInfo = struct('pxPerMm', 31.25, 'mouseName', solo_obj.mouseName,'sessionName',solo_obj.sessionName(end-6:end),'SoloTrialStartEnd',solo_obj.trialStartEnd,'whiskerPadOrigin_nx',[375,70],'whiskerImageDim',[520,400],...
% %     'bar_coords',[],'bar_coordsall',[],'bar_time_window',[.5,1.5828],'whisker_trajIDs',[0],'theta_kappa_roi',[0,20,140,170],'gotrials',[],'nogotrials',[],'gopos',[],'nogopos',[],'gopix',[],'nogopix',[],'goPosition_mean',[]);


cd([d '/whisker_data']);
list = dir('20*_*');
cd (list(1).name);
d =pwd;

[barposmat,barposmatall]= prep(d,solo_obj,coordsatfirst,coordsatnext,barposatfirst,barposatnext);
save ('barposmat.mat','barposmat');
save ('barposmatall.mat','barposmatall');
% cd and save
cd ..
cd ..
% save ('barposmat.mat');
% list = dir('SessionInfo_*.mat');
% load(list(1).name);

%%
sessionInfo. bar_coordsall = barposmatall(:,[1,2]);
sessionInfo.bar_coords = [];
sessionInfo.bar_coords = barposmat(:,[1,2]);

sessionInfo.nogotrials = find(solo_obj.trialTypes==0);
sessionInfo.gotrials = find(solo_obj.trialTypes==1);


sessionInfo.nogopos=unique(solo_obj.polePositions(sessionInfo.nogotrials));
nogopos = sessionInfo.nogopos;

sessionInfo.gopos=unique(solo_obj.polePositions(sessionInfo.gotrials));
gopos = sessionInfo.gopos;

sessionInfo.gopix(:,1) =unique(barposmatall(sessionInfo.gotrials));
sessionInfo.gopix(:,1) = sort(sessionInfo.gopix(:,1),'descend');
sessionInfo.gopix(:,2) =barposmatall(1,2);
sessionInfo.nogopix(:,1) = unique(barposmatall(sessionInfo.nogotrials));
sessionInfo.nogopix(:,2) =barposmatall(1,2);

sessionInfo.goPosition_runmean(:,1) =solo_obj.goPosition_runmean;
sessionInfo.goPosition_mean(1,1) =solo_obj.goPosition_mean;

sessionInfo.polePositions = solo_obj.polePositions;
name = ['SessionInfo_' solo_obj.mouseName '_' datestr(now,'mmddyy') ];
save(name,'sessionInfo');
'Made and saved SessionInfo'


function [barposmat,barposmatall]= prep(d,solo_obj,coordsatfirst,coordsatnext,barposatfirst,barposatnext)
%% to make the barposmat conversion
%d =
%load('data_*'); %load solodata

%% evaluate tracker files
files = dir('*.whiskers');
temp=struct2cell(files);
trialnames= temp(1,:)';
names = char(trialnames);
if sum(ismember(names(1,:),'g'))>0
    trialno_ind = [29:32];
else
    trialno_ind=[30:33];
end
whisknumind = str2num(names(:,trialno_ind));

files = dir('*.measurements');
temp=struct2cell(files);
trialnames= temp(1,:)';
names = char(trialnames);
measnumind = str2num(names(:,trialno_ind ));

files = dir('*.mp4');
temp=struct2cell(files);
trialnames= temp(1,:)';
names = char(trialnames);
mp4numind = str2num(names(:,trialno_ind ));
incomplete =0;

if (length (whisknumind) == length(measnumind))
    if(length(whisknumind)== length (mp4numind))
        'OK go ahead with analysis'
    else
        
        err(['incomplete data:' num2str(length(whisknumind)) 'whiskers and' num2str(length(mp4numind)) 'mp4']);
        incomplete=1;
    end
else
    lookat = find((~ismember(measnumind, whisknumind)))
    err(['incomplete data:' num2str(length(whisknumind)) 'whiskers and' num2str(length(measnumind)) 'measurements']);
    incomplete =1;
end


if (incomplete)
    %% get list of files to delete
    deletewhisk = zeros(length(whisknumind),1);
    for i=1:length(whisknumind)
        check = find(measnumind==whisknumind(i));
        if isempty(check)
            deletewhisk(i) = whisknumind(i);
        end
    end
    
    
    deletemeas = zeros(length(measnumind),1);
    for i=1:length(measnumind)
        check = find(whisknumind==measnumind(i));
        if isempty(check)
            deletemeas(i) = measnumind(i);
        end
    end
    pause(1)
end

%% make barposmat
files = dir('*.whiskers');
temp=struct2cell(files);
trialnames= temp(1,:)';
names = char(trialnames);
trialnumind = str2num(names(:,trialno_ind));

%     pos = saved_history.MotorsSection_motor_position;
barpos = solo_obj.polePositions';
%     barpos = cell2mat(pos);
barpos = round(barpos/1000)/10;

coordsdiff = abs(coordsatfirst-coordsatnext);
barposdiff = abs(barposatfirst-barposatnext);
barposmatall = zeros(length(barpos),2);
factor = coordsdiff/barposdiff;
barposmatall(:,1) = repmat(coordsatfirst(1),length(barpos),1)- round((barpos(:,1)-barposatfirst(1))*factor(1)) ;
if(factor(2)~=1)&& (coordsatnext(2)>coordsatfirst(2))
    barposmatall(:,2) = repmat(coordsatnext(2),length(barpos),1)- round((barposatnext(1)-barpos(:,1))*factor(2));
elseif(factor(2)~=1)&& (coordsatnext(2)<coordsatfirst(2))
    barposmatall(:,2) = repmat(coordsatnext(2),length(barpos),1)+ round((barposatnext(1)-barpos(:,1))*factor(2));
else
    barposmatall(:,2) = coordsatfirst(2);
end

barposmatall=round(barposmatall);
barposmat = barposmatall(trialnumind,:);


['no trials =' num2str(length(trialnumind))]
['no. whisker files =' num2str(length(whisknumind))]
['no. meas files =' num2str(length(measnumind))]
['length of barposmat =' num2str(length(barposmat))]





% --- Executes on button press in secProc.
function secProc_Callback(hObject, eventdata, handles)
secProc=get(handles.secProc,'Value');
if(secProc==1)
    set(handles.secProcPanel,'Visible','On');
    set(handles.primProcPanel,'Visible','Off');
    set(handles.tertProcPanel,'Visible','Off');
end


% --- Executes on button press in tertProc.
function tertProc_Callback(hObject, eventdata, handles)
tertProc=get(handles.tertProc,'Value');
if(tertProc==1)
    set(handles.tertProcPanel,'Visible','On');
    set(handles.secProcPanel,'Visible','Off');
    set(handles.primProcPanel,'Visible','Off');
end
% --- Executes on button press in primProc.
function primProc_Callback(hObject, eventdata, handles)
primProc=get(handles.primProc,'Value');
if(primProc==1)
    set(handles.primProcPanel,'Visible','On');
    set(handles.secProcPanel,'Visible','Off');
    set(handles.tertProcPanel,'Visible','Off');
end


% --- Executes on button press in uibasedatapath.
function uibasedatapath_Callback(hObject, eventdata, handles)
basedatapath = get(handles.baseDataPath,'String');
if exist(basedatapath, 'dir')
    cd(basedatapath);
end
[basedatapath] = uigetdir(basedatapath,'Set base path');
cd(basedatapath);
set(handles.baseDataPath,'String',basedatapath);


% --- Executes during object creation, after setting all properties.
function numsolotrials_CreateFcn(hObject, eventdata, handles)



function CaSignal_datapath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function CaSignal_datapath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in load_CaSignal.
function load_CaSignal_Callback(hObject, eventdata, handles)
global CaTrials
global sorted_CaTrials
global contact_CaTrials
basedatapath = get(handles.CaSignal_datapath,'String');
cd (basedatapath);

if(get(handles.CaTrials_select,'Value')==1)
    [filename,pathName]=uigetfile('CaSignal*.mat','Load CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    
    set(handles.CaSignal_datapath,'String',pathName);
    cd(pathName);
    load( [pathName filesep filename], '-mat');
    
    if (strcmp(filename(1:6),'sorted'))
        msgbox('Change settings before loading sorted_CaTrials');
        return
    end
    numrois = CaTrials(1,1).nROIs;
elseif (get(handles.sorted_CaTrials_select,'Value')==1)
    [filename,pathName]=uigetfile('sorted_CaSignal*.mat','Load sorted_CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    set(handles.CaSignal_datapath,'String',pathName);
    cd(pathName);
    load( [pathName filesep filename], '-mat');
    
    [filename,pathName]=uigetfile('CaSignal*.mat','Also Load CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    load( [pathName filesep filename], '-mat');
    numrois = CaTrials(1,1).nROIs;
elseif(get(handles.contact_CaSignal_select,'Value')==1)
    
    [filename,pathName]=uigetfile('contact_CaSignal*.mat','Load contact_CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    set(handles.CaSignal_datapath,'String',pathName);
    cd(pathName);
    load( [pathName filesep filename], '-mat');
    %         numrois = size(contact_CaTrials{1,1},1);
    numrois = contact_CaTrials(1).nROIs;
end


set(handles.CaSignalrois,'String',num2str(numrois));



function fov_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function fov_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roislist_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function roislist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotroiSignals.
function plotroiSignals_Callback(hObject, eventdata, handles)
global CaTrials
global sorted_CaTrials
fov = get(handles.fov,'String');
roislist = get(handles.roislist,'String');
rois = str2num(roislist);

if(isempty(CaTrials))
    [filename,pathName]=uigetfile('CaSignal*.mat','Load CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        'No CaTrial loaded!'
        return
    end
    load( [pathName filesep filename], '-mat');
end

nam = strrep(CaTrials(1).FileName_prefix,'Image_Registration_5_','');
nam = strrep(nam,'_main_','');
nam = strrep(nam,'_',' ');

if(isempty(sorted_CaTrials) && (get(handles.CaTrials_select,'Value')~=1) )
    [filename,pathName]=uigetfile('sorted_CaSignal*.mat','Load sorted_CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        'No sorted_CaTrial loaded!'
        return
    end
    load( [pathName filesep filename], '-mat');
end


if (length(rois) > CaTrials(1).nROIs)
    rois = 1:CaTrials(1).nROIs;
    set(handles.roislist,'String',num2str(rois));
end
if(get(handles.CaTrials_select,'Value') ==1)
    tag_trialtypes =0;
    sfx='Unsort';
    trialtypes = ones(length(CaTrials),1);
    
    plot_roiSignals(CaTrials,fov,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);
elseif(get(handles.sorted_CaTrials_select,'Value') ==1)
    %     global sorted_CaTrials
    tag_trialtypes =1;
    sfx = 'Bsort';
    count =0;
    trialorder  = [sorted_CaTrials.hits , sorted_CaTrials.misses , sorted_CaTrials.cr, sorted_CaTrials.fa];
    disp('order = hits misses cr  fa')
    trialtypes = zeros(length(trialorder),1);
    trialtypes(count+1:count+length(sorted_CaTrials.hits )) = 1;
    count = count +length(sorted_CaTrials.hits);
    
    if(isempty(sorted_CaTrials.misses))
        'No Miss Trials in this list'
    else
        trialtypes(count+1:count+length(sorted_CaTrials.misses )) = 2;
        count = count +length(sorted_CaTrials.misses );
    end
    
    if(isempty(sorted_CaTrials.cr))
        'No Correct Rejection Trials in this list'
        
    else
        trialtypes(count+1:count+length(sorted_CaTrials.cr )) = 3;
        count = count +length(sorted_CaTrials.cr );
    end
    
    
    if(isempty(sorted_CaTrials.fa))
        'No False alarm Trials in this list'
    else
        trialtypes(count+1:count+length(sorted_CaTrials.fa )) = 4;
    end
    
    plot_roiSignals(CaTrials(trialorder),fov ,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);
    
    if(get(handles.sortwtouchInfo,'Value')==1)
        %% sort by trial time in session
        tag_trialtypes =1;
        sfx = 'TSort';
        count =0;
        trialorder  = [sorted_CaTrials.touch , sorted_CaTrials.notouch];
        disp('order = touch notouch')
        trialtypes = zeros(length(trialorder),1);
        trialtypes(count+1:count+length(sorted_CaTrials.touch )) = 1;
        count = count +length(sorted_CaTrials.touch);
        trialtypes(count+1:count+length(sorted_CaTrials.notouch )) = 3;
        count = count +length(sorted_CaTrials.notouch );
        plot_roiSignals(CaTrials(trialorder),fov ,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);
        
        %% sort by bar_pos_trial
        tag_trialtypes =1;
        sfx = 'TSort_barpos';
        count =0;
        trialtypes = zeros(length(trialorder),1);
        touchinds = zeros(length(sorted_CaTrials.touch_barpos),1);
        notouchinds = zeros(length(sorted_CaTrials.notouch_barpos),1);
        
        barpositions1 = [ unique(sorted_CaTrials.touch_barpos')];
        for i=1:length(barpositions1)
            inds= find(sorted_CaTrials.touch_barpos==barpositions1(i)) ;
            touchinds(count+1:count+length(inds))=inds;
            trialtypes(count+1:count+length(inds)) = i;
            count = count +length(inds);
        end
        offset = count;
        count=0;
        barpositions2 = unique(sorted_CaTrials.notouch_barpos');
        for j=1:length(barpositions2)
            inds= find(sorted_CaTrials.notouch_barpos==barpositions2(j)) ;
            notouchinds(count+1:count+length(inds))=inds;
            trialtypes(offset+count+1:offset+count+length(inds)) = find(barpositions1==barpositions2(j));
            count = count +length(inds);
        end
        
        trialorder  = [sorted_CaTrials.touch(touchinds) , sorted_CaTrials.notouch(notouchinds)];
        disp('order = touch_barpos_Ant(Top)-Post(Bottom) notouch_barpos_Ant(Top)-Post(Bottom)')
        plot_roiSignals(CaTrials(trialorder),fov ,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);
        
    end
else(get(handles.contact_CaSignal_select,'Value')==1)
    
    global contact_CaTrials
    tag_trialtypes =0;
    sfx ='Csort';
    trialtypes = ones(length(contact_CaTrials),1);
    plot_roiSignals(contact_CaTrials,fov,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);
    
    
    %% sort by bar_pos_trial
    tag_trialtypes =1;
    sfx = 'CSort_barpos';
    count =0;
    trialtypes = ones(length(contact_CaTrials),1);
    
    touchinds = zeros(length(contact_CaTrials),1);
    barposall=cell2mat(arrayfun(@(x) x.barpos, contact_CaTrials, 'uniformoutput',false));
    barpositions1 = unique(barposall);
    for i=1:length(barpositions1)
        inds= find(barposall==barpositions1(i)) ;
        touchinds(count+1:count+length(inds))=inds;
        trialtypes(count+1:count+length(inds)) = i;
        count = count +length(inds);
    end
    
    %         trialorder  = [sorted_CaTrials.touch(touchinds) ];%, sorted_CaTrials.notouch(notouchinds)];
    disp('order = touch_barpos_Ant(Top)-Post(Bottom)');% notouch_barpos_Ant(Top)-Post(Bottom)')
    
    plot_roiSignals(contact_CaTrials(touchinds),fov,rois,roislist,tag_trialtypes,trialtypes,sfx,nam);

    
end
    javaaddpath('/Users/ranganathang/Documents/MATLAB/universal/helper_funcs/jheapcl/jheapcl/MatlabGarbageCollector.jar')
    jheapcl(1)


function wSig_datapath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function wSig_datapath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadwSigsessionInfo.
function loadwSigsessionInfo_Callback(hObject, eventdata, handles)
global sessionInfo
global wSigTrials
global wsArray
global solo_data

basedatapath = get(handles.wSig_datapath,'String');
try
    cd (basedatapath);
    basedatapath = uigetdir(basedatapath,'Pick the base folder');
catch
    basedatapath = uigetdir('/Volumes/','Pick the base folder');
end
cd (basedatapath);
set(handles.wSig_datapath,'String',basedatapath);


files = dir('wsArray*.mat');
if(isempty(files))
    [filename,pathName]=uigetfile('wsArray*.mat','Load wsArray.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
    return
    end
else
    filename = files(1).name;
    pathName = pwd;
    set(handles.wSig_datapath,'String',pathName);
    load( [pathName filesep filename],'-mat');
end

cd('./solo_data');
files = dir('solodata*.mat');
if(isempty(files))
    [filename,pathName]=uigetfile('solodata*.mat','Load solo_data.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
    return
    end
else
    filename = files(1).name;
    pathName = pwd;
    load( [pathName filesep filename],'-mat');
end
cd ..

files = dir('wSigTrials*.mat');
if(isempty(files))
    [filename,pathName]=uigetfile('wSigTrials*.mat','Load wSig.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
    return
    end
else
    filename = files(1).name;
    pathName = pwd;
    load( [pathName filesep filename],'-mat');
end

files = dir('SessionInfo*.mat');
if(isempty(files))
    [filename,pathName]=uigetfile('SessionInfo*.mat','Load SessionInfo.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
    return
    end
else
    filename = files(1).name;
    pathName = pwd;
    load( [pathName filesep filename],'-mat');
end

bartheta_all=cellfun(@(x) x.mThetaNearBar,wSigTrials,'uniformoutput',false);
wSigfilenames =cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false);
wSig_trials = str2num(char(wSigfilenames));

wSig_nogotrials=ismember(wSig_trials,sessionInfo.nogotrials);
temp = bartheta_all(wSig_nogotrials);
nogo_bartheta = nanmean(cell2mat(temp));

wSig_gotrials=ismember(wSig_trials,sessionInfo.gotrials);

go_bartheta = zeros(size(sessionInfo.gopos));

for k = 1: length( sessionInfo.gopos)
    gotrials_at_currentpos = find(sessionInfo.bar_coords(:,1) == sessionInfo.gopix(k,1));
    bartheta_at_currentpos = cell2mat(bartheta_all(gotrials_at_currentpos));
    if ~isempty(find(~isnan(bartheta_at_currentpos)))        
        go_bartheta (k) = nanmean(bartheta_at_currentpos);
    else
        go_bartheta (k) = nan;
    end
    
end

sessionInfo.nogo_bartheta = nogo_bartheta;
sessionInfo.go_bartheta   = go_bartheta;
cd (pathName);
save(filename, 'sessionInfo');




% --- Executes on button press in plotwSigData.
function plotwSigData_Callback(hObject, eventdata, handles)
global sessionInfo
global wSigTrials
global wsArray
global solo_data

folder = dir('plots');
if length(folder) <1
    mkdir ('plots');
end
d = './plots';
restrictTime = str2num(get(handles.timewindow_wSiganal,'String'));
epoch_threshold = 2.5;
if(get(handles.select_plot_SetAmp,'Value'))
    timewindow = [.5 , 4];
    plot_SetAmp(d,wsArray,solo_data,restrictTime,timewindow,epoch_threshold,1);
end

set = {};
gopix = sessionInfo.gopix;
nogopix =  sessionInfo.nogopix;
numgotrials = zeros(size(gopix,1),1);
numnogotrials = [];
set.gotrials = sessionInfo.gotrials';
set.nogotrials = sessionInfo.nogotrials';
wAmp = zeros(4,2);
barposmat = sessionInfo.bar_coords;
 
% get trial names
if sum(ismember(wSigTrials{1}.trackerFileName,'gr')) >0
    wSigfilenames =char(cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false));
else
    wSigfilenames =char(cellfun(@(x) x.trackerFileName(30:33),wSigTrials,'uniformoutput',false));
    
end
wSigtrials=str2num(wSigfilenames);
trialtypes = cellfun(@(x) x.trialType,wSigTrials);
trialsets = {'nogo','go','hit','miss','CR','FA'};
for i = 1:4
    temp  = find(trialtypes==i);
    str = [trialsets{i+2} 'trials'];
    set.(str)  = wSigtrials(temp);
end
pd =  pwd;
%% get trial blocks
numblocks = str2num(get(handles.numblocks,'String'));
trialblocks=strsplit(get(handles.trialswindow,'String'),';');
tags =strsplit(get(handles.trialswindow_tag,'String'));
numblocks = size(tags,2);
if(numblocks==1)
    tags={tags};
    trialblocks={trialblocks};
end

blocks = struct('tag','','gotrialnums',[],'nogotrialnums',[],'gotrialnames',[],'nogotrialnames',[],'hittrialnums',[],'hittrialnames',[],...
                'misstrialnums',[],'misstrialnames',[],'CRtrialnums',[],'CRtrialnames',[],'FAtrialnums',[],'FAtrialnames',[]);

 trialsets = {'nogo','go','hit','miss','CR','FA'};

for sets = 1:6
    for i=1:numblocks
        blocks.tag{i}= tags{i};
        temp = str2num(trialblocks{i});
        str = [trialsets{sets} 'trials'];
        curr_trials = set.(str);
        ind= find(ismember(curr_trials ,temp(1,:)));
        str = [trialsets{sets} 'trialnames'];
        blocks.(str){i}= curr_trials(ind);

        temp= zeros(length(curr_trials(ind)),1);
        for k=1:length(curr_trials(ind))
            if (ismember(blocks.(str){i}(k),wSigtrials))
%                 k
                temp(k)=find(wSigtrials==blocks.(str){i}(k));
            end
        end
        temp(temp==0)=[];
        str2 =  [trialsets{sets} 'trialnums'];
        blocks.(str2){i}=temp;
    end
end
avg_trials = str2num(get(handles.wh_trialstoavg,'string')); %% these many from last
plot_whiskerfits = get(handles.plot_fittedwhisker,'Value');
timewindowtag = cell2mat(strcat('Trials',strrep(trialblocks,':','_'),'pole',get(handles.timewindowtag,'String')));

min_meanbarpos = str2double(get(handles.min_meanbartheta,'String'));
baseline_barpos = str2double(get(handles.baseline_meanbarpos,'String'));

trialsets = {'nogo','go','hit','miss','CR','FA'};

for sets = [1,2,3,4,5,6]
    str= [trialsets{sets} 'trialnums']; 
    if (size(blocks.(str){1},1) < 20)
        ['Too few trials for type ' str ' :Skipping']
        continue
    end
    var_set = {'thetaenvtrials';'time';'dist';'bins';'amp';'meandev_thetaenv';'meandev_thetaenv_binned';'meanpole_thetaenv';'meanpole_thetaenv_binned';...
                'meandev_whiskamp';'meandev_whiskamp_binned'; 'meanpole_whiskamp';'meanpole_whiskamp_binned'; ...
                'peakdev_thetaenv'; 'peakdev_thetaenv_binned'; 'prepole_thetaenv'; 'prepole_thetaenv_binned'; 'prcoccupancy'; 'prcoccupancy_binned';'prcoccupancy_epoch'; 'prcoccupancy_epoch_binned';...
                'pval'; 'mean_barpos';'biased_barpos';'baseline_barpos';'occupancy';'occupancybins';...
                'totalTouchKappa';'maxTouchKappa';'kappatrials'};
            % 'totaldev_whiskamp'; 'totaldev_whiskamp_binned'; 'totalpole_whiskamp'; 'totalpole_whiskamp_binned';
%     [w_thetaenv] =   wdatasummary_devepoch(sessionInfo,wSigTrials,blocks.tag,blocks.(str),avg_trials,gopix,nogopix,restrictTime,pd,plot_whiskerfits,trialsets{sets},timewindowtag,min_meanbarpos,baseline_barpos,2.5);
    [w_thetaenv] =   wdatasummary_wepoch(sessionInfo,wSigTrials,blocks.tag,blocks.(str),avg_trials,gopix,nogopix,restrictTime,pd,plot_whiskerfits,trialsets{sets},timewindowtag,min_meanbarpos,baseline_barpos,epoch_threshold);

    for i=1:numblocks
        for v = 1:length(var_set)
            blocks.([trialsets{sets} '_' var_set{v}]){i} = w_thetaenv.(var_set{v}){i};
        end

    end
    
end
fpath = pwd;
fpath = [fpath filesep 'plots' filesep timewindowtag];
list = dir('wSigTrials*.mat');
fname = list(1).name;
fname = strrep(fname,'wSigTrials','wSigBlocks');
blocks.fname = fname;
fname = [fpath filesep fname];
save(fname,'blocks');
javaaddpath('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/jheapcl/jheapcl/MatlabGarbageCollector.jar')
jheapcl(1);


% --- Executes on button press in zstack_avg.
function zstack_avg_Callback(hObject, eventdata, handles)

[filename,path] = uigetfile('*.tif','Pick the zstack file');
cd(path);
finfo = imfinfo(filename);
if isfield(finfo, 'ImageDescription')
    [header] = extern_scim_opentif(filename);
    n_channel = length(header.SI4.channelsSave);
    %     header.width = header.acq.pixelsPerLine;
    %     header.height = header.acq.linesPerFrame;
    header.n_frame = length(finfo);
end
n_channel=2;
header.width = finfo(1).Width;
header.height = finfo(1).Height;
channel= get(handles.zstack_channel,'String');
if n_channel > 1
    if strncmpi(channel, 'g', 1)
        firstframe = 1;
        step = n_channel;
    elseif strncmpi(channel, 'r', 1)
        firstframe = 2;
        step = n_channel;
    else
        error('unknown channel name?')
    end
else
    firstframe = 1;
    step = 1;
end

im = zeros(header.height, header.width, header.n_frame/step, 'uint16');

count = 0;
for i = firstframe : step : length(finfo)
    count = count+1;
    im (:,:,count) = imread(filename, i);
end



nframes = str2num(get(handles.zstack_nframes,'String') );
temp = uint16(zeros(size(im,1),size(im,2),size(im,3)/nframes));
% temp = zeros(size(im,1),size(im,2),nframes);
im_avg=uint16(zeros(size(im,1),size(im,2),size(im,3)/nframes));
count=0;
% for i = 1:size(im,3)/nframes
for i = 1:nframes
    temp = im(:,:,count+1:count+size(im,3)/nframes);
    im_avg =im_avg+ temp;
    count=count+size(im,3)/nframes;
    % % %    temp = im(:,:,count+1:count+nframes);
    % % %    im_avg(:,:,i) = mean(temp,3);
    % % %     count=count+nframes;
end
im_avg(:,:,:)=im_avg(:,:,:)./nframes;
imwrite(uint16(im_avg(:,:,1)),colormap(gray), ['zstack' filename(length(filename)-7 : length(filename)-4) '.tiff'])
for i = 2:size(im,3)/nframes
    imwrite(uint16(im_avg(:,:,i)),colormap(gray), ['zstack' filename(length(filename)-7 : length(filename)-4) '.tiff'], 'writemode', 'append')
end


function zstack_channel_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function zstack_channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstack_nframes_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function zstack_nframes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Image_disp_axes1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function export2avi_button_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SaveFrameButton_CreateFcn(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function Image_disp_axes2_CreateFcn(hObject, eventdata, handles)




function barpos1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function barpos1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function barpos2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function barpos2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function coords1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function coords1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function coords2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function coords2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coords2 (see GCBO)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function solo_datapath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, af0ter setting all properties.
function solo_datapath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_solo_obj.
function load_solo_obj_Callback(hObject, eventdata, handles)
global solo_data
basedatapath = get(handles.solo_datapath,'String');
cd (basedatapath);
[filename,pathName]=uigetfile('*.mat','Load solo_data.mat file')
if isequal(filename, 0) || isequal(pathName,0)
    return
end
set(handles.solo_datapath,'String',pathName);
cd(pathName);
load( [pathName filesep filename], '-mat');




% --- Executes on button press in uigetsolo.
function uigetsolo_Callback(hObject, eventdata, handles)

[filename,pathName]=uigetfile('data*.mat','Load behavior data .mat file');
if isequal(filename, 0) || isequal(pathName,0)
    return
end
set(handles.SoloDataPath,'String',pathName);
set(handles.SoloDataFileName,'String',filename(1 :length(filename)-4));
set(handles.SoloSessionID,'String',filename(length(filename)-10 :length(filename)-4));
if sum(ismember(filename,'gr'))>2
    set(handles.AnimalNameEdit, 'String',filename(length(filename)-19 :length(filename)-12));
else
    set(handles.AnimalNameEdit, 'String',filename(length(filename)-20 :length(filename)-12));
end
load([pathName filesep filename]);
set(handles.SoloEndTrialNo, 'String', saved.AnalysisSection_NumTrials);

[imaging_datapath] = uigetdir(pathName,'Setimaging data path');
if isequal(imaging_datapath, 0)
else
    cd (imaging_datapath);
    list = dir('Image*.tif');
    filenames =cell2mat(arrayfun(@(x) x.name(length(x.name)-6 :length(x.name)-4),list,'uniformoutput',false));
    trials=str2num(filenames);
    alltrials = 1:saved.AnalysisSection_NumTrials;
    excluded=alltrials;
    excluded(find(ismember(alltrials,trials)))=[];
    set(handles.behavTrialNoToBeExcluded, 'String',num2str(excluded));
end
cd (pathName);




% --- Executes during object creation, after setting all properties.
function CaSignalrois_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in sort_CaSignal.
function sort_CaSignal_Callback(hObject, eventdata, handles)
global CaTrials

if(get(handles.sortwtouchInfo,'Value')==1)
    global sessObj
    [filename,pathname]=uigetfile('wSigTrials*.mat','Load wSigTrials.mat file');
    load([pathname filesep filename]);
    %     nametag = strrep(filename,'wSigTrials','');
end

if(isempty(CaTrials))
    msgbox( 'Load Casignal data');
    return;
elseif~(isfield(CaTrials,'behavTrial'))
    msgbox( 'Add behav trials (Prim panel)');
    return;
else
    nametag = strrep(CaTrials(1).behavTrial.sessionName, ['data_@' CaTrials(1).behavTrial.protName],'');
    trialCorrects = arrayfun(@(x) x.behavTrial.trialCorrect, CaTrials,'uniformoutput',false);
    [sorted,sortedtrialinds] = sort(cell2mat(trialCorrects),'descend');
    
    
    correcttrials = sortedtrialinds(find(sorted==1)); %% contains hits and correct rejections trial inds
    incorrecttrials = sortedtrialinds(find(sorted==0));%% xontains misses and false positives trial inds
    
    correcttrialstypes = arrayfun(@(x) x.behavTrial.trialType, CaTrials(correcttrials),'uniformoutput',false);
    incorrecttrialstypes = arrayfun(@(x) x.behavTrial.trialType, CaTrials(incorrecttrials),'uniformoutput',false);
    
    %     sortedtrialinds = zeros(1,length(sortedtrialinds));
    %     [sorted,sortedtrialinds1] = sort(cell2mat(correcttrialstypes),'descend');
    %     sorted_CaTrials.hits = correcttrials(find(sorted==1));
    %     sorted_CaTrials.cr = correcttrials(find(sorted==0));
    %      sortedtrialinds(1:length(sortedtrialinds1)) = correcttrials(sortedtrialinds1);
    %      [sorted,sortedtrialinds2] = sort(cell2mat(incorrecttrialstypes),'descend');
    %     sorted_CaTrials.misses = incorrecttrials(find(sorted==1));
    %     sorted_CaTrials.fa = incorrecttrials(find(sorted==0));
    %      sortedtrialinds(length(sortedtrialinds1)+1:length(sortedtrialinds1)+length(sortedtrialinds2)) = incorrecttrials(sortedtrialinds2);
    %
    sortedtrialinds(1:end) = 0;
    sorted_CaTrials.hits = correcttrials(find(cell2mat(correcttrialstypes)==1));
    sorted_CaTrials.cr = correcttrials(find(cell2mat(correcttrialstypes)==0));
    
    sorted_CaTrials.misses = incorrecttrials(find(cell2mat(incorrecttrialstypes)==1));
    sorted_CaTrials.fa = incorrecttrials(find(cell2mat(incorrecttrialstypes)==0));
    
    if(get(handles.sortwtouchInfo,'Value')==1)
        names=arrayfun(@(x) x.FileName(length(x.FileName)-6:length(x.FileName)-4), CaTrials,'uniformoutput',false);%%FileName_prefix removes everything but the trial counter
        CaSig_trialnums = str2num(char(names));%from trial filenames
        names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wSigTrials,'uniformoutput',false);
        wSig_trialnums =str2num(char(names)); % from trial filenames
        common_trialnums=CaSig_trialnums(find(ismember(CaSig_trialnums,wSig_trialnums)));
        temp=wSig_trialnums(find(ismember(wSig_trialnums,CaSig_trialnums)));
        if(size(temp,1)<size(common_trialnums,1))
            common_trialnums=temp;
        end
        
        tags = find(ismember(CaSig_trialnums,common_trialnums));
        CaSig_tags = tags;
        ind = zeros(length(tags),1);
        ind (find(ismember(tags,sorted_CaTrials.hits)))=1;
        ind (find(ismember(tags,sorted_CaTrials.cr)))=3;
        ind (find(ismember(tags,sorted_CaTrials.misses)))=2;
        ind (find(ismember(tags,sorted_CaTrials.fa)))=4;
        
        tags = find(ismember(wSig_trialnums,common_trialnums));
        wSig_tags=tags;
        trialnums=common_trialnums;% wrt CaTrials indices
        trialinds = 1:length(trialnums);
        whiskerID =1;
        contacttimes=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
        notouchtrials = find(cellfun(@isempty,contacttimes));
        %sorted_CaTrials.touch
        sorted_CaTrials.notouch =CaSig_tags(notouchtrials)';
        sorted_CaTrials.notouch_barpos =cell2mat(cellfun(@(x) x.bar_pos_trial(1,1), wSigTrials(wSig_tags(notouchtrials)),'uniformoutput',false)); % Y position alone A-P
        
        touchtrials = find(~cellfun(@isempty,contacttimes));
        sorted_CaTrials.touch =CaSig_tags(touchtrials)';
        sorted_CaTrials.touch_barpos=cell2mat(cellfun(@(x) x.bar_pos_trial(1,1), wSigTrials(wSig_tags(touchtrials)),'uniformoutput',false));
        
        % % %     for i=1:length(trialinds)
        % % %
        % % %             TrialName = strrep(CaTrials(CaSig_tags(i)).FileName,CaTrials(CaSig_tags(i)).FileName_prefix,'');
        % % %             TrialName=strrep(TrialName,'.tif','');
        % % %             sessObj(i).dff = CaTrials(CaSig_tags(i)).dff;
        % % %             sessObj(i).ts = {[1:size(CaTrials(CaSig_tags(i)).dff,2)]*CaTrials(CaSig_tags(i)).FrameTime};
        % % %             sessObj(i).theta = wSigTrials{wSig_tags(i)}.theta;
        % % %             sessObj(i).kappa = wSigTrials{wSig_tags(i)}.kappa;
        % %             sessObj(i).velocity = wSigTrials{wSig_tags(i)}.Velocity;
        % %             sessObj(i).deltaKappa = wSigTrials{wSig_tags(i)}.deltaKappa;
        % %             sessObj(i).ts_wsk = wSigTrials{wSig_tags(i)}.time;
        % %             sessObj(i).contactdir = wSigTrials{wSig_tags(i)}.contact_direct;
        % %             sessObj(i).FrameTime = CaTrials(CaSig_tags(i)).FrameTime;
        % %             sessObj(i).nframes = CaTrials(CaSig_tags(i)).nFrames;
        % %             sessObj(i).CaSigTrialind=CaTrials(CaSig_tags(i)).TrialNo;
        % %             sessObj(i).TrialName= TrialName;
        % %             sessObj(i).nROIs = CaTrials(CaSig_tags(i)).nROIs;
        % %             sessObj(i).contacts=wSigTrials{wSig_tags(i)}.contacts;
        % %             sessObj(i).barpos = cellfun(@(x) x.bar_pos_trial(1,1), wSigTrials(wSig_tags(touchtrials)),'uniformoutput',false);
        % %             switch(ind(i))
        % %                 case(1)
        % %                     sessObj(i).trialtype = 'Hit';
        %                 case(2)
        %                     sessObj(i).trialtype = 'Miss';
        %                 case(3)
        %                     sessObj(i).trialtype = 'CR';
        %                 case(4)
        %                     sessObj(i).trialtype = 'FA';
        %
        %             end
        %             if( isfield(CaTrials, 'ephusTrial'))
        %                 sessObj(i).licks = CaTrials(CaSig_tags(i)).ephusTrial.licks;
        %                 sessObj(i).poleposition = CaTrials(i).ephusTrial.poleposition;
        %                 sessObj(i).ephuststep = CaTrials(i).ephusTrial.ephuststep;
        %             end
        %     end
        dirname = pwd;
        sessdir = strrep(dirname,'/fov_01001/fluo_batch_out/',''); %% save under roi folder
        % %     roiname = strrep(sessname,'/fov_01001/fluo_batch_out/','');
        %     save('sessObj','sessObj');
    end
    save(['sorted_CaTrials' nametag],'sorted_CaTrials');
end


% --- Executes on button press in CaTrials_select.
function CaTrials_select_Callback(hObject, eventdata, handles)
set(handles.CaTrials_select,'Value',1);
set(handles.sorted_CaTrials_select,'Value',0);
set(handles.contact_CaSignal_select,'Value',0);
% --- Executes on button press in sorted_CaTrials_select.
function sorted_CaTrials_select_Callback(hObject, eventdata, handles)
set(handles.sorted_CaTrials_select,'Value',1);
set(handles.CaTrials_select,'Value',0);
set(handles.contact_CaSignal_select,'Value',0);

% --- Executes on button press in compute_contact_CaSignal.
function compute_contact_CaSignal_Callback(hObject, eventdata, handles)
global wSigTrials
global CaTrials
global sorted_CaTrials
global contact_CaTrials
global sessionObj
framerate = 500; % Hz
whiskerID =1;
S = {'Protract';'Retract'};
[Selection,ok] = listdlg('PromptString','Select direction of touch','ListString',S,'SelectionMode','single','ListSize',[160,100])

selected_contact_direct = S{Selection};
if(isempty(wSigTrials))
    [filename,pathname]=uigetfile('wSigTrials*.mat','Load wSigTrials.mat file');
    load([pathname filesep filename]);
    nametag = strrep(filename,'wSigTrials','');
else
    nametag = [ '_' wSigTrials{1}.mouseName '_' wSigTrials{1}.sessionName];
    
end

if(isempty(CaTrials))
    [filename,pathname]=uigetfile('CaTrials*.mat','Load CaTrials.mat file');
    load([pathname filesep filename]);
end

if(isempty(sorted_CaTrials))
    [filename,pathname]=uigetfile('sorted_CaTrials*.mat','Load sorted_CaTrials.mat file');
    load([pathname filesep filename]);
end

names=arrayfun(@(x) x.FileName(length(x.FileName)-6:length(x.FileName)-4), CaTrials,'uniformoutput',false);%%FileName_prefix removes everything but the trial counter
CaSig_trialnums = str2num(char(names));%from trial filenames
names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wSigTrials,'uniformoutput',false);
wSig_trialnums =str2num(char(names)); % from trial filenames
[common_trialnums,ctags,wtags]=intersect(CaSig_trialnums,wSig_trialnums);

ind = zeros(length(ctags),1);
ind (find(ismember(ctags,sorted_CaTrials.hits)))=1;
ind (find(ismember(ctags,sorted_CaTrials.cr)))=3;
ind (find(ismember(ctags,sorted_CaTrials.misses)))=2;
ind (find(ismember(ctags,sorted_CaTrials.fa)))=4;
[Y,indorder] = sort(ind,'ascend');

%% removing nogo trials
nogotrials = find(Y>2);
Y(nogotrials) = [];
indorder(nogotrials)=[];
ind(nogotrials) = [];


CaSig_tags = ctags(indorder);
% %  [lia,locb] = ismember(wSig_trialnums,common_trialnums);
% % tags =wSig_trialnums (lia);
wSig_tags=wtags(indorder);

trialnums=common_trialnums(indorder);% wrt CaTrials indices
trialinds = 1:length(trialnums);







%% removing contacttimes outside bar available time
contacttimes=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);


for i = 1: length(trialnums)
    barOntime= CaTrials(CaSig_tags(i)).behavTrial.pinDescentOnsetTime;
    barOfftime=CaTrials(CaSig_tags(i)).behavTrial.pinAscentOnsetTime;
    firsttouches = contacttimes{i};
    %            extraneouscontacts = contacttimes
end



%% removing all trials with no contact (try plotting only for this later)
contacttimes=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
numtrials = size(contacttimes,2);
nocontacts = find(cellfun(@isempty,contacttimes));
trialinds(nocontacts) =[];

contacttimes=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
thetavals=cellfun(@(x) x.theta{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
kappavals=cellfun(@(x) x.kappa{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Velocity=cellfun(@(x) x.Velocity{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Setpoint=cellfun(@(x) x.Setpoint{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Amplitude=cellfun(@(x) x.Amplitude{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
deltaKappa=cellfun(@(x) x.deltaKappa{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
ts_wsk=cellfun(@(x) x.time{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
contactdir=cellfun(@(x) x.contact_direct{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
contacts=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
trialnums(nocontacts) = [];
wSig_tags(nocontacts)=[];
CaSig_tags(nocontacts)=[];
Y(nocontacts)=[];

%% get CaSig data from sorted_CaTrials.CaTRials
CaTrials_data  = arrayfun(@(x) x.dff,CaTrials(CaSig_tags),'uniformoutput',false);
numtrials = length(CaTrials_data);
numrois = size(CaTrials_data{1},1);
numframes =size(CaTrials_data{1},2);
CaSig = zeros(numrois,numframes,numtrials);

for i= 1:numtrials
    tempmat = zeros(size(CaTrials_data,1),size(CaTrials_data,2));
    tempmat = CaTrials_data{i};
    if (size(tempmat,2)>size(CaSig,2))
        CaSig(:,:,i) = tempmat(1:numrois,1:numframes);
    else
        CaSig(:,1:size(tempmat,2),i) = tempmat(:,:);
    end
end

Caframetime = CaTrials.FrameTime;
baseline = 0.5;
dur = 3.0;
wSigframerate = 500;
numpts=ceil((dur+baseline)*wSigframerate);% 3.5seconds worth of data
numframes = ceil((dur+baseline)/Caframetime);% 2.5seconds worth of data

numcontacts =0;
contact_CaTrials=struct('solo_trial',[],'dff',{},'ts',{},'FrameTime',{},'nframes',{},'trialtype',[],'trialCorrect',[],'FileName_prefix',{},'FileName',{},...
    'TrialName',{},   'licks', {},'poleposition',{},'nROIs',{},'theta',{},'kappa',{},...
    'deltaKappa',{},'ts_wsk',{},'contactdir',{},'contacts',{},'barpos',[],'Setpoint',{},'Amplitude',{},'Velocity',{},'total_touchKappa',{},'max_touchKappa',{});
count=0;
handles.aligned_contact = get(handles.align_to_first_touch,'Value'); % 1 for first

ButtonName = questdlg('Is there a .5 s trigger delay in wdata acq?','Data acq mismatch?','Yes','No','No');
switch ButtonName,
 case 'Yes',
  mismatch =1;
 case 'No',
  mismatch =0;
end %

for i = 1:numtrials
    allcontacts = size(contacttimes{i},2);
    if get(handles.align_to_first_touch,'Value')
        pickedcontact=1; %first contact
        contact_CaSig_tag = 'Ftouch';
    elseif get(handles.align_to_last_touch,'Value');
        pickedcontact=allcontacts;%last contact
        contact_CaSig_tag = 'Ltouch';
    end
    numcontacts = 1;
    contactind = zeros(numcontacts,1);
    for j=1:numcontacts
        ind= 1; %first ind
        
        %                   ind= length(contacttimes{i}{1,pickedcontact(j)}); %last ind
        temp=contacttimes{i}{1,pickedcontact(j)}(ind);%for now just the first contact after bartime
        if(temp/wSigframerate<=baseline)&&(allcontacts>1)
            contactind(j) = contacttimes{i}{1,(j+1)}(1);
        elseif(temp/wSigframerate<=baseline)&&(allcontacts==1)
            contactind(j) = ceil(baseline*wSigframerate)+1;
        else
            contactind(j) =temp;% for now just the first contact
        end
        % for now just the first contact
    end
    extractedCaSig = zeros(numrois,numframes);
    extractedTheta=zeros(1,numpts);
    extractedKappa=zeros(1,numpts);
    extractedVelocity=zeros(1,numpts);
    extractedSetpoint=zeros(1,numpts);
    extractedAmplitude=zeros(1,numpts);
    extracteddeltaKappa=zeros(1,numpts);
    extractedts_wsk=zeros(1,numpts);
    contact_sorted_CaSig = zeros(numrois,numframes,numcontacts);
    
    
    for j= 1:numcontacts
        temp_ts_wsk = round(ts_wsk{i}*1000)/1000;
        if mismatch
            temp_ts_wsk = temp_ts_wsk +.5;
        end
        timepoint = temp_ts_wsk(contactind(j));
       
        wdata_indtimes = (timepoint - baseline)+ (1/wSigframerate) :1/wSigframerate: timepoint+dur;
        wdata_indtimes = round (wdata_indtimes*1000)/1000;
        wdata_temp = nan(round((baseline+dur)*wSigframerate),1);
        diff=[0,0];
        if ( timepoint < baseline)
            
        else
             [lia,loc] = ismember(temp_ts_wsk,wdata_indtimes);
             wdata_src_inds = find(lia);
             wdata_dest_inds = loc(find(lia));
        end
       
%         strp = contactind(j)-floor(baseline*wSigframerate);
%         endp=contactind(j)+ceil(dur*wSigframerate);
        
% %         if(strp<1)
% %             diff(1,1)=strp*-1+1;
% %             strp=1;
% %         elseif(endp>length(temp))
% %             diff(1,2)=endp-length(temp);
% %             endp=length(temp);
% %         end
% %         temp=thetavals{i};
% %         extractedTheta(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         temp=kappavals{i};
% %         extractedKappa(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         
% %         temp=Velocity{i};
% %         extractedVelocity(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         temp=Setpoint{i};
% %         extractedSetpoint(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         temp=Amplitude{i};
% %         extractedAmplitude(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         temp=deltaKappa{i};
% %         extracteddeltaKappa(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);
% %         temp=ts_wsk{i};
% %         extractedts_wsk(diff(1,1)+1:numpts-diff(1,2))= temp(strp+1:endp);


        temp=thetavals{i};
        wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedTheta = inpaint_nans(wdata_temp);
        

        temp=kappavals{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedKappa=inpaint_nans(wdata_temp);
        
        temp=Velocity{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedVelocity= inpaint_nans(wdata_temp);
        temp=Setpoint{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedSetpoint= inpaint_nans(wdata_temp);
        temp=Amplitude{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedAmplitude= inpaint_nans(wdata_temp);
        temp=deltaKappa{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extracteddeltaKappa= inpaint_nans(wdata_temp);
        temp=ts_wsk{i};wdata_temp(wdata_dest_inds) = temp(wdata_src_inds);
        extractedts_wsk= inpaint_nans(wdata_temp);
        
        
        extractedcontactdir=contactdir{i};
        extractedcontacts=contacts{i};
        if( isfield(CaTrials, 'ephusTrial') && ~isempty(CaTrials(i).ephusTrial.ephuststep))
            ephussamplerate = 1/CaTrials(i).ephusTrial.ephuststep(1);
            ephusattimepoint = ceil(timepoint*ephussamplerate);
            if( ephusattimepoint< ceil(.5*ephussamplerate))
                diffephus=ceil(.5*ephussamplerate) - ephusattimepoint;
                newbaseline=ephusattimepoint/ephussamplerate;
                ephussamples(1:diffephus)=1;
                ephussamples(diffephus+1:diffephus+ceil((newbaseline+dur)*ephussamplerate)+1) =(ephusattimepoint-ceil(newbaseline*ephussamplerate)+1):( ephusattimepoint+ceil(dur*ephussamplerate)+1);
            else
                ephussamples =(ephusattimepoint-ceil(baseline*ephussamplerate)): min(( ephusattimepoint+ceil(dur*ephussamplerate)),length(CaTrials(i).ephusTrial.ephuststep));
            end
        end
        
        if(timepoint<=.5) 
            strframe=1;
            diff=ceil((0.5-timepoint)/Caframetime);
        else
            strframe=ceil((timepoint-baseline)/Caframetime);
        end
        
        endframe = strframe + numframes-1;
        
        if(endframe>size(CaSig,2))
            extractedCaSig(:,1:size(CaSig,2)-strframe+1) = CaSig(:,strframe:size(CaSig,2),i);
        elseif(timepoint<=baseline)
            
            extractedCaSig(:,diff+strframe:diff+endframe)= CaSig(:,strframe:endframe,i);
        else
            extractedCaSig = CaSig(:,strframe:endframe,i);
        end
        count=count+1;
        % % %             contact_CaTrials{count}=struct{'dff',{extractedCaSig},'FrameTime',CaTrials(CaSig_tags(i)).FrameTime,'nFrames',numframes,...
        % % %                                        'Trialind', CaTrials(CaSig_tags(i)).TrialNo,'TrialNo',trialnums(i),'nROIs',numrois};
        TrialName = strrep(CaTrials(CaSig_tags(i)).FileName,CaTrials(CaSig_tags(i)).FileName_prefix,'');
        TrialName=strrep(TrialName,'.tif','');
        contact_CaTrials(count).solo_trial = str2num(TrialName);
        contact_CaTrials(count).dff = extractedCaSig;
        contact_CaTrials(count).ts = [strframe:endframe].*Caframetime;
        contact_CaTrials(count).theta = {extractedTheta};
        contact_CaTrials(count).kappa = {extractedKappa};
        contact_CaTrials(count).Velocity = {extractedVelocity};
        contact_CaTrials(count).Setpoint = {extractedSetpoint};
        contact_CaTrials(count).Amplitude = {extractedAmplitude};
        contact_CaTrials(count).deltaKappa = {extracteddeltaKappa};
        contact_CaTrials(count).ts_wsk={extractedts_wsk};
        contact_CaTrials(count).contactdir = {extractedcontactdir};
        contact_CaTrials(count).contacts = {extractedcontacts};
        contact_CaTrials(count).FrameTime = CaTrials(CaSig_tags(i)).FrameTime;
        contact_CaTrials(count).nFrames = numframes;
        contact_CaTrials(count).CaSigTrialind=CaTrials(CaSig_tags(i)).TrialNo;
        contact_CaTrials(count).TrialName= TrialName;
        contact_CaTrials(count).nROIs = numrois;
        contact_CaTrials(count).FileName_prefix=CaTrials(CaSig_tags(i)).FileName_prefix;
        %             contact_CaTrials(count).contacts={contactind};
        contact_CaTrials(count).contacts={horzcat(contacttimes{i}{:})};
        contact_CaTrials(count).barpos = wSigTrials{wSig_tags(i)}.bar_pos_trial(1,1);%cellfun(@(x) x.bar_pos_trial(1,1), wSigTrials(wSig_tags),'uniformoutput',false);
        contact_CaTrials(count).total_touchKappa = wSigTrials{wSig_tags(i)}.totalTouchKappaTrial (1,1);
        contact_CaTrials(count).max_touchKappa = wSigTrials{wSig_tags(i)}.maxTouchKappaTrial(1,1);
        
        switch(Y(i))
            case(1)
                contact_CaTrials(count).trialtype = 'Hit';
            case(2)
                contact_CaTrials(count).trialtype = 'Miss';
            case(3)
                contact_CaTrials(count).trialtype = 'CR';
            case(4)
                contact_CaTrials(count).trialtype = 'FA';
        end
        
        if( isfield(CaTrials, 'ephusTrial'))
            if ~isempty(CaTrials(CaSig_tags(i)).ephusTrial.licks)
                
                contact_CaTrials(count).licks = CaTrials(CaSig_tags(i)).ephusTrial.licks(ephussamples);
                contact_CaTrials(count).poleposition = CaTrials(CaSig_tags(i)).ephusTrial.poleposition(ephussamples);
                contact_CaTrials(count).ephuststep = CaTrials(CaSig_tags(i)).ephusTrial.ephuststep(ephussamples);
                
            else
                contact_CaTrials(count).licks = zeros(    (baseline +dur)*10000,1);
                contact_CaTrials(count).poleposition = zeros((baseline +dur)*10000,1);
                contact_CaTrials(count).ephuststep = zeros((baseline +dur)*10000,1);
            end
            
        end
    end
    
end

sorted_CaTrials.contact_trialnums = trialnums;
sorted_CaTrials.contact_trialtypes = Y;


save(['contact_CaTrials' contact_CaSig_tag nametag],'contact_CaTrials');
save(['sorted_CaTrials' nametag], 'sorted_CaTrials');



% --- Executes on button press in contact_CaSignal_select.
function contact_CaSignal_select_Callback(hObject, eventdata, handles)
set(handles.contact_CaSignal_select,'Value',1);
set(handles.sorted_CaTrials_select,'Value',0);
set(handles.CaTrials_select,'Value',0);

% --- Executes during object creation, after setting all properties.
function contact_CaSignal_select_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in contactdetect.
function contactdetect_Callback(hObject, eventdata, handles)
cd(get(handles.baseDataPath,'String'));
files = dir('wsArray*.mat');
if (isempty(files))
    [filename1,path]= uigetfile('wsArray*.mat', 'Load wsArray.mat file');
else
    filename1 = files(1).name;
    path = pwd;
end
load([path filesep filename1]);

files = dir('wSigTrials*.mat');
if (isempty(files))
    [filename2,path]= uigetfile('wSigTrials*.mat', 'Load wSigTrials.mat file');
else
    filename2 = files(1).name;
    path = pwd;
end
load([path filesep filename2]);

contacts_detected = cellfun(@(x) x.contacts{1}, wsArray.ws_trials,'UniformOutput', false);
nodetects =  find(cellfun(@isempty,contacts_detected));
            contDet_param.threshDistToBarCenter = [.1   1.0]; % super lax for bad tracking files
%           contDet_param.threshDistToBarCenter = [.1   .70]; %most lax
%         contDet_param.threshDistToBarCenter = [.1   .50]; %lax
%          contDet_param.threshDistToBarCenter = [.1   .45]; % stringent
%           contDet_param.threshDistToBarCenter = [.1   .4]; % most stringent
        contDet_param.thresh_deltaKappa = [-.1	.1];
        if isempty(wsArray.bar_time_window)
            barTimeWindow = str2num(get(handles.barTimeWindow,'String'));
        else
            barTimeWindow = wsArray.bar_time_window;
        end
         contDet_param.bar_time_window = barTimeWindow;
        %      contDet_param.bar_time_window = cellfun(@(x) x.bar_time_win, wsArray.ws_trials,'UniformOutput', false);

if(size(contacts_detected,2)> size(nodetects,2))
    ButtonName = questdlg('Re-do overwrite contacts?', ...
                         'Contacts question', ...
                         'Yes', 'No', 'Yes');
    switch ButtonName,
     case 'Yes',
        contact_inds = cell(wsArray.nTrials,1);
        contact_direct = cell(wsArray.nTrials,1);
        [contact_inds, contact_direct] = Contact_detection_session_auto(wsArray, contDet_param);
        for i = 1:wsArray.nTrials
            wsArray.ws_trials{i}.contacts = contact_inds{i};
            wsArray.ws_trials{i}.contact_direct = contact_direct{i};
        end
        wSigTrials =wsArray.ws_trials;
        save(filename1, 'wsArray');
        save (filename2,'wSigTrials');
     case 'No',
         
    end
    
else
        contact_inds = cell(wsArray.nTrials,1);
        contact_direct = cell(wsArray.nTrials,1);
        [contact_inds, contact_direct] = Contact_detection_session_auto(wsArray, contDet_param);
        for i = 1:wsArray.nTrials
            wsArray.ws_trials{i}.contacts = contact_inds{i};
            wsArray.ws_trials{i}.contact_direct = contact_direct{i};
        end
        wSigTrials =wsArray.ws_trials;
        save(filename1, 'wsArray');
        save (filename2,'wSigTrials');
end


try
    obj = NX_WhiskerSignalTrialArray([],wSigTrials);
    wsArray = obj;
catch
    ('Error: processing NX_WhiskerSignalTrialArray')
    
end

cd ('./solo_data');
files = dir('solodata*.mat');
if (isempty(files))
    [filename3,path]= uigetfile('solodata*.mat', 'Load solodata.mat file');
else
    filename3 = files(1).name;
    path = pwd;
end
load([path filesep filename3]);
cd ..
names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wsArray.ws_trials,'uniformoutput',false);
wSig_trialnums =str2num(char(names));
    for i = 1:wsArray.nTrials
        try
            wsArray.ws_trials{i}.totalTouchKappaTrial = wsArray.totalTouchKappaTrial{1}(i);
            wsArray.ws_trials{i}.maxTouchKappaTrial = wsArray.maxTouchKappaTrial{1}(i);
        catch
            ('Error: processing wsArray.totalTouchKappaTrial')
            ('Did not process TouchKappa data')
            break
        end 
        inds = (wsArray.ws_trials{i}.distToBar{1} <  contDet_param.threshDistToBarCenter (2));
        wsArray.ws_trials{i}.mThetaNearBar =mean(wsArray.ws_trials{i}.theta{1}(inds));
        wsArray.ws_trials{i}.mKappaNearBar =mean(wsArray.ws_trials{i}.kappa{1}(inds));
        wsArray.ws_trials{i}.trialNum = wSig_trialnums(i);
        n=wSig_trialnums(i);
        switch solo_data.trialTypes(n)
            case 1
                if solo_data.trialCorrects(i)
                     wsArray.ws_trials{i}.trialType = 1; %Hit
                else
                    wsArray.ws_trials{i}.trialType = 2; %Miss
                end
            case 0            
                if solo_data.trialCorrects(i)
                     wsArray.ws_trials{i}.trialType = 3; %CR
                else
                    wsArray.ws_trials{i}.trialType = 4; %FA
                end
        end

    end


    wSigTrials =wsArray.ws_trials;
    save(filename1, 'wsArray');

    save (filename2,'wSigTrials');


    %% adding this to sessObj
    sessObj_found = dir('sessObj.mat');
    if isempty(sessObj_found)
        sessObj = {};
        sessObj.wSigTrials = wSigTrials;
        save('sessObj','sessObj','-v7.3');
    else
        load('sessObj.mat');
        sessObj.wSigTrials = wSigTrials;;
        save('sessObj','sessObj','-v7.3');
    end

% end


% --- Executes on button press in movefine.
function movefine_Callback(hObject, eventdata, handles)



% --- Executes on button press in donottransferROIinfo.
function donottransferROIinfo_Callback(hObject, eventdata, handles)




function trialswindow_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function trialswindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trialswindow_tag_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function trialswindow_tag_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_solodata.
function plot_solodata_Callback(hObject, eventdata, handles)
global solo_data
name = solo_data.sessionName;
uscors = find(name == '_');
sessionID = strrep(name,name(1:uscors(end)),'');

[filename,pathName]=uigetfile('wSigTrials*.mat','Want to add contact info? The load wSigTrials.mat file');
if isequal(filename, 0) || isequal(pathName,0)
    addcontactinfo =0;
else
    addcontactinfo =1;
    load([pathName filesep filename]);
end



figure;

hf1 = subplot(2,1,2);
plot(solo_data.polePositions/100000,'b*','MarkerSize',2);hold on;
plot(solo_data.hitTrialNums,zeros(1,length(solo_data.hitTrialNums)),'gd','MarkerSize',6,'MarkerFaceColor','g');
plot(solo_data.missTrialNums,zeros(1,length(solo_data.missTrialNums)),'rd','MarkerSize',6,'MarkerFaceColor','r');
plot(solo_data.falseAlarmTrialNums,ones(1,length(solo_data.falseAlarmTrialNums)),'rd','MarkerSize',6,'MarkerFaceColor','r');
plot(solo_data.correctRejectionTrialNums,ones(1,length(solo_data.correctRejectionTrialNums)),'gd','MarkerSize',6,'MarkerFaceColor','g');

title(['Pole positions and Trial performance ' name(length(name)-17:length(name)-8) ' Session' name(length(name)-6:length(name)-1)]);
axis([ 0 solo_data.trialStartEnd(2) -.5 2]);
% 
% axis(hf1,[0 solo_data.trialStartEnd(2) -.5 3.5]);
% set(hf1,'YTick',[-.5 0 0.5 1 1.5 2 2.5 3 3.5]);
% 
% axis(AX(2),[0 solo_data.trialStartEnd(2) -.1 1]);
% set(AX(2),'YTick',[-.1:.1:1]);


if addcontactinfo
    if(sum(ismember (wSigTrials{1}.trackerFileName,'anm'))>2)
        wSigfilenames =cellfun(@(x) x.trackerFileName(30:33),wSigTrials,'uniformoutput',false);
    else
        wSigfilenames =cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false);
    end
    whisker_trials = str2num(char(wSigfilenames));
    contacttimes=cellfun(@(x) x.contacts{1}, wSigTrials,'uniformoutput',false)   ;
    nocontactTrials = cellfun(@isempty,contacttimes);
    contactTrials = ~nocontactTrials;
    plot(whisker_trials,nocontactTrials,'kd','MarkerSize',6); hold on;
    lickTrials = solo_data.hitTrialInds + solo_data.falseAlarmTrialInds;
    lickTrials = lickTrials(whisker_trials);
    nolickTrials = solo_data.missTrialInds + solo_data.correctRejectionTrialInds;
    nolickTrials = nolickTrials(whisker_trials);
    
    goTrials = solo_data.hitTrialInds +solo_data.missTrialInds;
    nogoTrials = solo_data.correctRejectionTrialInds + solo_data.falseAlarmTrialInds;
    nogoTrials = nogoTrials(whisker_trials);
    goTrials = goTrials(whisker_trials);
    
    contact_hit = find(goTrials & contactTrials & lickTrials);
    contact_miss = find(goTrials & contactTrials & nolickTrials);
    
%     contact_fa = find((nogoTrials & nocontactTrials & lickTrials);
%     contact_cr = find(nocontactTrials & nolickTrials & nogoTrials);

    contact_fa = find(lickTrials & ~(goTrials & contactTrials));
    contact_cr = find(nolickTrials & ~(goTrials & contactTrials));
     
    for k = 1: length(whisker_trials)
%         trials = whisker_trials(1:k);
        trials = whisker_trials(max(1,k-20):k);

%         trials = whisker_trials(k:min(k+25,length(whisker_trials)));
        hit =  ismember(trials,contact_hit);
        miss =  ismember(trials,contact_miss);
        fa =  ismember(trials,contact_fa);
        cr =  ismember(trials,contact_cr);
        
        num_s1 = sum( hit) + sum( miss );
        num_s0 = sum(fa ) + sum(cr);
        
        pc(k) = (sum(hit) + sum(cr))/(num_s1 + num_s0);
        hit_rate = sum(hit)/num_s1;
        false_alarm_rate = sum(fa)/num_s0;
        
        r(k) = Solo.dprime(hit_rate,false_alarm_rate,num_s1,num_s0);
        
    end
    solo_data.PC_contact = pc;
    solo_data.Dprime_contact = r;
    solo_data.whisker_trials = whisker_trials;
    
    subplot(2,1,1);

    [AX,H1,H2] = plotyy([1:solo_data.trialStartEnd(2)],solo_data.Dprime_null,[1:solo_data.trialStartEnd(2)],solo_data.PC_null);hold on;
    set(get(AX(1),'Ylabel'),'String','Dprime_null');set(get(AX(2),'Ylabel'),'String','PC_null');
%     set(H1,'markersize',6,'Marker','.');set(H2,'markersize',6,'Marker','.') ;
    set(H1,'Linestyle','-','linewidth',1);
    set(H2,'Linestyle','-','linewidth',1);
    axis(AX(1),[0 solo_data.trialStartEnd(2) -.5 3.5]);
    set(AX(1),'YTick',[-.5 0 0.5 1 1.5 2 2.5 3 3.5]);
    
    axis(AX(2),[0 solo_data.trialStartEnd(2) -.1 1]);
    set(AX(2),'YTick',[-.1:.1:1]);
    
    hold(AX(1), 'on');hold(AX(2), 'on');
    [AX,H3,H4] = plotyy(whisker_trials,solo_data.Dprime_contact,whisker_trials,solo_data.PC_contact);
    set(H3,'color',[.5 .5 1.0],'Linestyle','-','linewidth',2);
    set(H4,'color',[.5 1 .5],'Linestyle','-','linewidth',2);
    hold(AX(2), 'off');
    
end

title(['Performance from ' name(length(name)-17:length(name)-8) ' Session' name(length(name)-6:length(name)-1)]);
hold(AX(1), 'off');        hold(AX(2), 'off');
axis(AX(1),[0 solo_data.trialStartEnd(2) -.5 3.5]);
set(AX(1),'YTick',[-.5 0 0.5 1 1.5 2 2.5 3 3.5]);
axis(AX(2),[0 solo_data.trialStartEnd(2) -.1 1]);
set(AX(2),'YTick',[-.1:.1:1]);

% saveas(gcf,'solo_performance_barpos','tif');
 h = gcf;
print(h,'-dtiff','-painters','-loose','solo_performance_barpos')

% saveas(gcf,'solo_performance_barpos','jpg');
save(['solodata_' solo_data.mouseName '_' sessionID],'solo_data');





function timewindow_wSiganal_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function timewindow_wSiganal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_fittedwhisker.
function plot_fittedwhisker_Callback(hObject, eventdata, handles)




function numblocks_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function numblocks_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wh_trialstoavg_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function wh_trialstoavg_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function wSigSum_datapath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function wSigSum_datapath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_wSigSum.
function load_wSigSum_Callback(hObject, eventdata, handles)

global wSigSummary
wSigSummary = {};
basedatapath = get(handles.wSigSum_datapath,'String');
if(length(basedatapath)<1)
    basedatapath = '/Volumes/GR_Data_01/Data/';
end
cd (basedatapath);
count=0;

while(count>=0)
    [filename,pathName]=uigetfile('wSigBlocks*.mat','Load wSigBlocks*.mat file');    
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    separators = find(pathName == filesep);
    load( [pathName filesep filename], '-mat');
    solopath = [pathName(1:separators(length(separators)-2))   'solo_data'];
    solofile = strrep(filename,'wSigBlocks','solodata');
    load([solopath filesep solofile],'-mat');
    set(handles.wSigSum_datapath,'String',pathName);
    blocks.solodata.Dprime_contact = solo_data.Dprime_contact;
    blocks.solodata.PC_contact = solo_data.PC_contact;
    blocks.solodata.Dprime_null = solo_data.Dprime_null;
    blocks.solodata.PC_null = solo_data.PC_null;
    blocks.solodata.polePositions = solo_data.polePositions;
    cd (pathName);
    wSigSummary{count} = blocks;
    
end
folder = uigetdir;
cd (folder);
save('wSigSummary','wSigSummary');
fieldlist = fieldnames(wSigSummary{1,1});
list = strmatch('nogo',fieldlist);
set(handles.wSigblocks_datalist, 'String',list);


% --- Executes on selection change in wSigSum_toplot.
function wSigSum_toplot_Callback(hObject, eventdata, handles)
global wSigSummary
fieldlist = fieldnames(wSigSummary{1,1});
plotlist = get(handles.wSigSum_toplot,'String');
datatoplot =  plotlist(get(handles.wSigSum_toplot,'Value'));
list = strmatch(datatoplot,fieldlist);
set(handles.wSigblocks_datalist, 'String',fieldlist(list));


% --- Executes during object creation, after setting all properties.
function wSigSum_toplot_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_wSigSum.
function plot_wSigSum_Callback(hObject, eventdata, handles)
global wSigSummary
% ButtonName = questdlg('Override mean and biased barpos?', ...
%                          'Override', ...
%                          'Yes', 'No', 'No');
ButtonName = 'No';
switch ButtonName,
     case 'Yes',
        override =1; 
% % %         biased_barpos= str2num(get(handles.current_bartheta,'String'));
% % %         baseline_barpos = str2num(get(handles.unbiased_bartheta,'String'));
% % %         [filename2,path]= uigetfile('SessionInfo*.mat', 'Load SessionInfo.mat file');
% % %         load([path filesep filename2]);
% % % 
% % %         y  =sessionInfo.go_bartheta;
% % %         x = sessionInfo.gopos;
% % %         ind = find(~isnan(y));
% % %         y = y(ind);
% % %         x = x(ind);
% % %         y = sort(y ,'ascend');
% % %         p=polyfit(x,y,1);
% % %         biased_bartheta = round(polyval(p,biased_barpos*10000)*100)/100;
% % %         baseline_bartheta =  round(polyval(p,baseline_barpos*10000)*100)/100;

        biased_bartheta = str2num(get(handles.current_bartheta,'String'));
        baseline_bartheta = str2num(get(handles.unbiased_bartheta,'String'));
        
    case 'No'
        tags=cell2mat(cellfun(@(x) x.tag{1},wSigSummary,'uniformoutput',false)');
        temp = cell2mat(cellfun(@(x) x.nogo_mean_barpos{1}{1},wSigSummary,'uniformoutput',false));
        temp(tags=='B') = nan;
        biased_bartheta = nanmean(temp);
        temp = cell2mat(cellfun(@(x) x.nogo_mean_barpos{1}{1},wSigSummary,'uniformoutput',false));
        temp(tags ~= 'B') = nan;
        baseline_bartheta = nanmean(temp);
end


plotlist = get(handles.wSigSum_toplot,'String');
datatoplot= plotlist{get(handles.wSigSum_toplot,'Value')};


blocks= get(handles.wSigSum_block,'String');
blocklist = blocks(get(handles.wSigSum_block,'Value'));
block= get(handles.wSigSum_block,'Value');
numblocks = length(blocklist);

numsessions=size(wSigSummary,2);
commentstr = get(handles.plot_wSigSum_title,'String');
col = [.75 .75 .75; 1 .6 0];
lwidth = linspace(0 ,1,numsessions);
transparency =  0.5;
legendstr = cell(numsessions,1);
datacollected = zeros(numsessions*70,4,numblocks);


tags=cell2mat(cellfun(@(x) x.tag{1},wSigSummary,'uniformoutput',false)');

num_baseline_sessions = sum(tags=='B');

mindata = 0; maxdata =0;
% plotting Thetaenvelope
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw setpoint
    ah1=axes('Parent',h_fig1);
    title([commentstr{1} 'Theta Envelope' ]);%blocklist{j} 'Data ' datatoplot]);
    
    h_fig2 = figure('position', [300, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %% error from bartheat
    ah2=axes('Parent',h_fig2); title([commentstr{1}  'Theta Envelope Change from Baseline  ' ]);%blocklist{j} 'Data ' datatoplot]);
    hold on;
    %     figure;
    count =0;
    prev=0; 
    datawave = {'meandev_thetaenv_binned','peakdev_thetaenv_binned','meanpole_thetaenv_binned'};

    if(num_baseline_sessions>0)
        baseline_sessions = find(tags == 'B');
        mean_baseline = zeros(length(datawave),1);
         for k = 1:length(datawave)           
            
            selecteddata = strcat(datatoplot,'_',datawave(k));
                for i = 1:num_baseline_sessions
                    temp = wSigSummary{i}.(selecteddata{1});
                    temp = temp{1};
                    binnedydata = temp{block}(:,2)';       
                    mean_baseline (k) = mean_baseline (k)  + mean(binnedydata);
                end
             mean_baseline (k) = mean_baseline (k) / num_baseline_sessions ;
         end
    else
        mean_baseline = 0;
    end
    for i = 1:numsessions
        colr(:,:,2) = [ 0 0 1 ; 1 0 0 ;0 0 0]; % blue red black
        colr(:,:,1) = [ .5 .5 1 ; 1 .5 .5; .5 .5 .5 ]; %
        for k = 1:length(datawave)           
            selecteddata = strcat(datatoplot,'_',datawave(k));
            temp = wSigSummary{i}.(selecteddata{1});
            temp = temp{1};
            binnedxdata = temp{block}(:,1)';
            binnedydata = temp{block}(:,2)';
            binnedydata_sdev = temp{block}(:,3)';
            curr_meanbarpos = wSigSummary{i}.nogo_mean_barpos{1}{1};
            curr_biasedbarpos = wSigSummary{i}.nogo_biased_barpos{1}{1};
            %            mean_bartheta = getfield(wSigSummary{i},strrep(datatoplot,'databinned','meanbar'));
            %            mean_bartheta  = cell2mat(mean_bartheta {1});
            axes(ah1);
            
            if(i<num_baseline_sessions+1)
                tcol = colr(:,:,1);
                errorbar(binnedxdata-binnedxdata(1)+count,binnedydata,binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
                axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -30  max(binnedydata)-10]);
                hline(curr_meanbarpos,{'k--','linewidth',1.5});
                hline(baseline_bartheta ,{'k-','linewidth',1.5});
                
            else
                tcol = colr(:,:,2);
                errorbar(binnedxdata-binnedxdata(1)+count,binnedydata,binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
                axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) min(binnedydata)-10 max(binnedydata)+10 ]);
                %                 hline(biased_bartheta,'r--');
                hline(biased_bartheta,{'r-','linewidth',1.5});
                hline(curr_meanbarpos,{'r--','linewidth',1.5});
            end
            mindata = (mindata<min(binnedydata))*mindata + (mindata>min(binnedydata))*min(binnedydata);
            maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
            collateddata = [binnedxdata;binnedydata]';
            wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata};
            
            legendstr(i) = {['session' num2str(i) ' ']};
            
            axes(ah2);
            if(i<num_baseline_sessions+1)
                tcol = colr(:,:,1);
                
%                 errorbar(binnedxdata+count,(binnedydata-baseline_bartheta),binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
                errorbar(binnedxdata-binnedxdata(1)+count,(binnedydata-mean_baseline(k)),binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;

            else
                tcol = colr(:,:,2);
                %        plot(xdata+count,(ydata-bartheta),'color',col(j,:),'linewidth',1.0);
                errorbar(binnedxdata-binnedxdata(1)+count,(binnedydata-mean_baseline(k)),binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
            end
            legendstr(i) = {['session' num2str(i) ' ']};
            hline(0,{'r-','linewidth',1});
        end
        
        count = count+binnedxdata(end)-binnedxdata(1)+50;
        
    end
    axes(ah1); axis([0 count mindata-5 mindata+35]);grid on; ylabel('Thetaenvelope'); xlabel('Trials');
    legend('Mean Whisk Epoch','Peak Whisk Epoch','Mean Sampling Period');
    title([commentstr{1} 'Theta envelope']);set(gca,'FontSize',18);
    saveas(gcf,['Thetaenv' datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print( h_fig1 ,'-depsc2','-painters','-loose',['Thetaenv ' datatoplot ' ' blocklist{j}]);
    saveas(gcf,['Thetaenv ' datatoplot ' ' blocklist{j}] ,'tif');
    
    
    axes(ah2);axis([0 count -10  25]);grid on; ylabel('delta Theta Envelope'); xlabel('Trials');
    title([commentstr{1} ' Change in Theta envelope ']);set(gca,'FontSize',18);
    legend('Mean Whisk Epoch','Peak Whisk Epoch','Mean Sampling Period');
    saveas(gcf,['dThetaenv'  datatoplot ' ' blocklist{j}] ,'tif');
    saveas(gcf,['dThetaenv'  datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print( h_fig2 ,'-depsc2','-painters','-loose',['Thetaenv Error'  datatoplot ' ' blocklist{j}]);
    hold off;
end
close(h_fig1);
close(h_fig2);


% plotting proccupancy sampling period
mindata =0;
maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    h_fig3 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw theta
    ah3 = axes('Parent',h_fig3);
    title([commentstr 'Percent Ocuupancy past biased bar position ' datatoplot  ]);%blocklist{j} 'Data ' datatoplot]);
    
    h_fig4 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw theta
    ah4 = axes('Parent',h_fig4);
    title([commentstr 'Change in Percent Ocuupancy past biased bar position from baseline' ]);
    
    hold on;
    count =0;
    prev=0;
    datawave = {'prcoccupancy_binned'};

    if(num_baseline_sessions>0)
        baseline_sessions = find(tags == 'B');
        mean_baseline = zeros(length(datawave),1);
         for k = 1:length(datawave)           
            
            selecteddata = strcat(datatoplot,'_',datawave(k));
                for i = 1:num_baseline_sessions
                    temp = wSigSummary{i}.(selecteddata{1});
                    temp = temp{1};
                    binnedydata = temp{block}(:,2)';       
                    mean_baseline (k) = mean_baseline (k)  + mean(binnedydata);
                end
             mean_baseline (k) = mean_baseline (k) / num_baseline_sessions ;
         end
    else
        mean_baseline = 1;
    end    
    
    
    
    for i = 1:numsessions
        selecteddata = strcat(datatoplot,'_',datawave);
        temp = wSigSummary{i}.(selecteddata{1});
        temp = temp{1};
        
        binnedxdata = temp{block}(:,1)';
        binnedydata = temp{block}(:,2)';
        axes(ah3);
        if(i<num_baseline_sessions+1)
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
            
        else
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
            
        end
        hline(0,{'k-','linewidth',1});
        hline(.5,{'r-','linewidth',1});
        legendstr(i) = {['session' num2str(i) ' ']};
        collateddata = [binnedxdata;binnedydata]';
        maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
        wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata}; 
%         count = count+binnedxdata(end)-binnedxdata(1)+50;
        
        axes(ah4);
        if(i<num_baseline_sessions+1)
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) 0 5]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata./mean_baseline,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
            
        else
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) 0 5]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata./mean_baseline,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
            
        end
        hline(0,{'k-','linewidth',1});
        hline(.5,{'k-','linewidth',1});
        legendstr(i) = {['session' num2str(i) ' ']};
        collateddata = [binnedxdata;binnedydata]';
        maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
        wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata}; 
        count = count+binnedxdata(end)-binnedxdata(1)+50;
        
        
    end
    axes(ah3);
    axis([0 count 0 .5]);grid on; ylabel('Percent occupancy past biased position'); xlabel('Trials');
    set(gca,'FontSize',18);  title([commentstr 'Percent Ocuupancy past biased bar position ' datatoplot  ]); 
    saveas(gcf,['PrcOccupancy' datatoplot ' '  blocklist{j}] ,'tif');
    saveas(gcf,['PrcOccupancy'  datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print(h_fig3,'-depsc2','-painters','-loose',['PrcOccupancy' datatoplot ]);
    axes(ah4);
    axis([0 count 0 8]);grid on; ylabel('Change in Percent occupancy past biased position'); xlabel('Trials');
    set(gca,'FontSize',18);   title([commentstr 'Change in Percent Ocuupancy past biased position' datatoplot  ]);
    saveas(gcf,['dPrcOccupancy' datatoplot ' '  blocklist{j}] ,'tif');
    saveas(gcf,['dPrcOccupancy'  datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print(h_fig4,'-depsc2','-painters','-loose',['dPrcOccupancy' datatoplot]);

    
end
hold off;
close(h_fig3);
close(h_fig4);

% plotting proccupancy whisking epochs
% mindata =0;
% maxdata =0;
% for j= 1:numblocks
%     block =j;
%     sc = get(0,'ScreenSize');
%     h_fig5 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw theta
%     ah5 = axes('Parent',h_fig5);
%     title([commentstr 'Percent Ocuupancy past biased bar position from whisk epochs ' datatoplot  ]);%blocklist{j} 'Data ' datatoplot]);
%     
%     h_fig6 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw theta
%     ah6 = axes('Parent',h_fig6);
%     title([commentstr 'Change in Percent Ocuupancy past biased bar position from whisking epochs ' ]);
%     
%     hold on;
%     count =0;
%     prev=0;
%     datawave = {'prcoccupancy_epoch_binned'};
% 
%     if(num_baseline_sessions>0)
%         baseline_sessions = find(tags == 'B');
%         mean_baseline = zeros(length(datawave),1);
%          for k = 1:length(datawave)           
%             
%             selecteddata = strcat(datatoplot,'_',datawave(k));
%                 for i = 1:num_baseline_sessions
%                     temp = wSigSummary{i}.(selecteddata{1});
%                     temp = temp{1};
%                     binnedydata = temp{block}(:,2)';       
%                     mean_baseline (k) = mean_baseline (k)  + mean(binnedydata);
%                 end
%              mean_baseline (k) = mean_baseline (k) / num_baseline_sessions ;
%          end
%     else
%         mean_baseline = 1;
%     end    
%     
%     
%     
%     for i = 1:numsessions
%         selecteddata = strcat(datatoplot,'_',datawave);
%         temp = wSigSummary{i}.(selecteddata{1});
%         temp = temp{1};
%         
%         binnedxdata = temp{block}(:,1)';
%         binnedydata = temp{block}(:,2)';
%         axes(ah5);
%         if(i<num_baseline_sessions+1)
%             axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
%             plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
%             
%         else
%             axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
%             plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
%             
%         end
%         hline(0,{'k-','linewidth',1});
%         hline(.5,{'r-','linewidth',1});
%         legendstr(i) = {['session' num2str(i) ' ']};
%         collateddata = [binnedxdata;binnedydata]';
%         maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
%         wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata}; 
% %         count = count+binnedxdata(end)-binnedxdata(1)+50;
%         
%         axes(ah6);
%         if(i<num_baseline_sessions+1)
%             axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) 0 5]);
%             plot(binnedxdata-binnedxdata(1)+count,binnedydata./mean_baseline,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
%             
%         else
%             axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) 0 5]);
%             plot(binnedxdata-binnedxdata(1)+count,binnedydata./mean_baseline,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
%             
%         end
%         hline(0,{'k-','linewidth',1});
%         hline(.5,{'k-','linewidth',1});
%         legendstr(i) = {['session' num2str(i) ' ']};
%         collateddata = [binnedxdata;binnedydata]';
%         maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
%         wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata}; 
%         count = count+binnedxdata(end)-binnedxdata(1)+50;
%         
%         
%     end
%     axes(ah5);
%     axis([0 count 0 .5]);grid on; ylabel('Percent occupancy from whisking epoch'); xlabel('Trials');
%     set(gca,'FontSize',18);   
%     saveas(gcf,['PrcOccupancy whisk epoch' datatoplot ' '  blocklist{j}] ,'tif');
%     saveas(gcf,['PrcOccupancy whisk epoch'  datatoplot ' ' blocklist{j}],'fig');
%     set(gcf,'PaperPositionMode','auto');
%     print(h_fig5,'-depsc2','-painters','-loose',['PrcOccupancy whisking epoch' datatoplot ' '  blocklist{j}]);
%     axes(ah6);
%     axis([0 count 0 8]);grid on; ylabel('Change in Percent occupancy from whisking epoch'); xlabel('Trials');
%     set(gca,'FontSize',18);   
%     saveas(gcf,['dPrcOccupancy whisk epoch' datatoplot ' '  blocklist{j}] ,'tif');
%     saveas(gcf,['dPrcOccupancy whisk epoch'  datatoplot ' ' blocklist{j}],'fig');
%     set(gcf,'PaperPositionMode','auto');
%     print(h_fig6,'-depsc2','-painters','-loose',['PrcOccupancy whisking epoch' datatoplot ' '  blocklist{j}]);
% 
%     
% end
% hold off;



% plotting whisker amplitude
mindata =0;
maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    ah7=figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); %%raw theta
    %     title([commentstr 'Amplitude Block ' blocklist{j} 'Data ' 'Amp_med']);
    title([commentstr 'Mean whisking amplitude ' datatoplot  ]);%blocklist{j} 'Data ' datatoplot]);
    hold on;
    count =0;
    prev=0;
    for i = 1:numsessions
        
        datawave = {'meandev_whiskamp_binned'};
        selecteddata = strcat(datatoplot,'_',datawave);
        temp = wSigSummary{i}.(selecteddata{1});
        temp = temp{1};
        
        binnedxdata = temp{block}(:,1)';
        binnedydata = temp{block}(:,2)';
        
        if(i<num_baseline_sessions+1)
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
            
        else
            axis([min(binnedxdata-binnedxdata(1)+count) max(binnedxdata-binnedxdata(1)+count) -.1 .6]);
            plot(binnedxdata-binnedxdata(1)+count,binnedydata,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
            
        end
        hline(0,{'k-','linewidth',1});
        hline(.5,{'r-','linewidth',1});
        legendstr(i) = {['session' num2str(i) ' ']};
        collateddata = [binnedxdata;binnedydata]';
        maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
        wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata}; 
        count = count+binnedxdata(end)-binnedxdata(1)+50;
        
    end
    axis([0 count 0 8]);grid on; ylabel('Mean Whisking amplitude'); xlabel('Trials');
    set(gca,'FontSize',18);
    saveas(gcf,['Mean Whisk Amp' datatoplot ' '  blocklist{j}] ,'tif');
    saveas(gcf,['Mean Whisk Amp'  datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print(ah7,'-depsc2','-painters','-loose',['Mean Whisk Amp'  datatoplot ' ' blocklist{j}]);
end
hold off;
close(ah7);
% plotting kappa
mindata =0;
maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    ah8=figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w');
    title([commentstr 'TotalTouchKappa ' datatoplot ]); %' blocklist{j}]);
    
    hold on;
    count =0;
    prev=0;
    for i = 1:numsessions
  
        datawave = {'totalTouchKappa'};
        selecteddata = strcat('go','_',datawave);
        temp = wSigSummary{i}.(selecteddata{1});
        temp = temp{1};
        temp = temp{1};
         ydata = temp(:,2);
         xdata= temp(:,1);
        
        if(i<num_baseline_sessions+1)
            axis([min(xdata+count) max(xdata+count) -10 40]);
            plot(xdata+count,ydata,'color',[.5 .5 .5],'linewidth',.2,'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);
        else
            axis([min(xdata+count) max(xdata+count) -10 40]);

            plot(xdata+count,ydata,'color',[0 0 0 ],'linewidth',.2,'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);

        end
        
        legendstr(i) = {['session' num2str(i) ' ']};
        %        wSigSum_Sessions.thr_durbinned{i,j}= [binnedxdata;binnedydata]';
        collateddata = [xdata;ydata]';
        wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata};
        count = count+binnedxdata(end)+50;

    end
    axis([0 count -15 15]);grid on; ylabel('TotalTouchKappa'); xlabel('Trials');
    set(gca,'FontSize',18);
    saveas(gcf,['TotalTouchKappa'  datatoplot ' ' blocklist{j}] ,'tif');
    saveas(gcf,['TotalTouchKappa'  datatoplot ' ' blocklist{j}],'fig');
    set(gcf,'PaperPositionMode','auto');
    print(ah8,'-depsc2','-painters','-loose',['TotalTouchKappa'  datatoplot ' ' blocklist{j}]);
    hold off;
end
close(ah8);
    plot_dist_sessions(commentstr,numsessions);
    
% plotting performance
mindata = 0; maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    datawave = {'Dprime_contact','PC_contact'};
    ax = {'ah9','ah10'};
    axavg = {'ax11','ax12'};
    colp(:,:,1) = [ 0 0 1 ; 0 1 0 ;];%0 0 0]; %b,g
    colp(:,:,2) = [  .1 .5 .75;.1 .75 .5];% .5 .5 .5 ]; % b,g
    for k = 1:length(datawave)  
        count =0;    
        selecteddata =datawave(k);
        avg_ydata = zeros(numsessions,1);
        h_fig11 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w');        
        ah11=axes('Parent',h_fig11);
        for i = 1:numsessions

            temp = [wSigSummary{i}.gotrialnames{1};wSigSummary{i}.nogotrialnames{1}];
            xdata = sort(temp,'ascend');
            temp = wSigSummary{i}.solodata.(selecteddata{1});  
            xdata(xdata>length(temp)) = [];     
            if(isempty(xdata))
                xdata = 1;
            end
            ydata = temp(xdata)';
            avg_ydata(i) = prctile(ydata,75);        
            if(i<num_baseline_sessions+1)
                tcol = colp(:,:,1);
                plot(xdata+count,ydata,'color',tcol(k,:),'Linewidth',2);hold on;
%                 axis([min(xdata+count) max(xdata+count) .5  2.0]);
            else
                tcol = colp(:,:,2);
                plot(xdata+count,ydata,'color',tcol(k,:),'Linewidth',2);hold on;
%                 axis([min(xdata+count) max(xdata+count) .5  2.0]);
            end
            collateddata = [xdata;ydata]';
            wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata};
            
            legendstr(i) = {['session' num2str(i) ' ']};
            count = count+xdata(end)+50;
            
        end       
        if(k ==1)
            axis([0 count 0 3]);
        else
            axis([0 count 0 1]);
        end
        title([commentstr selecteddata]);set(gca,'FontSize',18);
        saveas(gcf, [commentstr{1} selecteddata{1}],'fig');
        saveas(gcf, [commentstr{1} selecteddata{1}],'tif');
        set(gcf,'PaperPositionMode','auto');
        print( h_fig11 ,'-depsc2','-painters','-loose', [commentstr{1} selecteddata{1}]);
        close (h_fig11);
         
        h_fig12 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); 
        ah12=axes('Parent',h_fig12);
        plot(1:numsessions,avg_ydata,'color',tcol(1,:),'linewidth',2,'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(1,:)); 
        if(k ==1)
            axis([0 numsessions+1 0 3]);
        else
            axis([0 numsessions+1 0 1]);
        end
        set(gca,'FontSize',18);
        saveas(gcf,[commentstr{1} 'Avg_' selecteddata{1}],'fig');
        saveas(gcf,[commentstr{1} 'Avg_' selecteddata{1}],'tif');
        set(gcf,'PaperPositionMode','auto');
        print( h_fig12 ,'-depsc2','-painters','-loose',[commentstr{1} 'Avg_' selecteddata{1}]);
        close (h_fig12);
           
    end  
end
close(h_fig11);
close(h_fig12);
     javaaddpath('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/jheapcl/jheapcl/MatlabGarbageCollector.jar');
     jheapcl(1);
    

% --- Executes on selection change in wSigSum_block.
function wSigSum_block_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function wSigSum_block_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plot_wSigSum_title_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function plot_wSigSum_title_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timewindowtag_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function timewindowtag_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in sortwtouchInfo.
function sortwtouchInfo_Callback(hObject, eventdata, handles)




function ephusDataPath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ephusDataPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in make_ephus_obj.
function make_ephus_obj_Callback(hObject, eventdata, handles)

ephuspath= get(handles.ephusDataPath,'String');
[fname,ephuspath] = uigetfile(ephuspath,'Pick ephus dir');
if isequal(ephuspath, 0)
    return
else
    set(handles.ephusDataPath,'String',ephuspath);
    cd(ephuspath);
end
mouseName = get(handles.AnimalNameEdit, 'String');
sessionID = get(handles.SoloSessionID, 'String');
if((isempty(mouseName))||(isempty(sessionID)))
    msgbox('Fill in details');
    return;
end
% trialStartEnd = [get(handles.SoloStartTrialNo,'value'), get(handles.SoloEndTrialNo,'value')];
% trialStartEnd = [handles.SoloStartTrial,handles.SoloEndTrial];
% mouseName=
obj = ephusTrialArray_gr(mouseName, sessionID,ephuspath);
cd ..
save(['ephusdata_' mouseName '_' sessionID],'obj');
['ephusdata_' mouseName '_' sessionID ':   Saved']

%% adding ephus to sessObj
current_dir = pwd;
separators = find(current_dir == filesep);
session_dir = current_dir(1:separators(length(separators)-0)); % one folder up from ephus_data dir
cd (session_dir);
sessObj_found = dir('sessObj.mat');
if isempty(sessObj_found)
    sessObj = {};
    sessObj.ephusTrials = obj;
    save('sessObj','sessObj','-v7.3');
else
    load('sessObj.mat');
    sessObj.ephusTrials = obj;
    save('sessObj','sessObj','-v7.3');
end
cd (current_dir);
['sessObj :  Saved']


% --- Executes on button press in addephusTrials.
function addephusTrials_Callback(hObject, eventdata, handles)
global CaSignal %  ROIinfo ICA_ROIs
ephuspath = get(handles.ephusDataPath,'String');

[fname,pathName]=uigetfile(ephuspath,'Load the ehus obj');
if(isequal(pathName, 0))
else
    load([pathName filesep fname],'-mat');
end
ephustrials = size(obj,2);
trialStartEnd(1) = str2num(obj(1).trialname);
trialStartEnd(2) = str2num(obj(ephustrials).trialname);

[fname,imaging_datapath] = uigetfile(ephuspath,'Setimaging data path');
if isequal(imaging_datapath, 0)
else
    cd (imaging_datapath);
    list = dir('Image*.tif');
    filenames =cell2mat(arrayfun(@(x) x.name(length(x.name)-6 :length(x.name)-4),list,'uniformoutput',false));
    trials=str2num(filenames);
    filenames=arrayfun(@(x) x.trialname,obj,'uniformoutput',false);
    ephustrials=str2num(cell2mat(filenames'));
    commontrials=ephustrials(ismember(ephustrials,trials));
    commontrialinds = find(ismember(ephustrials,trials));
end


if length(commontrials) ~= str2num(get(handles.TotTrialNum, 'String'))
    error('Number of ephus trials NOT equal to Number of Ca Image Trials!')
end

for i = 1:length(commontrials)
    
    CaSignal.CaTrials(i).ephusTrial = obj(commontrialinds(i));
end
disp([num2str(i) ' Ephus Trials added to CaSignal.CaTrials']);
set(handles.msgBox, 'String', [num2str(i) ' Ephus Trials added to CaSignal.CaTrials']);

guidata(hObject, handles)




function ephusTrialsToBeExcluded_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ephusTrialsToBeExcluded_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_wSigSummary.
function load_wSigSummary_Callback(hObject, eventdata, handles)
global wSigSummary
wSigSummary ={};
dir= get(handles.wSigSum_datapath,'String');
[fname,datapath] = uigetfile(dir,'Select wSigSummary data');
cd (datapath);
load(fname,'-mat');
fieldlist = fieldnames(wSigSummary{1,1});
plotlist = get(handles.wSigSum_toplot,'String');
datatoplot =  plotlist(get(handles.wSigSum_toplot,'Value'));
list = strmatch(datatoplot,fieldlist);
set(handles.wSigblocks_datalist, 'String',fieldlist(list));
set (handles.wSigSum_datapath,'String',datapath);

% --- Executes on button press in pooleddata.
function pooleddata_Callback(hObject, eventdata, handles)
global wSigSum_anm
wSigSum_anm = {};
basedatapath = '/Volumes/';
folder = uigetdir;
cd (folder);
count=0;

while(count>=0)
    [filename,pathName]=uigetfile('wSigSummary*.mat',folder,'Load wSigSummary.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    cd (pathName);
    wSigSum_anm{count} = wSigSummary;
    
end
folder = uigetdir;
cd (folder);
save('wSigSum_anm','wSigSum_anm');




% --- Executes on button press in plot_pooledbatchdata.
function plot_pooledbatchdata_Callback(hObject, eventdata, handles)
global wSigSessSum_anm
[filename,pathName]=uigetfile('wSigSum_anm.mat','Load wSigSum_anm.mat file');
load( [pathName filesep filename], '-mat');
cd (pathName);
trialtype_select = 'nogo';
mean_subtract_on =1;
count =1;

fieldnames = {'meandev_thetaenv';'peakdev_thetaenv';'meanpole_thetaenv';'prcoccupancy';'meandev_whiskamp'}; 

for k = 1:length(fieldnames)
    current_field = strcat(trialtype_select,'_',fieldnames(k),'_binned');
    if(strcmp(current_field,'nogo_prcoccupancy_binned')||strcmp(current_field,'nogo_meandev_whiskamp') )
        mean_subtract_on = 0;
    end    
    [tempobj,propname,sess_count] = sort_SessionData(wSigSum_anm,current_field{1},mean_subtract_on);
    wSigSessSum_anm.(propname) = tempobj;
    numanm = length(tempobj);
end   

for i = 1:numanm    
    temp = '';
    for j = 1 : sess_count(i)
         temp= strcat(temp, wSigSum_anm{i}{j}.tag{1});
    end
    wSigSessSum_anm.sesstype{i}{1}=temp'; 
end
save('wSigSessSum_anm.mat','wSigSessSum_anm');

%         colr(:,:,1) = gray(num);
%         colr(:,:,2) = winter(num);
%         colr(:,:,3) = hot(num);
%         colr(:,:,4) = bone(num);

colr(:,:,1) = lines(numanm);


for k = 1:length(fieldnames)  
    current_field = strcat(trialtype_select,'_',fieldnames(k),'_binned');
    
    if(strcmp(current_field,'nogo_prcoccupancy_binned')||strcmp(current_field,'nogo_meandev_whiskamp_binned'))
        propname = strrep(current_field,'_binned','');       
        mean_subtract_on = 0;
    else
        propname = strrep(current_field,'_binned','_err');
        mean_subtract_on = 1;
    end
    propname= propname{1};
    name = [propname 'normchange'];
    resid = [propname 'residuals'];
    tempobj = wSigSessSum_anm.(propname) ;
    
    numanm = size(tempobj,2);
    tempmat =nan(2,max(sess_count)+2,numanm);
    sc = get(0,'ScreenSize');   
    f1=figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*1/3], 'color','w');
    a1=axes('Parent',f1);title([ propname]);
    no_bs=0;
%     temp_collected_data = zeros(numanm,(max(sess_count)+2)*2);
    for i = 1:numanm        
        numsessions = size(tempobj{i},2);   
        sesstags = wSigSessSum_anm.sesstype{i}{1};
        num_bs=sum(sesstags=='B');
        if (num_bs >0) || (no_bs<1)
            no_bs =0;
        else
            no_bs =1;
        end
        numskips  =  2 - num_bs;        
        count = 250*numskips;
        for j = 1:numsessions
            
            tempmat(:,j+numskips,i) = tempobj{i}{j}.(name)(:,2);
            if mean_subtract_on
                errorbar(tempobj{i}{j}.(name)(:,1)+count,tempobj{i}{j}.(name)(:,2),tempobj{i}{j}.(name)(:,3),'color',colr(i,:,1),'Marker','o','Markersize',8,'MarkerFaceColor',colr(i,:,1)); hold on;
            else
                plot(tempobj{i}{j}.(name)(:,1)+count ,tempobj{i}{j}.(name)(:,2),'color',colr(i,:,1),'Marker','o','Markersize',8,'MarkerFaceColor',colr(i,:,1)); hold on;
            end
            hline (0,'k:');
            xlabel('Trials'); ylabel ([propname ' change']);
            count = max(tempobj{i}{j}.(name)(:,1)+count);
        end
        if mean_subtract_on
            title ([strrep(propname,'_',' ') '  Norm. Change']);
        else
            title ([strrep(propname,'_',' ') '  Change ']);
        end
    end   
    
    set(gcf,'PaperPositionMode','auto');set(gca,'FontSize',18);
     saveas(gcf,propname,'fig');
     saveas(gcf,propname,'tif');
    print(gcf,'-depsc2','-painters','-loose',propname)  
     wSigSessSum_anm.(propname) = tempmat;
    avg_anm_sess = nanmean(tempmat,3); 
    
    temp = isnan(avg_anm_sess);
    avg_anm_sess(:,find(sum(temp)>0)) = [];
%     tempmat(:,find(sum(temp)>0),:) = [];
    std_anm_sess = nanstd(tempmat,1,3);%./sqrt(numanm+1); 
     std_anm_sess(:,find(sum(temp)>0)) = [];
    f2 =figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*1/3], 'color','w');
    a2=axes('Parent',f2);
    title(['avg_' propname]);
    for i = 1: length(avg_anm_sess)
        xval(:,i) = [(no_bs*250)+((i-1)*250)+50 ;(no_bs*250)+((i-1)*250)+250];
        errorbar(xval(:,i),avg_anm_sess(:,i),std_anm_sess(:,i),'color','k','Marker','o','Markersize',8,'MarkerFaceColor',[0 0 0],'linewidth',2);hold on;
    end
    temp =zeros(size(xval,1),size(xval,2),3);
    temp(:,:,1) = xval(:,:);
    temp(:,:,2) =avg_anm_sess(:,:);
    temp(:,:,3) =std_anm_sess(:,:);
    wSigSessSum_anm.(['avg' propname]) = temp;
    set(gcf,'PaperPositionMode','auto');set(gca,'FontSize',18);
     saveas(gcf,['avg_' propname],'fig');
      saveas(gcf,['avg_' propname],'tif');
    print(gcf,'-depsc2','-painters','-loose',['avg' propname])  
     
end
save('wSigSessSum_anm.mat','wSigSessSum_anm');


    
    
function [tempobj,propname,sess_count] = sort_SessionData(wSigSum_anm,fieldname,mean_subtract_on)
%     propname = strrep(fieldname,'nogo_','');   
    if mean_subtract_on
         propname = strrep(fieldname,'_binned','_err');
         
    else
         propname = strrep(fieldname,'_binned','');
    end
    numanm = size(wSigSum_anm,2);    
    for i = 1:numanm
        curr_anm=wSigSum_anm{i};
        numsessions=size(curr_anm,2);         
        sess_count(i,1) =numsessions;
        
        for j= 1:numsessions
            block =1;
            curr_sess = curr_anm{j};
            curr_sess_type = curr_sess.tag;
            curr_data =curr_sess.(fieldname);
            curr_data = cell2mat(curr_data{block});
            if(strcmpi(curr_sess_type,'b'))
                target_barpos = curr_sess.nogo_mean_barpos{1};
                target_barpos = target_barpos{block};
            else
                target_barpos = curr_sess.nogo_biased_barpos{1};
                target_barpos = target_barpos{block};
            end
            x = curr_data(:,1) %+ (numskips*100);
            if(mean_subtract_on)
                y=curr_data(:,2)-target_barpos;  
            else
                y=curr_data(:,2);
            end
            [p,S] = polyfit(x,y,1); %st line fit
            [yfit,delta] = polyval(p,x,S); %delta is the error estimate in prediction
            temp = length(x);
            tempobj{i}{j}.([propname ]) = [x,y];
            tempobj{i}{j}.([propname 'slope_intercept']) = p';
            tempobj{i}{j}.([propname 'residuals']) = delta;
            tempobj{i}{j}.([propname 'change']) = [x(1) ,yfit(1);x(temp),yfit(temp)];
            [y1,delta1] =polyval(p,50,S);
            [y2,delta2] =polyval(p,250,S);
            tempobj{i}{j}.([propname 'normchange']) = [50 ,y1,delta1;250,y2,delta2];


        end

    end



function current_bartheta_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function current_bartheta_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in align_to_first_touch.
function align_to_first_touch_Callback(hObject, eventdata, handles)
handles.aligned_contact = get(handles.align_to_first_touch,'Value');
if handles.aligned_contact
    set(handles.align_to_last_touch,'Value',0);
end

% --- Executes on button press in align_to_last_touch.
function align_to_last_touch_Callback(hObject, eventdata, handles)
handles.aligned_contact = get(handles.align_to_last_touch,'Value');
if handles.aligned_contact
    set(handles.align_to_first_touch,'Value',0);
end



function unbiased_bartheta_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function unbiased_bartheta_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc_meanbartheta.
function calc_meanbartheta_Callback(hObject, eventdata, handles)
global sessionInfo
global wSigTrials

[filename1,pathName]=uigetfile('SessionInfo*.mat','Load SessionInfo.mat file');
load( [pathName filesep filename1],'-mat');

[filename2,pathName]=uigetfile('wSigTrials*.mat','Load wSigTrials.mat file');
load( [pathName filesep filename2],'-mat');

bartheta_all=cellfun(@(x) x.mThetaNearBar,wSigTrials,'uniformoutput',false);
wSigfilenames =cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false);
wSig_trials = str2num(char(wSigfilenames));

wSig_nogotrials=ismember(wSig_trials,sessionInfo.nogotrials);
temp = bartheta_all(wSig_nogotrials);
nogo_bartheta = nanmean(cell2mat(temp));

wSig_gotrials=ismember(wSig_trials,sessionInfo.gotrials);

go_bartheta = zeros(size(sessionInfo.gopos));

for k = 1: length( sessionInfo.gopos)
    gotrials_at_currentpos = find(sessionInfo.bar_coordsall(:,1) == sessionInfo.gopix(k,1));
    go_bartheta (k) = nanmean(cell2mat(bartheta_all(gotrials_at_currentpos)));
end

sessionInfo.nogo_bartheta = nogo_bartheta;
sessionInfo.go_bartheta   = go_bartheta;

cd (pathName);
save(filename1, 'sessionInfo');



function min_meanbartheta_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function min_meanbartheta_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function baseline_meanbarpos_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function baseline_meanbarpos_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function contact_Sig_datapath_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function contact_Sig_datapath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_contactTrialsdata.
function load_contactTrialsdata_Callback(hObject, eventdata, handles)
global CaSigSummary
CaSigSummary = {};
basedatapath = get(handles.contact_Sig_datapath,'String');
if(length(basedatapath)<10)
    basedatapath = '/Volumes/';
end
cd (basedatapath);
count=0;

while(count>=0)
    [filename,pathName]=uigetfile('contact_CaTrial*.mat','Load contact_CaTrials*.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    set(handles.wSigSum_datapath,'String',pathName);
    cd (pathName);
    CaSigSummary{count} = contact_CaTrials;
    
end
folder = uigetdir;
cd (folder);
save('CaSigSummary','CaSigSummary');


% --- Executes on button press in load_pooled_contact_Trials.
function load_pooled_contact_Trials_Callback(hObject, eventdata, handles)


% --- Executes on button press in plot_contactSig_sessions.
function plot_contactSig_sessions_Callback(hObject, eventdata, handles)
global CaSigSummary
global CaSigSum_Sessions

num_baseline_sessions=2;
contact_roistoplot = str2num(get(handles.CaSigSum_rois,'String'));
numsessions=size(CaSigSummary,2);
numrois = length(contact_roistoplot);
trialtypes = 6; % nogo + 5 go pos % CaSigSummary{1,1}
commentstr = get(handles.plot_contactSigSum_title,'String');


roi_trace_handles = {'t1','t2','t3','t4','t5'};
roi_traceavg_handles = {'a1','a2','a3','a4','a5'};
roi_kappa_handles = {'k1','k2','k3','k4','k5'};

% prep plot figs for rois
for j= 1:numrois
    sc = get(0,'ScreenSize');
% %     roi_trace_handles{j} = figure('position', [1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');  %% im and raw trace
% %     suptitle([commentstr 'Roi ' num2str(contact_roistoplot(j)) 'Trial types traces' ]);
    roi_traceavg_handles{j} = figure('position',[1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');  %% im and raw trace
    suptitle([commentstr 'Roi ' num2str(contact_roistoplot(j)) 'Trial types avg traces' ]);
    roi_kappa_handles{j} = figure('position',[1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');  %% im and raw trace
    suptitle([commentstr 'Roi ' num2str(contact_roistoplot(j)) 'Trial types dKappa vs. dFF' ]);

    
end
j=0;
count =0;
prev=0;
roiTcount = ones(length(contact_roistoplot),1);
roiKcount = ones(length(contact_roistoplot),1);
for j = 1:numsessions
    obj = CaSigSummary{1,j};
    rois_trials  = arrayfun(@(x) x.dff, obj,'uniformoutput',false);
    dKappa = cell2mat(arrayfun(@(x) x.deltaKappa{1}, obj,'uniformoutput',false)');
    velocity =cell2mat(arrayfun(@(x) x.Velocity{1}, obj,'uniformoutput',false)');
    ts_wsk = cell2mat(arrayfun(@(x) x.ts_wsk{1}, obj,'uniformoutput',false)');
    total_TouchKappa = cell2mat(arrayfun(@(x) x.total_touchKappa, obj,'uniformoutput',false)');
    wsk_frametime =1/(ts_wsk(2)-ts_wsk(1));
    trialtypes = ones(length(obj),1);
    touchinds = zeros(length(obj),1);
    barposall=cell2mat(arrayfun(@(x) x.barpos, obj, 'uniformoutput',false));
    barpositions1 = unique(barposall);
    cnt=0;
    for i=1:length(barpositions1)
        inds= find(barposall==barpositions1(i)) ;
        touchinds(cnt+1:cnt+length(inds))=inds;
        trialtypes(cnt+1:cnt+length(inds)) = i;
        cnt = cnt +length(inds);
    end
    numtrials = length(rois_trials);
    numrois = size(rois_trials{1},1);
    numframes =size(rois_trials{1},2);
    frametime = obj(1).FrameTime(1);
    ts = frametime:frametime:frametime*numframes;
    temprois = zeros(numrois,numframes,numtrials);
    for i= 1:numtrials
        tempmat = zeros(size(rois_trials,1),size(rois_trials,2));
        tempmat = rois_trials{i};
        if (size(tempmat,2)>size(temprois,2))
            temprois(:,:,i) = tempmat(1:numrois,1:numframes);
        else
            temprois(:,1:size(tempmat,2),i) = tempmat(:,:);
        end
        
    end
    cscale=[0 300];
    col = [0 0 .5 ;0 0 1; 0 .5 1; 1 .44 0; 1 0 0;.5 0 0 ;.5 1 .5]; %[0 0 1; 0 .5 1;.5 .5 1; 1 0 0;.5 0 0 ;0 0 0];
    scaledcol = [1;38;76;230;263;300;151];
    
    
    temp = permute(temprois,[3,2,1]);
    newrois=zeros(size(temp,1),size(temp,2)+1,size(temp,3));
    newrois(:,1:size(temp,2),:) = temp;
    temp2=repmat(trialtypes,1,size(temp,3));
    temp2 = reshape(temp2,numtrials,1,numrois);
    for t=1:length(temp2)
        temp2(t,:,:)  = scaledcol(temp2(t,1));
    end
%     temp2=temp2*(1/length(unique(trialtypes))) *cscale(1,2);
    temp2 = [temp2 temp2 temp2 temp2 temp2];
    newrois(:,size(temp,2)+1:size(temp,2)+5,:) = temp2;
    
    numcolstoplot = 1+length(unique(trialtypes));
    dt = ts(length(ts))-ts(length(ts)-1);
    
    count1=1;
    sc = get(0,'ScreenSize');
    
    % plot rois
    for i= 1:length(contact_roistoplot)
        count = roiTcount(i);

% %         figure(roi_trace_handles{i});
% %         hold on;     
% %         axt(i,count)=subplot(numsessions,numcolstoplot,count,'Parent',roi_trace_handles{i});
% %         hold (axt(i,count),'on');
% %         imagesc([ts ts(length(ts))+dt*1:dt:ts(length(ts))+dt*5],1:numtrials,newrois(:,:,contact_roistoplot(i)));caxis(cscale);colormap(jet);xlabel('Time(s)'); ylabel('Trials');
% %         ylim([0,numtrials]);
% %         set(gca,'YDir','reverse');
% %         vline([.5 1 1.5 2 2.5 ],'k-');
        
        figure(roi_traceavg_handles{i});
        hold on;     
        axt(i,count)=subplot(numsessions,numcolstoplot,count,'Parent',roi_traceavg_handles{i});
        hold (axt(i,count),'on');
        imagesc([ts ts(length(ts))+dt*1:dt:ts(length(ts))+dt*5],1:numtrials,newrois(:,:,contact_roistoplot(i)));caxis(cscale);colormap(jet);xlabel('Time(s)'); ylabel('Trials');
        ylim([0,numtrials]);
        set(gca,'YDir','reverse');
        vline([.5 1 1.5 2 2.5 ],'k-');
        
        count=count+1;
        types= unique(trialtypes);
        for k = 1:length(types)
            trials_ktype=(find(trialtypes==types(k)));
            
% %             figure(roi_trace_handles{i});
% %             axt(i,count) = subplot(numsessions,numcolstoplot, count ,'Parent',roi_trace_handles{i});
% %             hold (axt(i,count),'on');      
% %             for m=1:length(trials_ktype)
% %                 figure(roi_trace_handles{i});
% %                 plot(ts ,newrois(trials_ktype(m),1:length(ts),contact_roistoplot(i))','color',col(types(k),:),'linewidth',2);
% %                 hold on;
% %             end
% %             xlabel('Time (s)'); ylabel('dFF');
% %             axis([0 ts(length(ts)) -100 300]);set(gca,'YMinorTick','on','YTick', -100:200:800);
% %             vline([ .5 1 1.5 2 2.5],'k-');
            
            figure(roi_traceavg_handles{i});
            axt(i,count)= subplot(numsessions,numcolstoplot, count,'Parent',roi_traceavg_handles{i});
            hold (axt(i,count),'on');    
            temp_data=newrois(trials_ktype,1:length(ts),contact_roistoplot(i));
            threshold = 2;
            
            [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
            alltrials_avg = mean(temp_data,1);
            plot([frametime:frametime:length(alltrials_avg)*frametime] ,alltrials_avg,'color',col(types(k),:),'linewidth',2);
            hold on;
            u = 300;
            axis([0 ts(length(ts)) -10 300]);set(gca,'YMinorTick','on','YTick', -200:100:300);xlabel('Time(s)'); ylabel('mean_dFF');           
            vline([.5 1 1.5 2 2.5],'k-');
            txtbox = text(2.0,u-100,[ num2str(sum(detected,1)) '/' num2str(size(event_detected_data,1)) '(' num2str(round( (sum(detected,1)/size(event_detected_data,1))*100)/100) ')'],'FontSize',13);
                    
            count = count+1;

            
        end
        

        roiTcount(i) = count;
        
        % plot max(dFF) vs. dKappa
        
        figure(roi_kappa_handles{i});
        count =roiKcount(i);
        
        types= unique(trialtypes);
        
        for k = 1:length(types)
            axt(i,count)=subplot(numsessions,length(types), count,'Parent',roi_kappa_handles{i});
            hold (axt(i,count),'on');
            count=count+1;
            trials_ktype=(find(trialtypes==types(k)));
            temp_data=newrois(trials_ktype,1:length(ts),contact_roistoplot(i));
            [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
            temp_dKappa = dKappa(trials_ktype,:);
            temp_velocity = velocity(trials_ktype,:);
            temp_ts_wsk = ts_wsk(trials_ktype,:);
            temp_totalTouchKappa = total_TouchKappa(trials_ktype,:);
            
            max_dFF=zeros(size(temp_data,1),1);
           
            for m = 1:size(events_septs,1)
              temp2 = temp_data(m,events_septs(m,1):events_septs(m,2));
              total_dFF(m,1) = sum(temp2);
              max_dFF(m,1) = mean(prctile(temp2,90));
            end
            total_velocity = sum(temp_velocity,2);
            [X, outliers_idx] = outliers(temp_totalTouchKappa.*max_dFF);
            scatter(temp_totalTouchKappa,max_dFF,80,col(types(k),:),'fill');hold on;
            plot(temp_totalTouchKappa(outliers_idx),max_dFF(outliers_idx),'*','color',[1,1,1],'MarkerSize',6);
            hold on;
%             temp_totalTouchKappa(outliers_idx) = [];
%             max_dFF(outliers_idx)=[];
            P=polyfit(temp_totalTouchKappa,max_dFF,1);
            yfit = P(1)*temp_totalTouchKappa + P(2);
            hold on;
            plot(temp_totalTouchKappa,yfit,'color',col(types(k),:),'linewidth',2);hold off;
            grid on;xlabel('total_dKappa'); ylabel('peak_dFF');
%             txtbox = text(max(temp_totalTouchKappa)-1, max(max_dFF) -50, [num2str(round(P(1)*100)/100)],'FontSize',13);
            %                  set(txtbox,'position');
%             axis([min(temp_totalTouchKappa)-1 max(temp_totalTouchKappa)+1 -10 max(max_dFF) ]); set(gca,'YMinorTick','on','YTick', 0:100:1000);
            axis([-10 40 -10 500 ]); set(gca,'YMinorTick','on','YTick', 0:100:500);
            txtbox = text(20, 300 , [num2str(round(P(1)*100)/100)],'FontSize',13);

            %                     vline([.5 1 1.5 2 2.5],'k-');
            
            
        end
    
        roiKcount(i) = count;
    end
end



for i = 1:length(contact_roistoplot)
% %     figure(roi_trace_handles{i}); set(gcf,'PaperPositionMode','auto');
% %     saveas(gcf,['Roi_Traces ' num2str(contact_roistoplot(i))] ,'tif');
% %     saveas(gcf,['Roi_Traces ' num2str(contact_roistoplot(i))],'fig');
    figure(roi_traceavg_handles{i}); set(gcf,'PaperPositionMode','auto');
    saveas(gcf,['Roi_Traces_avg ' num2str(contact_roistoplot(i))] ,'jpg');
    saveas(gcf,['Roi_Traces_avg ' num2str(contact_roistoplot(i))],'fig');
    
    figure(roi_kappa_handles{i}); set(gcf,'PaperPositionMode','auto');
    saveas(gcf,['Roi_dKappa_dFF ' num2str(contact_roistoplot(i))] ,'jpg');
    saveas(gcf,['Roi_dKappa_dFF ' num2str(contact_roistoplot(i))],'fig');
    
end
javaaddpath('/Users/ranganathang/Documents/MATLAB/universal/helper_funcs/jheapcl/jheapcl/MatlabGarbageCollector.jar');
jheapcl(1)
% title([commentstr ' Block ' blocklist{j} ]);
%  hold off;
%
%
%
%    folder=uigetdir;
%    cd(folder);
% save('wSigSum_Sessions','wSigSum_Sessions');
% cd ..



function plot_contactSigSum_title_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function plot_contactSigSum_title_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CaSigSum_rois_Callback(hObject, eventdata, handles)
contact_roistoplot = str2num(get(handles.CaSigSum_rois,'String'));
if(length(contact_roistoplot)>5)
    msgbox('Cant handle more than 5 rois at a time, chosing the first five');
    contact_roistoplot = contact_roistoplot(1:5);
end

% --- Executes during object creation, after setting all properties.
function CaSigSum_rois_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_CaSigSummary.
function load_CaSigSummary_Callback(hObject, eventdata, handles)
global CaSigSummary
CaSigSummary ={};
dir= get(handles.contact_Sig_datapath,'String');
[fname,datapath] = uigetfile(dir,'Select CaSigSummary data');
cd (datapath);
load(fname,'-mat');




function edit60_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit60_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function barTimeWindow_Callback(hObject, eventdata, handles)
barTimeWindow = get(handles.barTimeWindow,'String');

% --- Executes during object creation, after setting all properties.
function barTimeWindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function soloSigSum_datapath_Callback(~, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function soloSigSum_datapath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_sessions_solo.
function load_sessions_solo_Callback(hObject, eventdata, handles)
global soloSigSummary
soloSigSummary = {};
basedatapath = get(handles.soloSigSum_datapath,'String');
if(length(basedatapath)<10)
    basedatapath = '/Volumes/';
end
cd (basedatapath);
count=0;

while(count>=0)
    [filename,pathName]=uigetfile('solodata*.mat','Load solodata*.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    set(handles.wSigSum_datapath,'String',pathName);
    cd (pathName);
    soloSigSummary{count} = solo_data;
    
end
folder = uigetdir;
cd (folder);
title = get(handles.plot_soloSigSum_title,'String');
save(['soloSigSummary' title] ,'soloSigSummary');


function plot_soloSigSum_title_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function plot_soloSigSum_title_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_soloSigSum.
function plot_soloSigSum_Callback(hObject, eventdata, handles)
global soloSigSummary
    mousename = get(handles.plot_soloSigSum_title,'String');
    sc = get(0,'ScreenSize');
    fdprime = figure('position',[1000, sc(4)/10-100, sc(3)/2, sc(4)/2], 'color','w');  %% dprime
    ah1=axes('Parent',fdprime);
    suptitle([mousename 'Dprime']);
    fpc = figure('position',[1000, sc(4)/10-100, sc(3)/2, sc(4)/2], 'color','w');  %% pc
    ah2=axes('Parent',fpc);
    suptitle([mousename 'PC']);
    numsessions  =  size(soloSigSummary,2);
    count =0 ;
    
    avg_dprime_corrected = zeros(numsessions,1);
    avg_pc_corrected = zeros(numsessions,1);
    
    for j = 1:numsessions
       obj =  soloSigSummary{j};
      dprime_null = getfield(obj,'Dprime_null');
      dprime_corrected = getfield(obj,'Dprime_contact');
      pc_null = getfield(obj,'PC_null');
      pc_corrected = getfield(obj,'PC_contact');
      numtrials = size(dprime_null,2);
      
      windowSize = 25;
      dprime_corrected_smth  = filter(ones(1,windowSize)/windowSize,1, dprime_corrected);
      pc_corrected_smth = filter(ones(1,windowSize)/windowSize,1, pc_corrected);
      axes(ah1);
%       plot([count+1:count+numtrials], dprime_null,'color',[.1 .5 .75],'Linestyle','-','Marker','o','MarkerSize',.5,'MarkerFaceColor',[.1 .5 .75],'Linewidth',2);
      hold on;
      numtrials = size(dprime_corrected,2);
       plot([count+1:count+numtrials], dprime_corrected_smth,'color','b','Linestyle','-','Marker','o','MarkerSize',.5,'MarkerFaceColor','b','Linewidth',2);
      hline (1,{'r--','linewidth',1.5});
      avg_dprime_corrected = median(dprime_corrected);
      axes(ah2);
      numtrials = size(dprime_null,2);
%       plot([count+1:count+numtrials], pc_null,'color','g','Linestyle','-','Marker','o','MarkerSize',.5,'MarkerFaceColor','g');
      hold on;
      numtrials = size(dprime_corrected,2);
      plot([count+1:count+numtrials], pc_corrected_smth,'color',[.1 .75 .5],'Linestyle','-','Marker','o','MarkerSize',.5,'MarkerFaceColor',[.1 .75 .5],'Linewidth',2);
      hline (.60,{'r--','linewidth',1.5});
      avg_pc_corrected = median(pc_corrected);
      numtrials = max( size(dprime_corrected,2),size(dprime_null,2));
      count = count + numtrials +10;      
    end
axes(ah1);
legend('Dprime null','Dprime Touchcorrected');
saveas(gcf,[mousename 'Dprime_sessions'] ,'jpg');
axes(ah2);
legend('PC null','PC Touchcorrected');
saveas(gcf,[mousename 'PC_sessions'] ,'jpg');
figure;suptitle([mousename 'Performance']);
plot(numsessions,avg_dprime_corrected,'color','b'); hold on;
plot(numsessions,avg_pc_corrected,'color',[.1 .75 .5]);
saveas(gcf,[mousename 'Performance_sessions'] ,'jpg');

% --- Executes on button press in load_soloSigSummary.
function load_soloSigSummary_Callback(hObject, eventdata, handles)
global soloSigSummary
soloSigSummary ={};
dir= get(handles.soloSigSum_datapath,'String');
[fname,datapath] = uigetfile(dir,'Select soloSigSummary data');
cd (datapath);
load(fname,'-mat');



% --- Executes on selection change in wSigblocks_datalist.
function wSigblocks_datalist_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function wSigblocks_datalist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_preplog.
function save_preplog_Callback(hObject, eventdata, handles)
basedatapath= get(handles.baseDataPath,'String');
coordsatfirst= get(handles.coords1,'String');
coordsatnext= get(handles.coords2,'String');
barposatfirst=get(handles.barpos1,'String');
barposatnext= get(handles.barpos2,'String');
cont_detwindow = get(handles.barTimeWindow,'String');

mouseName = get(handles.AnimalNameEdit, 'String');
% sessionName = get(handles.SoloDataFileName, 'String');
sessionID = get(handles.SoloSessionID, 'String');

fname = [ mouseName sessionID 'log.txt'];
t1 = ['Mouse name   ' , mouseName]
t2 = ['Session ID   ', sessionID]
t3 = ['Pos 1     '  barposatfirst  '     '  , coordsatfirst ]
t4 = ['Pos 2    ' barposatnext '     '   coordsatnext]
t5 = ['Contact_detect window  ' cont_detwindow]

fid = fopen(fname,'w');
fprintf(fid,'%s\n', t1); 
fprintf(fid,'%s\n', t2); 
fprintf(fid,'%s\n', t3); 
fprintf(fid,'%s\n', t4);
fprintf(fid,'%s\n', t5); %12.8f\n',y);
fclose(fid);


% --- Executes on button press in select_plot_SetAmp.
function select_plot_SetAmp_Callback(hObject, eventdata, handles)

% --- Executes on button press in plotSetAmp.
function plotSetAmp_Callback(hObject, eventdata, handles)
global solo_data
global wsArray
if isempty(solo_data)
   msgbox('Load data first');
end
cd (get(handles.wSig_datapath,'String'));
list = dir('plots');
if (isempty(list))
    mkdir ('plots');
end
d = [ get(handles.wSig_datapath,'String') '/plots'];
timewindow = [.5,4];
redo = 0;
mad_threshold = 2.5;
restrictTime = str2num(get(handles.timewindow_wSiganal,'String'));
plot_SetAmp(d,wsArray,solo_data,restrictTime,timewindow,mad_threshold,redo);
