%
% This function allows you to pass two eventSeries (or just event times),
%  and will, for the timeSeries in question, compute the area under the 
%  ROC curve for discriminating values of the timeSeries around the two
%  eventSeries.  
%
% USAGE:
%
%  [aucRaw aucNic idxMat1 idxMat2] = ...
%    session.timeSeries.computePeriEventAUCS (params)
%
% RETURNS:
%
%   aucRaw: AUC when pooling all values
%   aucNic: AUC of nicolelis distances
%   idxMat1, idxMat2: indices used for both ; in case you want to hit this
%                     many times without the most computation-intensive step
%
% PARAMETERS: params -- structure with fields (*: required):
% 
%   es1*: eventSeries 1 ; either an eventSeries or vector of times
%   es2*: eventSeries 2
%   xes: excluded event series
%   xesTimeWindow: how much to exclude around excluded? unit timeWindowUnit.
%   timeWindow: how big of a window to take? [-2 5] means 2 timeUnits before
%               upto 5 timeUnits after ; default [-2 5]
%   timeWindowUnit: session.timeSeries.timeUnitId for window timeUnit ; default
%                   2 (seconds)
%   idxMat1, idxMat2: which indices, within timeSeries.value, to use for 
%                     the eventSeries.  If these are passed, NONE OF THE ABOVE
%                     variables need to be passed (nor do they matter).
%   ts*: the timeSeries to do this on(!)
% 
% SP Jan 2012
%
function  [aucRaw aucNic idxMat1 idxMat2] = computePeriEventAUCS (params)
  aucRaw = 0.5;
	aucNic = 0.5;
  idxMat1 = [];
	idxMat2 = [];

  % --- process inputs
	if (nargin < 1 || ~isstruct (params))
		help ('session.timeSeries.computePeriEventAUCS');
	  disp('computePeriEventAUCS::must pass minimal parameters.');
		return
	end

	passedVars = {'es1', 'es2', 'timeWindow', 'timeWindowUnit', 'idxMat1', 'idxMat2', 'ts', 'xes','xesTimeWindow'};
	varDefault = {'[]','[]','[-2 5]', '2', '[]','[]','[]','[]','[]'};
	for p=1:length(passedVars)
	  if (isfield(params, passedVars{p})); 
		  eval([passedVars{p} ' = params.' passedVars{p} ';']) ; 
		else
		  eval([passedVars{p} ' = ' varDefault{p} ';']);
		end
  end

	if (length(es1) == 0 | length(es2) == 0) 
	  disp('computePeriEventAUCS::cannot process empty event series.');
	end

	% --- c'mon do it
 
	% build indexes for both event series
	if (length(idxMat1) == 0)
		[dataMat1 xTimeMat idxMat1 plotTimeVec] = ts.getValuesAroundEvents(es1, timeWindow, timeWindowUnit, 0, xes, xesTimeWindow);
	else 
	  dataMat1 = nan*idxMat1;
	  dataMat1(find(~isnan(idxMat1))) = ts.value(idxMat1(find(~isnan(idxMat1))));
	end
	if (length(idxMat2) == 0)
		[dataMat2 xTimeMat idxMat2 plotTimeVec] = ts.getValuesAroundEvents(es2, timeWindow, timeWindowUnit, 0, xes, xesTimeWindow);
	else 
	  dataMat2 = nan*idxMat2;
	  dataMat2(find(~isnan(idxMat2))) = ts.value(idxMat2(find(~isnan(idxMat2))));
	end

	% AUC from distance to mean (nicolelis approach)
	fullMat = [dataMat1 ; dataMat2];
	idxA = 1:size(dataMat1,1);
	idxB = size(dataMat1,1)+1:size(dataMat1,1)+size(dataMat2,1);
	if (length(idxA) > 1 & length(idxB) > 1)
		[DVa DVb] = nicolelis_distance(fullMat, idxA, idxB);
		aucNic = roc_area_from_distro(DVa, DVb);
	end

	% AUC off distro alone
	aucRaw = roc_area_from_distro(reshape(dataMat1,[],1)',reshape(dataMat2,[],1)');

%	hold off;
%	plot (nanmean(dataMat1)); hold on;
%	plot (nanmean(dataMat2),'r-');
%	title(['raw: ' num2str(aucRaw) ' ' num2str(aucNic)]);
%	pause




