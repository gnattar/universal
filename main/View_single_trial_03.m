function varargout = View_single_trial_03(varargin)
% VIEW_SINGLE_TRIAL_03 MATLAB code for View_single_trial_03.fig
%      VIEW_SINGLE_TRIAL_03, by itself, creates a new VIEW_SINGLE_TRIAL_03 or raises the existing
%      singleton*.
%
%      H = VIEW_SINGLE_TRIAL_03 returns the handle to a new VIEW_SINGLE_TRIAL_03 or the handle to
%      the existing singleton*.
%
%      VIEW_SINGLE_TRIAL_03('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_SINGLE_TRIAL_03.M with the given input arguments.
%
%      VIEW_SINGLE_TRIAL_03('Property','Value',...) creates a new VIEW_SINGLE_TRIAL_03 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before View_single_trial_03_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to View_single_trial_03_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help View_single_trial_03

% Last Modified by GUIDE v2.5 03-Feb-2017 10:54:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @View_single_trial_03_OpeningFcn, ...
    'gui_OutputFcn',  @View_single_trial_03_OutputFcn, ...
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


% --- Executes just before View_single_trial_03 is made visible.
function View_single_trial_03_OpeningFcn(hObject, eventdata, handles, varargin)
global h1
% Choose default command line output for View_single_trial_03
handles.output = hObject;
scrsz = get(0,'ScreenSize');
h1=figure('Position',[scrsz(4)/2 scrsz(4) scrsz(3)/2.5 scrsz(4)/1.5],'name','View Trials','numbertitle','off','color','w');
handles.whiskpath = '';
% Update handles structure
guidata(hObject, handles);



% UIWAIT makes View_single_trial_03 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = View_single_trial_03_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nexttrial.
function nexttrial_Callback(hObject, eventdata, handles)
currenttrial=str2num(get(handles.currenttrial,'String'));
maxtrials=str2num(get(handles.numtrials,'String'));
if(currenttrial+1<=maxtrials)
    currenttrial =currenttrial +1;
    set(handles.currenttrial,'String',num2str(currenttrial));
    %     currenttrial_Callback(handles.currenttrial,handles.cell_num);
    currenttrial_Callback(hObject,eventdata,handles);
else
    disp('Cannot increment trials anymore');
end

% --- Executes on button press in prevtrial.
function prevtrial_Callback(hObject, eventdata, handles)
currenttrial=str2num(get(handles.currenttrial,'String'));
if(currenttrial-1>0)
    currenttrial =currenttrial -1;
    set(handles.currenttrial,'String',num2str(currenttrial));
    %     currenttrial_Callback(handles.currenttrial,handles.cell_num);
    currenttrial_Callback(hObject,eventdata,handles);
else
    disp('Cannot decrement trials anymore');
end

function currenttrial_Callback(hObject, eventdata, handles)
currenttrial = str2num(get(handles.currenttrial,'String'));
roiNo = str2num(get(handles.cell_num,'String'));
global syncedData
global h1
figure(h1);
trNo = currenttrial;

%solo info

obj=syncedData;
soloTrNo =  obj{trNo}.solo_trial;
trType = obj{trNo}.trialtype;
trCorrect =obj{trNo}.trialCorrect;


fig_export_dir = ['Trialdata'];
folder=dir(fig_export_dir);
if(isempty(folder))
    mkdir(fig_export_dir);
end
% winfo and einfo
if ~isempty( obj(trNo).wTimeScale)
    wID=1;
    wskNo = '2';
     goodind = find(~isnan(obj(trNo).ts_wsk{wID}) & ~(obj(trNo).ts_wsk{wID} == 0));
    ts_wsk = obj{trNo}.ts_wsk{wID}(goodind);
     ts_wsk =ts_wsk-ts_wsk(wID);    
     contacts=obj{trNo}.contacts{wID};
    
    
    list = get(handles.selectObj,'String');
    target=list(get(handles.selectObj,'Value'));
    licks=obj{trNo}.licks;
    ephys_time = [1:length(licks)].* obj{trNo}.wsTimeScale ;
    lickTime_trial = ephys_time(licks >3)';
    barOnOff = [0.5, 2.08];

    ha(1) = subaxis(6,1,1, 'sv', 0.05);
    
    Setpoint = obj{trNo}.Setpoint{1}(goodind);
    plot(ts_wsk, Setpoint,'k','linewidth',1.5);
    line([lickTime_trial'; lickTime_trial'], ...
        [zeros(1,length(lickTime_trial)); ones(1,length(lickTime_trial))*10],'color','m','linewidth',.5)
    if(barOnOff(1)>0)
        line([barOnOff(1); barOnOff(1)], [0 0; 30 30], 'color','c','linewidth',.5);
    end
    if (barOnOff(2)<3.5)
        line([barOnOff(2); barOnOff(2)], [0 0; 30 30], 'color','b','linewidth',.5);
    end
    
        if(~isempty(contacts))
             numcontacts = size(contacts,2);
    
                for i = 1:numcontacts
                    if(iscell(contacts))
                        ithcontact=contacts{i}-(contacts{1}(1)-250)*(strcmp(target,'contact_CaTrials')); %with respect to the first contact being fixed at .5s
                    else
                       ithcontact=contacts(i)-(contacts(1)-250)*(strcmp(target,'contact_CaTrials'));
                    end
                    ithcontact=(ithcontact/500);
                    line([ithcontact;ithcontact],[zeros(1,length(ithcontact))+10;ones(1,length(ithcontact))*20],'color',[.6 .5 0],'linewidth',.5)
    
                end
    
        end
    
    ylabel('Setpoint','fontsize',15);xlim([0 max(ts_wsk)])
    set(gca,'XMinorTick','on','XTick',0:.2:6);
    condir= num2str(obj{trNo}.contactdir{1});
    if(isempty(condir))
        condir='nocontact';
    end
    if(strcmp(target,'contact_CaTrials'))
        title(sprintf('%d:Trial %d, Type %s, \n  %s ',trNo,soloTrNo,trType,condir), 'fontsize',20);
    else
        title(sprintf('%d:Trial %d, Type %d, \n C/NC %d,  %s ',trNo,soloTrNo,trType,trCorrect,condir), 'fontsize',20);
    end
    
    ha(5) = subaxis(6,1,5, 'sv', 0.05);
    
    vel =  obj{trNo}.Velocity{1}(goodind);
    plot(ts_wsk, vel, 'r','linewidth',1.5);
    ylabel('Velocity','fontsize',15);  xlim([0 max(ts_wsk)]);
    set(gca,'XMinorTick','on','XTick',0:.2:6);
    
    ha(6) = subaxis(6,1,6, 'sv', 0.05);
    Amplitude=obj{trNo}.Amplitude{1}(goodind);
    plot(ts_wsk, Amplitude,'k','linewidth',1.5);    
    ylabel('Amplitude','fontsize',15);
    xlabel('Time (s)','fontsize',20);xlim([0 max(ts_wsk)])
    %      set(ha, 'box','off', 'xlim',[0 max(ts_wsk)]);
    set(gca,'XMinorTick','on','XTick',0:.2:6); %
    
    ha(2) = subaxis(6,1,2, 'sv', 0.05);
    theta=obj{trNo}.theta{1}(goodind);
    plot(ts_wsk, theta,'k','linewidth',1.5);    
    ylabel('Theta','fontsize',15);
    xlabel('Time (s)','fontsize',20);xlim([0 max(ts_wsk)])
    %      set(ha, 'box','off', 'xlim',[0 max(ts_wsk)]);
    set(gca,'XMinorTick','on','XTick',0:.2:6); %
    
    
    ha(4) = subaxis(6,1,4, 'sv', 0.05);
    dKappa = obj{trNo}.deltaKappa{1}(goodind);
    plot(ts_wsk,dKappa,'b','linewidth',1.5);
    line([lickTime_trial'; lickTime_trial'], ...
        [zeros(1,length(lickTime_trial)); ones(1,length(lickTime_trial))*.5],'color','m','linewidth',1)
    if(barOnOff(1)>0)
        line([barOnOff(1); barOnOff(1)], [0 0; .5 .5], 'color','c','linewidth',2.5);
    end
    if (barOnOff(2)<3.5)
        line([barOnOff(2); barOnOff(2)], [0 0; .5 .5], 'color','k','linewidth',2.5);
    end
    if(~isempty(contacts))
        numcontacts = size(contacts,2);
        
        for i = 1:numcontacts
            if(iscell(contacts))
                ithcontact=contacts{i}-(contacts{1}(1)-250)*(strcmp(target,'contact_CaTrials')); %with respect to the first contact being fixed at .5s
            else
                ithcontact=contacts(i)-(contacts(1)-250)*(strcmp(target,'contact_CaTrials'));
            end
            ithcontact=(ithcontact/500);
            line([ithcontact;ithcontact],[ones(1,length(ithcontact))*-1;ones(1,length(ithcontact))*-2],'color',[.6 .5 0],'linewidth',1)
            
        end
        
    end
    ylabel('deltaKappa','fontsize',15);  xlim([0 max(ts_wsk)]);
    set(gca,'XMinorTick','on','XTick',0:.2:6);
    set(handles.whiskmp4_tag,'String',['Fr No' num2str(1) 'Time' num2str(ts_wsk(1))]);
    set(handles.whiskmp4_sl,'Value',0);
else
    ha(1) = subaxis(6,1,1, 'sv', 0.05);
    %       set(ha(1),'visible','off');
    delete(ha(1));
    ha(5) = subaxis(6,1,5, 'sv', 0.05);
    delete(ha(5));
    ha(2) = subaxis(6,1,2, 'sv', 0.05);
    delete(ha(2));
    ha(4) = subaxis(6,1,4, 'sv', 0.05);
    delete(ha(4));
end


% ephys info
if(~isempty(ephys))
    
    ha(3) = subaxis(6,1,3, 'MarginTop', 0.1);
    
    ephys=obj{trNo}.ephys;
    
    plot(ephys_time, ephys,'k','linewidth',1.5);    
    ylabel('Ephys','fontsize',15);
    xlabel('Time (s)','fontsize',20);xlim([0 max(ts_wsk)])
    %      set(ha, 'box','off', 'xlim',[0 max(ts_wsk)]);
    set(gca,'XMinorTick','on','XTick',0:.2:6); %
    
    line([lickTime_trial'; lickTime_trial'], ...
        [zeros(1,length(lickTime_trial)); ones(1,length(lickTime_trial))*20],'color','m','linewidth',1)
    if(barOnOff(1)>0)
        line([barOnOff(1); barOnOff(1)], [0 0; 100 100], 'color','c','linewidth',1);%hold on;
    end
    % % %     if(~isempty(contacts))
    % % %          numcontacts = size(contacts,2);
    % % %
    % % %             for i = 1:numcontacts
    % % %                 if(iscell(contacts))
    % % %                     ithcontact=contacts{i}-(contacts{1}(1)-250)*(strcmp(target,'contact_CaTrials')); %with respect to the first contact being fixed at .5s
    % % %                 else
    % % %                    ithcontact=contacts(i)-(contacts(1)-250)*(strcmp(target,'contact_CaTrials'));
    % % %                 end
    % % %                 ithcontact=(ithcontact/500);
    % % %                 line([ithcontact;ithcontact],[ones(1,length(ithcontact))*50;ones(1,length(ithcontact))*100],'color',[.6 .5 0],'linewidth',.5); hold on;
    % % %
    % % %             end
    % % %
    % % %     end
    if (barOnOff(2)<3.5)
        line([barOnOff(2); barOnOff(2)], [0 0; 100 100], 'color','b','linewidth',.5);
    end

else
    ha(3) = subaxis(6,1,3, 'sv', 0.05);
    %       set(ha(3),'visible','off');
    delete(ha(3));
end

%%
figure(gcf)
%     fname=sprintf('ROIs %s_%d_Trial_%s',roiName,trNo,soloTrNo);
fname=sprintf('%d_Trial_%s',trNo,soloTrNo);
if get(handles.save_fig,'Value')
    export_fig(fullfile(fig_export_dir,fname ),gcf,'-png')
end






% --- Executes during object creation, after setting all properties.
function currenttrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in selectObj.
function selectObj_Callback(hObject, eventdata, handles)
global obj
list = get(hObject,'String');
target=list(get(hObject,'Value'));
if(strcmp(target,'contact_CaTrials'))
    [fname,path]=uigetfile(pwd,'contact_CaTrials obj');
    cd (path);
    load([path fname],'-mat');
    obj=contact_CaTrials;
    numrois=obj.nROIs;
else
    [fname,path]=uigetfile(pwd,'*sessobj');
    cd (path);
    load([path fname],'-mat');
    obj=synced_sessObj;
end
Cadata=cell2mat(arrayfun(@(x) ~isempty(x.dff), obj , 'uniformoutput',0));
trialswCadata=find(Cadata==1);
numrois = size(obj(trialswCadata(1)).dff,1);
set(handles.totalrois,'String',num2str(numrois));
set(handles.numtrials,'String',num2str(size(obj,2)));
temp = arrayfun(@(x) x.Setpoint,obj,'uniformoutput',false);
temp2 = cellfun(@isempty, temp);
temp2 = ~temp2;
currenttrial = min(find(temp2));
set(handles.currenttrial,'String',num2str(currenttrial));
guidata(hObject,handles);
%currenttrial_Callback(handles.currenttrial);
currenttrial_Callback(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function selectObj_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function cell_num_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_num_Callback(hObject, eventdata, handles)

handles.cellNo = str2num(get(hObject,'String'));


% --- Executes on key press with focus on cell_num and none of its controls.
function cell_num_KeyPressFcn(hObject, eventdata, handles)
handles.cellNo = str2num(get(hObject,'String'));


% --- Executes on button press in save_fig.
function save_fig_Callback(hObject, eventdata, handles)



% --- Executes on button press in sync_data.
function sync_data_Callback(hObject, eventdata, handles)
    prompt={'Roi name:','Fov name:'};
    name='Input for Ca data';
    numlines=1;
    defaultanswer={'1','1'};
    ans=inputdlg(prompt,name,numlines,defaultanswer);
    Cadatasrc = ['R' ans{1} 'F' ans{2} ];
    
%% point to objects
    %CaTrials
    [filename,pathName]=uigetfile('CaSignal*.mat','Load CaSignal.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    load( [pathName filesep filename], '-mat');
    sessObj.([Cadatasrc 'CaTrials']) = CaTrials;
    
    %% behavTrials
    [filename,pathName]=uigetfile('solodata*.mat','Load solodata.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    load( [pathName filesep filename], '-mat');
   
    behavTrialNums=[solo_data.trialStartEnd(1):solo_data.trialStartEnd(2)];
    [Solo_data, SoloFileName] = Solo.load_data_gr(solo_data.mouseName, solo_data.sessionName,solo_data.trialStartEnd,pathName);
    behavTrials = {};
    for i = 1:length(behavTrialNums)
        behavTrials{i} = Solo.BehavTrial_gr(Solo_data,behavTrialNums(i),1);
    end
    sessObj.behavTrials = behavTrials;
    
    
    %ephusTrials
    [filename,pathName]=uigetfile('ephusdata*.mat','Load ephusdata.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    load( [pathName filesep filename], '-mat');
    sessObj.ephusTrials = obj;
    
    %%wSigTrials
        [filename,pathName]=uigetfile('wSigTrials*.mat','Load wSigTrials.mat file')
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    load( [pathName filesep filename], '-mat');
    sessObj.wSigTrials = wSigTrials;
    
    [synced_sessObj] = sync_all_session_data( sessObj,Cadatasrc);   
    save([Cadatasrc 'synced_sessObj'],'synced_sessObj','-v7.3');   
    obj = synced_sessObj;
    if isfield(obj,'nROIs')
        numrois=obj.nROIs;
    else
        numrois = 0;
    end


% --- Executes on button press in open_whiskmp4.
function open_whiskmp4_Callback(hObject, eventdata, handles)
%    set(handles.open_whiskmp4,'Value',1); 
%    current_trial = get(handles.currenttrial,'String');
%    if strcmp(handles.whiskpath,'')
%        [filename,pathName]=uigetfile('WDBP*.mp4','Load whisker mp4 file')
%        
%    end
   
% --- Executes on slider movement.
function whiskmp4_sl_Callback(hObject, eventdata, handles)
    global obj
    trNo  = str2num(get(handles.currenttrial,'String'));
    ts_wsk = obj(trNo).ts_wsk{1};
    wrate = 1/(ts_wsk(2)-ts_wsk(1));
    tracked_frames = size(ts_wsk,2);
    sl_pos=get(handles.whiskmp4_sl,'Value');
    pos = floor(sl_pos*tracked_frames);
    current_frame = ts_wsk(pos)*wrate;
    new_sl_pos = pos/tracked_frames;
    set(handles.whiskmp4_tag,'String',['Fr No' num2str(current_frame) ' Tracked ' num2str(tracked_frames) ' Time' num2str(ts_wsk(pos))]);
    set(handles.whiskmp4_sl,'Value',new_sl_pos);


% --- Executes during object creation, after setting all properties.
function whiskmp4_sl_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function totalrois_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalrois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
