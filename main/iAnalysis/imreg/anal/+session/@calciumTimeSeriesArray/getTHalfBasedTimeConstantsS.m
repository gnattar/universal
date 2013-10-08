%
% SP Apr 2011
%
% Pulls time constants using t1/2 by computing time of LAST peak (even a minor
%  one, which is why this sucks and GOF is better).  Gets only the decay tau.
%
%  USAGE:
%
% [riseTimes decayTimes] = getTHalfBasedTimeConstantsS(startTimes, endTimes, peakTimes, valueMatrix, timeVec)
%
%  PARAMS:
%
%   riseTimes: cell array of vectors with rise times; for now, simply NaN
%   decayTimes: the key stuff ; again, cell array of vectors.  Note that ALL the 
%     xxTimes cell arrays should be the same size and their constituent vectors
%     also need to be the same size.  Returned data holds to this.
%
%   startTimes: start of event epochs; cell array of VECTORS, one vector / ROI
%   endTimes: ends of event epochs (unused for now)
%   peakTimes: peak times of events, from which decays are measured
%   valueMatrix: as in all timeSEriesArrays 
%   timeVec: vector of times for valueMatrix
%
function [riseTimes decayTimes] = getTHalfBasedTimeConstantsS(startTimes, endTimes, peakTimes, valueMatrix, timeVec)
  % misc defaults
  maxRiseTime = 10000; % ms
  maxDecayTime = 10000; % ms
    
	% setup peak finder
	dvm = diff(valueMatrix')';
	dvm(find(dvm>0)) = 1;
	dvm(find(dvm<0)) = -1;

	% loop over rois
	for r=1:size(valueMatrix,1);
		% quick peak finder
		pv = find(dvm(r,1:end-1) == 1);
		peakidx = pv(find(dvm(r,pv+1) == -1))+1;

		% loop thru all events ...
		riseTimes{r} = nan*ones(size(peakTimes{r}));
		decayTimes{r} = nan*ones(size(peakTimes{r}));
		for e=1:length(peakTimes{r})
			ei1 = find(timeVec == startTimes{r}(e));
			ei2 = find(timeVec == endTimes{r}(e));
			if (length(ei1) + length(ei2) == 2) % found both
				pk1 = peakidx(min(find(peakidx > ei1)));
				pk2 = peakidx(max(find(peakidx < ei2-1)));
				if (length(pk1) + length(pk2) == 2 && pk2 >= pk1) % found both
					% finally we can do some real work -- determine what time you would cross
					%  half peak-min value
					baseVal1 = valueMatrix(r,ei1);
					baseVal2 = valueMatrix(r,ei2);
					peakVal1 = valueMatrix(r,pk1);
					peakVal2 = valueMatrix(r,pk2);

					% one final condition -- make sure peaks are above otherwise skip
					if (baseVal1 < peakVal1 && baseVal2 < peakVal2)

						tv = timeVec(ei1:ei2); % a tiny time vector
						vv = valueMatrix(r,ei1:ei2); % and a tiny value matrix

						% set indexing in 'tiny terms'
						pk1 = pk1-ei1+1;
						pk2 = pk2-ei1+1;
					
						% rise time
						vhalf = (peakVal1-baseVal1)/2;
						aIdx = max(find(vv(1:pk1) < vhalf));
						bIdx = aIdx+1;
						m = (vv(bIdx)-vv(aIdx))/(tv(bIdx)-tv(aIdx));
						vzero = vv(aIdx)-m*tv(aIdx);
						thalf = (vhalf-vzero)/m;
						thalf = tv(pk1)-thalf;
						if (length(thalf) > 0 && thalf > 0 && thalf < maxRiseTime)
							riseTimes{r}(e) = 1.4428*thalf;
						end

						% decay time
						vhalf = (peakVal2-baseVal2)/2;
						aIdx = max(find(vv(pk2:end) > vhalf)) + pk2 - 1;
						bIdx = aIdx+1;
						if (bIdx <= length(vv))
							m = (vv(bIdx)-vv(aIdx))/(tv(bIdx)-tv(aIdx));
							vzero = vv(aIdx)-m*tv(aIdx);
							thalf = (vhalf-vzero)/m;
							thalf = thalf-tv(pk2);
							if (length(thalf) > 0 && thalf > 0 && thalf < maxDecayTime)
								decayTimes{r}(e) = 1.4428*thalf;
							end
						end
						if (0) % debug
							hold off;
							plot(tv,vv)
							hold on;
							plot( (thalf + tv(pk2))*[1 1], [0 1], 'r-');
							plot( (tv(pk2))*[1 1], [0 1], 'm-');
							pause
						end
					end
				end
			end
		end
	end

