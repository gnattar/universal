% LM 2012-Apr 27: plot for times
if (0)
	cd /media/an160508b/session_merged
	load L1_cellmat
	load L23_cellmat
	load L5_cellmat
	cd /data/an166558/session
	load ALL_L4_cellmat
end

% highly active
freq_thresh = 0.05;
figure('Position', [0 0 1200 800]);
sp = subplot('Position', [0.1 .1 .15 .8]);
plot_sorted_peaks (cellmat_L1, freq_L1, freq_thresh, sp);
title(['Layer 1, Activity Threshold ' num2str(freq_thresh) ' Hz']);

sp = subplot('Position', [0.3 .1 .15 .8]);
plot_sorted_peaks (cellmat_L23, freq_L23, freq_thresh, sp);
title('Layer 2/3');
ylabel('');

sp = subplot('Position', [0.5 .1 .15 .8]);
plot_sorted_peaks (cellmat_L4, freq_L4, freq_thresh, sp);
title('Layer 4');
ylabel('');

sp = subplot('Position', [0.7 .1 .15 .8]);
plot_sorted_peaks (cellmat_L5, freq_L5, freq_thresh, sp);
title('Layer 5');
ylabel('');

print('-dpng' ,sprintf('~/Desktop/time_act_freq_%3.2f.png', freq_thresh));

