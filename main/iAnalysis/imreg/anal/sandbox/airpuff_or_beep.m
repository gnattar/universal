% testing detection of airpuff v beep
[dataMat timeMat idxMat plotTimeVec] = s.whiskerAngleTSA.getTimeSeriesById(1).getValuesAroundEvents(s.behavESA.getEventSeriesByIdStr('Punishment Preans'), [-.01 .02], session.timeSeries.second, 0, [],[]);
[dataMat timeMat idxMat plotTimeVec] = s.whiskerAngleTSA.getTimeSeriesById(1).getValuesAroundEvents(s.behavESA.getEventSeriesByIdStr('Punishment Sample'), [-.01 .02], session.timeSeries.second, 0, [],[]);

mid = find(plotTimeVec == 0);


% classify initially: look for big deflection in first ~10 ms
punClass = [];
punClass(size(dataMat,1)) = 0;
for i=1:size(dataMat,1)
  dVec = diff(dataMat(i,:));
  dVecV(i) = min(dVec);
	if (min(dVec(mid:end)) < -3)
		disp('PUFF');
		punClass(i) = 1; 
	else
		disp('BEEP');
		punClass(i) = 0;
	end
end

% median filter ...
punClass = round(nanmedfilt1(punClass,5)); 
