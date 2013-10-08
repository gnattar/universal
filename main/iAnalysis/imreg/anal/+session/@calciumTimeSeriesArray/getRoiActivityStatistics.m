%
% Generates statistics that are useful for estimating activity levels.
%
% This will examine statistics to infer various activity classes of ROIs. Uses
%  the distribution of raw fluorescence and looks at geneartes two metrics.
%  First, it fits a PDF to the distribution of fluorescence values.  Then, it
%  computes a cutoff fluo value below which 90% of the distribution fits.  
%  The fraction of points above twice this value is "numAboveCutoff".  The
%  ratio of this cutoff value to the peak value is "cutoffToMaxRatio".
%
%  The method assigns the following fields to the roiActivityStatsHash:
%
%    numAboveCutoff: see above
%    cutoffToMaxRatio: see above
%    thresh: cutoff threshold for each ROI
%    sd: sd for each ROI
%    hyperactiveIds: list of ROIs that are considered hyperactive
%    activeIds: list of ROIs that are considered active
%    inactiveIds: list of ROIs that are considered inactive
%
%  Also assignd the field obj.activeRoiIds, comprising active and hyperactive.
%
% USAGE: 
% 
%  caTSA.getRoiActivityStatistics(params)
%
% ARGUMENTS:
%
%  params: structure (optional) with stuff
%    params.valueMatrix: if you pass, it will base off this ; so e.g., if you want
%                        to use caTSA.dffTimeSeriesArray.valueMatrix
%    params.nabThresh: fractional thresh for numAboveCutoff ; if above, active
%    params.cofThresh: frac thresh for cutoff-to-max ratio (hyperactive)
%    params.forceRedo: if passed and 1, it will redo ; otherwise, it will only 
%                      proceed if roiActivityStatsHash is blank
%    params.debug: some plotz n shit
%
% (C) S Peron Jan 2011
%
function obj = getRoiActivityStatistics(obj, params)


  %% --- parse input arguments
	valueMatrix = obj.valueMatrix;
  nabThresh = .01;
  cofThresh = .25;
	forceRedo = 0;
	debug = 0;
	if (nargin > 1 && isstruct(params))
	  eval(assign_vars_from_struct(params, 'params'));
	end

	% should this even happen?
	if (isobject(obj.roiActivityStatsHash) && ~forceRedo)
	  disp('getRoiActivityStatistics::either set params.forceRedo to 1 or blank roiActivityStatsHash to force recalculation ; for now, skipping.');
	end
  
	% populated below and then popped into roiActivityStats ...
	if (~isobject(obj.roiActivityStatsHash)) ; obj.roiActivityStatsHash = hash() ; end
  hyperactiveIdx = [];
	activeIdx = [];
	inactiveIdx = [];
	thresh = [];
	stats = [];
	sds = [];

  %% --- body

  % get ksdensity
	thresh = zeros(1,size(valueMatrix,1));
	nab = 0*thresh;
	cof = 0*thresh;
	skew = 0*thresh;
	for r=1:size(valueMatrix,1)
		vec = valueMatrix(r,:);
		vec = vec(~isnan(vec));
		if (length(vec) == 0) ; continue ; end % skip nan

    skew(r) = skewness(vec);

		[f xi] = ksdensity(vec);
		[peak_f idx] = max(f);
		peak_x = xi(idx);
   
	  % align so that peak is at 0, then pull values to left of peak
		xi = xi-peak_x;
    vec = vec-peak_x;
		nval = find(xi <= 0);
		if (length(nval) == 0) ; continue ; end % skip blanks

		sds(r) = std(vec);

		% compute your cutoff value -- 1/10 peak
		cutoff_idx = max(find(f(nval) < peak_f/10));
		if (length(cutoff_idx) == 0)

		  thresh(r) = 0;
			nab(r) = 0;
			cor(r) = 0;
		else
			cutoff_val = 2*abs(xi(nval(cutoff_idx(1))));
			thresh(r) = cutoff_val+peak_x;

			% how many points are above cutoff?
			n_above = length(find(vec > cutoff_val));
			nab(r) = n_above/length(vec);;

			% compute pdf's value at cutoff
			cvip = min(find(xi > cutoff_val));
			if (length(cvip) > 0)
				cutoff_f = abs(f(cvip));
			else 
				cutoff_f = 0;
			end
			cof(r) = cutoff_f/max(f);
		end
  end

  % activeIdx: 5% of pdf above cutoff
  activeIdx = find(nab > nabThresh);

	% hyperactiveIdx: pdf_cutoff/pdf_peak > 0.1 ; also negative skewness
	hyperactiveIdx = find(cof > cofThresh);
	hyperactiveIdx = union(hyperactiveIdx, find(skew < -0.1)); % very rare but ocassional

	% inactive: all else
	inactiveIdx = setdiff(1:size(valueMatrix,1), activeIdx);
	inactiveIdx = setdiff(inactiveIdx, hyperactiveIdx);

  % build stats
	stats = [nab ; cof];

	% assign activeRoiIds
	obj.activeRoiIds = obj.ids(union(hyperactiveIdx, activeIdx));

	% assign outputs to hash...
  obj.roiActivityStatsHash.setOrAdd('nabThresh', nabThresh);
  obj.roiActivityStatsHash.setOrAdd('cofThresh', cofThresh);
  obj.roiActivityStatsHash.setOrAdd('inactiveIdx', inactiveIdx);
  obj.roiActivityStatsHash.setOrAdd('activeIdx', activeIdx);
  obj.roiActivityStatsHash.setOrAdd('hyperactiveIdx', hyperactiveIdx);
  obj.roiActivityStatsHash.setOrAdd('numAboveCutoff', nab);
  obj.roiActivityStatsHash.setOrAdd('cutoffToMaxRatio', cof);
  obj.roiActivityStatsHash.setOrAdd('thresh', thresh);
  obj.roiActivityStatsHash.setOrAdd('stats', stats);
  obj.roiActivityStatsHash.setOrAdd('sds', sds);
  obj.roiActivityStatsHash.setOrAdd('skew', skew);

  % report?
	if (debug)
	  for r=1:length(obj.ids)
			cla;
		  obj.getTimeSeriesByIdx(r).plot();
			titleStr = ['Cell ID: ' num2str(obj.ids(r))];
			titleStr = [ ' cof: ' num2str(cof(r)) ' nab: ' num2str(nab(r)) ' skewness: ' num2str(skew(r))];
			if (ismember(r, hyperactiveIdx))
			  titleStr = [titleStr ' HYPERACTIVE'];
			elseif (ismember(r, activeIdx))
			  titleStr = [titleStr ' ACTIVE'];
			else
			  titleStr = [titleStr ' INACTIVE'];
			end
      title(titleStr);
			pause;
		end
	end
   

