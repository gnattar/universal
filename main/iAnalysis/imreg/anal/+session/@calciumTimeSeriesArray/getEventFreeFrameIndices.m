%
% SP May 2011
%
% Will return (if available) frames that are members of contiguous blocks at 
%  least nFrames long where roiIds have no events in caPeakEventSeries.
%
% USAGE:
%
%   frameIdx = caTSA.getEventFreeFrameIndices(nFrames, roiIds)
%
%   frameIdx: indices of frames that are still
%
%   nFramse: how long the block of stillness is, at least
%   roiIds: vector of IDs of rois to include ; blank means all
%   
function frameIdx = getEventFreeFrameIndices(obj, nFrames, roiIds)

  % --- arguments
  if (nargin < 3) ; roiIds = obj.ids ; end

  % --- find stillest blocks 

  % rate vector same as time (not actually rate in hz)
	rateVec = 0*obj.time;

	% for each roi, generate rate vector and add to rateVec
	dt = mode(diff(obj.time));
	dt = session.timeSeries.convertTime(dt,obj.timeUnit,2); % dt in seconds
	for r=1:length(roiIds)
	  ri = find(obj.ids == roiIds(r));
	  ts = obj.caPeakEventSeriesArray.esa{ri}.deriveTimeSeries(obj.time, obj.timeUnit);
		ts.value(find(ts.value ~=0)) = 1;
		rateVec = rateVec + ts.value;
	end

	% find contiguous periods in rateVec of nFrames or more length with rate 0
	validFrame = 0*rateVec;
	valid = (find(rateVec == 0));
	cbsCandi = valid(find(diff(valid) == 1));
	for c=1:length(cbsCandi)
	  firstBad = min(find(rateVec(cbsCandi(c):end) > 0));
		firstBad = firstBad + cbsCandi(c)-1;
		if (length(firstBad) > 0)
		  blockLen = firstBad-cbsCandi(c);
      if (blockLen >= nFrames)
			  validFrame(cbsCandi(c):firstBad-1) = 1;
			end
		end
	end
	frameIdx = find(validFrame);

  % debug
  if (0)
		plot(rateVec, 'b-')
		hold on ;
		nv = 0*rateVec - 1;
		nv(frameIdx) = 1;
		plot(nv, 'r-');
	end



