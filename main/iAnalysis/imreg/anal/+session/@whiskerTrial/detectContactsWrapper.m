%
% SP Nov 2010
%
% This will detect contacts, using a three step proces.
%
% 1) Intial estimates: look for places that are 'on' the pole (within
%    poleEdgeDistanceForceContact), or places at start of a large cumulative
%    curvature change AND a bit less close to pole - this is a contact.
% 2) use pole distance/curvature statistics to establish large kappas during the
%    bar-in-reach phase and count these as contacts
% 3) finally, use distance/curvature to establish NOT touching and reject
%    some false contacts
%
%  For the meat, look at the code.
%
% USAGE:
%  
%   obj.detectContacts()
%
function detectContactsWrapper(obj)
  if (obj.messageLevel >= 1) ; disp(['detectContacts::processing ' obj.basePathName]); end

  % --- set things up
	[barInReach irr] = obj.getFractionCorrectedBarInReach();

  % --- make the call
	detectContactsParams.barRadius = obj.barRadius;
  obj.whiskerContacts = session.whiskerTrial.detectContacts(obj.kappas, ...
	  obj.distanceToBarCenter, barInReach, detectContactsParams);

	% --- populate whiskerBarContactESA
	numContacts = max(obj.whiskerContacts);
	dt = mode(diff(obj.frameTimes));
	for w=1:obj.numWhiskers
	  % gather contact start & end times
		startTimes = [];
		endTimes  =[];
    for c=1:numContacts(w)
		  if (numContacts(w) > 0)
				startTimes(c) = obj.frameTimes(min(find(obj.whiskerContacts(:,w) == c)));
        % add dt since a one-frame contact should have duration dt!
				endTimes(c) = obj.frameTimes(max(find(obj.whiskerContacts(:,w) == c))) + dt; 
			end
		end

    % populate
		allTimes = sort([startTimes endTimes]);
		trials = obj.trialId*ones(1,length(allTimes));
	  esa{w} = session.eventSeries(allTimes, trials, obj.frameTimeUnit, w, ...
		  ['Contacts for ' num2str(w)], 0, '', obj.matFilePath, [1 0 0], 2);
	end
  obj.whiskerBarContactESA = session.eventSeriesArray(esa);

