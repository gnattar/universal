%
% SP Nov 2010
%
% This will first load a batchConfigFile and use its params on the calling
%  object, and then invoke process.
%
% USAGE:
%
%  wt.processFromBatchConfigFile(batchConfigFilePath)
%
%  batchConfigFilePath: leave out if you want default (batchParameters.mat)
%
function processFromBatchConfigFile(obj, batchConfigFilePath)
  % --- sanity
	if (nargin == 1)
	  batchConfigFilePath = [fileparts(obj.whiskerMoviePath) filesep 'batchParameters.mat'];
	end
	if (exist(batchConfigFilePath,'file') ~=2)
	  disp(['processFromBatchConfigFile::aborting - could not find config file ' batchConfigFile]);
		return;
	end

obj.messageLevel=1; % for now
	% --- load params
	load(batchConfigFilePath);
  obj.numWhiskers = numWhiskers;
	obj.whiskerTag = whiskerTag;
	obj.minWhiskerLength = minWhiskerLength;
	obj.maxFollicleY = maxFollicleY;
	obj.positionDirection = positionDirection;
	obj.polynomialDistanceFromFace = polynomialDistanceFromFace;
	obj.polynomialFitMaxFollicleY = polynomialFitMaxFollicleY;
	obj.kappaPositionType = kappaPositionType;
	obj.kappaPosition = kappaPosition;
	obj.thetaPositionType = thetaPositionType;
	obj.thetaPosition = thetaPosition;
  obj.barFractionTrajectoryInReach = barFractionTrajectoryInReach;
	obj.barInReachParameterUsed = barInReachParameterUsed;
	obj.polynomialOffset = [0 0 polynomialOffset];
 
	% --- invoke
	obj.process();
