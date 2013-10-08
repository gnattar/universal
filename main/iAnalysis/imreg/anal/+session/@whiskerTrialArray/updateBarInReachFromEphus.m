%
% Reads in ephus file with pole-in-reach info and updates barInReach with it.
%
% This first loads the ephus files with the pole_position variable that contains
%  voltage of the photodiode indicating if pole is/is not in reach for animal.
%  The ephus data is stored in barVoltageTS, with time alignment consisting of
%  aligning start time with some offset.  Then, for each trial, voltage 
%  distribution is used to infer when the bar was in reach for that trial. 
%  whiskerBarInReachTS and ES are updated.  Specifically, it looks at specific
%  quantiles of the voltage distro to determine the in and out of reach 
%  positions.
%
%  Note that you must have exactly one ephus file for every trial of whisker
%  data, and their order must be the same.   Also, note that the algorithm 
%  assumes that the bar is out of reach most of the time.
% 
% USAGE:
%
%  wta.updateBarInReachFromEphus(ephusFilePath, ephusFileWC, params)
%
% ARGUMENTS:
%
%   ephusFilePath: where ephus files reside; if cell array, treated as file list
%                  and WC ignored
%   ephusFileWC: leave blank and it is *xsg
%   params: structure with following (optional) fields:
%     whiskerEphusOffsetMs: if positive (default is 100), ephus starts this many 
%                           milliseconds prior to whisker
%     individualTrial: if 1, (dflt 0), it will process each trial individually
%     fracInReach: default 1; otherwise, it will count as in reach at some other
%                  fraction of total trajectory
%     forceEphusReload: default is 0, which means that if barVoltageTS is 
%                       populated, no loading from ephus files.
%     barCenterCorrection: if 0, no correction ; if 1, uses bar center that
%                          is corrected (see code for specifics)
%
% (C) S Peron Mar 2012
%
function obj = updateBarInReachFromEphus(obj,ephusFilePath, ephusFileWC, params) 

  %% --- input processing
	if (nargin < 2)
	  help('session.whiskerTrialArray.updateBarInReachFromEphus');
	  error('Must at least give ephusFilePath');
	end
 
  % default params
  whiskerEphusOffsetMs = 100; 
	individualTrial = 0;
	fracInReach = 1;
  forceEphusReload = 0;
  barCenterCorrection = 0;

  % params 
  if (nargin >= 4 && isstruct(params))
	  pfields = fieldnames(params);
	  for p=1:length(pfields)
		  eval([pfields{p} ' = params.' pfields{p} ';']);
		end
	end
 
	% file list
	if (~iscell(ephusFilePath) && nargin < 3) ; ephusFileWC = '*xsg'; end
	if (iscell(ephusFilePath))
	  flist = ephusFilePath;
	else
	  fl = dir([ephusFilePath filesep ephusFileWC]);
		for f=1:length(fl)
		  flist{f} = [ephusFilePath filesep fl(f).name];
		end
	end

	% mismatch between ephus trial # and here ...
	if (length(flist) ~= obj.numTrials) 
	  disp('updateBarInReachFromEphus::mismatch between ephus and whisker data.  This could be a serious problem,');
		disp(' but for now will be handled by using file numbers and aligning, replacing missing ephus trials with');
		disp(' temporally proximal available ones.');

	  % compile file #s from wtArray, ephus
		whNum = zeros(1,obj.numTrials);
	  for t=1:obj.numTrials
		  [irr whName] = fileparts(obj.wtArray{t}.matFilePath);
			undIdx = find(whName == '_');
      whNum(t) = str2num(whName(undIdx(end-1)+1:undIdx(end)-1));
		end

		ephNum = zeros(1,length(flist));
		for f=1:length(flist)
		  dotXsgIdx = strfind(flist{f}, '.xsg');
		  ephNum(f) = str2num(flist{f}(dotXsgIdx-4:dotXsgIdx-1));
		end
		% align, and create new flist ...
		nflist = {};
		for t=1:obj.numTrials
		  % match? use it
			idx = find(ephNum == whNum(t));

      if (length(idx) == 0) % no match? use closest
			  dist = abs(ephNum - whNum(t));
        [irr idx] = min(dist);
			end

			% nflist
			nflist{t} = flist{idx};
		end
		flist = nflist;
	end


  %% --- load ephus data from file 
	if (isobject(obj.barVoltageTS) && length(obj.barVoltageTS.value) == length(obj.fileIndices))
	  if (forceEphusReload)  
      loadEphusData (obj, flist, whiskerEphusOffsetMs);
		else
		  disp('updateBarInReachFromEphus::barVoltageTS already present ; skipping reload.');
		end
	else
    loadEphusData (obj, flist, whiskerEphusOffsetMs);
	end

	%% --- re-compute bar in reach within whiskerTrial ...
	nBir = 0*obj.fileIndices;
	if (individualTrial)
		for f=1:length(unique(obj.fileIndices))
			disp(['updateBarInReachFromEphus::processing trial ' num2str(f)]);
			fIdx = find(obj.fileIndices == f);

      nBir (fIdx) = computeBarInReach (obj.barVoltageTS.value(fIdx), fracInReach);
	  end
	else % all at once ..
	  nBir = computeBarInReach(obj.barVoltageTS.value, fracInReach);
  end

 	%% --- redo whiskerBarInReach
  timeVec = obj.time;
  trialIndices = obj.trialIndices;
  if (size(timeVec,1) ~= 1) ; timeVec = timeVec' ; end
  if (size(trialIndices,1) ~= 1) ; trialIndices = trialIndices' ; end

	% bar in reach
	dbir = diff(nBir);
  sbti = find(dbir == 1);
  ebti = find(dbir == -1);
	birTimes = sort(timeVec([sbti ebti]));
	birTrials = sort(trialIndices([sbti ebti]));

	obj.whiskerBarInReachES = session.eventSeries(birTimes, birTrials, obj.timeUnit, 1, ...
				['Bar-in-reach times'], 0, '', [], [0.5 0.5 0.5], 2);
  obj.whiskerBarInReachTS = session.timeSeries(timeVec, obj.timeUnit, nBir, 1, 'Bar In Reach', 0, []);

 	%% --- apply bar-center correction if requested
	if (barCenterCorrection == 1)
    % loop thru trials
		for t=1:obj.numTrials
		  ti = find(obj.fileIndices == t);

		  % get first value of bar-in-reach
			birti = find(obj.whiskerBarInReachTS.value(ti) > 0);
      b1 = min(birti);
			initBarCenter = obj.barCenterTSA.valueMatrix(:,ti(b1));

      % apply this value throughout this trial
			obj.barCenterTSA.valueMatrix(:,ti(birti)) = repmat(initBarCenter,1,length(birti));
		end
	end


function barInReach = computeBarInReach (valueVec, fractionInReach)
  % get top two peaks in histogram -- these are your in/out of range poitns
	[count values] = hist(valueVec,10);
	dbin = abs(values(2)-values(1));

  % quick check that this was not messed up
	rangeMinMax = range(valueVec);
	[sortedCount idx] = sort(count, 'descend');
	dPeaks = values(idx(1))-values(idx(2));

	% assign off histo
	offset = max(dPeaks*(1-fractionInReach),dbin);
	if (dPeaks > 0)
		outReachPos = find(valueVec > values(idx(1))-dbin & valueVec < values(idx(1))+dbin);
		inReachPos = find(valueVec > values(idx(2))-dbin & valueVec < values(idx(2))+offset);
  else
		outReachPos = find(valueVec > values(idx(1))-dbin & valueVec < values(idx(1))+dbin);
		inReachPos = find(valueVec > values(idx(2))-offset & valueVec < values(idx(2))+dbin);
	end

  % generate output -- assumes bar is in reach LESS than out of reach
	barInReach = 0*valueVec;
	barInReach(inReachPos) = 1; 


function loadEphusData (obj, flist, whiskerEphusOffsetMs)
	allPoleVm = nan*obj.fileIndices;
  for f=1:length(flist)
		disp(['updateBarInReachFromEphus::processing ' flist{f}]);
    
    % load ephus file ; check its integrity
		e = session.session.getEphusFile(flist{f}, 'pole_position');
    if (~isfield(e, 'channel'))
			disp(['updateBarInReachFromEphus::field channel not present - something is amiss.  Skipping.']);
	    continue;
		end
     
    % pull data
		eTime = e.channel(1).time;
		poleVm = e.channel(1).values;
		poleVm = medfilt1(poleVm, 20/e.channel(1).dt); % 20 ms median filter - pole vm is quite noisy

		% resample ephus data to the density of whisker data
		wIdx = find(obj.fileIndices == f);
    wTime = obj.time(wIdx);
		wTime = wTime - min(wTime) + whiskerEphusOffsetMs; % align to ephus time trac, which starts at zero, while this should start at whisker video offset time

		% find matching times
		nPoleVm = zeros(1,length(wTime));
		for e=1:length(wTime)
		  idx = min(find(eTime > wTime(e)));
		  nPoleVm(e) = poleVm(idx(1));
		end

		% clean up start -- first 100 ms
		sidx = find(wTime < 100+whiskerEphusOffsetMs);
		nidx = find(wTime > 100+whiskerEphusOffsetMs & wTime < 200+whiskerEphusOffsetMs);
		nPoleVm(sidx) = median(nPoleVm(nidx));

    % finalize and pump into allPoleValues 
		nPoleVm = abs(nPoleVm - min(nPoleVm)); % make it positive
		nPoleVm = nPoleVm/max(nPoleVm); % [0 1]
		allPoleVm(wIdx) = nPoleVm;
	end

 	%% --- generate the TS object
  obj.barVoltageTS =  session.timeSeries(obj.time, obj.timeUnit, ...
	  allPoleVm, 1, ['Ephus pole_position trace'], 0, []);
