function bitCodeTrialNums = getBitCodes(syncedData)
  % --- definitions
  debug = 0; % set to 1 to see some stufs
	nBits = 12; % how many bits? usually 10 but just in case
	bcDt = 7.2e-3; % in ms, time between bits -- this is FIXED and depends on your bitcode output

% 	bitCodeTrialNums = nan*ones(1,length(ephusFile));

%   % --- what is the bitcode channel? -- assume same across all datasets
% 	bcIdx = -1;
%   for c=1:length(ephusFile(1).channel)
% 	  if (strcmp(ephusFile(1).channel(c).channelName, 'bitcode'))
% 		  bcIdx = c;
%       disp('generateEphusTimeSeriesArray.getBitCodes::found bitCode channel.');
% 			break;
% 		end
% 	end
%   if (bcIdx == -1) ; disp('generateEphusTimeSeriesArray.getBitCodes::did not find bitcode channel ; cannot align ephus-behavior'); end

	% --- loop thru trials; find rising edges and store their times
	vTRise = [];
	for f=1:size(syncedData,2)
        if ~isempty(syncedData(f).solo_trial)
% 	  bcTs = ephusFile(f).channel(bcIdx).values;
     bcTs = syncedData(f).bitcode;
     dt = syncedData(f).wsTimeScale;
% 		tvec = (1:length(bcTs))*ephusFile(f).channel(bcIdx).dt - ephusFile(f).channel(bcIdx).dt; % time vector
		tvec = (1:length(bcTs))*dt - dt; % time vector

		% find time points of rising edges
		bcTs = bcTs - min(bcTs);
    dbcTs = diff(bcTs);
		dThresh = max(dbcTs)/2;
		tRise = tvec(find(dbcTs > dThresh));
    
		% aggregate vector  ; store for final processing
    vTRise = [vTRise tRise];
		tmpTrial(f).tRise = tRise;
        end
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
	tWin = bcDt/2; % considered 'up' if within bcStarts +/- tWin

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
         if ~isempty(syncedData(f))
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
	end
