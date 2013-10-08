%% makes a movie of behavior correlated with cellular imaging
sess_path = '/data/an148378/session/an148378_2011_09_10_sess.mat';
impath = '/data/an148378/2011_09_10/scanimage/fov_%03d/an148378_2011_09_10_main_%03d.tif';
avi_out_deet = '~/Desktop/an148378_2011_09_10_sample_movie.avi';
avi_out_4p = '~/Desktop/an148378_2011_09_10_4panel.avi';
trials_plotted = [220:230];
fov = 2;

if (~exist('s','var'))
  load (sess_path);
end

if (~exist('im','var'))
  for f=1:4
	  flist = {};
		for t=1:length(trials_plotted)
		  flist{t} = sprintf(impath, f, trials_plotted(t));
		end
	  im{f} = load_image(flist);
	end
end

%% generate the movie
% a) 4 panel
aviobj = avifile(avi_out_4p);
ax = figure_tight;
fig =gcf;
for i=1:size(im{1},3)-12
  for f=1:4
	  axes(ax{f}); cla;
    imshow(mean(im{f}(:,:,i:i+9),3), [0 4000], 'Parent', ax{f}, 'Border', 'tight');
	end

	% axis
	hold on ;
	plot([20 20], [20 20+85], 'w-', 'LineWidth' , 5);


	pause(.01);
  F = getframe(fig);
	aviobj = addframe(aviobj,F);
end
close(fig);
aviobj = close(aviobj);


% b) single FOV with whisker setpoint, touches marked and cells marked
aviobj = avifile(avi_out_deet);

fig = figure('Position',[0 0 1000 600]);
caax = subplot('Position', [0 0 .6 1]);
whax = subplot('Position',[.65 .075 .35 .125]);
contax = subplot('Position',[.65 .225 .35 .08]);
dffax = subplot('Position',[.65 .325 .35 .6]);
vidx = find(ismember(s.derivedDataTSA.trialIndices, trials_plotted));
cvidx = find(ismember(s.caTSA.trialIndices, trials_plotted));
t_zero = s.derivedDataTSA.time(min(vidx));
ct_zero = s.caTSA.time(min(cvidx));
ts = s.derivedDataTSA.getTimeSeriesByIdStr('Whisker setpoint');
proTimes = s.whiskerBarContactClassifiedESA.esa{3}.getStartTimes();
proTrials = s.whiskerBarContactClassifiedESA.esa{3}.getStartTrials();
retTimes = s.whiskerBarContactClassifiedESA.esa{4}.getStartTimes();
retTrials = s.whiskerBarContactClassifiedESA.esa{4}.getStartTrials();
allT = unique([retTrials proTrials]);
for t=1:length(allT)
  ri = find(retTrials == allT(t));
	pidx = find(proTrials == allT(t));

	if (length(pidx) > 0 & length(ri) > 0)
	  if (length(pidx) > length(ri))
		  retTimes(ri) = nan;
		else
		  proTimes(pidx) = nan;
		end
	end
end
proTimes = proTimes(find(~isnan(proTimes)));
retTimes = retTimes(find(~isnan(retTimes)));

dcell = [1023 1146 1103 1154 1001 1379 1176];
dcellcolors = [1 0 0 ; 1 0 0 ; 1 0 0 ; 1 0 0 ; 1  0 1 ; 0 1 1 ; 0 1 1];

cellcen = zeros(2,length(dcell));
for c=1:length(dcell)
  ci = find(s.caTSA.roiArray{fov}.roiIds == dcell(c));
  X = mean(s.caTSA.roiArray{fov}.rois{ci}.corners(1,:));
  Y = mean(s.caTSA.roiArray{fov}.rois{ci}.corners(2,:));
	cellcen(:,c) = [X Y];
	cellts{c} = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(dcell(c));
end

% sort by X
[irr plotOrder] = sort(cellcen(2,:), 'descend');

for i=1:size(im{fov},3)-10
	axes(caax);
	cla;
  imshow(mean(im{fov}(:,:,i:i+9),3), [0 4000], 'Parent', caax, 'Border', 'tight');
  hold on;
  
  % circle cells
	for c=1:size(cellcen,2)
	  rectangle('Position', [cellcen(1,c)-15 cellcen(2,c)-15 30 30], 'Curvature', [ 1 1 ], 'LineWidth' , 2 , 'EdgeColor' , dcellcolors(c,:));
	end

	% axis
	plot([20 20], [20 20+85], 'w-', 'LineWidth' , 5);
	
  % whisking
	axes(whax);
	plot((ts.time(vidx(1:i+9))-t_zero)/1000, ts.value(vidx(1:i+9)), 'r-', 'LineWidth', 2);
	axis([0 (ts.time(vidx(end))-t_zero)/1000 -30 60]);
	xlabel('Time (s)');
	ylabel('Whisker Angle (deg)');
	set(gca,'TickDir', 'out');

  % contacts
  axes(contax);
	cla;
	hold on;
	axis([0 (ts.time(vidx(end))-t_zero)/1000 0 2]);
  procon = find(proTimes > t_zero & proTimes < ts.time(vidx(i+9)));
	for c=1:length(procon)
	  et = proTimes(procon(c)) - t_zero;
		plot([et et]/1000, [0 1], 'Color', [0 1 1], 'LineWidth', 2);
	end
  retcon = find(retTimes > t_zero & retTimes < ts.time(vidx(i+9)));
	for c=1:length(retcon)
	  et = retTimes(retcon(c)) - t_zero;
		plot([et et]/1000, [1 2], 'Color', [1 0 1], 'LineWidth', 2);
	end
	axis([0 (ts.time(vidx(end))-t_zero)/1000 0 2]);
	set(gca, 'XTick',[],'YTick',[]);
	ylabel('Contacts');

  % cell dff
	axes(dffax);
	cla;
	hold on;
	for c=1:length(plotOrder)
	  cts = cellts{plotOrder(c)};
	  plot((cts.time(cvidx(1:i+9))-ct_zero)/1000, (5*c-5)+cts.value(cvidx(1:i+9)), '-', 'LineWidth', 2, 'Color', dcellcolors(plotOrder(c),:));
	end
	axis([0 (cts.time(cvidx(end))-ct_zero)/1000 -1 35]);
	ylabel('$\Delta F/F$', 'Interpreter', 'latex');
	set(gca, 'XTick',[]);
  
	pause(.01);
  F = getframe(fig);
	aviobj = addframe(aviobj,F);
end
close(fig);
aviobj = close(aviobj);



