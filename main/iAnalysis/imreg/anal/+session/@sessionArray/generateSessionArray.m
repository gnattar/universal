%
% SP 2010 Dec
%
% This will generate a sessionArray object given a path and a wildcard.
%
% USAGE:
%
%   sA = generateSessionArray(sessionFilePath, sessionFileWC)
%
%     sessionFilePath: directory where individual session files are
%     sessionFileWC: all matches to this wildcard will be incorporated
%
function sA = generateSessionArray(sessionFilePath, sessionFileWC)
  % --- sanity checks
	if (nargin < 2)
	  disp('generateSessionArray::Must specify path & wildcard');
		return
	end
	if (exist(sessionFilePath) ~= 7)
	  disp(['generateSessionArray::' sessionFilePath ' is not a valid file path.']);
		return;
	end

	% get file list
	fl = dir([sessionFilePath filesep sessionFileWC]);
	if (length(fl) < 1)
	  disp(['generateSessionArray::' sessionFilePath filesep sessionFileWC ' has no matching files.']);
		return;
	end

	% generate
	for f=1:length(fl)
	  load([sessionFilePath filesep fl(f).name]);
		S{f} = s;
	end
	sA = session.sessionArray(S);

