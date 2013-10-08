%
% SP 2010 Dec
%
% This function opens a single ephus file and reads in the data as ephusFile 
%  structure.  REturns -1 on fail or a structure.
%
% USAGE:
% 
%  ephusFile = session.session.getEphusFile(ephFname, channelId)
%
%   ephFname - full path for file for load
%   channelId - optional parameter that is either # of channel you want or
%               string ID
% 
%  returns:
%
%   ephusFile.fileCreateTime: when file was created [not terribly useful]
%   ephusFile.timeUnitId: unit for above
%   ephusFile.channel(*).sourceFile: name of source file
%   ephusFile.channel(c).values: values for channel c
%   ephusFile.channel(c).time: time vector
%   ephusFile.channel(c).startTime: relative trial -- 0
%   ephusFile.channel(c).channelNum: for searchability
%   ephusFile.channel(c).channelName: xsg.data.acquirer.channelName_c, where 
%     c is the channel number
%
function ephusFile = getEphusFile(ephFname, channelId)
  d2ms = 24*60*60*1000; % date number from MATLAB to ms conversion factor
	ephusFile = [];

	if (nargin == 1) ; channelId = [] ; end

  % --- prelims // sanity cheX
  if (~ exist(ephFname,'file'))
	  disp(['getEphusFile::' ephFname ' not a valid xsg file; aborting (1).']);
		ephusFile = -1;
	else
		% --- header/singleton info
		try % try block since some of these fail ocassionaly due to write problems
			xsg = load(ephFname, '-mat');
			% trial start
			ephusFile.fileCreateTime = d2ms*datenum(xsg.header.xsgFileCreationTimestamp);
			% other stuff
			samRate = xsg.header.acquirer.acquirer.sampleRate;
        %dh change
        %nchans = size(struct2cell(xsg.data.acquirer),1)/3;
        
        fn=fieldnames(xsg.data.acquirer); 
        cn=find(cellfun(@(x) ~isempty(x), (strfind(fieldnames(xsg.data.acquirer), 'channelName_')))); %find where channnel name are  
        nchans = length(cn);
        c_nums=cell2mat(cellfun(@(x) str2num(x(end)), fn(cn),'UniformOutput', false));
        
		catch
		  ephusFile = -1;
			disp(['getEphusFile::' ephFname ' not a valid xsg file; aborting (2).']);
			return;
		end

		% --- channel digestion
		ephusFile.timeUnitId = 1; % ms

    % loop dem chans
		c = 1;
		for C=1:nchans
        % dh change
        chanName = eval(['xsg.data.acquirer.channelName_' num2str(c_nums(C))]);

      % channel ID skip?
		  if (length(channelId) > 0 )
			  if (isnumeric(channelId))
				  if (C ~= channelId) ; continue ;end
				else
				  if (~strcmp(channelId,chanName)) ; continue ;end
				end
			end

			dt = 1000/samRate; % in ms

      % populate
		  ephusFile.channel(c).sourcefile{1} = ephFname;
        %dh change
        ephusFile.channel(c).values = eval(['xsg.data.acquirer.trace_' num2str(c_nums(C))]);
		  ephusFile.channel(c).startTime = 0; % ASSUME it starts at start of trial
			ephusFile.channel(c).dt = dt;
			ephusFile.channel(c).time = (dt)*(0:length(ephusFile.channel(c).values)-1);
			ephusFile.channel(c).channelNum = C;
			ephusFile.channel(c).channelName = chanName;
			c = c + 1;
    end

		% xsg.header.acquirer.acquirer.channels -- size of this tells you how many channels
		% xsg.header.acquirer.acquirer.channels(n).channelName -- self explan
		% xsg.header.acquirer.acquirer.sampleRate -- in Hz ; want your time vectors in ms
		% xsg.data.acquirer.trace_n -- trace for channel n
		% xsg.data.acquirer.channelName_n -- channel n name
	end 

