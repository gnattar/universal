% 
% SP Jan 2011
%
% For plotting two timeseries against one another.  Will only use common time points.
%
% USAGE:
%
%   plotVersus (ts1, ts2)
%
%   ts1: timeSeries object represented in x axis
%   ts2: timeSeries object represented in y axis
%   tOffs: how much, in terms of INDICES, to offset ts1 vs. ts2 -- that is,
%          it will plot time point ts1.time(x+tOffs) vs. ts2.time(x) ; pass a 
%          vector to plot many.  Note that if tOffs is positive, that means
%          you are plotting the case where ts1 is shifted LATER in time while
%          ts2 remains 'in place'.
%   ax: axes ; if tOffs is vector, pass vector
%
function plotVersusS (ts1, ts2, tOffs, ax)
  % argument parsing
	if (nargin < 2) ; help('session.timeSeries.plotVersusS'); return ; end
	if (nargin < 3) ; tOffs = 0 ; end
	nS = 1;
	if (nargin < 4) 
	  figure ; 
		if (length(tOffs) == 1)
  		ax = axes; 
		else
		  nS = ceil(sqrt(length(tOffs)));
			for s = 1:length(tOffs)
			  ax(s) = subplot(nS,nS,s);
			end
		end
	end

  % tOffs
	for toi=1:length(tOffs)
		if (tOffs(toi) == 0)
			t2 = ts1.time;
		elseif (tOffs(toi) > 0)
			t2 = ts1.time(1:end-tOffs(toi));
		else
			t2 = ts1.time(-1*tOffs(toi)+1:end);
		end
	 
		% overlapping times ...
		[valT i1 i2] = intersect(t2, ts2.time);
		if (tOffs(toi) > 0) 
			i1 = i1+tOffs(toi);
		end

		% now plot
		axes(ax(toi));
		plot (ts1.value(i1), ts2.value(i2), 'b.');
		set(gca,'TickDir','out');
		if (toi > nS*(nS-1)); xlabel(ts1.idStr); end
		if (rem(toi-1,nS) ==0); ylabel(ts2.idStr); end
		if(length(tOffs) > 0)
		  title(['offset: ' num2str(tOffs(toi))]);
		end
  end



