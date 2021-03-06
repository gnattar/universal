script_to_decode_from_all_cells

n=0;
for i= 1:size(pooled_contactCaTrials_locdep,2)
all_cells{n+i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak;
all_cells{n+i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc;
all_cells{n+i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim;
all_cells{n+i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK;
% all_cells{n+i}.decoder.NLS = pooled_contactCaTrials_locdep{i}.decoder.NLS;
end
n=n+size(pooled_contactCaTrials_locdep,2);

%% make poleloc into ids [1:4]

for i = 1:size(all_cells,2)
temp = all_cells{i}.poleloc;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
all_cells{i}.loc = temp2';
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
    trials{i}(6,1) = sum(templ{i}==1 & tempp{i}==6);
    trials{i}(6,2) = sum(templ{i}==0 & tempp{i}==6);
end

%% session 1 remove pos 1
%% sessions 2:6,8  4 pos already
%% session 7 remove pos 2
%% session 9 remove pos 1
%% session 10 remove pos 2 & 5

%% cells  [1:12] [13:24] [25:36] [37-54] [55:73] [74:88] [89:101] [102:115] [116:130] [131:152]  
           
%% cells  [1:23] [24:41] [42:56] [57:73] 
%% session 1 remove pos 6
%% sessions 2: pos 6 (0)
%% session 3 remove pos 6
%% session 4 remove pos 1



% removing  positions to bring to 4
all_copy = all_cells;
for i = [57:73]
temp = all_cells{i}.loc;
rem = find(temp==1)%| temp==5);
all_copy{i}.sigpeak(rem)=[];
all_copy{i}.poleloc(rem)=[];
all_copy{i}.lightstim(rem)=[];
all_copy{i}.re_totaldK(rem)=[];
all_copy{i}.phase(rem)=[];
all_copy{i}.theta(rem)=[];
all_copy{i}.loc(rem)=[];
% all_copy{i}.decoder.NLS.sigpeak(rem)=[];
% all_copy{i}.decoder.NLS.poleloc(rem)=[];
% all_copy{i}.decoder.NLS.lightstim(rem)=[];
% all_copy{i}.decoder.NLS.re_totaldK(rem)=[];
% all_copy{i}.decoder.loc(rem)=[];
end
pooled_contactCaTrials_locdep = all_copy;
save('pooled_contactCaTrials_locdep_allcells','pooled_contactCaTrials_locdep');

for i = 1:size(pooled_contactCaTrials_locdep,2)
temp = pooled_contactCaTrials_locdep{i}.poleloc;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
pooled_contactCaTrials_locdep{i}.loc = temp2';
% all_cells{i}.decoder.loc = temp2';
end

templ =cellfun(@(x) x.lightstim,all_copy,'uni',0);
tempp =cellfun(@(x) x.loc,all_copy,'uni',0);


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


% to find min
% tempwave = cellfun(@(x) x(1,2),trials)';min(tempwave)

minlist = [ 25,24;38,41;50,50;19,34];

minlist = [ 0 21;0 91;0 34;0 35;0 33];

% if light 
for i = 1:size(pooled_contactCaTrials_locdep,2)
    ind_all = []; count =0;
    for p = 1:size(minlist,1)
    lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
    sel_lind= randperm(length(lind),minlist(p,1));
    nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
    sel_nlind= randperm(length(nlind),minlist(p,2));   
    temp = [lind(sel_lind)';nlind(sel_nlind)'];
    num = length(temp);
    ind_all(count+1:count+num) = temp;
    count = count+num;
    end    
    pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
    pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
    pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all');
    pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
    pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
    
%         pcopy{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all');
%       pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all');
%             pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all');
    pcopy{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
     pcopy{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
      pcopy{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
     pcopy{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
         pcopy{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID; 
end
for i = 1:size(pcopy,2)
pcopy{i}.poleloc = pcopy{i}.loc;
end
 save('pcopy','pcopy');


%if ctrl
for i = 1:size(pooled_contactCaTrials_locdep,2)
    ind_all = []; count =0;
    for p = 1:4
    lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
    sel_lind= randperm(length(lind),minlist(p,1));
    nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
    sel_nlind= randperm(length(nlind),minlist(p,2));   
    temp = [nlind(sel_nlind)'];
    num = length(temp);
    ind_all(count+1:count+num) = temp;
    count = count+num;
    end    
    pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
    pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
    pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all');
    pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
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
[pcopy] = whiskloc_dependence_decoder(pcopy,'sigpeak','ctrl_mani','All_cells_T130',0,[1 2 3 4],'diaglinear','def',1,0)