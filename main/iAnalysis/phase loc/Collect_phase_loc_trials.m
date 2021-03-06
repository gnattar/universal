function [data] = Collect_phase_loc_trials()

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
         l=pooled_contactCaTrials_locdep{d}.poleloc;
         ph = pooled_contactCaTrials_locdep{d}.touchPhase;
         ca = pooled_contactCaTrials_locdep{d}.sigpeak;
         ls = pooled_contactCaTrials_locdep{d}.lightstim;
         [v,i]=unique(l);
         for i = 1:length(l)
             l2(i)=find(v==l(i));
         end
         l2 = l2';
        locs{count}(:,1) = l2;     
        phase{count}(:,1) = ph;
        caSig{count}(:,1) = ca;
        lightstim{count}(:,1) = ls;
        l=[];l2=[];ph=[];ca=[];ls=[];
        
    end
    
    cd (pathName);
end
data.locs=locs;
data.phase=phase;
data.ca=caSig;
data.lightstim=lightstim;


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

