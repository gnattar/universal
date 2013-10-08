%
% SP 2010 DEc
%
% This will save a sessionArray to file, making sure that underlying session
%  objects are stripped of most of their internal components
%
% USAGE:
%
%   sA.saveToFile(fileName)
%
%     fileName: file to write to ; full path (or pwd if just filename)
%
function saveToFile(obj, fileName)
  % --- sanity check
	if (nargin < 2)
	  disp('saveToFile::you must specify an output target.');
	  return;
	end

	% --- main logic

	% loop through the session array and get a light copy of each
	for s=1:length(obj.sessions)
		% grab original sessions array
		realSessions{s} = obj.sessions{s};

		% and light copy
	  savedSessions{s} = obj.sessions{s}.lightCopy();
	end

	% save call with savedSessions
	obj.sessions = savedSessions;
	sA = obj;
	sA.saveFlag = 1; % suppress warning message
	save (fileName, 'sA');
	obj.sessions=realSessions; 
