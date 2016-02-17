% script_to_combine_phase_loc_setpoint


% % files = dir('*_pooled_contactCaTrials_phasedep.mat')
% % for fn = 2:10
% %     f = files(fn).name;
% %     load(f)
% % temp=pooled_contactCaTrials_locdep{1}.touchSetpoint;
% % Setpoint_bins = linspace(-30,30,6);
% % [num edges mid id] = histcn(temp,Setpoint_bins);
% % Setpoint_mid = mid{1};
% % for s = 1: length(Setpoint_mid)
% %     tempid = find(id == s);
% %     setpoint_binned (tempid,1) = Setpoint_mid(s);
% % end
% % 
% % for d= 1:size(pooled_contactCaTrials_locdep,2)
% % pooled_contactCaTrials_locdep{d}.setpoint_binned = setpoint_binned;
% % end
% % 
% % save(f,'pooled_contactCaTrials_locdep')
% % 

files = dir('*_pooled_contactCaTrials_phasedep.mat')

n=0;i=1;
 for fn = 1:10
    f = files(fn).name;
    load(f)
all_cells{fn}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak;
all_cells{fn}.phase = pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned;
all_cells{fn}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim;
all_cells{fn}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK;
all_cells{fn}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc;
all_cells{fn}.setpoint = pooled_contactCaTrials_locdep{i}.setpoint_binned;

 end

%% make loc into ids [1:4]

for i = 1:size(all_cells,2)
temp = all_cells{i}.poleloc;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
all_cells{i}.loc = temp2';

end
save('all_cells','all_cells')


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
%% session 1 remove pos 1
%% sessions 2:6,8  4 pos already
%% session 7 remove pos 2
%% session 9 remove pos 1
%% session 10 remove pos 2

%% cells  [1:12] [13:24] [25:36] [37-54] [55:73] [74:88] [89:101] [102:115] [116:130] [131:152]  
           
%% cells  [1:23] [24:41] [42:56] [57:73] 
%% session 1 remove pos 6
%% sessions 2: pos 6 (0)
%% session 3 remove pos 6
%% session 4 remove pos 1

% removing  positions to bring to 4
all_copy = all_cells;
for i = 10
temp = all_cells{i}.loc;
rem = find(temp==2)%| temp==5);
all_copy{i}.sigpeak(rem)=[];
all_copy{i}.phase(rem)=[];
all_copy{i}.lightstim(rem)=[];
all_copy{i}.re_totaldK(rem)=[];
all_copy{i}.poleloc(rem)=[];
all_copy{i}.loc(rem)=[];
all_copy{i}.setpoint(rem)=[];
end
pooled_contactCaTrials_locdep = all_copy;
save('pooled_contactCaTrials_locdep_allsess','pooled_contactCaTrials_locdep');


for i = 1:size(pooled_contactCaTrials_locdep,2)
temp = pooled_contactCaTrials_locdep{i}.poleloc;
pl = unique(temp);
temp2 =[];
for p = 1:length(pl)
ind = find(temp == pl(p));
temp2(ind) = p;
end
pooled_contactCaTrials_locdep{i}.loc = temp2';

end
save('pooled_contactCaTrials_locdep_allsess_reloc','pooled_contactCaTrials_locdep');


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
end

pcopy{1}.sigpeak=cell2mat(cellfun(@(x) x.sigpeak,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.phase=cell2mat(cellfun(@(x) x.phase,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.lightstim=cell2mat(cellfun(@(x) x.lightstim,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.re_totaldK=cell2mat(cellfun(@(x) x.re_totaldK,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.poleloc=cell2mat(cellfun(@(x) x.poleloc,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.loc=cell2mat(cellfun(@(x) x.loc,pooled_contactCaTrials_locdep,'uni',0)');
pcopy{1}.setpoint=cell2mat(cellfun(@(x) x.setpoint,pooled_contactCaTrials_locdep,'uni',0)');
 save('pcopy','pcopy');
 %%%%%%%%%%%%%%%
 
 
 
