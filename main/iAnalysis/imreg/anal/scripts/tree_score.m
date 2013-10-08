s = sA.sessions{1};

rid = 65;
sdsf = 2;
%for f=[10 16 22]
for f=[1 2 4 6 8 10 16 22 30]
	[pv av tv] = sA.sessions{1}.getPredictedFromTree('~/data/an38596/tree_par', [], f, rid, sA.sessions{1}); % lick rate
	nn = find(~isnan(pv) & ~isnan(av));
	resp_p = find(pv(nn) > sdsf*nanstd(pv(nn)) + nanmean(pv(nn)));
	resp_a = find(av(nn) > sdsf*nanstd(av(nn)) + nanmean(av(nn)));

  % percent of actual that is predicted
	ap = intersect(resp_p,resp_a);
	V = length(ap) / length(resp_a);
	disp([sA.sessions{1}.treeFeatureList{f} ':' num2str(V)]);

	val = find(~isnan(pv) & ~isnan(av) & abs(pv) > sdsf*nanstd(pv)+nanmean(pv) &  abs(av) > sdsf*nanstd(av)+nanmean(av));
	c=corr(pv(val),av(val),'type','Spearman');
	disp([sA.sessions{1}.treeFeatureList{f} ':' num2str(c)]);

	% rescale distributions to match based on 95%iles, ksdensity peaks
	[fv xi] = ksdensity(pv);
  [val idx] = max(fv);
	pzero = xi(idx);
  pv = pv-pzero;
	spv = sort(pv,'ascend');
  v95 = spv(round(length(spv)*.95));
	pv = pv/v95;

	[fv xi] = ksdensity(av);
  [val idx] = max(fv);
	azero = xi(idx);
  av = av-azero;
	sav = sort(av,'ascend');
  v95 = sav(round(length(sav)*.95));
	av = av/v95;

	nn = find(~isnan(pv) & (~isnan(av)));
	rmse = mean(sqrt((pv(nn)-av(nn)).^2))

  figure;
	plot(tv,av,'k-');
	hold on ;
	plot(tv,pv,'r-');
	title(sA.sessions{1}.treeFeatureList{f});

end
