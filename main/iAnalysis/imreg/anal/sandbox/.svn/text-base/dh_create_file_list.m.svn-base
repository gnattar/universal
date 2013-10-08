function [scimFileList scimFileTrial]=dh_create_file_list(d,incl_numb, wc)

%     
% global rootDataPath;
% 	rootDataPath ='D:\';
% 	base='D:\'; 
%     dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091223a']; 
% 	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_122309.mat']; % check if present
% 	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_122309/fluo_batch_out/rigid/'];
% 	dsp{6}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_122309*.tif';
% 	dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1223/zese']; 
% 	dsp{6}.ephusFileWC='dh1223zese*'; 
% 	dsp{6}.ephusDownsample=[]; 
% 	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
% 	dsp{6}.whiskerFileWC = 'jf25607x122909_3_123_session_B.mat';
% 	%dsp{6}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
% 	dsp{6}.whiskerBarInReachES=2*[610 1006]; %check
% 	dsp{6}.whiskerTag={'C1'};
% 	dsp{6}.baseFileName=[base 'DOM3_results/jf25607/jf25607x122309_sessSP.mat'];
% 	dsp{6}.userDefinedValidTrialIds=[8:103]; 
%     dsp{6}.scimFileList=[];
%     dsp{6}.scimFileTrial=[];
%     
%     d=dsp{6}.scimFilePath;
%     incl_numb=dsp{6}.userDefinedValidTrialIds;
%     wc=dsp{6}.scimFileWC;
    
nargin
if nargin==3
   d_file_names=dir(fullfile([d, wc]));
   file_names=arrayfun(@(x) x.name, d_file_names, 'UniformOutput',false);
   full_file_names=cellfun(@(x) [d x], file_names, 'UniformOutput',false);
elseif nargin<3
    %choose flies from list
    [b d] = uigetfile('*.tif', 'select go imaging data');
    filename=[d b];
    file_names=selectFilesFromList(d, '*.tif');
    full_file_names=cellfun(@(x) [d x], file_names, 'UniformOutput',false);   
end
    
%get the trial numbers: 
trial_numA=cell2mat(cellfun(@(x) str2num([x(end-6:end-4)]), file_names, 'UniformOutput',false));

%check for imposed minimal trial number
if ~isempty(incl_numb)
    [kickout I]=setdiff(trial_numA, incl_numb);
end
  full_file_names(I)=[]; 
  trial_numA(I)=[]; 
  
  scimFileList=full_file_names;
  scimFileTrial=trial_numA;



function names = selectFilesFromList(path, type)

global gh state

if nargin < 1
	path = pwd;
	type = '.tif'
end

if nargin == 1
	try
		filetype = get(gh.autotransformGUI.fileType, 'String');	
		value = get(gh.autotransformGUI.fileType, 'Value');
		filetype = filetype{value};
	catch
		filetype = type;
	end
end
if nargin == 2 
	filetype = type;
end

d = dir(fullfile(path, ['/*' filetype]));
if length(d) == 0
	str = 'No Files Found';
else
	str = {d.name};
end
str = sortrows({d.name}');
if isempty(str)
	names = {};
	disp('No Files with that Extension Selected. Please choose a Path with Image files');
	return
end

[s,v] = listdlg('PromptString','Select a file:', 'OKString', 'OK',...
	'SelectionMode','multiple',...
	'ListString', str, 'Name', 'Select a File');
names = str(s);






