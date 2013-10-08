function [r, fn] = solo_load_data(mouseName, sessionName, trialStartEnd, datapath)
%
% fn is file name of a solo file.
% section has form: [firstTrial lastTrial], the section of trails needed for analysis 
% 
% 
% NX, 8/2009

if ~exist('datapath','var')|| isempty(datapath)
%     datapath = 'E:\DATA\Whisker_Behavior_Data\SoloData\Data_2PRig\'; 
       datapath = '/Volumes/mageelab/GR_dm11/Data/Solo_Data/Data/'; 
end
% r.mouse_name = r.saved.SavingSection_MouseName;
pwd0 = pwd;
cd([datapath mouseName]);
files = dir('*.mat');
for i = 1:length(files)
    if strcmp(sessionName(end-6:end), files(i).name(end-10:end-4))
        fn = files(i).name;
    end;
end;
r = load(fn); 
r.trialStartEnd = trialStartEnd;
r.mouse_name = mouseName;
r.session_name = sessionName;
[pathstr, filename, ext] = fileparts(fn);
r.session_name = filename(end-6:end);
a = strrep(filename, r.mouse_name, '');
a = strrep(a, ['__' r.session_name], '');
r.protocol_name = strrep(a, 'data_@', '');
cd(pwd0);