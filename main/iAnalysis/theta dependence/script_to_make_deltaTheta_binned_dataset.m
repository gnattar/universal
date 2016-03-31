n=0;
files = dir('*_pooled_contactCaTrials_thetadep*.mat')

for fn = 1:6
    f = files(fn).name
    load(f)
        for i= 1:size(pooled_contactCaTrials_locdep,2)
            all_cells{n+i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak;
            all_cells{n+i}.phase = pooled_contactCaTrials_locdep{i}.phase.touchPhase_binned;
            all_cells{n+i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim;
            all_cells{n+i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK;
            all_cells{n+i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc;
%              all_cells{n+i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned;
             all_cells{n+i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
             all_cells{n+i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
             all_cells{n+i}.reg_fov = [pooled_contactCaTrials_locdep{i}.reg pooled_contactCaTrials_locdep{i}.fov];
             all_cells{n+i}.dend = pooled_contactCaTrials_locdep{i}.dend;
             all_cells{n+i}.CellID = n+i;
             all_cells{n+i}.theta = pooled_contactCaTrials_locdep{i}.Theta_at_contact_Mean;
            % all_cells{n+i}.decoder.NLS = pooled_contactCaTrials_locdep{i}.decoder.NLS;
        end
        n=n+size(pooled_contactCaTrials_locdep,2);
        clear pooled_contactCaTrials_locdep
end

%% sessions [1:23] [24:41] [42:52] [53:67] [68:84]
% removed sessions 2 and 4 from ctrl data set
%% sessions [1:23] [24:27] [28:45] [46:56] [57:71] [72:88]
cells=[1,23;24,27;28 45;46,56;57,71;72,88]; % all cells
cells=[1,23;24,41;42,56;57,73] % 73 cells

%  session1,3,4 - del pos 6
%

for s = 1:4
temp=[];
temp=unique(all_cells{cells(s,1)}.poleloc)
 num=[];
for i = 1:length(temp)
    num(i) =  length(find(all_cells{cells(s,1)}.poleloc == temp(i)));
end
trialnum(1:length(num),s) = num;
end


s=4
temp=unique(all_cells{cells(s,1)}.poleloc)
remtrials = find(all_cells{cells(s,1)}.poleloc == temp(6) )
numremtrials(s) = length(remtrials);

 for n= cells(s,1):cells(s,2)
all_cells{n}.sigpeak(remtrials) = [];
all_cells{n}.phase(remtrials) = [];
all_cells{n}.lightstim(remtrials) = [];
all_cells{n}.re_totaldK(remtrials) = [];
all_cells{n}.poleloc(remtrials) = [];
all_cells{n}.theta(remtrials) = [];
 end

 %%
 for s = 1:4
temp=[];
temp=unique(all_cells{cells(s,1)}.poleloc)
 num=[];
for i = 1:length(temp)
    num(i) =  length(find(all_cells{cells(s,1)}.poleloc == temp(i)));
end
trialnum(1:length(num),s) = num;
 end

 for s = 1:4
temp=unique(all_cells{cells(s,1)}.poleloc);
for p = 1:length(temp)
cp=find(all_cells{cells(s,1)}.poleloc==temp(p));
M(p,s) = mean(all_cells{cells(s,1)}.theta(cp));
S(p,s) = std(all_cells{cells(s,1)}.theta(cp));
end
end
 
ST=M;
STdelta = bsxfun(@minus,ST,max(ST));