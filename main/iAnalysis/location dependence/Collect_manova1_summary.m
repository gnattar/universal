function [data] = Collect_manova1_summary(lightcond)
% global collected_data
% global collected_summary

count=0;
def={'149','150515','self'};
%   data=struct('pOL_ctrl',[],'pOL_mani',[],'p50_ctrl',[],'p50_mani',[],'info',{});
meanFrCo_ctrl = {};
meanFrCo_mani={};

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

    
    meanFrCo_ctrl{count} = [summary.ctrl.meanFrCo{1}';summary.ctrl.meanFrCo{2}']';


    if lightcond
    meanFrCo_mani{count} = [summary.mani.meanFrCo{1}';summary.mani.meanFrCo{2}']';
    end
    info{count} = {summary.info};
    
end
data.meanFrCo_ctrl=meanFrCo_ctrl;


if lightcond
    data.meanFrCo_mani=meanFrCo_mani;
end
data.info=info;
folder = uigetdir;
cd (folder);
save('Lin Manova1 data','data');

%% quick plot
% % load the summary

