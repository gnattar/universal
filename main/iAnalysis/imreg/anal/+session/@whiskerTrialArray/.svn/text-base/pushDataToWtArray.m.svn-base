%
% This will push relevant whiskerTrialArray variables into whiskerTrial objects.
%
% To facilitate review of calculations, this pushes the following variables into
%  the wtArray whiskerTrial objedts:
%    
%    barCenterTSA
%    barRadius
%    whiskerBarContactESA
%    whiskerBarInReachES
%
% You can 'undo' by calling compileArrayDataFromTrials().
%
% USAGE:
%
%   wta.pushDataToWtArray()
%
function obj = pushDataToWtArray(obj)

  %% --- main loop
	disp('pushDataToWtArray::updating ...');
	for t=1:obj.numTrials
	  disp([8 '.']);
	  idx = find(obj.fileIndices == t);
		tvec = obj.time(idx);
  
    % non-whisker variables
		obj.wtArray{t}.barCenter = obj.barCenterTSA.valueMatrix(:,idx)';
		obj.wtArray{t}.barRadius = obj.wtArray{t}.barRadius*0 + obj.barRadius;
		obj.wtArray{t}.barInReach = obj.whiskerBarInReachTS.value(idx);

	  % whisker dependents
		for w=1:obj.numWhiskers
		  sc = strcmp (obj.whiskerTags{w}, obj.wtArray{t}.whiskerTag);

		  if (sum(sc) == 1) % if this is not true somethin is weirdxx
				wi = find(sc);

				% pull contacts
				wcesa = obj.whiskerBarContactESA.esa{w};
			  cidx = find(ismember(wcesa.eventTrials, t));
 
        % populate whiskerContacts matrix
				obj.wtArray{t}.whiskerContacts = zeros(obj.wtArray{t}.numFrames, obj.wtArray{t}.numWhiskers);
				if (length(cidx) > 0)
					eframes = find(ismember(tvec, wcesa.eventTimes(cidx)));
					if (length(eframes) > 0)
					  if (mod(length(eframes),2) ~= 0)
						  disp('pushDataToWtArray::something is wrong -- contacts should have start and end.');
						end
						for e=1:2:length(eframes)-1;
    					obj.wtArray{t}.whiskerContacts(eframes(e):eframes(e+1),wi) = 1;
						end
					end
				end
			end
		end
	end
