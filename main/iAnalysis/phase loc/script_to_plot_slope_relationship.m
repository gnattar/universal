%% location

load('sl_nl.mat')
load('sl_l.mat')
load('Ploc.mat')
load('sl_diff.mat')
b=1;
count=0;
for i = 1: size(sl_diff,2)
n = size(sl_diff{i},1);
nl(count+1:count+n,b) = sl_nl{i}(:,b);
l(count+1:count+n,b) = sl_l{i}(:,b);
dif(count+1:count+n,b) = sl_diff{i}(:,b);
count = count+n;
end
b=2;
count=0;
for i = 1: size(sl_diff,2)
n = size(sl_diff{i},1);
nl(count+1:count+n,b) = sl_nl{i}(:,b);
l(count+1:count+n,b) = sl_l{i}(:,b);
dif(count+1:count+n,b) = sl_diff{i}(:,b);
count = count+n;
end
b=3;
count=0;
for i = 1: size(sl_diff,2)
n = size(sl_diff{i},1);
nl(count+1:count+n,b) = sl_nl{i}(:,b);
l(count+1:count+n,b) = sl_l{i}(:,b);
dif(count+1:count+n,b) = sl_diff{i}(:,b);
count = count+n;
end
frch = (nl - l )./nl;
figure;subplot (3,1,1);plot(nl(:,1),'o-')
hold on;plot(l(:,1),'ro-')
title('slope loc bin 1','fontsize',16)
subplot (3,1,2);plot(nl(:,2),'o-')
hold on;plot(l(:,2),'ro-')
title('slope loc bin 2','fontsize',16)
subplot (3,1,3);plot(nl(:,3),'o-')
hold on;plot(l(:,3),'ro-')
title('slope loc bin 3','fontsize',16)
b1inds = find(ploc==1);
b2inds = find(ploc==2);
b3inds = find(ploc==3);
figure;subplot (3,1,1);plot(b1inds,nl(b1inds,1),'o-')
hold on;plot(b1inds,l(b1inds,1),'ro-')
title('slope loc bin 1','fontsize',16)
stat_nl = round([nanmean(nl(b1inds,1))  nanstd(nl(b1inds,1))]*100)/100;
stat_l = round([nanmean(l(b1inds,1))  nanstd(l(b1inds,1))]*100)/100;
stat_frch = round([nanmean(frch(b1inds,1)) nanstd(frch(b1inds,1))]*100)/100;
tb = text(180,1500,['nl ' num2str(stat_nl(1)) '+/-' num2str(stat_nl(2)) ])
tb = text(180,1300,['l mean ' num2str(stat_l(1)) '+/-' num2str(stat_l(2)) ])
tb = text(180,1100,['fr ch mean ' num2str(stat_frch(1)) '+/-' num2str(stat_frch(2)) ])
subplot (3,1,2);plot(b2inds,nl(b2inds,2),'o-')
hold on;plot(b2inds,l(b2inds,2),'ro-')
title('slope loc bin 2','fontsize',16)
stat_nl = round([nanmean(nl(b2inds,2))  nanstd(nl(b2inds,2))]*100)/100;
stat_l = round([nanmean(l(b2inds,2))  nanstd(l(b2inds,2))]*100)/100;
stat_frch = round([nanmean(frch(b2inds,2)) nanstd(frch(b2inds,2))]*100)/100;
tb = text(180,1500,['nl ' num2str(stat_nl(1)) '+/-' num2str(stat_nl(2)) ])
tb = text(180,1300,['l mean ' num2str(stat_l(1)) '+/-' num2str(stat_l(2)) ])
tb = text(180,1100,['fr ch mean ' num2str(stat_frch(1)) '+/-' num2str(stat_frch(2)) ])
subplot (3,1,3);plot(b3inds,nl(b3inds,3),'o-')
hold on;plot(b3inds,l(b3inds,3),'ro-')
title('slope loc bin 3','fontsize',16)
stat_nl = round([nanmean(nl(b3inds,3))  nanstd(nl(b3inds,3))]*100)/100;
stat_l = round([nanmean(l(b3inds,3))  nanstd(l(b3inds,3))]*100)/100;
stat_frch = round([nanmean(frch(b3inds,3)) nanstd(frch(b3inds,3))]*100)/100;
tb = text(180,600,['nl ' num2str(stat_nl(1)) '+/-' num2str(stat_nl(2)) ])
tb = text(180,400,['l mean ' num2str(stat_l(1)) '+/-' num2str(stat_l(2)) ])
tb = text(180,200,['fr ch mean ' num2str(stat_frch(1)) '+/-' num2str(stat_frch(2)) ])


%% phase
load('sl_nl.mat')
load('sl_l.mat')
nl = sl_nl;
l=sl_l;
frch = (nl-l)./nl;
for i = 1: size(data.slopes_ctrl,2)
temp  = data.slopes_ctrl{i};
[v,in] = max(temp');
ppid {i} = in'
end
pph=cell2mat(cellfun(@(x) x,ppid,'uni',0)');
b2inds = find(pph==2);
b3inds = find(pph==3);



figure;subplot (2,1,1);plot(sl_nl(:,2),'o-')
hold on;plot(sl_l(:,2),'ro-')
title('slope phase bin 2','fontsize',16)
subplot (2,1,2);plot(sl_nl(:,3),'o-')
hold on;plot(sl_l(:,3),'ro-')
title('slope phase bin 3','fontsize',16)

figure;subplot (2,1,1);plot(sl_nl(b2inds,2),'o-')
hold on;plot(sl_l(b2inds,2),'ro-')
title('slope phase bin 2','fontsize',16)
tb = text(180,600,['nl ' num2str(nanmean(nl(b2inds,2))) '+/-' num2str(nanstd(nl(b2inds,2))) ])
tb = text(180,400,['l mean ' num2str(nanmean(l(b2inds,2))) '+/-' num2str(nanstd(l(b2inds,2))) ])
tb = text(180,200,['fr ch mean ' num2str(nanmean(frch(b2inds,2))) '+/-' num2str(nanstd(frch(b2inds,2))) ])

subplot (2,1,2);plot(sl_nl(b3inds,3),'o-')
hold on;plot(sl_l(b3inds,3),'ro-')
title('slope phase bin 3','fontsize',16)
tb = text(180,600,['nl ' num2str(nanmean(nl(b3inds,1))) '+/-' num2str(nanstd(nl(b3inds,3))) ])
tb = text(180,400,['l mean ' num2str(nanmean(l(b3inds,1))) '+/-' num2str(nanstd(l(b3inds,3))) ])
tb = text(180,200,['fr ch mean ' num2str(nanmean(frch(b3inds,3))) '+/-' num2str(nanstd(frch(b3inds,3))) ])

