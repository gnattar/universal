%
% May 2011 SP
%
% Returns all possible sequences of 2 or more whiskers contacting pole.
%  Basically makes a bunch of calls to getSequentialWhiskerContactES. Note
%  that to generate the possible combinations, it uses matlab's nchoosek,
%  but then filters the result to ensure that only *adjacent* combos
%  are allowed (e.g., 12 123 23, but not 13).
%
%  It should also be noted that the results are always sorted so that, in terms
%  of the index of contacts, you will get back, for 3 members, 12 21 23 32 123
%  321 ; for 4 12 21 23 32 34 43 123 321 234 432 1234 4321. 
%
% USAGE:
%
%  sESA = s.getSequentialWhiskerContactESA(contacts, sequenceMaxDt, burstDt)
%
% PARAMS:
%
%  sESA: the eventSeriesArray object
%
%  contacts: which contacts to consider? cell array of strings with whisker 
%            names.  Whiskers that are adjacent in the cell array are assumed
%            adjacent by the subsequent adjacency filter.  You can either use
%            whisker names or preface with R or P to specify re/protraction and
%            thereby use whiskerBarContactClassifiedESA vs whiskerBarContactESA
%            as source.
%  sequenceMaxDt: what is the maximal spacing, in seconds, between contacts
%                 for them to be part of a seuqence?
%  burstDt: if specified, will restrict to FIRST contact in a series of contacts
%           lasting burstDt.  This is very useful if you want to, e.g., restrict
%           to first contact in trial (in which case a value of 2 is a good one --
%           units seconds).
%
function sESA = getSequentialWhiskerContactESA(obj, contacts, sequenceMaxDt, burstDt)
  % --- params process
	if (nargin < 3)
	  help ('session.session.getSequentialWhiskerContactESA');
		sESA = [];
		return;
	end

	if (nargin < 4) 
	  burstDt = 0;
	end

	% --- work
	
	%setup your combinations
	combos = {};
	for c=2:length(contacts)
	  ci = nchoosek(1:length(contacts), c);
		S2 = size(ci,2);

    if (size(ci,1) > 1)
			% restrict to only adjacents
			dci = diff(ci,1,2);
			sdci = sum(dci,2);
			val = find(sdci == c-1);
			ci = ci(val,:);
		end

		% and now add
		for c2=1:size(ci,1)
		  combos{length(combos)+1} = contacts(ci(c2,:));
		  combos{length(combos)+1} = contacts(ci(c2,S2:-1:1));

		end
	end

	% pull the individual ESs
	esa = {};
	for c=1:length(combos)
	  es = obj.getSequentialWhiskerContactES(combos{c}, sequenceMaxDt, burstDt);
		if (isobject(es))
			esa{c} = es;
			if (length(esa{c}.timeUnit) == 0) ; esa{c}.timeUnit = obj.whiskerBarContactESA.esa{1}.timeUnit; end
		else % blank
		  esa{c} = session.eventSeries();
			esa{c}.timeUnit = obj.whiskerBarContactESA.esa{1}.timeUnit;
		end
	end

	% build ESA
	sESA = session.eventSeriesArray(esa, obj.behavESA.trialTimes, 1:length(combos));


