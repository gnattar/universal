for d = 1 : size(pooled_contactCaTrials_locdep,2)
r={};
resp = pooled_contactCaTrials_locdep{d}.sigpeak;
ls = pooled_contactCaTrials_locdep{d}.lightstim;
ploc = pooled_contactCaTrials_locdep{d}.poleloc;
loc = unique(ploc);
for l = 1: length(loc)
    ind = find(ploc == loc(l) & ls == 0);
    r{l} = resp(ind);
end

s=cell2mat(cellfun(@size,r ,'uni',0)');
ms = max(s);
x = nan(ms(1),l);

for l = 1: length(loc)
    x(1:s(l),l) = r{l};
end

[p,t,stats] = anova1(x,[],'off');
pooled_contactCaTrials_locdep{d}.locpref_pval = p;
pooled_contactCaTrials_locdep{d}.locpref_anovastats = stats;
 [c,m,h] = multcompare(stats,'ctype','bonferroni');
%  waitforbuttonpress
end

pval=cell2mat(cellfun(@(x) x.locpref_pval,pooled_contactCaTrials_locdep,'uni',0));
notsig=find(pval>0.05)
length(notsig)
