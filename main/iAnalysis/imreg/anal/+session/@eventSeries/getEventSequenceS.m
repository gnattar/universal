%
% SP May 2011
%
% This will create an eventSeries where events indicate that a particular 
%  sequence of other eventSeries took place at that point.  Note that it ONLY
%  works with event starts.
%
% USAGE:
%
%   es = session.eventSeries.getEventSequenceS(ies, sequence, sequenceMaxDt,
%                   returnedTimeUnit, returnType, xes, xTimeWindow, 
%                   xTimeWindowUnit)
%
% PARAMS:
%
%   ies: cell array of events that are used for sequence
%   sequence: index SEQUENCE of ies (e.g., if you want ies{2}->ies{3}->ies{1},
%             this would be [2 3 1])
%   sequenceMaxDt: what is the maximal temporal interval (in ies{1}.timeUnit) 
%                  between events to be part of the sequence.
%   returnedTimeUnit: by default ies{1}.timeUnit
%   returnType: 1 for just starts, 2 for start and END of sequence (default is
%               most common type in ies)
%   xes: optional exclusion cell array of event series -- if the events occur
%        during a sequence epoch, that sequence epoch is not returned
%   xTimeWindow: whta is the time window for xes exclusion to apply?
%   xTimeWindowUnit: unit of xTimeWindow (seconds default)
%               
function es = getEventSequenceS(ies, sequence, sequenceMaxDt, ...
                   returnedTimeUnit, returnType, xes, xTimeWindow, ...
                   xTimeWindowUnit)

  es = session.eventSeries(); % default is return an empty

  % --- process params
  if (nargin < 3) 
	  help('session.eventSeries.getEventSequenceS');
	  disp('getEventSequenceS::must specify at least first 3 parameters.');
		return;
	end

	if (nargin < 4 || length(returnedTimeUnit) == 0) ; returnedTimeUnit= 0 ; end
  if (nargin < 5 || length(returnType) == 0) ; returnType = 0; end
	if (nargin < 6 || length(xes) == 0) ; xes = []; end
	if (nargin < 7 || length(xTimeWindow) == 0) ; xTimeWindow = []; end
	if (nargin < 8 || length(xTimeWindowUnit) == 0) ; xTimeWindowUnit = 2 ; end

	% cell it
	if (~iscell(ies)) ; ies = {ies} ; end
	if (length(xes) > 0 & ~iscell(xes)) ; xes = {xes} ; end

	% return tiem unit
	if (returnedTimeUnit == 0)
	  returnedTimeUnit = ies{1}.timeUnit;
	end

	% return type ...
	if (returnType == 0)
		nt1 = 0;
		nt2 = 0;
		for i=1:length(ies)
			if (ies{i}.type == 1) ; nt1 = nt1+1; else ; nt2 = nt2+1; end
		end
		if (nt2 > nt1) ; returnType = 2;  else ; returnType = 1; end
	end

  % --- more preliminaries ...

  % convert time units (all to returnedTimeUnit)
	sequenceMaxDt = session.timeSeries.convertTime(sequenceMaxDt, ies{1}.timeUnit, returnedTimeUnit);
	for i=1:length(ies)
	  ies{i} = ies{i}.copy();
		ies{i}.eventTimes = session.timeSeries.convertTime(ies{i}.eventTimes, ies{i}.timeUnit, returnedTimeUnit);
	end
	for x=1:length(xes)
	  xes{x} = xes{x}.copy();
		xes{x}.eventTimes = session.timeSeries.convertTime(xes{x}.eventTimes, xes{x}.timeUnit, returnedTimeUnit);
	end
	if (length(xTimeWindow) > 0) ; xTimeWindow = session.timeSeries.convertTime(xTimeWindow, xTimeWindowUnit, returnedTimeUnit); end

	% build exclude event time matrix ... [start end] is each row
	Lx = 0; for x=1:length(xes) ; Lx= Lx+ length(xes{x}.getStartTimes()); end
  xTimes = nan*ones(2,Lx);
	xi = 1;
	for x=1:length(xes)
	  sTimes = xes{x}.getStartTimes() + xTimeWindow(1) ;
	  eTimes = xes{x}.getEndTimes() + xTimeWindow(2);
	  xTimes(:,xi:xi+length(eTimes)-1) = [sTimes ; eTimes];
		xi = xi + length(eTimes);
	end

	% --- find sequences!

	% build a matrix with each row [idx time] where idx is the ies index and tiem is
	%  that particular event's time.  The matrix is sorted in time ascending.  
	for i=1:length(ies) ; L(i) = length(ies{i}.getStartTimes()) ; end
	seqMat = nan*ones(2,sum(L));
	si = 1;
	for i=1:length(ies)
	  tes = ies{i};
		eTimes = tes.getStartTimes();
    if (length(eTimes) > 0)
		  seqMat(:,si:si+length(eTimes)-1) = [i*ones(1,L(i)) ; eTimes];
		  si = si+length(eTimes);
    end
	end
  [irr idx] = sort(seqMat(2,:));
	seqMat = seqMat(:,idx);

	% handle co-incident events -- set BOTH id entries to nan
	dSeq = diff(seqMat(2,:));
	remove = find(dSeq == 0);
	for r=1:length(remove)
	  seqMat(1,remove(r)) = nan;
	  seqMat(1,remove(r)+1) = nan;
	end

	% now with this handy matrix, detect your desired sequence 
	candidateStartIdx = strfind(seqMat(1,:), sequence);
	acceptSeq = ones(1,length(candidateStartIdx));

	% ensure that sequenceMaxDt is obeyed ...
	for c=1:length(candidateStartIdx)
	  seqIdx = candidateStartIdx(c):candidateStartIdx(c)+length(sequence)-1;
		dt = diff(seqMat(2,seqIdx));
		if (length(find(dt > sequenceMaxDt)) > 0) 
		  acceptSeq(c) = 0;
		% apply exclusion here as well -- if xTime window overlaps WITH START
		elseif (length(xTimes) > 0)
		  dx = xTimes - seqMat(2,seqIdx(1));
			if (length(find(dx == 0)) > 0) % exact match
			  acceptSeq(c) = 0;
			else % 2 different signs in a row of dx means you fall between
			  dx(find(dx < 0)) = -1;
			  dx(find(dx > 0)) = 1;
				if (sum(diff(dx)) > 0) 
				  acceptSeq(c) = 0;
				end
			end
		end
	end

	% and now build your initial results
	val = find(acceptSeq);
	sIdx = candidateStartIdx(val);
	eIdx = sIdx + length(sequence)-1;
 	if (length(val) > 0)
		seqStartTimes = seqMat(2,sIdx);
		seqEndTimes = seqMat(2,eIdx);

		% --- build returned eventSeries
		seqName = [ies{sequence(1)}.idStr];
		for i=2:length(sequence) 
		  seqName = [seqName '->' ies{sequence(i)}.idStr];
		end
		if (returnType == 1) 
		  eTimes = seqStartTimes;
		else
		  eTimes = 0*[seqStartTimes seqStartTimes];
			eTimes(1:2:end-1) = seqStartTimes;
			eTimes(2:2:end) = seqEndTimes;
		end
    es = session.eventSeries(eTimes, nan*eTimes, returnedTimeUnit, 1, ...
	       seqName, 0, '', 'generated by getEventSequenceS', ...
			   [1 0 1], returnType);
	end


