function [collected_decoder_summary_stats,data] = Collect_decoder_summary(lightcond)
%[collected_decoder_summary_stats,data] = Collect_decoder_summary(lightcond)
% global collected_data
% global collected_summary

collected_decoder_summary_stats = {};
count=0;
def={'149','150515','self'};
%   data=struct('pOL_ctrl',[],'pOL_mani',[],'p50_ctrl',[],'p50_mani',[],'info',{});
mOL_ctrl = [];
mOL_mani=[];
m50_ctrl=[];
m50_mani=[];
sOL_ctrl = [];
sOL_mani=[];
s50_ctrl=[];
s50_mani=[];
info = {};
filename = '';
while(count>=0)
    
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('* decoder results.mat','Load * decoder results.mat file');
    else
        [filename,pathName]=uigetfile(filename,'Load * decoder results.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    %     set(handles.wSigSum_datapath,'String',pathName);
    cd (pathName);
    %     prompt={'Mouse name','Date ','Train Condition'};
    %     name='Point to collect';
    %     numlines=3;
    %     d = inputdlg(prompt,name,numlines,def) ;
    %     def=d;
    %     collected_decoder_summary_stats{count}.info = [ d{1} ' ' d{2} ' ' d{3}];
    
    
    collected_decoder_summary_stats{count}.info = summary.info;
    collected_decoder_summary_stats{count}.pOL_ctrl = summary.ctrl.percentoverlap(1,1,1);
    collected_decoder_summary_stats{count}.mEr_ctrl = summary.ctrl.mEr(1,:,1)';
    
    mOL_ctrl(count) =summary.ctrl.mpercentoverlap(1,1,1);
    mEr_ctrl(count,:) =summary.ctrl.mmEr(1,:,1);
    sOL_ctrl(count) =summary.ctrl.spercentoverlap(1,1,1);
    sEr_ctrl(count,:) =summary.ctrl.smEr(1,:,1);
    mFrCo_ctrl(count,:) =summary.ctrl.mFrCor(1,:,1);
    sFrCo_ctrl(count,:) =summary.ctrl.sFrCor(1,:,1);
%     pV_ctrl(count) =summary.ctrl.pvalue(1,1,1);
    if lightcond
        collected_decoder_summary_stats{count}.pOL_mani = summary.mani.percentoverlap(1,1,1);
        collected_decoder_summary_stats{count}.mEr_mani = summary.mani.mEr(1,:,1)';
        mOL_mani(count) =summary.mani.mpercentoverlap(1,1,1);
        mEr_mani(count,:) =summary.mani.mmEr(1,:,1);
        sOL_mani(count) =summary.mani.spercentoverlap(1,1,1);
        sEr_mani(count,:) =summary.mani.smEr(1,:,1);
            mFrCo_mani(count,:) =summary.mani.mFrCor(1,:,1);
            sFrCo_mani(count,:) =summary.mani.sFrCor(1,:,1);
%         pV_mani(count) =summary.mani.pvalue(1,1,1);
    end
    info(count) = {summary.info};
    
end
data.mOL_ctrl=mOL_ctrl;
data.mEr_ctrl=mEr_ctrl;
data.sOL_ctrl=sOL_ctrl;
data.sEr_ctrl=sEr_ctrl;
data.mFrCo_ctrl=mFrCo_ctrl;
data.sFrCo_ctrl=sFrCo_ctrl;
% data.pV_ctrl=pV_ctrl;
if lightcond
    data.mOL_mani=mOL_mani;    
    data.mEr_mani=mEr_mani;
    data.sOL_mani=sOL_mani;    
    data.sEr_mani=sEr_mani;
    data.mFrCo_mani=mFrCo_mani;
    data.sFrCo_mani=sFrCo_mani;
%     data.pV_mani=pV_mani;
end
data.info=info;
folder = uigetdir;
cd (folder);
save('Lin Decoder data','data');
save('collected_decoder_summary_stats','collected_decoder_summary_stats');

%% quick plot
% % load the summary

% % for ctrl only 
%% plottting mean error
%  figure;plot(data.p50_ctrl(:,[1:2])','color',[.5 .5 .5]); hold on;
%  m=mean(data.p50_ctrl(:,[1:2]));
%  s=std(data.p50_ctrl(:,[1:2]))./sqrt(7);
%  h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25);
%   set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'shuffled'});
% axis([0 3 1 4.5])
% ylabel('Mean error (mm)','fontsize',16)
% suptitle('Control data decoder results')
% set(gca,'Fontsize',16)

% %%  for ctrl only
%  C = data.mFrCo_ctrl(:,:); L = data.mFrCo_mani(:,:);
% temp(:,1) = C(:,1)-C(:,2);
% temp(:,2) = L(:,1)-L(:,2)
%  


C = data.mFrCo_ctrl(:,:); L = data.mFrCo_mani(:,:);
temp(:,1) = C(:,1)-C(:,2);
temp(:,2) = L(:,1)-L(:,2)

 numsess = size(C,1);
 figure;plot(C','color',[.5 .5 .5],'markersize',10); hold on;plot(repmat([3,4],numsess,1)',L','color',[.85 .5 .5],'markersize',10); hold on;
 m=mean(C);
 s=std(C)./sqrt(numsess+1);
 h=errorbar([1,2],m,s,'ko-'); set(h,'linewidth',1.25,'markersize',20);hold on;
  m=mean(L);
 s=std(L)./sqrt(numsess+1);
 h=errorbar([3,4],m,s,'ro-'); set(h,'linewidth',1.25,'markersize',20);
  set(gca,'XTick',[1 2 3 4 ]);set(gca,'XTicklabel',{'data';'shuff';'light';'light shuff'});
axis([0 4.5 .2 .4])
ylabel('Fraction Correct ','fontsize',16)
suptitle('Fraction Correct')
set(gca,'Fontsize',16);

numsess = size(C,1);
 figure;plot(temp','color',[.5 .5 .5],'markersize',10); hold on;
 m=mean(temp);
 s=std(temp)./sqrt(numsess+1);
 h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25,'markersize',20);
  set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'light'});
axis([0 3 -.1 .25])
ylabel('Fraction Correct difference','fontsize',16)
suptitle('Fraction Correct')
set(gca,'Fontsize',16);

temp =[ C(:,1) L(:,1)]
figure;plot(temp','color',[.5 .5 .5]); hold on;
 m=mean(temp);
 s=std(temp)./sqrt(size(temp,1)+1);
 h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25,'markersize',20);
  set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'Control';'light'});
axis([0 3 .35 .65])
ylabel('Fraction Correct','fontsize',16)
title('Fraction Correct ','Fontsize',16)
set(gca,'Fontsize',16);
%  

% 
% %% if regularized 
% temp = cell2mat(summary.ctrl.num_predictors{1});
% minpred= zeros(length(temp),1);
% runid= zeros(length(temp),1);
% for n = 1: length(temp)
% [v,i] = (min(temp));
% minpred(n) = v;
% runid(n) = i;
% temp(i) = nan;
% end
% 
% 
% inds = [(1:50:5000)]';
% inds(:,2) = inds(:,1)+49;
% err_all = summary.ctrl.dist_err{1,1}(:,1);
% for i = 1:100
% temp = err_all(inds(i,1):inds(i,2));
% frc= sum(temp==0);
% err_coll(i) = frc;
% end
% frCor=err_coll./50;
% frCor_sorted = frCor(runid);
% frCor_sorted = (frCor(runid))';
% 
% figure;plot(minpred,frCor_sorted,'o');
% [P,S] = polyfit(minpred,frCor_sorted,1);
% Y=polyval(P,[1:123]);
% hold on ; plot([1:123],Y,'b');
% 
% inds = [(1:50:5000)]';
% inds(:,2) = inds(:,1)+49;
% err_all = summary.mani.dist_err{1,1}(:,1);
% for i = 1:100
% temp = err_all(inds(i,1):inds(i,2));
% frc= sum(temp==0);
% err_coll(i) = frc;
% end
% frCor=err_coll./50;
% frCor_sorted = frCor(runid);
% frCor_sorted = (frCor(runid))';
% 
% 
% summary.ctrl.avg_numpred = mean(cell2mat(summary.ctrl.num_predictors{1,1}));
% mean(cell2mat(summary.ctrl.num_predictors{1,1}))
% plot(minpred,frCor_sorted,'ro');
% [P,S] = polyfit(minpred,frCor_sorted,1);
% Y=polyval(P,[1:123]);
% hold on ; plot([1:123],Y,'r');
% title('Fraction Correct vs Numpred','fontsize',16);
% text(100,.6, ['No. ' num2str(summary.ctrl.avg_numpred)]);
% 
% saveas(gca,'FrCor numpred','fig');
% set(gcf,'PaperPositionMode','manual');
% print( gcf ,'-depsc2','-painters','-loose','FrCor numpred');
% save('All_cells_phase diaglinear ctrltrain decoder results','summary')
% 
% 
% save('minpred','minpred');
% save('runid','runid');
% save('frCor_sorted','frCor_sorted');
% 
% clear

