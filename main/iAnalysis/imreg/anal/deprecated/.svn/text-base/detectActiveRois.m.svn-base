%
% SP 2010 Aug
%
% This method will use the desired method to determine which ROIs constitute
%  active ROIs under the particular assumptions of the method.  This info
%  is stored in [calling object].activeRoiIds.
%
% USAGE:
% 
% 	detectActiveRois(darOpts)
%
% PARAMETERS: (* implies default)
%   darOpts: structure with following (optional) fields:
%     method: 1 - skewness of fluo
%             2* - call getRoiActivityStatistics which depends on dff
%   indexRange: use only this index range of data points (time wise)
%
% RETURNS:
%
%   Nothing for now; populates the class variable acitveRoiIds.
%
function obj = detectActiveRois(obj, darOpts)
  
	% defaults
	method = 2;
	indexRange = 1:size(obj.valueMatrix,2);

  % -- process inputs
	if (nargin > 1 & isstruct(darOpts))
	 if (isfield(darOpts, 'method'))
		 method = darOpts.method;
	 end
	 if (isfield(darOpts, 'indexRange'))
		 indexRange = darOpts.indexRange;
	 end
	end

  % -- the main switch statement over method
	switch method
	  case 1 % skew of dff
		  % partition into 10 equal subsets
			ntp = length(indexRange);
			nrois = size(obj.valueMatrix,1);
      tmpSkews = nan*zeros(10,nrois);
      Lti = ceil(ntp/10);

			for t=1:10
			  i1 = (t-1)*Lti+indexRange(1);
				i2 = min(ntp, t*Lti + indexRange(1));
			  
				% compute skewneess for this partition
				tmpSkews(t,:) = skewness(obj.valueMatrix(:,i1:i2)');
			end

      % take median across partitions
			roiSkews = nanmedian(tmpSkews);

      % skew > 1 ==> active
		  obj.activeRoiIds = obj.ids(find(roiSkews > 1));

    case 2 % call getRoiActivityStatistics, and include hyperactive and active 
	    if (length(obj.dffTimeSeriesArray) == 0) % fallback -- method 1
			  darOpts.method = 1;
				obj.detectActiveRois();
			else 
			  if (~ isobject(obj.roiActivityStatsHash()))
					obj.getRoiActivityStatistics();
				end
				hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
				activeIdx = obj.roiActivityStatsHash.get('activeIdx');
				inactiveIdx = obj.roiActivityStatsHash.get('inactiveIdx');
				thresh = obj.roiActivityStatsHash.get('thresh');
				stats = obj.roiActivityStatsHash.get('stats');
				obj.activeRoiIds = obj.ids(union(hyperactiveIdx, activeIdx));
			end

		otherwise
		  disp('detectActiveRois::invalid method specified.');
	 end

