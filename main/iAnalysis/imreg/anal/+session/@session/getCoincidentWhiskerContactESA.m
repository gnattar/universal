%
% May 2011 SP
%
% Returns all possible combinations of 2 or more whiskers contacting pole.
%  Basically makes a bunch of calls to getCoincidentWhiskerContactES. Note
%  that to generate the possible combinations, it uses matlab's nchoosek,
%  but then filters the result to ensure that only *adjacent* combos
%  are allowed (e.g., 12 123 23, but not 13).
%
%  It should also be noted that the results are always sorted so that, in terms
%  of the index of contacts, you will get back, for 3 members, 12 23 123, for 4
%  12 23 34 123 234 1234.  
%
% USAGE:
%
%  cESA = s.getCoincidentWhiskerContactESA(contacts, coincidentDtMax)
%
% PARAMS:
%
%  cESA: the eventSeriesArray object
%
%  contacts: which contacts to consider? cell array of strings with whisker 
%            names.  Whiskers that are adjacent in the cell array are assumed
%            adjacent by the subsequent adjacency filter.  You can either use
%            whisker names or preface with R or P to specify re/protraction and
%            thereby use whiskerBarContactClassifiedESA vs whiskerBarContactESA
%            as source.
%  coincidentDtMax: 0 is event time; in seconds.  How big of a window must
%                        everyone be in to be part of a conicidence?
%
function cESA = getCoincidentWhiskerContactESA(obj, contacts, coincidentDtMax)
  % --- params process
	if (nargin < 3)
	  help ('session.session.getCoincidentWhiskerContactESA');
		cESA = [];
		return;
	end

	% --- work
	
	%setup your combinations
	combos = {};
	for c=2:length(contacts)
	  ci = nchoosek(1:length(contacts), c);

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
		end
	end

	% pull the individual ESs
	esa = {};
	for c=1:length(combos)
	  es = obj.getCoincidentWhiskerContactES(combos{c}, coincidentDtMax);
		if (isobject(es))
			esa{c} = es;
		else % blank
		  esa{c} = session.eventSeries();
		end
	end

	% build ESA
	cESA = session.eventSeriesArray(esa, obj.behavESA.trialTimes, 1:length(combos));


