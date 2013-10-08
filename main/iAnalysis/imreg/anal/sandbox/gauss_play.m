r = 38;
for r=1:200

%	vec = s.caTSA.dffTimeSeriesArray.valueMatrix(r,:);
	vec = s.caTSA.valueMatrix(r,:);
	[f xi] = ksdensity(vec);
	[peak_f idx] = max(f);
	peak_x = xi(idx);

	xi = xi-peak_x;

  subplot(2,2,1);
	plot(xi,f);

	subplot(2,2,3)
	nval = find(xi <= 0);

  hold off;
	plot(xi(nval),f(nval));
	title(num2str(r)); 
	cutoff_idx = max(find(f(nval) < peak_f/10));
	cutoff_val = 2*abs(xi(nval(cutoff_idx)));
	cvip = min(find(xi > cutoff_val));
	if (length(cvip) > 0)
		cutoff_f = abs(f(cvip))
	else 
	  cufoff_f = 0;
	end


	subplot(2,2,4);
	hold off;
	hist(vec,100);
	hold on ;
	a=axis;
	plot ([-1 -1]*cutoff_val, [0 a(4)],'r-');
	plot ([1 1]*cutoff_val, [0 a(4)],'r-');

  n_above = length(find(vec > cutoff_val));
	title(['nab %: ' num2str(n_above/length(vec)) ' cof: ' num2str(cutoff_f/max(f))]);
	pause;

  nab(r) = n_above/length(vec);;
  cof(r) = cutoff_f/max(f);


	%so = fitoptions('Method','NonlinearLeastSquares','Lower',[0],'Upper',[Inf],'Startpoint',1.4826*mad(vec));
	%ft = fittype('((1/a/sqrt(2*pi)))*exp((-x.*x)/(2*a*a))','options',so);
	%c2 = fit(xi(nval)',f(nval)',ft)

	%a = c2.a;
	%x = xi(nval);
	%hold on
	%plot(x, ((1/a/sqrt(2*pi)))*exp((-x.*x)/(2*a*a)), 'r-');
	%hold on;plot(-1:0.01:1, normpdf(-1:0.01:1, 0, c2.a),'r-');
end
