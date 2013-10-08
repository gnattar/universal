function lm_2012_04_27_gather_peaks

  if (1)

		% 1,2 : L1 
		load('an160508_vol_01_sess');
		[cellmat_L1 freq_L1 freq_pre_L1 freq_pole_L1 ids_L1] = gather_subset(s,[0 1999]);
		save('L1_cellmat.mat', 'cellmat_L1','freq_L1', 'freq_pre_L1', 'freq_pole_L1', 'ids_L1');

		% 3-18: L2/3
		vids = 1:6;
		cellmat_L23 = [];
		freq_L23 = [];
		freq_pre_L23 = [];
		freq_pole_L23 = [];
		ids_L23 = [];
		for i=1:length(vids)
			load(sprintf('an160508_vol_%02d_sess', vids(i)));
			[cellmat freq freq_pre freq_pole ids] = gather_subset(s,[2000 18999]);

			cellmat_L23 = [cellmat_L23 ; cellmat];
			freq_L23 = [freq_L23 freq];
			freq_pre_L23 = [freq_pre_L23 freq_pre];
			freq_pole_L23 = [freq_pole_L23 freq_pole];
			ids_L23 = [ids_L23 ids];
		end
		save('L23_cellmat.mat', 'cellmat_L23','freq_L23', 'freq_pre_L23', 'freq_pole_L23', 'ids_L23');

		% 29-33: L5 
		vids = 10:11;
		cellmat_L5 = [];
		freq_L5 = [];
		freq_pre_L5 = [];
		freq_pole_L5 = [];
		ids_L5 = [];
		for i=1:length(vids)
			load(sprintf('an160508_vol_%02d_sess', vids(i)));
			[cellmat freq freq_pre freq_pole ids] = gather_subset(s,[29000 38999]);

			cellmat_L5 = [cellmat_L5 ; cellmat];
			freq_L5 = [freq_L5 freq];
			freq_pre_L5 = [freq_pre_L5 freq_pre];
			freq_pole_L5 = [freq_pole_L5 freq_pole];
			ids_L5 = [ids_L5 ids];
		end
		save('L5_cellmat.mat', 'cellmat_L5','freq_L5', 'freq_pre_L5', 'freq_pole_L5', 'ids_L5');
	end

	% Layer 4
	if (0)
	  load ('an166558_2012_04_23_sess.mat');
		[cellmat_L4 freq_L4 freq_pre_L4 freq_pole_L4 ids_L4] = gather_subset(s,[0 5000]);
		save('L4_cellmat.mat', 'cellmat_L4','freq_L4', 'freq_pre_L4', 'freq_pole_L4', 'ids_L4');

    cd (strrep(pwd,'an166558','an166555'));
	  load ('an166555_2012_04_23_sess.mat');
		[cellmat_L4 freq_L4 freq_pre_L4 freq_pole_L4 ids_L4] = gather_subset(s,[0 5000]);
		save('L4_cellmat.mat', 'cellmat_L4','freq_L4', 'freq_pre_L4', 'freq_pole_L4', 'ids_L4');
	end

function [cellmat freq freqPre freqPole valId] = gather_subset (s, idRange)
	ntp = 70;
	uti = unique(s.caTSA.trialIndices);

  valId = s.caTSA.ids(find(s.caTSA.ids >= idRange(1) & s.caTSA.ids <= idRange(2)));
	cellmat= zeros(length(valId),ntp);

	sincellmat = zeros(length(uti),ntp);

	totalTime = length(s.caTSA.time)*mode(diff(s.caTSA.time))/1000; % in seconds
	freq = 0*valId;

  freqPole = 0*valId;
	freqPre = 0*valId;

  
	inReachIdx = 0*s.caTSA.time;
	startToPoleOutIdx = 0*s.caTSA.time;
	prePoleIdx = 0*s.caTSA.time;
	for t=1:length(uti)
	  ti = find(s.caTSA.trialIndices == uti(t));
    bari = find(s.whiskerBarInReachES.eventTrials == uti(t));
		if (length(bari) == 2 & length(ti) > 1)
		  si = ti(min(find(s.caTSA.time(ti) > s.whiskerBarInReachES.eventTimes(bari(1)))));
		  ei = ti(min(find(s.caTSA.time(ti) > s.whiskerBarInReachES.eventTimes(bari(2)))));
      inReachIdx(si:ei) = 1;
      
      startToPoleOutIdx(min(ti):ei) = 1;
      prePoleIdx(min(ti):si) = 1;
		end
  end
	totalTimePre = length(find(prePoleIdx))*mode(diff(s.caTSA.time))/1000; % in seconds
	totalTimePole = length(find(inReachIdx))*mode(diff(s.caTSA.time))/1000; % in seconds
	
  for c=1:length(valId)
		cid = valId(c);
    cidx = find(s.caTSA.ids == cid);
		vec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
		freq(c) = length(s.caTSA.caPeakEventSeriesArray.esa{c})/totalTime;
    
    % event count for epochs ...
    freqPole(c) = length(find(inReachIdx.*s.caTSA.caPeakTimeSeriesArray.valueMatrix(cidx,:)> 0))/totalTimePole;
    freqPre(c) = length(find(prePoleIdx.*s.caTSA.caPeakTimeSeriesArray.valueMatrix(cidx,:)> 0))/totalTimePre;

		% compile data for single cell
		sincellmat = 0*sincellmat;
		for t=1:length(uti)
			ti = find(s.caTSA.trialIndices == uti(t));
			sincellmat(t,1:min(length(ti),ntp)) = vec(ti(1:min(length(ti),ntp)));
		end
		cellmat(c,:) = nanmean(sincellmat,1);
	end

