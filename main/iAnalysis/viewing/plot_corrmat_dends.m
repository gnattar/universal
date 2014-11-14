function plot_corrmat_dends(corr_dend,pooled_contact_CaTrials,n)

 a =find(corr_dend==n);
 obj=pooled_contact_CaTrials(a);
numdends = length(a);
temp = zeros(size(obj{1,1}.intarea,1),numdends);
maxevents = 0;dendwmaxevents =0;
for i = 1:numdends
 temp(:,i) = obj{1,i}.intarea;
 t= sum(find(obj{1,i}.intarea>50));
 dendwmaxevents = (maxevents>t) * dendwmaxevents +(maxevents<t) *i;
 maxevents = (maxevents>t) * maxevents +(maxevents<t) *t;
end

t2 = setxor([1:numdends],dendwmaxevents);
tc = [1 0 0; 0 0 1 ; 0 1 0; 1 1 1];
tcl = [1 .5 0.5; 0.5 0.5 1 ; 0.5 1 0.5; .5 .5 .5];
figure;suptitle(['Corr Dend ' num2str(n) 'Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ])
for i = 1: numdends-1    
    ltrials = find(obj{1,dendwmaxevents}.lightstim == 0);
    nltrials= find(obj{1,dendwmaxevents}.lightstim == 1);
    hold on; plot(obj{1,dendwmaxevents}.intarea(ltrials),obj{1,t2(i)}.intarea(ltrials),'o','Markerfacecolor',tc(i,:),'markersize',10);
    hold on; plot(obj{1,dendwmaxevents}.intarea(nltrials),obj{1,t2(i)}.intarea(nltrials),'o','Markerfacecolor',tc(i,:),'markersize',10);
end

saveas(gcf,[pwd,filesep,'Int Area, Corrdend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2)],'jpg');

thresh = 30;

temp(isnan(temp)) = 0;
clim=[-1 1];
plat = temp;plat(plat<thresh) = 0;
figure
subplot(2,2,1);imagesc(corrcoef(plat),clim);title('plat');colormap('jet');
noplat = temp;noplat(noplat>thresh) = 0;
subplot(2,2,2);imagesc(corrcoef(noplat),clim);title('noplat');colormap('jet');
corrplat = corrcoef(plat)-eye(numdends); 
corrnoplat = corrcoef(noplat)-eye(numdends); 
tmat = [corrplat;corrnoplat];
corrplat = reshape(corrplat,numdends*numdends,1);corrplat(corrplat ==0) =nan;
corrnoplat = reshape(corrnoplat,numdends*numdends,1);corrnoplat(corrnoplat ==0) =nan;

hcorrplat = hist(corrplat,[0:.1:1]);
hcorrnoplat = hist(corrnoplat,[0:.1:1]);
subplot(2,2,3:4);plot([0:.1:1],hcorrplat ,'color',[1 .5 .5],'linewidth',3);hold on ; plot([0:.1:1],hcorrnoplat,'color',[0.25 .5 .5],'linewidth',3);colorbar
suptitle(['Corr Dend ' num2str(n)]);legend({'G';'L'});
saveas(gcf,[pwd,filesep,'Corr Dend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ' Thr ' num2str(thresh) ],'jpg');

save(['Corr Dend ' num2str(n) ' Br ' num2str(dendwmaxevents) ' vs ' num2str(t2) ' Thr ' num2str(thresh) 'corrcoef'],'tmat');
