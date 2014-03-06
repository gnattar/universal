function Summary_plot_stats(A,C)

save('ArchTheta','A');
save('CtrlTheta','C');
numanm_A = 7;
numanm_C = 6;
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_prcoccupancy(:,:,1),C.mavgnogo_prcoccupancy(:,:,2),C.mavgnogo_prcoccupancy(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_prcoccupancy(:,:,1),A.mavgnogo_prcoccupancy(:,:,2),A.mavgnogo_prcoccupancy(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(1,'k--');title('Relative change in whisker occupancy','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in whisker occupancy past biased pole location','FontSize',16);
set(gca,'FontSize',16);

figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_peakdev_data(:,:,1),C.mavgnogo_peakdev_data(:,:,2),C.mavgnogo_peakdev_data(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_peakdev_data(:,:,1),A.mavgnogo_peakdev_data(:,:,2),A.mavgnogo_peakdev_data(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(0,'k--');title('Relative change in peak whisker theta ','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in peak whisker theta  (deg)','FontSize',16);
set(gca,'FontSize',16);


figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_meandev_data(:,:,1),C.mavgnogo_meandev_data(:,:,2),C.mavgnogo_meandev_data(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_meandev_data(:,:,1),A.mavgnogo_meandev_data(:,:,2),A.mavgnogo_meandev_data(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(0,'k--');title('Relative change in mean whisker theta ','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in mean whisker theta  (deg)','FontSize',16);
set(gca,'FontSize',16);

fields = {'mavgnogo_prcoccupancy','mavgnogo_peakdev_data','mavgnogo_meandev_data'}
k=1;
samples = [C.(fields{k})(:,3:end,2)',A.(fields{k})(:,3:end,2)'];
[h,p,ks2stat] = kstest2(samples(:,1),samples(:,2),'alpha',.01); % p = .0013, h=1
[P,TABLE,STATS] = anova1(samples);
[c,m,h,nms]=multcompare(STATS);

b=[A.(fields{k})(:,1:2,2) C.(fields{k})(:,1:2,2)]'
 a=A.(fields{k})(:,3:end,2)'
 c = C.(fields{k})(:,3:end,2)'

[h,p,ks2stat] = kstest2(b,a,'alpha',.01)
[h,p,ks2stat] = kstest2(b,c,'alpha',.01)

end
% 

%%to plot switch variable vs. switch magnitude

A_bl = cell2mat(cellfun(@(x) nanmean(cell2mat(x(1:2))), A.mean_barpos, 'UniformOutput',false));
C_bl = cell2mat(cellfun(@(x) nanmean(cell2mat(x(1:2))), C.mean_barpos, 'UniformOutput',false));
A_bi = cell2mat(cellfun(@(x) nanmean(cell2mat(x(3:8))), A.mean_barpos, 'UniformOutput',false));
C_bi = cell2mat(cellfun(@(x) nanmean(cell2mat(x(3:8))), C.mean_barpos, 'UniformOutput',false));
A_mag = A_bi-A_bl;
C_mag = C_bi-C_bl;


temp = nanmean(A.nogo_prcoccupancy,1);
APrO=nanmean(temp(:,3:8,:),2);
APrO = reshape(APrO,7,1,1);

temp = nanmean(C.nogo_prcoccupancy,1);
CPrO=nanmean(temp(:,3:8,:),2);
CPrO = reshape(CPrO,6,1,1);

figure;plot(A_mag,APrO,'bo','MarkerSize',12); hold on; plot(C_mag,CPrO,'ro','MarkerSize',12),set(gca,'FontSize',16);
xlabel('Switch Magnitude (deg)');
ylabel('Change in PrOccupancy');
title('Chnge in PrOccupancy vs. switch magnitude');


temp = nanmean(A.nogo_peakdev_data,1);
Apeak=nanmean(temp(:,3:8,:),2);
Apeak = reshape(Apeak,7,1,1);

temp = nanmean(C.nogo_peakdev_data,1);
Cpeak=nanmean(temp(:,3:8,:),2);
Cpeak = reshape(Cpeak,6,1,1);

figure;plot(A_mag,Apeak,'bo','MarkerSize',12); hold on; plot(C_mag,Cpeak,'ro','MarkerSize',12),set(gca,'FontSize',16);
xlabel('Switch Magnitude (deg)');
ylabel('Change in Peak Theta');
title('Chnge in Peak Theta vs. switch magnitude');




temp = nanmean(A.nogo_meandev_data,1);
Amean=nanmean(temp(:,3:8,:),2);
Amean = reshape(Amean,7,1,1);

temp = nanmean(C.nogo_meandev_data,1);
Cmean=nanmean(temp(:,3:8,:),2);
Cmean = reshape(Cmean,6,1,1);

figure;plot(A_mag,Amean,'bo','MarkerSize',12); hold on; plot(C_mag,Cmean,'ro','MarkerSize',12),set(gca,'FontSize',16);
xlabel('Switch Magnitude (deg)');
ylabel('Change in Mean Theta');
title('Chnge in Mean Theta vs. switch magnitude');