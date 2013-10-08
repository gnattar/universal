%
% SP 2010 Nov
%
% Returns barInReach boolean vector but based on barFractionTrajectoryInReach.
%
%  [barInReach centerAtCutoff] = wt.getFractionCorrectedBarInReach(obj)
%
%  barInReach: boolean with 1 if bar is in reach
%  centerAtCutoff: optional; will return bar center @ point where bar comes into
%                  reach.  Note that if use fractionCorrectedPosition is 1, it will
%                  return nan.
%
function [barInReach centerAtCutoff] = getFractionCorrectedBarInReach(obj)
	centerAtCutoff = nan;

  % --- sanity
	abort = 0;
	if(length(obj.barCenter) == 0)
	  abort = 1;
	elseif (length(find(isnan(obj.barCenter(:,1)))) == length(obj.barCenter(:,1)))
	  abort = 1;
	elseif (length(obj.barInReachParameterUsed) == 0)
	  abort = 1;
	end
	if (abort)
	  if (obj.messageLevel >= 2) ; disp('getFractionCorrectBarInReach::must first track bar!'); end
    barInReach = obj.barInReach;
	% --- compute new bar in reach
	else
	  barInReach = 0*obj.barInReach;
	  % value vec from barInReachParameterUsed
	  valVec = obj.barCenter(:,1);
	  if (obj.barInReachParameterUsed == 2)
	    valVec = obj.barCenter(:,2);
		elseif (obj.barInReachParameterUsed == 3)
	    valVec = obj.barTemplateCorrelation;
		elseif (obj.barInReachParameterUsed == 4)
	    valVec = obj.barVoltageTrace;
		end
		  
	  % get value for in/out reach to deterime sign reach ...
		inReachVal = nanmean(valVec(find(obj.barInReach)));
		outReachVal = nanmean(valVec(find(~obj.barInReach)));
	  cutoffValOffs = obj.barFractionTrajectoryInReach*abs(inReachVal-outReachVal);
		
		% sign based move
		if (inReachVal > outReachVal)
		  cutoffVal = outReachVal + cutoffValOffs;
			barInReach(find(valVec >= cutoffVal))=1;
		else
		  cutoffVal = outReachVal - cutoffValOffs;
			barInReach(find(valVec <= cutoffVal))=1;
		end

		% jitter at move
    startIdx = min(find(barInReach));
		endIdx = max(find(barInReach));
		barInReach(startIdx:endIdx) = 1;

    % center @ cutoff
		if (obj.useFractionCorrectedPosition) ; centerAtCutoff = obj.barCenter(startIdx,:); end
	end

