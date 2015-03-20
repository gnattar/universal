function [KWtest_results] = run_KWtest(pooled_contactCaTrials_locdep,d,KWtest_results)
count =0;
d=d;
numloc = size(pooled_contactCaTrials_locdep{d}.num_trials,1);
for i = 1:numloc
temp = pooled_contactCaTrials_locdep{d}.CaSig_peak{i};
X(count+1:count+length(temp),1) = temp;
X(count+1:count+length(temp),2) = i;
count = count+length(temp);
end
[X2,F,P1,P2] = KWtest(X,0.05);
KWtest_results(d,:) = [X2,F,P1,P2];