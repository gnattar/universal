
% cells = [1,12;13,24;25,36;37,54;55,73;74,88;89,101;102,115;116,130;131,152]
load cells
load ST
load STdelta
load all_copy
 
for s= 1:4
    
temp=[];
loc=[];
temp_thetabinned =[];
temp = all_copy{cells(s,1)}.theta;
temp = temp - ST(1,s);

a = STdelta(:,s);
t=diff(a)/2;

% be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) a(3)+t(3) min(temp)-.1]; % for manip data set
 be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) a(3)+t(3) a(4)+t(4) min(temp)-.1] % for ctrl data set 5 positions
 
bedge=sort(be,'ascend');

[count edges mid loc] = histcn(temp, bedge);
mids = mid{1};
outliers = find(loc==0);
length(outliers)
temp (outliers) =[];
loc(outliers) = [];


for i = cells(s,1):cells(s,2)
all_copy{i}.sigpeak(outliers)=[];
all_copy{i}.phase(outliers)=[];
all_copy{i}.lightstim(outliers)=[];
all_copy{i}.re_totaldK(outliers)=[];
all_copy{i}.poleloc(outliers)=[];
all_copy{i}.theta(outliers)=[];
% all_copy{i}.loc(outliers)=[];
temp_thetabinned=mids(loc);
all_copy{i}.theta_binned=temp_thetabinned';
all_copy{i}.theta_bin_edges = be;
all_copy{i}.theta_bin_mids = mids;
all_copy{i}.theta_bin_counts = count;
end

end
save('all_copy_thetabinned','all_copy')

% glob=0:6.75:22
glob = 0:6.75:28
for i = 1: size(all_copy,2)
all = sort(unique(all_copy{i}.theta_binned),'descend');
temp = all_copy{i}.theta_binned;
for t = 1: length(all)
inds = [];
inds = find(temp==all(t));
temp2(inds) = glob(t);
end
all_copy{i}.theta_binned_new = temp2';
temp2 = [];
end
save('all_copy_thetabinned_glob','all_copy')
load all_copy_thetabinned_glob
%% %% make theta into ids [1:4]  - for theta decoding

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

pooled_contactCaTrials_locdep = all_copy;
save('pooled_contactCaTrials_locdep_allcells','pooled_contactCaTrials_locdep');

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
tempwave = cellfun(@(x) x(1,1),trials)';min(tempwave)
tempwave = cellfun(@(x) x(1,2),trials)';min(tempwave)
tempwave = cellfun(@(x) x(2,1),trials)';min(tempwave)
tempwave = cellfun(@(x) x(2,2),trials)';min(tempwave)

tempwave = cellfun(@(x) x(3,1),trials)';min(tempwave)
tempwave = cellfun(@(x) x(3,2),trials)';min(tempwave)
tempwave = cellfun(@(x) x(4,1),trials)';min(tempwave)
tempwave = cellfun(@(x) x(4,2),trials)';min(tempwave)
tempwave = cellfun(@(x) x(5,1),trials)';min(tempwave)
tempwave = cellfun(@(x) x(5,2),trials)';min(tempwave)

minlist =  [12,17;23,15;40,30;41,42];  %% for common deltatheta manip dataset
minlist =  [0,20;0,64;0,37;0,36;0 35];   %[0,35;0,36;0,37;0,64;0 20];  %% for common deltatheta ctrl dataset
%%
% if light 
% % % for i = 1:size(pooled_contactCaTrials_locdep,2)
% % %     ind_all = []; count =0;
% % %     for p = 1:size(minlist,1)
% % %     lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
% % %     sel_lind= randperm(length(lind),minlist(p,1));
% % %     nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
% % %     sel_nlind= randperm(length(nlind),minlist(p,2));   
% % %     temp = [lind(sel_lind);nlind(sel_nlind)];
% % %     num = length(temp);
% % %     ind_all(count+1:count+num) = temp;
% % %     count = count+num;
% % %     end    
% % %     pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
% % %     pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
% % %     pcopy{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all');
% % %      pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all');
% % %      pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
% % %       pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all'); 
% % %     pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
% % % end
% % % cells = size(pcopy,2);
% % % numrem = cells - 123;
% % % rem = randperm(cells,numrem);
% % % pcopy(rem) = [];
% % %  save('pcopy','pcopy');
% % % 
% % %  


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
save('pcopy','pcopy');
th=unique(pcopy{1}.theta);
[pcopy] = whisktheta_dependence_decoder(pcopy,'ctrl_mani','All_cells',0,th,'diaglinear','def',1,1)
clear pcopy
close all
