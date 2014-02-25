
numanm_A = 5;
numanm_C = 4;
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_prcoccupancy(:,:,1),C.mavgnogo_prcoccupancy(:,:,2),C.mavgnogo_prcoccupancy(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_prcoccupancy(:,:,1),A.mavgnogo_prcoccupancy(:,:,2),A.mavgnogo_prcoccupancy(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(1,'k--');title('Relative change in whisker occupancy','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in whisker occupancy past biased pole location','FontSize',16);
set(gca,'FontSize',16);

figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_peakdev_thetaenv(:,:,1),C.mavgnogo_peakdev_thetaenv(:,:,2),C.mavgnogo_peakdev_thetaenv(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_peakdev_thetaenv(:,:,1),A.mavgnogo_peakdev_thetaenv(:,:,2),A.mavgnogo_peakdev_thetaenv(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(0,'k--');title('Relative change in peak whisker theta envelope','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in peak whisker theta envelope (deg)','FontSize',16);
set(gca,'FontSize',16);


figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*3/3], 'color','w');
errorbar(C.mavgnogo_meandev_thetaenv(:,:,1),C.mavgnogo_meandev_thetaenv(:,:,2),C.mavgnogo_meandev_thetaenv(:,:,3)./sqrt(numanm_C),'color','k','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.5 .5 .5]);hold on;
errorbar(A.mavgnogo_meandev_thetaenv(:,:,1),A.mavgnogo_meandev_thetaenv(:,:,2),A.mavgnogo_meandev_thetaenv(:,:,3)./sqrt(numanm_A +1),'color','r','Linewidth',3,'Marker','o','MarkerSize',15,'Markerfacecolor',[.85 .5 .5]);hold on;
hline(0,'k--');title('Relative change in mean whisker theta envelope','FontSize',18);
xlabel ('Sessions','FontSize',16);ylabel('Relative change in mean whisker theta envelope (deg)','FontSize',16);
set(gca,'FontSize',16);

fields = {'mavgnogo_prcoccupancy','mavgnogo_peakdev_thetaenv','mavgnogo_meandev_thetaenv'}
samples = [C.(fields{k})(:,3:end,2)',A.(fields{k})(:,3:end,2)'];
[h,p,ks2stat] = kstest2(samples(:,1),samples(:,2)); % p = .0013, h=1
[P,TABLE,STATS] = anova1(samples);
[c,m,h,nms]=multcompare(STATS);
