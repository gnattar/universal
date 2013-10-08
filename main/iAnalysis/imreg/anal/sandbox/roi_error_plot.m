% For plotting the roi_error over days, Z

%%% Plot the error across days ...
multiday_path = '~/data/an38596/roi/multiday_roi_corr.mat';

% first, error across days
load (multiday_path);

% pull date stamps
for t=1:length(names)
  day(t) = datenum(strrep(names{t}(1:10), '_', '/'));
end
day = day-min(day)+19;

% plot
figure;
hold on;
plot_error_poly (day, mean(corrMat,1), std(corrMat,1), [1 0 0], [.8 .6 .6]);
plot(day, mean(corrMat,1), 'Color', [1 0 0], 'LineWidth', 2);

axis([min(day)-1 max(day)+1 0 1]);
ylabel('normalized cross-correlation (mu +/- SD)');
xlabel('day since injection');
set (gca, 'TickDir', 'out');

%%% Plot the error across z
z_path = '~/data/an38596/roi/z_roi_corr.mat';

% first, error across days
load (z_path);

% plot
figure;
hold on;
zvals = 1:size(corrMat,2);
zvals = zvals-18;
plot_error_poly (zvals, mean(corrMat,1), std(corrMat,1), [0 0 1], [.6 .6 .8]);
plot(zvals, mean(corrMat,1), 'Color', [0 0 1], 'LineWidth', 2);

axis([min(zvals)-1 max(zvals)+1 0 1]);
ylabel('normalized cross-correlation (mu +/- SD)');
xlabel('z (um)');
set (gca, 'TickDir', 'out');

%%% plot multiday shifts ...
roi_path = '~/data/an38596/roi/';
main_day = '2010_02_20_cell_20100220_093_based.mat';
day1 = '2010_02_02_cell_20100220_093_based.mat';
day2 = '2010_02_25_cell_20100220_093_based.mat';

load([roi_path main_day]);
rA = obj;
rA.colorByBaseScheme(1);
load([roi_path day1]);
rB = obj;
rB.colorByBaseScheme(1);
load([roi_path day2]);
rC = obj;
rC.colorByBaseScheme(1);

% plot
figure;
sb = subplot('Position', [0.01 0.2 0.3 0.3]);
sc = subplot('Position', [0.67 0.2 0.3 0.3]);

rA.plotInterdayTransform(rB, [nan sb]);
title('');
rA.plotInterdayTransform(rC, [nan sc]);
title('');

subplot('Position', [0.33 0.2 0.3 0.3]);
rA.plotImage(1,0,0);

% plot raw images
subplot('Position', [0.01 0.6 0.3 0.3]);
rB.plotImage(0,0,0);
title('Day R-18');
subplot('Position', [0.33 0.6 0.3 0.3]);
rA.plotImage(0,0,0);
title('Day R');
subplot('Position', [0.67 0.6 0.3 0.3]);
rC.plotImage(0,0,0);
title('Day R+5');

