function [data] = Collect_tuft_plat_data()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)
%Always have PrefLocFixed=1, doesnt make sense otherwise
%% you need to have run whiskloc_dep_stats & whisk_locdep_plot_contour before this 
% toquickly run them
% [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,[1:size(pooled_contactCaTrials_locdep,2)],'re_totaldK','sigpeak', [12 11 10 9 8],0,0);
% for d = 1: size(pooled_contactCaTrials_locdep,2)
%     [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,'re_totaldK','PR',[0 400],'cf',0,[180 210 230 250 270 300]);
% end


count=0;


info = {};
filename = '';
while(count>=0)
    if strcmp(filename, '');
    [filename,pathName]=uigetfile('*cd*.mat','Load cd.mat file');
    else
       [filename,pathName]=uigetfile([pathName filesep filename],'Load cd.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
   
    data{count}.cd_id = count;
    data{count}.rois= cd.rois;

    data{count}.intarea_plat_L=cd.intarea_plat_L;
    data{count}.intarea_plat_NL=cd.intarea_plat_NL;
    
    data{count}.mean_intarea_plat_L=mean(cd.plat_avgmag_L');% second col sd
    data{count}.mean_intarea_plat_NL=mean(cd.plat_avgmag_NL');
    
    data{count}.plat_rate_L=cd.plat_rate_L;
    data{count}.plat_rate_NL=cd.plat_rate_NL;
    
end

% data.info=info;
folder = uigetdir;
cd (folder);
save('Tuft plat data','data');

%%
% quick plot
Rate(:,1)=cellfun(@(x) x.plat_rate_NL,data);
Rate(:,2)=cellfun(@(x) x.plat_rate_L,data);
figure;plot(Rate')
figure;plot(Rate','color',[.5 .5 .5]);
m=mean(Rate);
s=std(Rate)./sqrt(size(data,2)+1);
hold on ; h=errorbar(m,s,'ko-');set(h,'linewidth',1.5);
title('Tuft plateau rate');
set(gca,'Xtick',[ 1 2]);
set(gca,'XtickLabel',{ 'NL'; 'L'});
axis([0 3 0 .8]);

temp=cell2mat(cellfun(@(x) x.mean_intarea_plat_NL',data,'uni',0));mag(:,1)=temp(1,:)';
temp=cell2mat(cellfun(@(x) x.mean_intarea_plat_NL',data,'uni',0));mag(:,2)=temp(2,:)';

figure;plot(mag')
figure;plot(Rate','color',[.5 .5 .5]);
m=mean(Rate);
s=std(Rate)./sqrt(size(data,2)+1);
hold on ; h=errorbar(m,s,'ko-');set(h,'linewidth',1.5);
title('Tuft plateau rate');
set(gca,'Xtick',[ 1 2]);
set(gca,'XtickLabel',{ 'NL'; 'L'});
axis([0 3 0 .8])

