% subtracts second principal component from each vector --> denoise biatch
function svd_play(s)

vm = s.caTSA.dffTimeSeriesArray.valueMatrix;
vm(find(isnan(vm))) = 0;
vm(find(isinf(vm))) = 0;
[U S V] = svd(vm, 0);

nvm = 0*vm;
% TEST which PCs to use by correlating with lick rate? [perhaps cross corr to make sure corr is @ t=0?]
pcs = [];

va = find(~isnan(s.derivedDataTSA.getTimeSeriesById(1).value));
[irr ia ib] = intersect(s.derivedDataTSA.time(va), s.caTSA.time);
cv = corr(s.derivedDataTSA.getTimeSeriesById(1).value(va(ia))', V(ib,1:10));
pcs = find(abs(cv) > 0.1);

tmi = find(ismember(s.trialTypeStr,{'FA', 'CR', 'Miss'}));
valtrials = s.trialIds(find(sum(s.trialTypeMat(tmi,:))));
ia2 = intersect(ia, find(ismember(s.derivedDataTSA.trialIndices, valtrials)));
ib2 = find(ismember(s.caTSA.time, s.derivedDataTSA.time(ia2)));
rcv = corr(s.derivedDataTSA.getTimeSeriesById(1).value(ia2)', V(ib2,1:10));

disp([s.dateStr ' corr ALL: ' sprintf('%2.2f ', cv) ' corr non-hit: ' sprintf('%2.2f ', rcv) ]);


% RESTRICT CORRELATION TO non-HIT TRIALS TO NOT CONSIDER 'reward collection lick'
% THIS SHOULD BE DONE WITH GRADIENT DESCENT OR NEWTON'S --> CONVERGENCE GUARANTEED!!
for r=1:size(vm,1)
  vec = vm(r,:);

	% restrict to < some % df/f (in future, perhaps omit events .. or look directly @ fluo)
	validx = find(vec < 0.5);
  for p=1:length(pcs)
		sf = -20:.1:20 ; for i=1:length(sf); rmse(i) = mean((vec(validx)-(sf(i)*V(validx,pcs(p)))').^2) ; end
		[irr idx] = min(rmse);
		vec = vec - sf(idx)*V(:,pcs(p))';
	end
	nvm(r,:) = vec;
end

s.caTSA.dffTimeSeriesArray.valueMatrix = nvm;
