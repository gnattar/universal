f=figure('Position',[0 0 800 800]);
sp1 = subplot('Position',[0.25 0.5 0.5 0.5]);
sp2 = subplot('Position',[0.075 0.075 0.9 .4]);

% draw used cells
used_cells = [1023 1178 1001 1199 1299 1360 1240 1020 1060 1146];
cols = [0 0 0 ; hsv(length(used_cells))];
colvec = zeros(1,length(s.caTSA.ids));
for u=1:length(used_cells) ; colvec(find(s.caTSA.ids == used_cells(u))) = u ; end
s.plotColorRois('custom', [],[],cols,colvec, [0 length(used_cells)], sp1, 0, 2);

% draw dff for them
axes(sp2); 
hold on;
trials_used = [20:30];
valIdx = find(ismember(s.caTSA.trialIndices, trials_used));
for u=1:length(used_cells)
  ts = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(used_cells(u));
	plot((ts.time(valIdx)-min(ts.time(valIdx)))/1000, ...
	   ts.value(valIdx) + 5*(u-1), 'Color', cols(u+1,:));
end
set(gca,'TickDir','out');
xlabel('time (s)');
ylabel('dF/F');
