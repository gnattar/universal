% 
% S Peron Feb 2010
%
% Temporal correlation based cell detection -- computes df/f for each pixel,
%  then starts with the first pixel and computes correlation with all others.
%  pixels that correlate above threshold are grouped with this pixel.  The
%  algorithm then moves to the next pixel that is not in a group or has not
%  been tested and does so for the whole image.
%
%  params(1).value - the image stack
%  params(2).value - 2 element vector specifying frame range for f_0
%  params(3).value - the threshold for correaltion
%  params(4).value - 2 element vector with min and max number of pixels that must be in a group
%  params(5).value - distance from border to exclude (0 disables)
%  params(6).value - what to correlate against:
%                    1 - last pixel in group currently considered
%                    2 - mean of pixels in group as it grows
%                    3 - seed pixel
%  params(7).value - signal ; 1 = raw fluo, 2 = df/f
%
% returns structure 'members', each of which has a vector, 'indices', specifying
%  index-based (in im) membership.
%
function members = celldet_tempcorr1(params)
  % --- assignables
	stack = params(1).value;
  base_frames = params(2).value;
	thresh = params(3).value;
	group_size = params(4).value;
	border_omit = params(5).value;
	corr_meth = params(6).value;
	signal_src = params(7).value;
   
  % --- prelims
	S = size(stack);
  if (length(S) < 3) ; disp('celldet_tempcorr1::Only works on movies.'); return ; end

  % --- first compute df/f, setting pixels omitted from registration to mean (OR just use raw fluo - 
	%     depends on signal_src
	mu = mean(stack,3);
  for t=1:S(3) % this removes registration-induced zeros
	  tim = stack(:,:,t);
	  zs = find(tim == 0);
		tim(zs) = mu(zs);
		stack(:,:,t) = tim;
	end
	if (signal_src == 2)
		f_0 = mean(stack(:,:,base_frames(1):base_frames(2)),3);
		df = diff(stack,1,3);
		dff = df;
		for f=1:S(3)-1
			dff(:,:,f) = (df(:,:,f)-f_0)./f_0;
		end
		signal = dff;
	else
		signal = stack;
	end
  
  % --- and the heart-of-the matter
	done = zeros(S(1),S(2));
	M = 1;
	members(1).indices = [];

  wb = waitbar(0, 'Detecting ROIs via temporal correlation ...');

  % go pixel-by-pixel
  for i1=1:S(1)
    waitbar(i1/S(1), wb, 'Detecting ROIs via temporal correlation ...');
	  for i2=1:S(2)
		  if (done(i1,i2)) ; continue ;end % skip done ones
%disp([num2str((i1-1)*S(2) + i2) ' of ' num2str(S(1)*S(2))]);
			% the df/f vector for this guy
		  v1 = reshape(signal(i1, i2,:),[],1);

			% first pass: add neighbors that have not been surveyed yet
			tin = [];
			if (i1 > 1 && done(i1-1,i2) == 0) ; tin = [tin ; i1-1 i2]; end
			if (i1 < S(1) && done(i1+1,i2) == 0) ; tin = [tin ; i1+1 i2]; end
			if (i2 > 1 && done(i1,i2-1) == 0) ; tin = [tin ; i1 i2-1]; end
			if (i2 < S(2) && done(i1,i2+1) == 0) ; tin = [tin ; i1 i2+1]; end
			lt = size(tin,1); 

			% now the while loop ... start at the end of tin (neighbor index list) and eat away
			while (lt > 1)
				% vector for last tin-specified coordinates
			  v2 = reshape(signal(tin(lt,1), tin(lt,2),:),[],1);
%				if (lt > 1)
%			    v1 = reshape(signal(tin(lt-1,1), tin(lt-1,2),:),[],1);
%				end

        % compute correlation 
				R = corrcoef(v1,v2);
	%plot(1:length(v1),v1, 'r-', 1:length(v2),v2,'k-') ; title(['r: ' num2str(R(1,2)) ' th: ' num2str(thresh)]);pause
	 
	      % trim it off but keep it in case you meet threshold criteria
        lr = tin(lt,:);
			  tin = tin(1:lt-1,:);

				% if high enough, add it to the members, check it as done, and grow tin to 
				%  accomodate neighbors of the newly added point
				if (R(1,2) > thresh)
					lin_idx = (lr(2)-1)*S(1) + lr(1);
					members(M).indices = [members(M).indices lin_idx];
					done(lr(1), lr(2)) = 1; % note it as done
				  tin = add_to_tin(lr, done, S, tin); % expand tin to neighbors of addded point
%disp(['  D: ' num2str(length(find(done == 1)))]);
          if (corr_meth == 2)
						v1 = v1 + v2;
					elseif (corr_meth == 1)
					  v1 = v2;
					end
        end

        % determine your size ..
				lt = size(tin,1);
%disp(['  st: ' num2str(size(tin,1))]);
			end

			% increment to next members only if you made a new one and it meets group size criteria, border distance criteria
			if (length(members(M).indices) > 0)		
				% compute min, max x; min, max y for border enforcement
				Y = members(M).indices-S(1)*floor(members(M).indices/S(1));
				X = ceil(members(M).indices/S(1));  

			  % group size criteria:
			  if (length(members(M).indices) < group_size(1) | length(members(M).indices) > group_size(2))
%disp(['size: ' num2str(length(members(M).indices))]);
				  members(M).indices = [];
				% border criteria fail:
				elseif ( (min(X) < border_omit) | (min(Y) < border_omit) | ...
						 (max(X) > S(2)-border_omit) | (max(Y) > S(1)-border_omit) )% border enforcement . . . are you an iLLLEGAL ALIEN!?!?!?
          members(M).indices = [];
        else
%disp([num2str(M) ' DINGDINGDING***size: ' num2str(length(members(M).indices))]);
					M = M +1;
					members(M).indices = [];
				end
			end
		end
	end
  
  close(wb);

	% If the last group is empty cut it
  if (length(members(M).indices) == 0 & M > 1)
	  members = members(1:M-1);
	end

%
% Expands your indexing matrix to neighbors of accepted point
%
function tin = add_to_tin(idx, done, S, tin)
  i1 = idx(1);
	i2 = idx(2);
	if (i1 > 1 && done(i1-1,i2) == 0) ; tin = [tin ; i1-1 i2]; end
	if (i1 < S(1) && done(i1+1,i2) == 0) ; tin = [tin ; i1+1 i2]; end
	if (i2 > 1 && done(i1,i2-1) == 0) ; tin = [tin ; i1 i2-1]; end
	if (i2 < S(2) && done(i1,i2+1) == 0) ; tin = [tin ; i1 i2+1]; end

	tin = unique(tin,'rows'); % remove duplicates
