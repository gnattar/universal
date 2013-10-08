%
% SP Jun 2011
%
% Computes the receptive field in terms of some whisker parametrization and
%  max dF/F for a roi.
%
% USAGE:
%
%   [st re params sTS rTS es rValMat] = s.getPeriWhiskerContactRF(params)
%
% PARAMS:
%
%   st: vector of stimulus values, determined by params
%   re: vector of ROI dF/F responses
%   params (returned): params used to obtain st/re, so that you can rerun 
%                      with this and get same results.  See below.
%   sTS: stimulus timeSeries object used
%   rTS: response timeSeries
%   es: eventSeries that was used in end
%   rValMat: allows you to do event-triggered average
%   
%   params (passed): Structure with following fields:
%
%     required:
%
%       roiId: ID of roi you wish to look @
%       wcESA: eventSeriesArray containg whisker contacts -- string that is eval'd
%       wcESId: within this ESA, Id that is used; string or numeric
%       stimTSA: timeSeriesArray from which st is obtained (string that is eval'd)
%       stimTSId: Id (string or numeric) within stimTSA to use
%       stimMode: mode for session.timeSeries.computeReceptiveFieldAroundEvents
% 
%     optional:
% 
%       useExclusive: if 1 (dflt 0), will only use exclusive contacts
%       trialEventNumber: number for specific contact in trial, [] for all
%                         or 'max' for strongest touch by dKappa. (dflt [])
%       respTSA: if you want something other than caTSA.dffTimeSeriesArray ; pass
%                *string* which is eval'd
%       stimTimeWindow: in seconds, peri-event time window for which st is 
%                       computed. [-0.1 0.5] default.
%       respTimeWindow: window over which response is computed [0 2] dflt. Sec.
%       respMode: as with stimMode but for resp ; default 'max'.
%       sTS: if you pass this, it is used as the final stimulus timeSeries --
%            useful for repeated calls.  Note that this renders stimTSA and
%            stimTSId moot.  
%     
function [st re params sTS rTS es rValMat] = getPeriWhiskerContactRF(obj, params)

  % --- presets
  st = [];
	re = [];
	xESTimeWindow = [];
	xES = [];
	rValMat = [];
	sIdxMat = [];
	rIdxMat = [];
	sIeIdxVec = [];
	rIeIdxVec = [];

	% --- process inputs
	if (nargin < 2) ; help('session.session.getPeriWhiskerContactRF'); return; end

	% required
	roiId = params.roiId;
	wcESA = params.wcESA;
	wcESId = params.wcESId;
	stimTSA = eval(['obj.' params.stimTSA ';']);
	stimTSId = params.stimTSId;
	stimMode = params.stimMode;

	% optional
  stimTimeWindow = [-0.1 0.5];
	respTimeWindow = [0 2];
	useExclusive = 0;
	trialEventNumber = [];
	respMode = 'max';
	respTSA = 'caTSA.dffTimeSeriesArray';
	sTS = [];
	if (isfield(params,'stimTimeWindow')) ; stimTimeWindow = params.stimTimeWindow; end
	if (isfield(params,'respTimeWindow')) ; respTimeWindow = params.respTimeWindow; end
	if (isfield(params,'useExclusive')) ; useExclusive = params.useExclusive; end
	if (isfield(params,'trialEventNumber')) ; trialEventNumber = params.trialEventNumber ; end
	if (isfield(params,'respMode')) ; respMode = params.respMode; end
	if (isfield(params,'respTSA')) ; respTSA = params.respTSA; end
	if (isfield(params,'sTS')) ; sTS = params.sTS; end

	% --- prepare
	% pull rTS
	rTSA = eval(['obj.' respTSA ';']);
	rTS = rTSA.getTimeSeriesById(roiId);

  % pull sTS
	if (length(sTS) == 0)
		if (isnumeric(stimTSId))
			sTS = stimTSA.getTimeSeriesById(stimTSId);
		else
			sTS = stimTSA.getTimeSeriesByIdStr(stimTSId, 1,1);
		end
	end

	% pull es -- the eventSeries that is used ...
	if (isobject(wcESA) & strcmp(class(wcESA), 'session.eventSeries'))
	  es = wcESA;
	else
		if (isobject(wcESA))
			wESA = wcESA;
		else
			wESA = eval(['obj.' wcESA ';']);
		end

		if (isnumeric(wcESId))
			es = wESA.getEventSeriesById(wcESId);
		else
			es = wESA.getEventSeriesByIdStr(wcESId, 1,1);
		end
	end

  % exclusive
	if (useExclusive)
		xESTimeWindow = [-2 2];
		xES = wESA.getExcludedCellArray(es.id);
	end

	% trialEventNumber 
	if (isstr(trialEventNumber) && strcmp(trialEventNumber,'max')) % STRONGEST contact per trial, ABSOLUTE VALUE

		% pull dKappa
		idStr = es.idStr;
		wStr = idStr(strfind(idStr,'for')+4:end);
		dKTS = obj.whiskerCurvatureChangeTSA.getTimeSeriesByIdStr(['Curvature change for ' wStr], 1, 0);

		sTrials = es.getStartTrials();
		sTimes = es.getStartTimes();
		eTimes = es.getEndTimes();

		uet = unique(sTrials);

		strongest = 0*(1:length(uet));
		for u=1:length(uet)
			eti = find(sTrials == uet(u));
			edk = 0*eti;
			for ei=1:length(eti)
				stidx = find(dKTS.time == sTimes(eti(ei)));  
        if (length(stidx) > 0) % only assign if found -- otherwise keep 0
          if (es.type == 2) % grab range
            eidx = find(dKTS.time == eTimes(eti(ei)));
            edk(ei) = max(abs(dKTS.value(stidx:eidx)));
          else % grab single value
            edk(ei) = abs(dKTS.value(stidx));
          end
        end
			end
			[maxVal idx] = max(edk);
			strongest(u) = eti(idx);
		end
		strongest = strongest(find(strongest > 0));

		% build the new ES
		if (length(strongest) > 0) 
			nes = es.restrictedCopy(sTimes(strongest));
			es = nes;
		else
			es = [];
		end
	elseif (trialEventNumber > 0) % contact NUMBER
		es = es.getESBasedOnNthEventByTrial(trialEventNumber);
	end
	
	if (length(es) > 0)
		% restrict sTS to period where event is active by nan'ing other timepoints
		%  only do if not passed
	  if (~isfield(params,'sTS') || length(params.sTS) == 0) 
  		ests = es.deriveTimeSeries(sTS.time, sTS.timeUnit, [nan 1]);
	  	sTS = sTS.copy();
		  sTS.value = sTS.value.*ests.value;
		end

		% --- hit computeReceptiveFeildAroundEvents
		[st re sidx nidx evIdx sIdxMat sValMat rIdxMat rValMat sIeIdxVec rIeIdxVec] = ... 
		    session.timeSeries.computeReceptiveFieldAroundEvents (sTS, stimMode, ...
		         rTS, respMode, es, stimTimeWindow, respTimeWindow, ...
				     2,0,xES,xESTimeWindow);

		% additional returnees via params
		eTrials = es.eventTrials(evIdx);
		params.eTrials = eTrials;
	end

	% rebuild params for return
	params.stimTimeWindow = stimTimeWindow;
	params.respTimeWindow = respTimeWindow;
	params.useExclusive = useExclusive; 
	params.trialEventNumber = trialEventNumber ;
	params.respMode = respMode;
	params.respTSA = respTSA;
  params.sIdxMat = sIdxMat;
 	params.rIdxMat = rIdxMat;
	params.sIeIdxVec = sIeIdxVec;
	params.rIeIdxVec = rIeIdxVec;

