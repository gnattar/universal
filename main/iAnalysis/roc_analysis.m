figure; 
for n = 1:152
% co=pooled_contactCaTrials_locdep{n}.theta_binned_new;
co=pooled_contactCaTrials_locdep{n}.phase;

ca=pooled_contactCaTrials_locdep{n}.sigpeak;
t=unique(co);
cList = [ 0:25:max(ca)];
col = parula(6);

for class = 1:length(t)
tcurrent = t(class);
t_c = find(co==tcurrent);
t_rest = find(co~=tcurrent);

for cNum = 1:length(cList)
c = cList(cNum);
pHit(cNum,class,n)=sum(ca(t_c)>c)/length(t_c);
pFA(cNum,class,n)=sum(ca(t_rest)>c)/length(t_rest);
end

auc(class) = -trapz(pFA(:,class,n),pHit(:,class,n));
plot(pFA(:,class,n),pHit(:,class,n),'color',col(class,:),'linewidth',2);hold on;
set(gca,'tickdir','out','ticklength',[.02 .02])
end
title(['Cell ' num2str(n)]);
waitforbuttonpress;
auroc(n,:)=auc;
hold off;
end