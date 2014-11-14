%% plot the distribution of light and no light event sizes for each cell
intarea_trials = cellfun(@(x) x.intarea (:,1),pooled_contact_CaTrials,'uniformoutput',0);
lightstim_trials = cellfun(@(x) x.lightstim (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
 eventsdetected_trials = cell2mat(cellfun(@(x) x.eventsdetected (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
eventsdetected_trials = cellfun(@(x) x.eventsdetected (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
numcells = size(eventsdetected_trials,2);
figure;
for j = 1: numcells
 e = eventsdetected_trials{j};
l = lightstim_trials{j};
i = intarea_trials{j};

il = i(e&l);
inl=i(e&~l);
plot(repmat(j,length(il),1),il,'ro'); hold on ;
end

for j = 1: numcells
 e = eventsdetected_trials{j};
l = lightstim_trials{j};
i = intarea_trials{j};
il = i(e&l);
inl=i(e&~l);
plot(repmat(j,length(inl),1),inl,'ko'); hold on ;
end

hline(30,'k');
hline(100,'k--');
hline(200,'k--');


%% plot fractional change in freq of rel event sizes within each cell for cells with > 30 trials
intarea_trials_cells = cellfun(@(x) x.intarea (:,1),pooled_contact_CaTrials,'uniformoutput',0);
lightstim_trials_cells = cellfun(@(x) x.lightstim (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
peakamp_trials_cells = cellfun(@(x) x.peakamp (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
fwhm_trials_cells = cellfun(@(x) x.fwhm (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
 eventsdetected_trials_cells = cellfun(@(x) x.eventsdetected (:,1) ,pooled_contact_CaTrials,'uniformoutput',0);
 
 numcells = size(intarea_trials_cells,2);
 
sigmag_cumfreq_L= zeros(4,numcells);
sigmag_cumfreq_NL = zeros(4,numcells);
 frac_red = zeros(4,numcells);
ntrials = zeros(2,numcells);

for j = 1:numcells
    i=intarea_trials_cells{j};
    i(find(i==inf)) = nan;
    e=eventsdetected_trials_cells{j};
    l=lightstim_trials_cells{j};
    maxia = max(i);
    
    x = [ maxia/4 : maxia/4 : maxia]; %  4 norm sized bins
    
    y = i(e&l); %% event and light
    n = length(i(l==1));   % just light
    ntrials(1,j) = n;
    sigmag_freq_L(:,j) = hist(y,x)./n;
 
    
    y = i(e&~l); %% event and nolight
    n = length(i(l==0));   % just nolight
    sigmag_freq_NL (:,j)= hist(y,x)./n;
    ntrials(2,j) = n;
    
    frac_red (:,j) = (sigmag_freq_NL (:,j) - sigmag_freq_L(:,j))./sigmag_freq_NL (:,j);
end

 goodones = find(ntrials(1,:)>20 & ntrials(2,:) >20)
 figure;plot(sigmag_freq_L(:,goodones) ,'color',[1.0 .5 .5],'linewidth',2)
ylabel('Prob of event size')
xlabel ('Event size in quartiles')
title('Event size freq Light')
figure;plot(sigmag_freq_NL(:,goodones) ,'color',[0.5 .5 .5],'linewidth',2)
xlabel ('Event size in quartiles')
ylabel('Prob of event size')
title('Event size freq No Light')

 figure;plot([1:4]./4,frac_red(:,goodones) ,'color',[1.0 .5 .5],'Marker','o','linewidth',1.5); 
axis([0 1.25 -2 1.1])
title('Prox Silenced Fr change cell wise mag')
xlabel('Relative signal mag per cell')
ylabel('Freq of rel. signal mag per cell');