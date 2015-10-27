function [collected_decoder_summary_stats,data] = Collect_decoder_summary(lightcond)
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
axis([0 3 0 .5])
ylabel('Fraction Correct difference','fontsize',16)
suptitle('Fraction Correct')
set(gca,'Fontsize',16);



%  
% numsess = size(data.mEr_ctrl,1);
%  figure;plot(data.mEr_ctrl(:,[1:2])','color',[.5 .5 .5],'markersize',10); hold on;
%  m=mean(data.mEr_ctrl(:,[1:2]));
%  s=std(data.mEr_ctrl(:,[1:2]))./sqrt(numsess+1);
%  h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25);
%   set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'shuffled'});
% axis([0 3 1 4.5])
% ylabel('Mean error (mm)','fontsize',16)
% suptitle('Control data decoder mean error results')
% set(gca,'Fontsize',16);
% 
% 
% tempDSctrl(:,1) = data.mEr_ctrl(:,2)-data.mEr_ctrl(:,1); %shuffled  - data
% [h,p]=ttest(tempDSctrl);
% tb = text(1,2.5,['Ctrl mEr p =' num2str(p)]);
% temp = ones(1,6);
% 
% 
% 
% 
% temp = ones(1,6);
% figure;plot(temp,data.mOL_ctrl,'o','color',[.5 .5 .5])
% m=mean(data.mOL_ctrl);
% s=std(data.mOL_ctrl)./sqrt(7);
% hold on;errorbar(1,m,s,'ko')
% axis([.5 1.5 0 .15]);
% suptitle('Percent overlap')
% axis([.5 1.5 0 .2]);
% temp = ones(1,6);
% figure;plot(temp,tempDSctrl(:,1),'o','color',[.5 .5 .5])
% axis([.5 1.5 0 2.5]);
% axis([.5 1.5 0.5 2.5]);
% m = mean(tempDSctrl(:,1))
% hold on;
% s = std(tempDSctrl(:,1))./sqrt(7);
% e1=errorbar(m,s,'ko');
% set(e1,'markersize',10)




% % for ctrl_mani
% numsess = size(data.mEr_ctrl,1);
%  figure;plot(data.mEr_ctrl(:,[1:2])','color',[.5 .5 .5],'markersize',10); hold on;
%  m=mean(data.mEr_ctrl(:,[1:2]));
%  s=std(data.mEr_ctrl(:,[1:2]))./sqrt(numsess+1);
%  h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25);
%   set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'shuffled'});
% axis([0 5 1 4.0])
% ylabel('Mean error (mm)','fontsize',16)
% suptitle('Control data decoder mean error results')
% set(gca,'Fontsize',16);
% 
% hold on;
% x = repmat([3 4],size(data.mEr_mani(:,1),1),1)';
% plot(x,data.mEr_mani(:,[1:2])','color',[.85 .5 0],'markersize',10); hold on;
%  m=mean(data.mEr_mani(:,[1:2]));
%  s=std(data.mEr_mani(:,[1:2]))./sqrt(numsess+1);
%  h=errorbar(x(:,1),m,s,'o-'); set(h,'linewidth',1.25,'color',[1 .5 0]);
%  set(gca,'XTick',[1 2 3 4]);set(gca,'XTicklabel',{'data';'shuffled';'data';'shuffled'});
% axis([0 5 1 4.0])
% ylabel('Mean error (mm)','fontsize',16)
% suptitle('Mani data decoder mean error results')
% set(gca,'Fontsize',16)
% 
% tempDSctrl(:,1) = data.mEr_ctrl(:,2)-data.mEr_ctrl(:,1); %shuffled  - data
% tempDSmani(:,1) = data.mEr_mani(:,2)-data.mEr_mani(:,1);
% 
% [h,p]=ttest(tempDSctrl);
% tb = text(1,2.5,['Ctrl mEr p =' num2str(p)]);
% [h,p]=ttest(tempDSmani);
% tb = text(4,2.5,['Mani mEr p =' num2str(p)]);set(tb,'color',[1 .5 0]);
% 
% [h,p]=ttest(tempDSctrl-tempDSmani);
% 
% tb = text(2,3,['Ctrl Diff mEr p =' num2str(p)]);set(tb,'color',[1 0 1]);
% 
% %%
%  figure;plot([tempDSctrl,tempDSmani]','o-','color',[.5 .5 .5],'markersize',10); hold on; 
% e1= errorbar(mean([tempDSctrl,tempDSmani]),std([tempDSctrl,tempDSmani])./sqrt(numsess+1),'ko-'); hold on;
% set(e1,'linewidth',1.5,'markersize',10);
% axis([0 3 -.5 3]);tb = text(1.5,2,['Ctrl Diff mEr p =' num2str(p)]);set(tb,'color',[1 0 1]);
% set(gca,'XTick',[1 2 ]);set(gca,'XTicklabel',{'Ctrl';'Light'});
%  title('Paired diff from shuffled');set(gca,'Fontsize',16)
% 
% temp = [data.mOL_ctrl',data.mOL_mani'];
% temps = [data.sOL_ctrl',data.sOL_mani'];
% diff = temp(:,1)-temp(:,2);
% [h,p]=ttest(diff);
% figure; errorbar(temp',temps','color',[.5 .5 .5]); hold on;
%  m=mean(temp);
%  sem=std(temp)./sqrt(size(temp,1)+1);
% 
%  e=errorbar(m,sem,'ko-');set(e,'linewidth',2,'markersize',10);
% axis([0 3 0 .8]);
%  text(1.6,.7,['Ctrl  trained p =' num2str(p)]);
%  set(gca,'XTick',[1 2 ]);set(gca,'XTicklabel',{'Ctrl';'Light'});
%  title('Ctrl pOL trained');set(gca,'Fontsize',16)


% % % % to check if individual sessions are decoding under ctrl cond
% % % temp = data.mEr_ctrl(:,[1:2]);
% % % temps = data.sEr_ctrl(:,[1:2]);
% % %  m=mean(temp);
% % % s=std(temp)./sqrt(size(temp,1)+1);
% % % 
% % % figure; errorbar(temp',temps','color',[.5 .5 .5]);
% % % hold on;
% % % errorbar(m,s,'ko-')
% % % [h,p] = ttest(temp(:,1),temp(:,2));
% % % text(1.5,2.8,['p=' num2str(p)]);
% % %  title('Decoder mean error Ctrl and shuffled under NL cond');
% % %   set(gca,'ticklength',[.025 .025]);
% % %   set(gca,'XTick',[1 2]);axis([.5 2.5 1 5]);
% % %   set(gca,'XTicklabel',{'Aligned';'Shuffled'});