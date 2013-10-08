% test forward model on Tsai-Wen's data

% 1) dff should be broken down and single-ROId (or matrix?)

% 2) event detection similar

% [just deprecate the old stuff?]5555a



% ---- ACTIVITY LEVEL:

actParams.cofThresh = 0.25;
actParams.nabThresh = 0.005;
s.caTSA.getRoiActivityStatistics(actParams);

% play:


idx = s.caTSA.roiActivityStatsHash.get('hyperactiveIdx');
th = s.caTSA.roiActivityStatsHash.get('thresh');
nab = s.caTSA.roiActivityStatsHash.get('numAboveCutoff');
cof = s.caTSA.roiActivityStatsHash.get('cutoffToMaxRatio');

if (0)
for i=idx ; close all ; figure('Position',[0 0 800 800]); subplot(2,1,1) ; s.caTSA.getTimeSeriesByIdx(i).plot ; hold on ; a=axis ; plot([a(1) a(2)], th(i)*[1 1], 'm-'); subplot(2,1,2) ; s.caTSA.dffTimeSeriesArray.getTimeSeriesByIdx(i).plot ; title([ 'cof: ' num2str(cof(i)) ' nab: ' num2str(nab(i)) ]); pause ; end

end

% cof sorted
[irr idx] = sort(cof,'descend');
[irr idx] = sort(nab,'descend');

for i=idx ; 
vec = s.caTSA.getTimeSeriesByIdx(i).value;
[f xi] = ksdensity(vec);
[peak_f idx] = max(f);
peak_x = xi(idx);
vec = vec-peak_x;
   

close all ; 
figure('Position',[0 0 1000 1000]);; subplot(2,1,1) ; 
s.caTSA.getTimeSeriesByIdx(i).plot ; 
hold on ; 
a=axis ; 
plot([a(1) a(2)], th(i)*[1 1], 'm-'); 
subplot(2,1,2) ; 
s.caTSA.dffTimeSeriesArray.getTimeSeriesByIdx(i).plot ; 
title([ 'cof: ' num2str(cof(i)) ' nab: ' num2str(nab(i)) ]);hold on ; 
s.caTSA.caPeakTimeSeriesArray.getTimeSeriesByIdx(i).plot([1 0 0]) ; 
pause ; 
end

