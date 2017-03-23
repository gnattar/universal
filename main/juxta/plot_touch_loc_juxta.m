function plot_touch_loc_juxta(contact_trig,cellnum)
barpos=arrayfun(@(x) x.bar_pos_trial, contact_trig);
touchmag=arrayfun(@(x) x.re_totaldK, contact_trig);
activity=arrayfun(@(x) x.numspikes, contact_trig);

bp=unique(barpos);
sc = get(0,'ScreenSize');
f1=figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)*1/2], 'color','w');

wsTimeScale=contact_trig(1).wsTimeScale;
wTimeScale=contact_trig(1).wTimeScale;
windowSize = .010/wsTimeScale;
for i =1:length(bp)
    ind = find(barpos == bp(i));
spikes = cell2mat(arrayfun(@(x) x.spikes, contact_trig(ind),'uni',0))';
% psth_smth  = filter(ones(1,windowSize)/windowSize,1, sum(spikes));
psth_smth  = smooth(sum(spikes),windowSize);
t =[ 1:length(psth_smth)].* wsTimeScale;
subplot(2,length(bp),i);plot(t,psth_smth);
axis([0 1.5 -.05 .25]);
set(gca,'ticklength',[.05 .05]);set(gca,'FontSize',12);
    ylabel('Psth');
    xlabel('Time(s)');
end

suptitle (['cell ' num2str(cellnum)]);

temp_var = 0;




% figure;plotyy(contact_trig(r).wsTime,contact_trig(r).filt_ephys,contact_trig(r).wTime{1},contact_trig(r).deltaKappa{1});hold on;
% 
% 
%                 contacts=contact_trig(r).contacts;
%              numcontacts = size(contacts);
%     
%                 for i = 1:numcontacts
%                   
%                         ithcontact=contacts{i}; %with respect to the first contact being fixed at .5s
%      
%                     ithcontact=(ithcontact*wTimeScale);
%                     line([ithcontact;ithcontact],[ones(1,length(ithcontact))*(temp_var-.05);ones(1,length(ithcontact))*(temp_var+.05)],'color',[.6 .5 0],'linewidth',.1); hold on;
%     
%                 end
% title([num2str(r) ' trial ' num2str(contact_trig(r).solo_trial)])



axisnum=i;

%  figure;
for i =1:length(bp)
ind = find(barpos == bp(i));
x=abs(touchmag(ind));
y=activity(ind);
notinc = find(x>0.2);
x(notinc) = [];
y(notinc) = [];

subplot(2,length(bp),axisnum+i);t=plot(x,y,'o'); hold on;

 
 [param,paramCI,fitevals,f] = FitEval(x,y,'lin',-1);
 
 plot([0.0001:.01:max(x)],polyval(param ,[0.0001:.01:max(x)]),'-','color','k','linewidth',1.5);set(gca,'ticklength',[.05 .05]);set(gca,'FontSize',18);
 set(t,'Marker','o','Markersize',8,'MarkerFaceColor',[.5 .5 .75],'linewidth',2);  
 ylabel('Spike count');
    xlabel('|dK|');
    text( .07 ,15,['s=' num2str(param(1))])
axis([0 .15 0 20]);
end
% suptitle (['cell ' num2str(cellnum)]);



    set(gcf,'PaperPositionMode','auto');set(gca,'FontSize',18);
     saveas(gcf,['Cell ' num2str(cellnum)],'fig');
      saveas(gcf,['Cell ' num2str(cellnum)],'tif');
    print(gcf,'-depsc2','-painters','-loose',['Cell ' num2str(cellnum)]) 

% for i =1:6
% ind = find(barpos == bp(i));
% tr = arrayfun(@(x) x.spikes', contact_trig(ind),'uni',0)';
% tr=cell2mat(tr);
% t=[1:size(tr,2)].*contact_trig(1).wsTimeScale;
% trl= [1:size(tr,1)];
% subplot(1,6,i);imagesc(tr);colormap(gray);
% end
% 

