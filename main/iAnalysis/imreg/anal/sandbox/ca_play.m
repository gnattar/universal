R = [1 6 38 42 67 100];
for r=1:length(R);
  if (length(f) < r) ; f(r) = figure ; end
	figure(f(r));

%	s.caTSA.dffTimeSeriesArray.tsa{R(r)}.plot;
	s.caTSA.dffTimeSeriesArray.tsa{R(r)}.plot([1 0 0]);
	hold on;
	title(num2str(R(r)));
end
