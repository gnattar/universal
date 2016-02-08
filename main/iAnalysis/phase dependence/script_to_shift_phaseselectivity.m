%% testing decoder for pop shift in phase selectivity
for d = 1: size(pcopy,2)
lightstim = pcopy{d}.lightstim;
sigpeak = pcopy{d}.sigpeak;
phase = pcopy{d}.phase;
loc = pcopy{d}.loc;
re_totaldK = pcopy{d}.re_totaldK;

nl_trial_inds = find(lightstim == 0);
l_trial_inds = find(lightstim == 1);


sigpeak_NL = sigpeak(nl_trial_inds);
lightstim_NL = lightstim(nl_trial_inds);
phase_NL = phase(nl_trial_inds);
loc_NL = loc(nl_trial_inds);
re_totaldK_NL = re_totaldK(nl_trial_inds);

sigpeak_L = sigpeak(nl_trial_inds);
lightstim_L = lightstim(nl_trial_inds);
phase_L = phase(nl_trial_inds);
loc_L = loc(nl_trial_inds);
re_totaldK_L = re_totaldK(nl_trial_inds);

phases = unique(phase_NL);
dph = diff(phases);
phase_L = ((loc_L<5) .* (phase_L+dph(1))) + ((loc_L==5) .* (phase_L*-1));
loc_L = ((loc_L<5) .* (loc_L+1)) + ((loc_L==5) .* (loc_L-3));
lightstim_L (:) = 1;


sigpeak = [sigpeak_NL;sigpeak_L];
lightstim = [lightstim_NL;lightstim_L];
phase= [phase_NL;phase_L];
loc = [loc_NL;loc_L];
re_totaldK = [re_totaldK_NL;re_totaldK_L];

pcopy_shift{d}.sigpeak = sigpeak;
pcopy_shift{d}.lightstim = lightstim;
pcopy_shift{d}.phase = phase;
pcopy_shift{d}.loc = loc;
pcopy_shift{d}.re_totaldK = re_totaldK;
end

save('pcopy1_shift','pcopy_shift');
clear
load('pcopy1_shift')
mkdir('shifted');
cd('shifted')
 ph=unique(pcopy_shift{1}.phase);
 [pcopy_shift] = whiskphase_dependence_decoder(pcopy_shift,'ctrl_mani','All_cells_phaseshifted',0,ph,'diaglinear','def',1)
