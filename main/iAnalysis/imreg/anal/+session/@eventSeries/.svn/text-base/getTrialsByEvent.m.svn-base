%
% SP 2011
%
% This will return trials including/excluding given events
%
% USAGE:
%
%   trialsMatching = session.eventSeries.getTrialsByEvent(ies, xes, validTrialIds)
%
%     trialsMatching: list of trial Ids for matching trials
%
%     ies: included event series objects ; cell array if multiple
%     xes: excluded event series objects; cell array if multiple
%     validTrialIds: trials to look over -- optional
%
function trialsMatching = getTrialsByEvent(ies, xes, validTrialIds)
  trialsMatching = [];

  % --- argument parse
	if (nargin < 1)
    help session.eventSeries.getTrialsByEvent;
	  return;
	end

	if (nargin == 1)
	  xes = {};
	end

	if (nargin > 1 & length(ies) == 0)
	  ies = {};
	end

	if (nargin >= 2 & length (xes) == 0)
	  xes = {};
	end
	
	if (nargin < 3) ; validTrialIds = []; end

  % so it can be assumed we are dealing with cells
	if (~iscell(ies)) ; ies = {ies} ; end
	if (~iscell(xes)) ; xes = {xes} ; end

	% --- get trials
	includedTrials = [];
	for i=1:length(ies)
	  includedTrials = union(includedTrials, unique(ies{i}.eventTrials));
	end
	if (length(ies) == 0)
	  includedTrials = validTrialIds;
	end

  excludedTrials = [];
	for x=1:length(xes)
	  excludedTrials = union(excludedTrials, unique(xes{x}.eventTrials));
	end

  % mop up
	trialsMatching = setdiff(includedTrials,excludedTrials);
	trialsMatching = trialsMatching(find(trialsMatching > 0));
	trialsMatching = trialsMatching(find(~isnan(trialsMatching)));

	% restrict to valid trials
	if (length(validTrialIds) > 0)
	  trialsMatching = intersect(trialsMatching, validTrialIds);
	end


