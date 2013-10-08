%
% load everything ...
%
base_dir = '~/Desktop/forKarel/';
dffOpts = []; 
evDetOpts = [];
dffOpts.subtractMethod = 1;
evdetOpts.evdetMethod = 3;
cellIndices = [42 17 6 19 61 58 38];

% ephus/scim.behav
if ( 0 == 1)
	load([base_dir '2010_02_02.mat']);s.caTSA.updateEvents(evdetOpts,dffOpts);
	s_pre = s;
	load([base_dir '2010_02_08.mat']);s.caTSA.updateEvents(evdetOpts,dffOpts);
	s_easy = s;
	load([base_dir '2010_02_18.mat']);s.caTSA.updateEvents(evdetOpts,dffOpts);
	s_hard = s;
	load([base_dir '2010_02_25.mat']);s.caTSA.updateEvents(evdetOpts,dffOpts);
	s_rev = s;
	load([base_dir '2010_03_01.mat']);s.caTSA.updateEvents(evdetOpts,dffOpts);
	s_trim = s;
end

% whisker data
if ( 0 == 1)
  wDir = '~/Desktop/38596w/';
	wTypesPlotted = [10 11 12];
	wTrialTypeColor = [1 0 1; 0 1 0; 0 1 0]; 

	load ([wDir '2010_02_02bc.mat']);
	W = load([wDir '2010_02_02.txt']);
  s_pre_wTrialsPlotted = [];
	for t=1:length(W(:,1))
	  tIdx = find(s_pre.trialIds == bitCodes(W(t,1)));
		if (length(tIdx) > 0)
			s_pre_wTrialsPlotted = [s_pre_wTrialsPlotted tIdx];
			s_pre.trial{tIdx}.typeIds = [s_pre.trial{tIdx}.typeIds W(t,2)+10];
		end
	end

	load ([wDir '2010_02_08bc.mat']);
	W = load([wDir '2010_02_08.txt']);
  s_easy_wTrialsPlotted = [];
	for t=1:length(W(:,1))
	  tIdx = find(s_easy.trialIds == bitCodes(W(t,1)));
		if (length(tIdx) > 0)
			s_easy_wTrialsPlotted = [s_easy_wTrialsPlotted tIdx];
			s_easy.trial{tIdx}.typeIds = [s_easy.trial{tIdx}.typeIds W(t,2)+10];
		end
	end

	load ([wDir '2010_02_18bc.mat']);
	W = load([wDir '2010_02_18.txt']);
  s_hard_wTrialsPlotted = [];
	for t=1:length(W(:,1))
	  tIdx = find(s_hard.trialIds == bitCodes(W(t,1)));
		if (length(tIdx) > 0)
			s_hard_wTrialsPlotted = [s_hard_wTrialsPlotted tIdx];
			s_hard.trial{tIdx}.typeIds = [s_hard.trial{tIdx}.typeIds W(t,2)+10];
		end
	end

	load ([wDir '2010_02_25bc.mat']);
	W = load([wDir '2010_02_25.txt']);
  s_rev_wTrialsPlotted = [];
	for t=1:length(W(:,1))
	  tIdx = find(s_rev.trialIds == bitCodes(W(t,1)));
		if (length(tIdx) > 0)
			s_rev_wTrialsPlotted = [s_rev_wTrialsPlotted tIdx];
			s_rev.trial{tIdx}.typeIds = [s_rev.trial{tIdx}.typeIds W(t,2)+10];
		end
	end
 
  % for trimmed data just set to no contact for all trials
  s_trim_wTrialsPlotted = s_trim.trialIds;
	for t=1:length(s_trim.trial)
		s_trim.trial{t}.typeIds = [s_trim.trial{t}.typeIds 10];
	end  
end

% PLOT whisker-style [10: no contact 11: contact on protraction 12: contact on retraction]
%	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
%	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
%	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
%	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
%	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)

% roi plot
f = figure;
s_pre.caTSA.roiArray.colorByBaseScheme(1);
s_pre.caTSA.roiArray.aspectRatio = [.8 1.6];
s_pre.caTSA.roiArray.plotImage(1, 0, 0);
saveas(f,[base_dir '/rois.fig']);


% plot 1: "default" + protract/retract
wTypesPlotted = [10 11 12];
wTrialTypeColor = [1 0 1; 0 1 0; 0 0 1]; 
for c=1:length(cellIndices)
  cellIdx = cellIndices(c);
  cf = figure('Position', [10 10 700 1000], 'Color', 'w');

	subplot(5,2,1);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices)
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial');
	set (gca, 'FontSize', 14);
	xlabel(''); title([{'H (bl) CR (red) FA (gr) miss(blk)', 'untrained'}]);
	ylabel('dF/F');

	subplot(5,2,3);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial');
	set (gca, 'FontSize', 14);
	xlabel(''); title(['cell ' num2str(cellIdx) 'easy']);
	ylabel('dF/F');

	subplot(5,2,5);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial');
	set (gca, 'FontSize', 14);
	xlabel(''); title(['hard']);
	ylabel('dF/F');

	subplot(5,2,7);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial');
	set (gca, 'FontSize', 14);
	xlabel(''); title(['reverse']);
	ylabel('dF/F');

	subplot(5,2,9);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial');
	set (gca, 'FontSize', 14);
	title(['trimmed']);
	xlabel('time (s)');
	ylabel('dF/F');

	subplot(5,2,2);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, wTypesPlotted, wTrialTypeColor);
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel(''); title([{'notouch (mag) pro (gr) retract(b)', 'untrained'}]);  ylabel('dF/F');

	subplot(5,2,4);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['easy']);

	subplot(5,2,6);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['hard']);

	subplot(5,2,8);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['reverse']);

	subplot(5,2,10);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel('time (s)'); ylabel('dF/F'); title(['trimmed']);
	saveas(cf,[base_dir '/cell_' num2str(cellIdx) '_reg_prore.fig']);
end


% plot 2: contact/nocontact [g/mag] + lick/nolick [bl{H,FA}/red{Miss,CR}]

w0TypesPlotted = [10 11 12];
w0TrialTypeColor = [1 0 1; 0 1 0; 0 1 0]; 
wTypesPlotted = [1 3 2 4];
wTrialTypeColor = [1 0 0; 1 0 0; 0 0 1; 0 0 1]; 
for c=1:length(cellIndices)
  cellIdx = cellIndices(c);
  cf = figure('Position', [10 10 700 1000], 'Color', 'w');

	subplot(5,2,1);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor);
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel(''); title([{'contact (g) no contact (mag)', 'untrained'}]); ylabel('dF/F');

	subplot(5,2,3);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); 
	xlabel(''); title(['cell ' num2str(cellIdx) 'easy']);

	subplot(5,2,5);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['hard']);

	subplot(5,2,7);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['reverse']);

	subplot(5,2,9);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel('time (s)'); ylabel('dF/F'); title(['trim']);

	subplot(5,2,2);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, wTypesPlotted, wTrialTypeColor);
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel(''); title([{'lick (bl) no lick (r)', 'untrained'}]); ylabel('dF/F');

	subplot(5,2,4);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['easy']);

	subplot(5,2,6);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['hard']);

	subplot(5,2,8);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['reverse']);

	subplot(5,2,10);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel('time (s)'); ylabel('dF/F'); title(['trim']);

	saveas(cf,[base_dir '/cell_' num2str(cellIdx) '_contact_lick.fig']);
end

% plot 3: punished/not + reward/not

wTypesPlotted = [1 2 3 4];
wTrialTypeColor = [0 0 1; 0 0 0; 0 0 0 ; 0 0 0 ]; 
w0TypesPlotted = [3 1 2 4];
w0TrialTypeColor = [0 1 0; 0 0 0; 0 0 0; 0 0 0]; 
for c=1:length(cellIndices)
  cellIdx = cellIndices(c);
  cf = figure('Position', [10 10 700 1000], 'Color', 'w');

	subplot(5,2,1);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor);
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel(''); title([{'airpuff (grn) none (blk)', 'untrained'}]); ylabel('dF/F');

	subplot(5,2,3);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); 
	xlabel(''); title(['cell ' num2str(cellIdx) 'easy']);

	subplot(5,2,5);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['hard']);

	subplot(5,2,7);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['reverse']);

	subplot(5,2,9);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, w0TypesPlotted, w0TrialTypeColor)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel('time (s)'); ylabel('dF/F'); title(['trim']);

	subplot(5,2,2);
	s_pre.plotByTrialType(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_pre.caTSA.trialIndices, s_pre_wTrialsPlotted, wTypesPlotted, wTrialTypeColor);
	M = 1 ; if (max(s_pre.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel(''); title([{'reward (bl) none (blk)', 'untrained'}]); ylabel('dF/F');

	subplot(5,2,4);
	s_easy.plotByTrialType(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_easy.caTSA.trialIndices, s_easy_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_easy.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['easy']);

	subplot(5,2,6);
	s_hard.plotByTrialType(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_hard.caTSA.trialIndices, s_hard_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_hard.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['hard']);

	subplot(5,2,8);
	s_rev.plotByTrialType(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_rev.caTSA.trialIndices, s_rev_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_rev.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	ylabel('dF/F'); xlabel(''); title(['reverse']);

	subplot(5,2,10);
	s_trim.plotByTrialType(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}, s_trim.caTSA.trialIndices, s_trim_wTrialsPlotted, wTypesPlotted, wTrialTypeColor)
	M = 1 ; if (max(s_trim.caTSA.dffTimeSeriesArray.tsa{cellIdx}.value) > 1) ; M = 2 ; end
	axis([0 10 -0.2 M]);
	set (gca,'TickDir','out', 'FontName', 'Arial', 'FontSize', 14);
	xlabel('time (s)'); ylabel('dF/F'); title(['trim']);

	saveas(cf,[base_dir '/cell_' num2str(cellIdx) '_reward_puff.fig']);
end


