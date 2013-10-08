%
% playing with previewing summary
%


% histo
figure;
idx = find(wta.whiskerBarInReachTS.value);
hist(wta.whiskerDistanceToBarTSA.valueMatrix(idx),0:.1:500);
a = axis;
axis([0 40 0 a(4)]);

% distance to bar eval
dt = 20;
tvec = wta.whiskerAngleTSA.time;
figure;
axes;
set(gcf,'Position', [5 100 3800 1000]);
set(gca,'Position', [0.025 0.05 .975 .95]);

for t=1:dt:wta.numTrials;
  idx = find(wta.fileIndices >= t & wta.fileIndices < t+dt);
  cla;
	hold on;
	plot(tvec(idx),wta.whiskerDistanceToBarTSA.valueMatrix(idx), 'b-');
	plot(tvec(idx),wta.whiskerBarInReachTS.value(idx)*10, 'k-');
  wta.whiskerBarContactESA.esa{1}.plot([1 0 0], [0 5]);
  axis([tvec(idx(1)) tvec(idx(end)) 0 50]); 
	for tt=t:dt+t
		iidx = find(wta.fileIndices == tt);
		text(tvec(iidx(round(length(iidx)/3))), 20, num2str(tt), 'FontSize', 14, 'FontWeight' ,'bold' , 'Color' , 'r')
	end
	pause;
end
	


