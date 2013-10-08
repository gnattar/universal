%
% Hack for plotting across days
%

% assemble
if ( 1 == 0 )
	fl = dir('der*');
%	F = [3 4 5 6 8 9 10 11 13 15]; % 38596
	F = [2 3 4 5 6 7 8 9 10 14]; %107029
	for f=1:length(F) ; load(fl(F(f)).name) ; s.generateDerivedDataStructures() ; S{f} = s; end
end

% plot
sv = 1:length(S);

N = ceil(sqrt(length(sv)));
ns = length(sv);
nRow = ceil(ns/2);
figure;

fi = 1;
for s=1:length(sv);
  si = S{sv(s)};
 
  % fig
	f1h = subplot(4,nRow, fi);
	f2h = subplot(4,nRow, fi+nRow);

  % plot
  si.plotTimeSeriesAsLine(si.caTSA.dffTimeSeriesArray, 53, {si.behavESA.esa{5}, si.whiskerBarInReachES}, [],[0 10 -0.5 2],[f1h f2h]);
%  esi = find(strcmp(si.whiskerTag,'c3'));
%  si.plotEventTriggeredAverage(si.caTSA.dffTimeSeriesArray, 40, si.whiskerBarContactClassifiedESA.esa{6}, 1,[-5 5 -0.5 2],[f1h f2h]);
%  si.plotEventTriggeredAverage(si.caTSA.dffTimeSeriesArray, 100, si.whiskerBarContactESA.esa{esi}, 1,[-5 5 -0.5 2],[f1h f2h]);
	legend off;
	axes(f1h);
	title(datestr(si.dateStr,2));

	axes(f2h);
	A = axis;
	axis([A(1) A(2) -0.25 0.5]);
%	set(lineFigH(2), 'XTick',[]);


	% increment figure
	fi = fi+1;
	if (fi == nRow+1) ; fi = fi+nRow; end
     
end
