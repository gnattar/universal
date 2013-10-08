function [r, fn] = load_data_gr(mouseName, sessionName, trialStartEnd,datapath)
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
    datapath = '/Users/ranganathang/Documents/Data/Solo_Data/Data/'; 
end
% r.mouse_name = r.saved.SavingSection_MouseName;
cd (datapath)
% cd([datapath mouseName]);
% files = dir('*.mat');
% %%%fname = ls([datapath mouseName filesep sessionName '.mat']);
fname = [sessionName '.mat'];

% for i = 1:length(files)
%     if strcmp(sessionID(end-6:end), files(i).name(end-10:end-4))
%         fn = files(i).name;
%     end;
% end;
pathstr = datapath;;
[pathstr, fn, ext] = fileparts(fname);

% r = load([pathstr filesep fn]); 
r = load(fname);
r.trialStartEnd = trialStartEnd;
r.mouse_name = mouseName;
r.session_name = sessionName;
[pathstr, filename, ext] = fileparts(fn);
r.session_ID =  filename(end-6:end); %sessionID; %
a = strrep(filename, r.mouse_name, '');
a = strrep(a, ['__' r.session_ID], '');
r.protocol_name = strrep(a, 'data_@', '');
% cd(pwd0);