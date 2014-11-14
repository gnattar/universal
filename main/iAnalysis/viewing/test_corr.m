function [r,id]=test_corr(obj)
numcells = size(obj,2);
r = zeros((numcells*(numcells+1)/2)-numcells,9,2);
id = zeros((numcells*(numcells+1)/2)-numcells,4);
count =1;
for i =1:numcells
    for j= i+1:numcells
        id(count,3) = obj{i}.dend;
        id(count,4) = obj{j}.dend;
        id(count,1) = i;
        id(count,2) = j;
        temp1=obj{i}.rawdata(obj{i}.lightstim==0,:);
        temp2 =obj{j}.rawdata(obj{j}.lightstim==0,:);
        temp1(isnan(temp1)) =0;
        temp2(isnan(temp2))=0;
        r(count,1,1) = corr2(temp1,temp2);
        r(count,2,1) = obj{i}.dend;
        r(count,3,1) = obj{j}.dend;
% %         r(count,2,1) = obj{i}.eventrate_NL(1,1);
% %         r(count,3,1) = obj{j}.eventrate_NL(1,1);
%         r(count,4,1) = nanmean(obj{i}.intarea(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,5,1) = nanmean(obj{j}.intarea(obj{j}.eventsdetected&~obj{i}.lightstim));
%         r(count,6,1) = nanmean(obj{i}.peakamp(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,7,1) = nanmean(obj{j}.peakamp(obj{j}.eventsdetected&~obj{i}.lightstim));        
%         r(count,8,1) = nanmean(obj{i}.fwhm(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,9,1) = nanmean(obj{j}.fwhm(obj{j}.eventsdetected&~obj{i}.lightstim));   
%         
        
        temp1=obj{i}.rawdata(obj{i}.lightstim==1,:);
        temp2 =obj{j}.rawdata(obj{j}.lightstim==1,:);
        temp1(isnan(temp1)) =0;
        temp2(isnan(temp2))=0;
        r(count,1,2) = corr2(temp1,temp2);
        r(count,2,2) = obj{i}.eventrate_L(1,1);
        r(count,3,2) = obj{j}.eventrate_L(1,1);
        r(count,4,2) = nanmean(obj{i}.intarea(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,5,2) = nanmean(obj{j}.intarea(obj{j}.eventsdetected&obj{i}.lightstim));
        r(count,6,2) = nanmean(obj{i}.peakamp(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,7,2) = nanmean(obj{j}.peakamp(obj{j}.eventsdetected&obj{i}.lightstim));        
        r(count,8,2) = nanmean(obj{i}.fwhm(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,9,2) = nanmean(obj{j}.fwhm(obj{j}.eventsdetected&obj{i}.lightstim));   
        count = count +1;
    end
end

%% to plot corr coef for each set of corr dends
% 
%  a =find(corr_dend==n);
%  obj=pooled_contact_CaTrials(a);
% numdends = length(a);
% temp = zeros(size(obj{1,1}.intarea,1),numdends);
% maxevents = 0;dendwmaxevents =0;
% for i = 1:numdends
%  temp(:,i) = obj{1,i}.intarea;
%  t= sum(find(obj{1,i}.intarea>50));
%  dendwmaxevents = (maxevents>t) * dendwmaxevents +(maxevents<t) *i;
%  maxevents = (maxevents>t) * maxevents +(maxevents<t) *t;
% end
% 
% t2 = setxor([1:numdends],dendwmaxevents);
% tc = {'r','b','g','k'};
% figure;suptitle(['Corr Dend ' num2str(n) 'Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ])
% for i = 1: numdends-1    
%     hold on; plot(obj{1,dendwmaxevents}.intarea,obj{1,t2(i)}.intarea,'o','Markerfacecolor',tc{i},'markersize',10);
% end
% 
% saveas(gcf,[pwd,filesep,'Int Area, Corrdend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2)],'jpg');
% 
% thresh = 100;
% 
% temp(isnan(temp)) = 0;
% clim=[-1 1];
% plat = temp;plat(plat<thresh) = 0;
% figure
% subplot(2,2,1);imagesc(corrcoef(plat),clim);title('plat');colormap('jet');
% noplat = temp;noplat(noplat>thresh) = 0;
% subplot(2,2,2);imagesc(corrcoef(noplat),clim);title('noplat');colormap('jet');
% corrplat = corrcoef(plat)-eye(numdends); 
% corrnoplat = corrcoef(noplat)-eye(numdends); 
% tmat = [corrplat;corrnoplat];
% corrplat = reshape(corrplat,numdends*numdends,1);corrplat(corrplat ==0) =nan;
% corrnoplat = reshape(corrnoplat,numdends*numdends,1);corrnoplat(corrnoplat ==0) =nan;
% 
% hcorrplat = hist(corrplat,[0:.1:1]);
% hcorrnoplat = hist(corrnoplat,[0:.1:1]);
% subplot(2,2,3:4);plot([0:.1:1],hcorrplat ,'color',[1 .5 .5],'linewidth',3);hold on ; plot([0:.1:1],hcorrnoplat,'color',[0.25 .5 .5],'linewidth',3);colorbar
% suptitle(['Corr Dend ' num2str(n)]);legend({'G';'L'});
% saveas(gcf,[pwd,filesep,'Corr Dend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ' Thr ' num2str(thresh) ],'jpg');
% 
% save(['Corr Dend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ' Thr ' num2str(thresh) 'corrcoef'],'tmat');
