%
% SP May 2011
%
% Given a PSTH matrix and trial membership vectors, it will compute the 
%  distributions of PSTH distances based on Nicolelis' psth-distance metric.
%
% USAGE:
%
%   [DVa DVb] = nicolelis_distance(psth, aTrials, bTrials)
%
% PARAMS:
%
%   DVa, DVb: distributuions of distance values for a and bTrials
%
%   psth: matrix where the (t,:) is a trial's PSTH
%   aTrials, bTrials: which elements are type a and b trials in the psth matrix?
%
function [DVa DVb] = nicolelis_distance(psth, aTrials, bTrials)
	
	% mean psths
	crMuPsth = nanmean(psth(bTrials,:),1);
	hitMuPsth = nanmean(psth(aTrials,:),1);

	% now compute CR decision variable for individual trials ...
	DVb = zeros(1,length(bTrials));
	for t=1:length(bTrials)
		allButIdx = setdiff(bTrials,bTrials(t));
		if (length(allButIdx > 1))
			allButVec = nanmean(psth(allButIdx,:),1);
		else
			allButVec = psth(allButIdx,:);
		end
		DVb(t) = nanmean(psth(bTrials(t),:).*(hitMuPsth - allButVec));
	end

	% now compute Hit decision variable for individual trials ...
	DVa =zeros(1,length(aTrials));
	for t=1:length(aTrials)
		allButIdx = setdiff(aTrials,aTrials(t));
		if (length(allButIdx > 1))
			allButVec = nanmean(psth(allButIdx,:),1);
		else
			allButVec = psth(allButIdx,:);
		end
		DVa(t) = nanmean(psth(aTrials(t),:).*(allButVec - crMuPsth));
	end

