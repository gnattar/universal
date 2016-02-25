ind = [];temp = [];SLchange=[];SLchange_np=[];ICchange=[];ICchange_np=[];
temp = Ctrl_phase_preference(:,3)

ind=find(temp==0)

SLchange (:,1) = Ctrl_slopes(ind,2)
SLchange (:,2) = Light_slopes(ind,2)
ICchange (:,2) = Light_intercept(ind,2)
ICchange (:,1) = Ctrl_intercept(ind,2)

figure;subplot(2,2,1);plot(SLchange);title('SL pref')
mS_p=nanmean(SLchange);
hline(mS_p(1),{'b'});hline(mS_p(2),{'r'});
tb=text(size(SLchange,1)-1,mS_p(1)+5,num2str(mS_p(1)));set(tb,'color',[ .02 .6 .8]);
tb=text(size(SLchange,1)-1,mS_p(2)+5,num2str(mS_p(2)));set(tb,'color','r');
subplot(2,2,2);plot(ICchange);title('IC pref')
mI_p=nanmean(ICchange);
hline(mI_p(1),{'b'});hline(mI_p(2),{'r'});
tb=text(size(ICchange,1)-1,mI_p(1)+5,num2str(mI_p(1)));set(tb,'color',[ .02 .6 .8]);
tb=text(size(ICchange,1)-1,mI_p(2)+5,num2str(mI_p(2)));set(tb,'color','r');



ind=find(temp<-1 | temp > 1)
SLchange_np (:,2) = Light_slopes(ind,2)
SLchange_np (:,1) = Ctrl_slopes(ind,2)
ICchange_np (:,1) = Ctrl_intercept(ind,2)
ICchange_np (:,2) = Light_intercept(ind,2)

subplot(2,2,3);plot(SLchange_np);title('SL Nonpref')
mS_np=nanmean(SLchange_np);
hline(mS_np(1),{'b'});hline(mS_np(2),{'r'});
tb=text(size(SLchange_np,1)-1,mS_np(1)+5,num2str(mS_np(1)));set(tb,'color',[ .02 .6 .8]);
tb=text(size(SLchange_np,1)-1,mS_np(2)+5,num2str(mS_np(2)));set(tb,'color','r');
subplot(2,2,4);plot(ICchange_np);title('IC Nonpref')
mI_np=nanmean(ICchange_np);
hline(mI_p(1),{'b'});hline(mI_p(2),{'r'});
tb=text(size(ICchange_np,1)-1,mI_np(1)+5,num2str(mI_np(1)));set(tb,'color',[ .02 .6 .8]);
tb=text(size(ICchange_np,1)-1,mI_np(2)+5,num2str(mI_np(2)));set(tb,'color','r');

suptitle ('Phase Bin 3')

