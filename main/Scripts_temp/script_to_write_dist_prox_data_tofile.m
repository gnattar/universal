numtrials = cell2mat(cellfun(@(x) length(x.lightstim),pooled_contactCaTrials_thetadep_Silenced_SW_RE,'uniformoutput',0));
sigmag = cell2mat(cellfun(@(x) x.sigmag,pooled_contactCaTrials_thetadep_Silenced_SW_RE,'uniformoutput',0)');
lightstim = cell2mat(cellfun(@(x) x.lightstim,pooled_contactCaTrials_thetadep_Silenced_SW_RE,'uniformoutput',0)');
touchmag = cell2mat(cellfun(@(x) x.totalKappa,pooled_contactCaTrials_thetadep_Silenced_SW_RE,'uniformoutput',0)');
 cellID =zeros(length(lightstim),1);
 
 count = 0;
 for i = 1: length(numtrials);
     cellID (count+1:count+numtrials(i)) = i;
     count = count + numtrials(i);
 end
 
 poleloc = cell2mat(cellfun(@(x) x.poleloc,pooled_contactCaTrials_thetadep_Silenced_SW_RE,'uniformoutput',0)')';
 
 grp = 'Prox'
 dlmwrite([grp 'SilencedCells SW TouchMag.txt'],touchmag,'delimiter',',')
dlmwrite([grp 'SilencedCells SW SignalMag.txt'],sigmag,'delimiter',',')
dlmwrite([grp 'SilencedCells SW lightstim.txt'],lightstim,'delimiter',',')
dlmwrite([grp 'SilencedCells SW  CellID.txt'],cellID,'delimiter',',')
dlmwrite([grp 'SilencedCells SW numtrials.txt'],numtrials','delimiter',',')
dlmwrite([grp 'SilencedCells SW poleloc.txt'],poleloc','delimiter',',')

d = [1,2]
 plot_thetadep_L_NL_mean_prot_ret(pooled_contactCaTrials_thetadep_Silenced_SW_RE,d)
  plot_thetadep_L_NL_reg_prot_ret(pooled_contactCaTrials_thetadep_Silenced_SW_RE,d)