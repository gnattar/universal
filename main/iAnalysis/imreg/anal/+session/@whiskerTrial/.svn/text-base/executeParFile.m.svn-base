%
% SP 2010 Nov
%
% This is to be called by par_execute to 
%  a) create a whiskerTrial object and run face detection etc.
%  b) run process()
%
% USAGE:
% 
%  session.whiskerTrial.executeParFile( params)
%
%  params: structure where params.dotWhiskersPath and params.batchParamsFilePath
%    are used to figure out everything else.
%                          
function executeParFile(params)
  % --- sanity
	if (~isstruct(params))
	  disp('executeParFile::params must be struct with members dotWhiskersPath and batchParamsFilePath.');
	  return;
	end

  % --- build everything up
	dotWhiskersPath = params.dotWhiskersPath;
	moviePath = strrep(dotWhiskersPath, 'whiskers','mp4');
	outputPath = strrep(dotWhiskersPath, 'whiskers', 'mat');
	
	batchParamsFile = params.batchParamsFilePath;
	load(batchParamsFile);
	polyFitMaxFollY = polynomialFitMaxFollicleY;
	polyDFromFace = polynomialDistanceFromFace;
  mwLen = minWhiskerLength;

  [a subPath] = fileparts(dotWhiskersPath);
	subidx = find(subPath == '_');
	trialId = str2num(subPath(subidx(length(subidx)-1)+1:subidx(length(subidx))-1));

	% --- run initial construction
	wt = session.whiskerTrial(trialId, dotWhiskersPath, moviePath, polyFitMaxFollY, polyDFromFace, mwLen);
	wt.matFilePath = outputPath;

	% --- and now process
	wt.processFromBatchConfigFile(batchParamsFile);

	% --- and save...
  save(outputPath, 'wt');










