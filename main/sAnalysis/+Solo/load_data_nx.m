function [r, fn] = load_data_nx(mouseName, sessionID, trialStartEnd, datapath)
%
% fn is file name of a solo file.
% section has form: [firstTrial lastTrial], the section of trails needed for analysis 
% 
% mouseName, e.g., 'NX102527'
% sessionID, e.g., '100627a'
% trialStartEnd, e.g., [2 151], the range of trials of a imaging sub-session.
% 
% NX, 8/2009

if ~exist('datapath','var')|| isempty(datapath)
    datapath = '/Users/xun/Documents/ExpData/Whisker_Behavior_Data/SoloData/Data_2PRig/'; 
end
% r.mouse_name = r.saved.SavingSection_MouseName;
pwd0 = pwd;
% cd([datapath mouseName]);
% files = dir('*.mat');
name = ls([datapath mouseName filesep '*' sessionID '.mat']);
% for i = 1:length(files)
%     if strcmp(sessionID(end-6:end), files(i).name(end-10:end-4))
%         fn = files(i).name;
%     end;
% end;
[pathstr, fn, ext] = fileparts(name);

r = load([pathstr filesep fn]); 
r.trialStartEnd = trialStartEnd;
r.mouse_name = mouseName;
r.session_name = sessionID;
[pathstr, filename, ext] = fileparts(fn);
r.session_name = sessionID; % filename(end-6:end);
a = strrep(filename, r.mouse_name, '');
a = strrep(a, ['__' r.session_name], '');
r.protocol_name = strrep(a, 'data_@', '');
% cd(pwd0);