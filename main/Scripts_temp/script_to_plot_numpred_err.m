temp = cell2mat(summary.ctrl.num_predictors{1})
minpred= zeros(length(temp),1)
runid= zeros(length(temp),1)
for n = 1: length(temp)
[v,i] = (min(temp));
minpred(n) = v;
runid(n) = i
temp(i) = nan;
end


inds = [(1:50:5000)]';
inds(:,2) = inds(:,1)+49;
err_all = summary.ctrl.dist_err{1,1}(:,1);

for i = 1:100
temp = err_all(inds(i,1):inds(i,2));
frc= sum(temp==0);
err_coll(i) = frc;
end
frCor=err_coll./50;
frCor_sorted = frCor(runid);
frCor_sorted = (frCor(runid))';


figure;plot(minpred,frCor_sorted,'o')

[P,S] = polyfit(minpred,frCor_sorted,1)
Y=polyval(P,[1:123])
hold on ; plot([1:123],Y,'r')
title('Fraction Correct vs. Numpredictors')
save('minpred','minpred');
save('runid','runid');
save('frCor_sorted','frCor_sorted');

[pooled_contactCaTrials_locdep] = prep_pcopy(pcopy)

m=75; % runid with desired numpred
dends = find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta)
r=[num2str(m) 'high']



[data] = Collect_theta_summary__frompcopy_T2(dends,r)
light =1;[data] = plot_normResp_theta(data,1,r) 

dends = setxor([1:123],find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta))
r=[num2str(m) 'low']
