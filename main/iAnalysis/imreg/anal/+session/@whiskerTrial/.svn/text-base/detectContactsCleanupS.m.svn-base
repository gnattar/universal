%
% This cleans up a contact vector (of 1s and 0s) filling in nan's and so on.
%
% Pass it a contact matrix, with one column per whisker, where the matrix is 1
% during a contact and 0 during non-contact.  Returns the same matrix but 
% cleaned up.
%  
% Performs cleanup in 3 ways:
%
%   1) blocks of nan in the kappas variable (you could pass angle or any other
%      whisker variable for that matter) are filled in as contacts if both ends
%      of the nan block are flanked by contact
%   2) if non-contact period is <= fillSkipSize, contacts flanking it merge
%   3) if contact period is < minTouchDuration, it is removed
%
% USAGE:
%
%   whiskerContacts = session.whiskerTrial.detectContactsCleanupS(whiskerContacts, kappas, fillSkipSize, minTouchDuration)
%
% PARAMS:
%
%   whiskerContacts: matrix with one column per whisker where 1 means contact
%                    0 means not
%   kappas: same length as numebr of rows in whiskerContact ; usually kappas 
%           but basically used to find where nan values are
%   fillSkipSize: if a whisker contact is broken for this long a period, it 
%                 is filled in
%   minTouchDuration: if touches are too short, shorter than this, they are axed
% 
% (C) 2012 Mar S Peron
% 
function whiskerContacts = detectContactsCleanupS (whiskerContacts, kappas, fillSkipSize, minTouchDuration)

  %% --- prelims
  if (size(whiskerContacts,2) > size(whiskerContacts,1)) 
    warning('detectContactsCleanupS::your whikserContacts matrix looks to be misoriented ; transposing it.');
    whiskerContacts = whiskerContacts';
  end
  if (size(kappas,2) > size(kappas,1)) 
    kappas = kappas';
  end
  numWhiskers = size(whiskerContacts,2);
  numFrames = size(whiskerContacts,1);
 
  for w=1:numWhiskers
		%% 1) --- find blocks where kappas were nan (disappearing whisker)
		nanIdx = find(isnan(kappas(:,w)));
		dni = diff(nanIdx);
		blockStart = [];
		blockEnd = [];
		if (length(nanIdx) > 1)
			blockStart = [nanIdx(1) nanIdx(1+find(dni>1))'];
			blockEnd = [nanIdx(find(dni>1))' nanIdx(end)];
		elseif(length(nanIdx) == 1)
		  blockStart = nanIdx;
			blockEnd = nanIdx;
		end

		% loop thru blocks
		for b=1:length(blockStart)
		  % ambiguous -- start or end
			if (blockStart(b) == 1 | blockEnd(b) == numFrames)
			  whiskerContacts(blockStart(b):blockEnd(b),w) = 0;
			elseif (whiskerContacts(blockStart(b)-1,w) ==0 | whiskerContacts(blockEnd(b)+1,w) == 0)% also ambiguous -- different flank
			  whiskerContacts(blockStart(b):blockEnd(b),w) = 0;
			else % both flanks are contacts? count it
			  whiskerContacts(blockStart(b):blockEnd(b),w) = 1;
			end
		end
		
		%% 2)  --- look for blocks of fillSkipSize or larger that have flanking contacts & fill
		noContactIdx = find(whiskerContacts(:,w) == 0);
		dci = diff(noContactIdx);
		blockStart = [];
		blockEnd = [];
		if (length(noContactIdx) > 2)
			blockStart = [noContactIdx(1) noContactIdx(1+find(dci>1))'];
			blockEnd = [find(dci>1)' noContactIdx(end)];
		end

		% loop thru blocks
		for b=1:length(blockStart)
			if (blockEnd(b)-blockStart(b) <= fillSkipSize & blockStart(b) > 1 & blockEnd(b) < numFrames) % not @ end and right size
			  if (whiskerContacts(blockStart(b)-1,w) ==1 & whiskerContacts(blockEnd(b)+1,w) == 1) % flanked by contacts 
			    whiskerContacts(blockStart(b):blockEnd(b),w) = 1; % fill it
				end
			end
		end
	
		%% 3) --- look for blocks of contact of minTouchDuration-1 or shorter and nuke em
   	contactIdx = find(whiskerContacts(:,w) == 1);
		dci = diff(contactIdx);
		blockStart = [];
		blockEnd = [];
		if (length(contactIdx) > 2)
			blockStart = [contactIdx(1) contactIdx(1+find(dci>1))'];
			blockEnd = [contactIdx(find(dci>1))' contactIdx(end)];
		end

		% loop thru blocks
		for b=1:length(blockStart)
			if (blockEnd(b)-blockStart(b)+1 < minTouchDuration & blockStart(b) > 1 & blockEnd(b) < numFrames) % not @ end and right size
		    whiskerContacts(blockStart(b):blockEnd(b),w) = 0; % nuke
			end
		end

	end
