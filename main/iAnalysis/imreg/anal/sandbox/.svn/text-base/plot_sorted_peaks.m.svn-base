% plots each cell's mean response relative all others, temporally sorted by peak
function plot_sorted_peaks (cellmat, freq, freq_thresh, ax)
	ntp = size(cellmat,2);

	% determine time & size of the dff peak
	[peakvalvec peakidxvec] = max(cellmat,[],2);

	% now sort by peak dff TIME for each cell, applying threshold
	%valid = find(peakvalvec > 0.25); % dff > .25
	valid = 1:length(freq);
	valid = find(freq > freq_thresh); % same cell population as previously -- 0.05 Hz

	valpeakidxvec = peakidxvec(valid);
	valcells = cellmat(valid,:);

	[irr sidx] = sort(valpeakidxvec);
	svalcells = valcells(sidx,:);

	% normalize?
	M = .5;
	if (1)
		for i=1:size(svalcells,1)
			svalcells(i,:) = svalcells(i,:)./max(svalcells(i,:));
		end
		M = 1;
	end

	% pole times
	dt = 143; % you know this MAN
	poleidx = round([1200 3200]/dt);

	% plot
	if (nargin < 4) 
  	figure('Position',[0 0 400 900]);
		ax = axes;
	end
	imagesc(svalcells, 'Parent', ax, [0 1]);

	hold on ; 
	plot(valpeakidxvec(sidx), 1:length(valpeakidxvec), 'k-', 'LineWidth',3)
	plot(poleidx(1)*[1 1], [1 length(valpeakidxvec)], '-', 'Color', [.5 .5 .5]);
	plot(poleidx(2)*[1 1], [1 length(valpeakidxvec)], '-', 'Color', [.5 .5 .5]);

	set(gca,'TickDir','out');

	% label time appropriately
	frameRate = 7; % 6.996 but close enuff
	tickPoints = 0:frameRate:ntp;
	for t=1:length(tickPoints)
		tickLabel{t} = num2str(tickPoints(t)/frameRate);
	end
	set(gca, 'XTick', tickPoints, 'XTickLabel', tickLabel);
	ylabel('Cell #');
	xlabel('Time (s)');
