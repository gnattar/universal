function [collected_decoder_summary_stats,data] = Collect_decoder_summary(lightcond)
% global collected_data
% global collected_summary
collected_decoder_summary_stats = {};
count=0;
def={'149','150515','self'};
%   data=struct('pOL_ctrl',[],'pOL_mani',[],'p50_ctrl',[],'p50_mani',[],'info',{});
pOL_ctrl = [];
pOL_mani=[];
p50_ctrl=[];
p50_mani=[];
pV_ctrl = [];
pV_mani = [];
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
    collected_decoder_summary_stats{count}.p50_ctrl = summary.ctrl.p50(1,:,1);
    
    pOL_ctrl(count) =summary.ctrl.percentoverlap(1,1,1);
    p50_ctrl(count,:) =summary.ctrl.p50(1,:,1);
    pV_ctrl(count) =summary.ctrl.pvalue(1,1,1);
    if lightcond
        collected_decoder_summary_stats{count}.pOL_mani = summary.mani.percentoverlap(1,1,1);
        collected_decoder_summary_stats{count}.p50_mani = summary.mani.p50(1,:,1);
        pOL_mani(count) =summary.mani.percentoverlap(1,1,1);
        p50_mani(count,:) =summary.mani.p50(1,:,1);
        pV_mani(count) =summary.mani.pvalue(1,1,1);
    end
    info(count) = {summary.info};
    
end
data.pOL_ctrl=pOL_ctrl;
data.p50_ctrl=p50_ctrl;
data.pV_ctrl=pV_ctrl;
if lightcond
    data.pOL_mani=pOL_mani;    
    data.p50_mani=p50_mani;
    data.pV_mani=pV_mani;
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

%% plotting percent overlap
% temp = ones(1,6);
% figure;plot(temp,data.pOL_ctrl,'o','color',[.5 .5 .5])
% m=mean(data.pOL_ctrl);
% s=std(data.pOL_ctrl)./sqrt(7);
% hold on;errorbar(1,m,s,'ko')
% axis([.5 1.5 0 .15]);
% suptitle('Percent overlap')



% % % % for ctrl_mani
% % % 
% % %  figure;plot(data.p50_ctrl(:,[1:2])','color',[.5 .5 .5]); hold on;
% % %  m=mean(data.p50_ctrl(:,[1:2]));
% % %  s=std(data.p50_ctrl(:,[1:2]))./sqrt(7);
% % %  h=errorbar(m,s,'ko-'); set(h,'linewidth',1.25);
% % %   set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'shuffled'});
% % % axis([0 3 1 4.5])
% % % ylabel('Mean error (mm)','fontsize',16)
% % % suptitle('Control data decoder mean error results')
% % % set(gca,'Fontsize',16);
% % % 
% % % hold on;
% % % 
% % % plot(data.p50_mani(:,[1:2])','color',[.85 .5 0]); hold on;
% % %  m=mean(data.p50_mani(:,[1:2]));
% % %  s=std(data.p50_mani(:,[1:2]))./sqrt(7);
% % %  h=errorbar(m,s,'o-'); set(h,'linewidth',1.25,'color',[1 .5 0]);
% % %  set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'data';'shuffled'});
% % % axis([0 3 1 4.5])
% % % ylabel('Mean error (mm)','fontsize',16)
% % % suptitle('Mani data decoder mean error results')
% % % set(gca,'Fontsize',16)


% temp = [data.pOL_ctrl',data.pOL_mani'];
% diff = temp(:,1)-temp(:,2);
% [h,p]=ttest(diff);
% figure; plot(temp','color',[.5 .5 .5]); hold on;
%  m=mean(temp);
%  sem=std(temp)./sqrt(size(temp,1)+1);
%  h=errorbar(m,sem,'ko-');set(h,'linewidth',2)
%  text(1.6,.7,['Self trained p =' num2str(p)]);
%  title('Self trained');