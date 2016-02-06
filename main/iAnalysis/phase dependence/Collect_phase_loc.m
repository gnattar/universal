function [data] = Collect_phase_loc()

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_phasedep.mat','Load .mat file');
    else
        [filename,pathName]=uigetfile( filename,'Load phasedep.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        
        pref_loc{count}(d,1) = pooled_contactCaTrials_locdep{d}.meanResp.NL_PrefLoc;     
        phase_tuning{count}(d,:) =pooled_contactCaTrials_locdep{d}.phase.normResp_NL;
        phase{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid;
        temp = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid;
        [v,i]=max(phase_tuning{count}(d,:));       
        pref_phase{count}(d,1) = temp(i);
        
        locPI{count}(d,1)=pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI;
        phPI{count}(d,1)=pooled_contactCaTrials_locdep{d}.phase.PPI_NL;
        
        if isfield( pooled_contactCaTrials_locdep{d}.phase,'PPI_L')

        end
        
    end
    
    cd (pathName);
end
data.pref_loc=pref_loc;
data.phase_tuning=phase_tuning;
data.pref_phase=pref_phase;
data.locPI=locPI;
data.phPI=phPI;

if isfield( pooled_contactCaTrials_locdep{1}.phase,'PPI_L')

end
folder = uigetdir;
cd (folder);
save('Phase Loc Data','data');

%%%
% temp=arrayfun(@(x) x.pref_loc, data,'uni',0)';
% temp=temp{1}';
% pref_loc_list = cell2mat(temp);
% 
% temp=arrayfun(@(x) x.pref_phase, data,'uni',0)';
% temp=temp{1}';
% pref_phase_list = cell2mat(temp);
%  r = -.1 + (.1+.1).*rand(200,1);
%  temp = pref_loc_list+r;
%  figure;plot(pref_phase_list,temp,'o','color',[.5 .5 .5],'markersize',10)

temp=arrayfun(@(x) x.locPI, data,'uni',0)';
temp=temp{1}';
locPI_list = cell2mat(temp);

temp=arrayfun(@(x) x.phPI, data,'uni',0)';
temp=temp{1}';
phPI_list = cell2mat(temp);

figure;plot(phPI_list,locPI_list,'o','color',[.5 .5 .5],'markersize',10);
hold on ; plot([0 1 2 3],[0 1 2 3],'k--');
xlabel('location Sel Index','fontsize',16)
ylabel('phase Sel Index','fontsize',16)
set(gca,'tickdir','out')
set(gca,'fontsize',16)
 axis([.8 3.5 .8 3.5]);