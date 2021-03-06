script_to_decode_phase_from_all_cells

n=0;
files = dir('*_pooled_contactCaTrials_thetadep.mat')

for fn = 1:6
    f = files(fn).name
    load(f)
        for i= 1:size(pooled_contactCaTrials_locdep,2)
            all_cells{n+i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak;
            all_cells{n+i}.phase = pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned;
            all_cells{n+i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim;
            all_cells{n+i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK;
            all_cells{n+i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc;
             all_cells{n+i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned;
             all_cells{n+i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
             all_cells{n+i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
             all_cells{n+i}.reg_fov = [pooled_contactCaTrials_locdep{i}.reg pooled_contactCaTrials_locdep{i}.fov];
             all_cells{n+i}.dend = pooled_contactCaTrials_locdep{i}.dend;
             all_cells{n+i}.CellID = n+i;
%             all_cells{n+i}.theta = pooled_contactCaTrials_locdep{i}.Theta_at_contact_Mean;
            % all_cells{n+i}.decoder.NLS = pooled_contactCaTrials_locdep{i}.decoder.NLS;
        end
        n=n+size(pooled_contactCaTrials_locdep,2);
        clear pooled_contactCaTrials_locdep
end

%% make phase into ids [1:4] - for phase decoding

for i = 1:size(all_cells,2)
temp = all_cells{i}.phase;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
all_cells{i}.loc = temp2';
% all_cells{i}.decoder.loc = temp2';
end
%% %% make loc into ids [1:6]  - for theta decoding

for i = 1:size(all_cells,2)
temp = all_cells{i}.theta;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
all_cells{i}.loc = temp2';
% all_cells{i}.decoder.loc = temp2';
end

%% cells  [1:12] [13:24] [25:36] [37-54] [55:73] [74:88] [89:101] [102:115] [116:130] [131:152]  
% % % %% session 1 remove theta 1
% % % %% sessions 2 remove theta 4
% % % %% sessions 3 :5  4 theta already
% % % %% session 6 remove theta 4
% % % %% session 7 remove theta 1
% % % %% session 8 remove theta 1
% % % %% session 9 4 theta already
% % % %% session 10 remove 3
% % % % %% session 1 remove theta 1
% % % % %% sessions 3 :5  4 theta already
% % % % %% session 6 remove theta 4
% % % % %% session 7 remove theta 1
% % % % %% session 8 remove theta 1
% % % % %% session 9 4 theta already
% % % % %% session 10 remove 3

%% [1:12,89:101,102:115] remove 1
%% [13:24,74:88] remove 4
%% [131:152] remove 3

all_copy = all_cells;
for i = [1:12]
temp = all_copy{i}.loc;
rem = find(temp==1)% | temp==5);
all_copy{i}.sigpeak(rem)=[];
all_copy{i}.poleloc(rem)=[];
all_copy{i}.lightstim(rem)=[];
all_copy{i}.re_totaldK(rem)=[];
all_copy{i}.loc(rem)=[];
all_copy{i}.phase(rem)=[];
all_copy{i}.theta(rem)=[];
end

for i = 1:size(all_copy,2)
temp = all_copy{i}.theta_binned_new;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
all_copy{i}.loc = temp2';
% all_cells{i}.decoder.loc = temp2';
end
%% find how many positions how many trials
templ =cellfun(@(x) x.lightstim,all_cells,'uni',0);
tempp =cellfun(@(x) x.loc,all_cells,'uni',0);

for i = 1:size(all_cells,2)
    trials{i}(1,1) = sum(templ{i}==1 & tempp{i}==1);
    trials{i}(1,2) = sum(templ{i}==0 & tempp{i}==1);
    trials{i}(2,1) = sum(templ{i}==1 & tempp{i}==2);
    trials{i}(2,2) = sum(templ{i}==0 & tempp{i}==2);
    trials{i}(3,1) = sum(templ{i}==1 & tempp{i}==3);
    trials{i}(3,2) = sum(templ{i}==0 & tempp{i}==3);
    trials{i}(4,1) = sum(templ{i}==1 & tempp{i}==4);
    trials{i}(4,2) = sum(templ{i}==0 & tempp{i}==4);
    trials{i}(5,1) = sum(templ{i}==1 & tempp{i}==5);
    trials{i}(5,2) = sum(templ{i}==0 & tempp{i}==5);
end

pooled_contactCaTrials_locdep = all_cells;
save('pooled_contactCaTrials_locdep_allcells','pooled_contactCaTrials_locdep');

% templ =cellfun(@(x) x.lightstim,all_copy,'uni',0);
% tempp =cellfun(@(x) x.loc,all_copy,'uni',0);

all_copy = all_cells;
rem=[74:88, 102:115];
 pooled_contactCaTrials_locdep (rem) = [];
 
%% make poleloc into ids [1:4]
 for i = 1:size(pooled_contactCaTrials_locdep,2)
temp = pooled_contactCaTrials_locdep{i}.poleloc;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
pooled_contactCaTrials_locdep{i}.poleloc = temp2';
% all_cells{i}.decoder.loc = temp2';
end

 save('pooled_contactCaTrials_locdep_123cells','pooled_contactCaTrials_locdep');
templ =cellfun(@(x) x.lightstim,pooled_contactCaTrials_locdep,'uni',0);
tempp =cellfun(@(x) x.loc,pooled_contactCaTrials_locdep,'uni',0);

for i = 1:size(pooled_contactCaTrials_locdep,2)
    trials{i}(1,1) = sum(templ{i}==1 & tempp{i}==1);
    trials{i}(1,2) = sum(templ{i}==0 & tempp{i}==1);
    trials{i}(2,1) = sum(templ{i}==1 & tempp{i}==2);
    trials{i}(2,2) = sum(templ{i}==0 & tempp{i}==2);
    trials{i}(3,1) = sum(templ{i}==1 & tempp{i}==3);
    trials{i}(3,2) = sum(templ{i}==0 & tempp{i}==3);
    trials{i}(4,1) = sum(templ{i}==1 & tempp{i}==4);
    trials{i}(4,2) = sum(templ{i}==0 & tempp{i}==4);
    trials{i}(5,1) = sum(templ{i}==1 & tempp{i}==5);
    trials{i}(5,2) = sum(templ{i}==0 & tempp{i}==5);
end

%%
% to find min
% tempwave = cellfun(@(x) x(1,2),trials)';min(tempwave)
minlist = [ 10,14;64,45;25,35;11,13;17 13]; %% for phase
minlist = [ 15,12;60,49;34,35;19,17;21 16]; %% shuffled
minlist = [ 18,14;64,45;26,43;19,13;18 17]; %% phase from loc
minlist =  [ 5,7;49,53;18,20;7,5];  %% for theta
% minlist =  [19,34;50,48;36,24;13,13];  %% for common deltatheta
minlist =  [12,17;23,15;40,30;41,42];  %% for glob deltatheta run2, run3
minlist =  [ 10,14;48,30;25,31;11,8;17 13]; %% for phase with theta Run4 not used
minlist = [ 10,14;48,30;25,31;11,6;17 13]; % run 4
minlist = [ 10,14;64,45;25,31;11,8;17 13]; % runs 5 and 6
minlist = [ 18,14;64,45;26,43;19,13;18 17]; %% run phase 8 123 cells 
minlist =  [27,20;29,17;45,43;41,42]; % run theta 8 123 cells
% if light 
for i = 1:size(pooled_contactCaTrials_locdep,2)
    ind_all = []; count =0;
    for p = 1:size(minlist,1)
    lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
    sel_lind= randperm(length(lind),minlist(p,1));
    nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
    sel_nlind= randperm(length(nlind),minlist(p,2));   
    temp = [lind(sel_lind);nlind(sel_nlind)];
    num = length(temp);
    ind_all(count+1:count+num) = temp;
    count = count+num;
    end    
    pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
    pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
    pcopy{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all');
%       pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all');
            pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all');

     pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
%       pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all'); 
    pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
    pcopy{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
     pcopy{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
      pcopy{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
     pcopy{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
         pcopy{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID;   
end
% cells = size(pcopy,2);
% numrem = cells - 123;
% rem = randperm(cells,numrem);
% pcopy(rem) = [];
 save('pcopy','pcopy');

%%
%if ctrl
for i = 1:size(pooled_contactCaTrials_locdep,2)
    ind_all = []; count =0;
    for p = 1:4
    lind = find(pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
    sel_lind= randperm(length(lind),minlist(p,1));
    nlind = find(pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
    sel_nlind= randperm(length(nlind),minlist(p,2));   
    temp = [nlind(sel_nlind)'];
    num = length(temp);
    ind_all(count+1:count+num) = temp;
    count = count+num;
    end    
    pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
    pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
    pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned(ind_all');
%     pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
    pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
end
for i = 1:size(pcopy,2)
pcopy{i}.poleloc = pcopy{i}.loc;
end
 save('pcopy','pcopy');







% % % 
% % % for i = 1 :152
% % % lind=find(pooled_contactCaTrials_locdep{i}.lightstim == 1);
% % % select_temp= randperm(length(lind),132);
% % % select_lind = lind(select_temp);
% % % rem=setxor([1:length(lind)],select_temp);
% % % rem_lind = lind(rem);
% % % 
% % % nlind=find(pooled_contactCaTrials_locdep{i}.lightstim == 0);
% % % select_temp= randperm(length(nlind),153);
% % % select_nlind = nlind(select_temp);
% % % rem=setxor([1:length(nlind)],select_temp);
% % % rem_nlind = nlind(rem);
% % % 
% % % rem_all = [rem_lind;rem_nlind];
% % % 
% % % pooled_contactCaTrials_locdep{i}.sigpeak(rem_all)=[];
% % % pooled_contactCaTrials_locdep{i}.poleloc(rem_all)=[];
% % % pooled_contactCaTrials_locdep{i}.lightstim(rem_all)=[];
% % % pooled_contactCaTrials_locdep{i}.re_totaldK(rem_all)=[];
% % % pooled_contactCaTrials_locdep{i}.loc(rem_all)=[];
% % % end
% % % %% order all the light and no light trials together
% % %  for i = 1:152
% % % lind = find(pooled_contactCaTrials_locdep{i}.lightstim == 1);
% % % nlind = find(pooled_contactCaTrials_locdep{i}.lightstim == 0);
% % % ind = [lind;nlind];
% % % temp = [];
% % % temp = pooled_contactCaTrials_locdep{i}.sigpeak(ind);
% % % pooled_contactCaTrials_locdep2{i}.sigpeak = temp;
% % % temp = pooled_contactCaTrials_locdep{i}.lightstim(ind);
% % % pooled_contactCaTrials_locdep2{i}.lightstim = temp;
% % % temp = pooled_contactCaTrials_locdep{i}.poleloc(ind);
% % % pooled_contactCaTrials_locdep2{i}.poleloc = temp;
% % % temp = pooled_contactCaTrials_locdep{i}.loc(ind);
% % % pooled_contactCaTrials_locdep2{i}.loc = temp;
% % % temp = pooled_contactCaTrials_locdep{i}.re_totaldK(ind);
% % % pooled_contactCaTrials_locdep2{i}.re_totaldK = temp;
% % % end

% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','All_cells_T130',0,[1 2 3 4],'diaglinear','def',1,0)
ph=unique(pcopy{1}.phase);
[pcopy] = whiskphase_dependence_decoder(pcopy,'ctrl_mani','All_cells_phase',0,ph,'diaglinear','def',1)


th=unique(pcopy{1}.theta);
[pcopy] = whisktheta_dependence_decoder(pcopy,'ctrl_mani','All_cells_phase',0,th,'diaglinear','def',1)
clear pcopy
close all
