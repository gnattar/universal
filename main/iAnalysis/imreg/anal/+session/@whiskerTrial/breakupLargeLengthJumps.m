%
% SP Sept 2010
%
% This will break whisker trajectories at places where a whisker's length
%  changes suddenly (by a specified fractional amount).
%
% USAGE
%
%  obj.breakupLargeLengthJumps()
%
function obj = breakupLargeLengthJumps(obj)
  fractionalLengthChangeMaximum = 0.1;

%obj.messageLevel = 2;
%global dlv;
%dlv = nan*zeros(1,1000000);dlvi = 1;
  % --- prelims
	if (length(find(diff(obj.frames) < 0)) > 0) ; disp('breakupLargeLengthJumps::cannot have descending obj.frames.'); return ; end
	if (obj.messageLevel >= 1) ; disp(['breakupLargeLengthJumps::processing ' obj.basePathName]); end

  % --- remove whisker duplicates ...
  obj.removeWhiskerIdDuplicates();

	% --- detect large changes 
	breakEndFrames = [];
	breakIds = [];
  newId = max(obj.whiskerIds)+1;
	for F=2:length(obj.frames) % loop thru ALL frames but then test if bad ...
	  % grab frame
    ft = obj.frames(F);
    fp = obj.frames(F-1);

    % find whiskers in both this and previous frame ...
    ftpmi = find(obj.positionMatrix(:,1) == ft);
    fppmi = find(obj.positionMatrix(:,1) == fp);

		twi = obj.positionMatrix(ftpmi,2);
		pwi = obj.positionMatrix(fppmi,2);

		consideredIds = unique(intersect(twi,pwi));
		consideredIds = consideredIds(find(consideredIds > 0));

    % loop through the whiskers consdiered
		for c=1:length(consideredIds)
		  twl = obj.getWhiskerLength(consideredIds(c),ft);
		  pwl = obj.getWhiskerLength(consideredIds(c),fp);
 
      % fractional change is defined as (a-b)/min(a,b)
			fracDL = abs(twl-pwl)/min(pwl,twl);
%dlv(dlvi) = fracDL ; dlvi = dlvi+1;
%disp(['frame: ' num2str(obj.frames(F)) ' id: ' num2str(consideredIds(c)) ' fracDL: ' num2str(fracDL)]);
			% breakup if needbe
			if (fracDL > fractionalLengthChangeMaximum)
				obj.breakupIdSegment (ft, consideredIds(c), newId);
				newId = newId+1;
			end
		end
	end

  % --- Update things that need updating and give some messages
	obj.refreshWhiskerIds();
	obj.updateFramesPresent();
