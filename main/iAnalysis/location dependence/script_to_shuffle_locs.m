%% script_to_shuffle_locs
load('pcopy')
temp=pcopy{1}.poleloc;
% temp2=temp(randperm(length(temp),length(temp)));
temp2 = round(1 + (4-1).*rand(length(temp),1));
for d = 1:size(pcopy,2)
pcopy{d}.poleloc = temp2;
end
save('pcopy_locshuffled','pcopy');


files = dir('*_pooled_contactCaTrials_locdep_smth.mat');
for i = 1: size(files,1);
     f=files(i).name;
     load(f);
     dends = size(pooled_contactCaTrials_locdep,2)
     for d = 1: dends
     temp=pooled_contactCaTrials_locdep{d}.poleloc;
    [locs,num] = unique(temp);
    temp2 = round(1 + (length(locs)-1).*rand(length(temp),1));
    nl = locs(temp2);
    pooled_contactCaTrials_locdep{d}.poleloc = nl;
     end
    cd('shuffled');
save([f(1:41) '_shuff'],'pooled_contactCaTrials_locdep');
cd ..
end


files = dir('*_pooled_contactCaTrials_phasedep.mat');
for i = 1: size(files,1);
     f=files(i).name;
     load(f);
     dends = size(pooled_contactCaTrials_locdep,2)
     for d = 1: dends
     temp=pooled_contactCaTrials_locdep{d}.touchPhase;
%     [locs,num] = unique(temp);
%     temp2 = round(1 + (length(locs)-1).*rand(length(temp),1));
 temp2 = randperm(length(temp),length(temp));
    nph = temp(temp2);
    pooled_contactCaTrials_locdep{d}.touchPhase = nph;
     end
    cd('shuffled');
save([f(1:42) '_shuff'],'pooled_contactCaTrials_locdep');
cd ..
end


files = dir('*_pooled_contactCaTrials_phasedep_shuff.mat');
for i = 1: size(files,1);
     f=files(i).name;
     load(f);
     dends = [1:size(pooled_contactCaTrials_locdep,2)]
     [pooled_contactCaTrials_locdep]=  plot_phase_at_touch(pooled_contactCaTrials_locdep,dends);
   
save(f,'pooled_contactCaTrials_locdep');
clear pooled_contactCaTrials_locdep
close all
end