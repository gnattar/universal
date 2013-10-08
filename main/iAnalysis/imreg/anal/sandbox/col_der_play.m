% for generating derived data on collumn data
function col_der_play(obj)

	% 1) generate a baseTSA that is a merge of all caTSA times ...
	tiVec = [];
	for c=1:length(obj.caTSAArray.caTSA)
    tiVec = [tiVec obj.caTSAArray.caTSA{c}.time];
	end
	tiVec = sort(tiVec);

	trVec = 0*tiVec;
	vVec = 0*tiVec;
  
  % and now make a trial vec
	for c=1:length(obj.caTSAArray.caTSA)
	  idxVec = find(ismember(tiVec,obj.caTSAArray.caTSA{c}.time));
		trVec(idxVec) = obj.caTSAArray.caTSA{c}.trialIndices;
	end

  % and a baseTS
	baseTS = session.timeSeries(tiVec, obj.caTSAArray.caTSA{1}.timeUnit, ...
	  vVec, 1, 'temp TS', 0, []);

	% TSA
	baseTSA = session.timeSeriesArray({baseTS}, trVec);

  % 2) run derive
	dParams.baseTSA = baseTSA;
	obj.generateDerivedDataStructures(dParams);
 
	% 3) save
	obj.saveToFile();
