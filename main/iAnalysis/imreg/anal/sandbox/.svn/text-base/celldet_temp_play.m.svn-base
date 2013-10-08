%% assumes im is given.

S = size(im);
S12 = S(1)*S(2);

% offset vector added to indices
vv = 0:(S(1)*S(2)):(S(1)*S(2)*(S(3)-1));

% --- simple correlation between two points test loop
if (0)
ri = 23;
rii = 1;

i1 = s.caTSA.roiArray{2}.rois{ri}.indices(rii) + vv;

corrmat = zeros(S(1),S(2));
cmi =1;
for i=1:S(1)*S(2)
  i2 = i+vv;
  corrmat(i) = corr(im(i1)',im(i2)');
  disp([num2str(i) '/' num2str(S(1)*S(2))]);
end
end
% --- end of test loop


% === build of initial label set
%%% starting at 1st nonedge pixel, build up labeled sets
labmat = zeros(S(1),S(2));
curlab = 1; % label seed
corrthresh = .5;
%% algo: test adjacent pixels for correlation ; 
%%       if no one exceeds thresh label -1
%%       proceed until all are labeled


% at every step, these are tested 
adj_idx_offs = [1 (S(1)-1):(S(1)+1)];

% remove border
exclude_idx = [1:S(1) S(1):S(1):S12 1:S(1):(S12-S(1)) (S12-S(1)):S12];
labmat(exclude_idx) = -1;
idx = min(find(labmat == 0));
while (length(idx) > 0)
  % compute adjacent dudes
  adj_idx = idx + adj_idx_offs;
  
	% exclude anyone that is not 0 -- excluded
	adj_idx = adj_idx(find(labmat(adj_idx) ~= -1));

	if (~isempty(adj_idx))
	  % test all candidates 
		ii = idx + vv;
		valcorrs = 0*adj_idx;
    for a=1:length(adj_idx)
		  ia = adj_idx(a) + vv;
			corria = corr(im(ia)',im(ii)');

			if (corria > corrthresh)
			  valcorrs(a)  =1;
			end
		end

		% any valid correlations?
		if (sum(valcorrs)  > 0)
		  grpidx = [idx adj_idx(find(valcorrs))];

			% are any of the guys already in a group? join groups
			already_idx = find(labmat(grpidx) > 0);
			if (length(already_idx) > 0)
			  ulab = unique(labmat(already_idx));
				nlab = min(ulab);
				for l=1:length(ulab)
				  lidx = find(labmat == ulab(l));
					labmat(lidx) = nlab;
				end
				labmat(idx) = nlab;
			else
			  labmat(grpidx) = curlab;
				curlab = curlab+1;
			end
		end
	end

  % if you are still labeled 0 at this point, don't pass go
  if (labmat(idx) == 0)
	  labmat(idx) = -1;
	end

	% take whoever is left ...
  candi = find(labmat == 0);
  idx = min(candi);
	disp([num2str(length(candi)) ' / ' num2str(S12) ' lab: ' num2str(curlab)]);
end


% === now join groups that are correlated ...
% currently does it off of correlation threshold for groups
% ADD: distance too (Allowing for lower corr)

grcorrthresh = .2;
flabmat = labmat;
ulab = unique(flabmat(find(flabmat > 0)));

% build up individual vectors
datmat = zeros(length(ulab), length(vv));
for u=1:length(ulab)
  idx = find(flabmat == ulab(u));
	midx = (repmat(vv,length(idx),1) + repmat(idx,1,size(vv,2)));
	datmat(u,:) = nanmean(im(midx));
end

% compute correlations
tic;cmat = corr(datmat');toc

% and now build up groups ...
for u1=1:length(ulab)
  idx1 = find(flabmat == ulab(u1));
	if (length(idx1) > 0)
		for u2=2:length(ulab)
			if (cmat(u1,u2) > grcorrthresh)
				flabmat(find(flabmat == ulab(u2))) = ulab(u1);
			end
		end
	end
	disp([num2str(u1) ' / ' num2str(length(ulab))]);
end

% === and exclude groups < some size
mingrpsize = 20;
ulab = unique(flabmat);
for u=1:length(ulab)
  if (length(find(flabmat == ulab(u))) < mingrpsize)
	  flabmat (find(flabmat == ulab(u))) = 0;
	end
end


% === relabel 1:# groups
ulab = unique(flabmat);
fflabmat = flabmat*0;
for u=1:length(ulab)
  fflabmat(find(flabmat == ulab(u))) = u;
end

