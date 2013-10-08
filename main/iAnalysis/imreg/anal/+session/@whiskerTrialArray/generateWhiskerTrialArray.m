%
% Generates a whiskerTrialArrayObject from raw whiskerTrial data files.
%
% USAGE:
%
%  wta = session.whiskerTrialArray.generateWhiskerTrialArray(whiskerFilePath, whiskerFileWC, baseFileName)
%
% ARGUMENTS:
%  
%  whiskerFilePath: path where individual whiskerTrial .mat files reside.  Or 
%                   cell array with list of files
%  whiskerFileWC: wildcard to use.  If wildcard is omitted, whiskerFilePath is
%                 treated as exact filename list.
%  baseFileName: where the whiskerTrialArray will be saved to ; default is 
%                [basePath filesep 'whiskerTrialArray.mat'], where basePath is
%                the directory where original data is.
%
% RETURNS:
%
%  wta: the whiskerTrialArray object.  Also compiles arrays.
%
% (C) S Peron Mar 2012
%
function wta = generateWhiskerTrialArray (whiskerFilePath, whiskerFileWC, baseFileName)
  
	%% --- process inputs
	if (nargin >= 2)
	  fl = dir([whiskerFilePath filesep whiskerFileWC]);
		if (length(fl) == 0)
		  error(['No files matching your wildcard: ' whiskerFilePath filesep whiskerFileWC]);
		end
		for f=1:length(fl)
		  flist{f} = [whiskerFilePath filesep fl(f).name];
		end
	elseif (nargin == 1 || length(whiskerFileWC) == 0)
    flist = whiskerFilePath;
		if (~iscell(flist)) ; flist = {flist}; end % single? why??
	else
	  help('session.whiskerTrialArray.generateWhiskerTrialArray');
		error('session.whiskerTrialArray.generateWhiskerTrialArray::inappropriate input arguments.');
	end
	basePath = fileparts(flist{1});

	if (nargin < 3) ; baseFileName = [basePath filesep 'whiskerTrialArray.mat']; end

	%% --- build it

	% load files
	wtArray = {};
  for f=1:length(flist)
	  disp(['session.whiskerTrialArray.generateWhiskerTrialArray::processing ' flist{f}]);
	  load(flist{f});
		wtArray{f} = wt;
	end

  % call constructor
	wta = session.whiskerTrialArray(wtArray, basePath, baseFileName);

	% compile arrays
	wta.compileArrayDataFromTrials();



