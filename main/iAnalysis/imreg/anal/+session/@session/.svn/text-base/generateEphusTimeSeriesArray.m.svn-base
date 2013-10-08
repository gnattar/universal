%
% SPeron Aug 2010
%
% Will populate calling object's ephus timeseries (ephusTSA).  Note that it
%  will immediately process the bitcode channel, if encountered, using it
%  to determine trial #.
%
% PARAMS:
%
%   ephusFilePAth: directory where xsg files reside
%   ephusFileWC: wildcard to use
%   ephusDownsample: how much to downsample data by (applies to ALL channels)
%
% RETURNS:
% 
%   nothing; populates calling object ephusTSA
%
% FORMAT: 
%
%   s.generateEphusTimeSeriesArray(ephusFilePath, ephusFileWC, ephusDownsample)
% 
function obj = generateEphusTimeSeriesArray(obj, ephusFilePath, ephusFileWC, ephusDownsample)

  % 1) --- prelims
  fList = dir([ephusFilePath filesep ephusFileWC]);
	if (length(fList) == 0)
	  disp(['generateEphusTimeSeriesArray::wildcard specified yield no files: ' ephusFilePath filesep ephusFileWC]);
	end
	N = length(fList);
	if (length(obj.dataSourceParams.ephusDownsample) > 0 && (nargin < 4 | length(ephusDownsample) == 0)) 
	  ephusDownsample = obj.dataSourceParams.ephusDownsample;
	end

  % 2) --- read data
	% go thru each file and grab data
	for f=1:N
		% grab the trigger time string - this is what we reference to
	  ephusFile(f) = session.session.getEphusFile([ephusFilePath filesep fList(f).name]);

		% check if the date on this data matches behavior -- if not, Houston, we
		% have a problem!
    if (f == 1)
      d2ms = 24*60*60*1000;
      if (~strcmp(datestr(datenum(obj.dateStr),'yymmdd'), datestr(datenum(ephusFile(1).fileCreateTime/d2ms),'yymmdd')))
        warning('generateEphusTimeSeriesArray::serious problem detected - ephus data is NOT same day as behavior.  PAUSING.');
        disp('Your best recourse is to go and figure out what is wrong -- probably you');
        disp('need to make sure you have the right behavior file in the right place,');
        disp('or you are using the wrong ephus directory.  In the rare case where you were');
        disp('recording ~midnight, this is off the FIRST file so should not happen.  But if');
        disp('your very first ephus acquisition was after midnight while behavior started before,');
        disp('just comment out the pause after this line in'); 
				disp('session.session.generateEphusTimeSeriesArray.m.');
				disp(['session_id: ' obj.mouseId ' date: ' obj.dateStr ' ephus path: ' ephusFilePath]);
        pause;
      end
    end

		% for timing
		fileCreateTime(f) = ephusFile(f).fileCreateTime;
	end

  % 3) --- bitcodes -- if available -- to reassign trial #
  bitCodeTrialNums = getBitCodes(ephusFile);
	obj.ephusOriginalTrialBitcodes = bitCodeTrialNums;

	% any duplicate bitcodes? (e.g., because behavior was restarted)  warn the user, 
	%  and set all but last instance to nan
	if (length(unique(bitCodeTrialNums)) ~= length(bitCodeTrialNums))
		disp('generateEphusTimeSeriesArray::detected duplicate bitcodes ; multiple behavior sessions?');
	  
		if (isfield(obj.dataSourceParams, 'soloSourceFileIdx')) % this means there were multiple behavior files
      usi = unique(obj.dataSourceParams.soloSourceFileIdx);
      diffBC = diff(bitCodeTrialNums);
      restartIdx = find(diffBC < 0)+1;
      for s=2:length(usi)
        
        % fix bitCodeTrialNums
        sfi = find(obj.dataSourceParams.soloSourceFileIdx == usi(s));
        sfiPre = find(obj.dataSourceParams.soloSourceFileIdx == usi(s-1));
        maxTrialPre = max(obj.trialIds(sfiPre));
        bitCodeTrialNums(restartIdx(s-1):end) = bitCodeTrialNums(restartIdx(s-1):end) + maxTrialPre;
        bitCodeTrialNums(restartIdx(s-1)-1) = 0; % NOPE
        
        % timing ...
        
      end
      
     	obj.ephusOriginalTrialBitcodes = bitCodeTrialNums;
		else % no? then kill dem dupes
			utbc = unique(obj.ephusOriginalTrialBitcodes);
			for b=1:length(utbc)
				bc = utbc(b);
				match = find(obj.ephusOriginalTrialBitcodes == bc);
				discard = setdiff(match,max(match));
				if (length(discard) > 0)
					disp('generateEphusTimeSeriesArray::CRITICAL PROBLEM: duplicated ephus bitcodes.  Will discard all but LAST instance of each bitcode.');
					obj.ephusOriginalTrialBitcodes(discard) = nan;
        end
      end
		end
	end
		
	% 4) --- build TSA object, applying downsample

	% assign start tiem based on behavior, but also on offset for messed up trials
	startTime = nan*bitCodeTrialNums;
	for t=1:length(bitCodeTrialNums)
	  if (~isnan(bitCodeTrialNums(t)))
			ti = find (obj.trialIds == bitCodeTrialNums(t));
			if (length(ti) > 0) % only do matches ...
				startTime(t) = obj.trialStartTimes(ti);
			end
		end
	end

	% remove trials with no start time ...
	val = find(~isnan(startTime));
	if (length(val) ~= length(startTime))
  	disp(['generateEphusTimeSeriesArray::rejecting ' num2str(length(startTime)-length(val)) ' trials due to missing bit code or lack of corresponding behavioral trial.']);
	end

	% create timing vector ...
	startTimesVec = startTime(val); % EVENTUALLY SHOULD BE DATA-SIZED ; aPPLY offset(t) VECTOR-WIDE for TRIAL
	bitCodeTrialNums = bitCodeTrialNums(val);

	% valid ephus trial ids are in terms of behavioral trial #s so bit codes, so this is perfect:
	obj.validEphusTrialIds = bitCodeTrialNums;
	ephusTrialIndices = bitCodeTrialNums;

	% create individual timeseries objects and populate -- downsample 
	timeVec = [];
  haveData = zeros(1,length(ephusFile(1).channel));
	for c=1:length(ephusFile(1).channel)
		% loop thru files and build up this particular channel's value/time
    if (iscell(obj.dataSourceParams.ephusChanIdent) && ...
		    sum(strcmp(ephusFile(1).channel(c).channelName, obj.dataSourceParams.ephusChanIdent)) == 1)
			ntp = 0;
			for ti=val
			  ntp = ntp + length(ephusFile(ti).channel(c).time);
			end
   
	    % value vector presetup then actually setup
	    valueVec = zeros(1,ntp);
			i1 = 1;
		  for ti=val
			  L = length(ephusFile(ti).channel(c).values);
			  valueVec(i1:i1+L-1) = ephusFile(ti).channel(c).values;
				i1 = i1+L;
      end

			% time vector if blank -- i.e., do only on first time
			%  also assigns trial indices for each timepoint
			if (isempty(timeVec))
			  ephusTrialIndices = zeros(1,ntp);
				timeVec = zeros(1,ntp);
				i1 = 1;
			  for i=1:length(val)
				  L = length(ephusFile(val(i)).channel(c).time);
				  timeVec(i1:i1+L-1) = ephusFile(ti).channel(c).time + startTimesVec(i);
				  ephusTrialIndices(i1:i1+L-1) = bitCodeTrialNums(i);
					i1 = i1+L;
        end
			end

			% downsample ...
			if (length(ephusDownsample) > 0)
			  valueVec = valueVec(1:ephusDownsample:end);
				if (length(timeVec) ~= length(valueVec))
  			  ephusTrialIndices = ephusTrialIndices(1:ephusDownsample:end);
					timeVec = timeVec(1:ephusDownsample:end);
				end
			end


			% find first with this
			firstEphIdx = 1;
			while (length(ephusFile(firstEphIdx).channel) < c & firstEphIdx < length(ephusFile)) ; firstEphIdx = firstEphIdx + 1; end

			% generate individual time series
			ts{c} = session.timeSeries(timeVec, 1, valueVec, c, ephusFile(firstEphIdx).channel(c).channelName, 0, [ephusFilePath filesep ephusFileWC]);
      haveData(c) = 1;
  	else
			disp('generateEphusTimeSeriesArray::not assigning data since you did not request any ephus channels saved.');
			values = zeros(size(bitCodeTrialNums));

			% find first with this
			firstEphIdx = 1;
			while (length(ephusFile(firstEphIdx).channel) < c & firstEphIdx < length(ephusFile)) ; firstEphIdx = firstEphIdx + 1; end

			% create the timeseries object -- assumes ephus time is in ms
			ts{c} = session.timeSeries(startTimesVec, 1, values, c, ephusFile(firstEphIdx).channel(c).channelName, 0, [ephusFilePath filesep ephusFileWC]);
		end
  end
  if (sum(haveData) > 0)
    ts = ts(find(haveData));
  end

	% and now create the TSA
	obj.ephusTSA = session.timeSeriesArray(ts, ephusTrialIndices);

	% lick laser?
	obj.generateLicklaserES();


%
% returns a vector corresponding to ephusFile indexing that tells you the 
%  bitcode specified trial# for each file; blank if no bitcode
%
% ephusFile is a set of structure from getEphusFile.
%
function bitCodeTrialNums = getBitCodes(ephusFile)
  % --- definitions
  debug = 0; % set to 1 to see some stufs
	nBits = 12; % how many bits? usually 10 but just in case
	bcDt = 7.2; % in ms, time between bits -- this is FIXED and depends on your bitcode output

	bitCodeTrialNums = nan*ones(1,length(ephusFile));

  % --- what is the bitcode channel? -- assume same across all datasets
	bcIdx = -1;
  for c=1:length(ephusFile(1).channel)
	  if (strcmp(ephusFile(1).channel(c).channelName, 'bitcode'))
		  bcIdx = c;
      disp('generateEphusTimeSeriesArray.getBitCodes::found bitCode channel.');
			break;
		end
	end
  if (bcIdx == -1) ; disp('generateEphusTimeSeriesArray.getBitCodes::did not find bitcode channel ; cannot align ephus-behavior'); end

	% --- loop thru trials; find rising edges and store their times
	vTRise = [];
	for f=1:length(ephusFile)
	  bcTs = ephusFile(f).channel(bcIdx).values;
		tvec = (1:length(bcTs))*ephusFile(f).channel(bcIdx).dt - ephusFile(f).channel(bcIdx).dt; % time vector

		% find time points of rising edges
		bcTs = bcTs - min(bcTs);
    dbcTs = diff(bcTs);
		dThresh = max(dbcTs)/2;
		tRise = tvec(find(dbcTs > dThresh));
    
		% aggregate vector  ; store for final processing
    vTRise = [vTRise tRise];
		tmpTrial(f).tRise = tRise;
	end

	% use histogram of over-threshold time points to determine bit code times - that way, we
	%  are bit-code timing independent (note that mis-recording will still screw you, but
	%  there is no way to get around this since there is no bitcode start code)
	% Assumtption - first bit code time slot is used most (this should be true)
	[n bin_val]  = hist(vTRise, 5000);
	if (debug >= 1)
		figure ; 
		hist(vTRise, 5000);
	end
	binSizeThr = .5*mean(n(find(n>0)));
	t0 = bin_val(min(find(n > binSizeThr))); % this should eventually be *fixed* by always having a signal code
	bcStarts = t0 + (0:nBits-1)*bcDt;
	tWin = bcDt/4; % considered 'up' if within bcStarts +/- tWin

  % plot the histogram for bin size threshold
	if (debug >= 1)
		hold on;
		plot([min(bin_val) max(bin_val)], [1 1]*binSizeThr, 'r-');
		for b=1:length(bcStarts)
			plot([1 1]*bcStarts(b), [0 500], 'm-');
		end
		pause;
	end

	% --- reloop and extract bitcodes, noting trials with *bad* bitcodes
  bcBinary = zeros(nBits, length(tmpTrial));
	eph2beh_idx = -1*ones(length(tmpTrial),1); % the final deposit for indices ; -1 => invalid
	for f=1:length(tmpTrial)
	  ttr = tmpTrial(f).tRise;
		tIdx = 0;
	  for b=1:nBits
		  val = find(ttr > bcStarts(b)-tWin & ttr < bcStarts(b)+tWin);
			% compute trial index by adding 
		  if (length(val) > 0) 
			  bcBinary(b,f) = 1; 
				tIdx = tIdx + 2^(b-1);
			end
		end
		if (tIdx > 0) ; bitCodeTrialNums(f) = tIdx ; end
	end

