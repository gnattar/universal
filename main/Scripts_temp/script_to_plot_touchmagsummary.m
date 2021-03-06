figure;
for l = 1:6
temp = tmag(:,l);
temp2=cell2mat(temp);
x=ones(length(temp2),1).*l;
plot(x,abs(temp2),'o','color',[.5 .5 .5]); hold on;
meanTmag(l,1) = mean(abs(temp2));
meanTmag(l,2) = std(abs(temp2));
end
axis([0 7 0 2])
figure;e=errorbar(meanTmag(:,1),meanTmag(:,2)./sqrt(7),'ko-');
set(e,'markersize',20,'linewidth',1.5)
axis([0 7 0 .3])
ylabel('touch mag abs (dKappa)','fontsize',20)
xlabel('location','fontsize',20)
title('touch mag distribution','fontsize',20)