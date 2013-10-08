%
% SP Feb 2011
%
% Given a matrix in which each row is a sample from a timeSeries, this will
%  take some kind of measurement for each row, returning a vector whose length
%  is the same as the number of rows.
%  
% USAGE:
%
%	valueVec = getSingleValuePerRowFromMatrix(valueType, valueMat)
%
%  valueVec: averaged responses
%
%  valueType: most are self-explanatory, and take the non-nan measure of values:
%             'mean', 'meanabs', 'median' ,'max', 'min', 'maxabs', 'sum', 'sumabs', 
%             'duration', 'deltameam', 'deltameanabs', 'deltamax', 'deltamaxabs',
%             'deltasum', 'deltasumabs', 'first', 'summax', 'summaxabs',
%             'abssummaxabs'
%  
%             XXXabs uses absolute value. maxabs will compute max on absolute
%               value, but will return NEGATIVE if that has largest absolute value.
%             duration returns total length of non-nan values in units of
%               obj.timeUnit.
%             deltaXXX means that the operation is applied to the diff of the
%               value vector.
%             first takes the VERY FIRST nonnan value found
%             summax sums the maxes of contiguous subsets of the vector 
%               separated by nan values, and summaxabs takes the largest 
%               amplitude for each event (+/-), returning the mean of
%               these.  Finally, abssummaxabs takes the absolute value 
%               across events before taking mean.  
%  valueMat: each row is a a response to which valueType operation will be
%               applied.
%   
function valueVec = getSingleValuePerRowFromMatrix(obj, valueType, valueMat)
	valueVec = [];

	% --- argument parse
	if (nargin < 2) 
	  help session.timeSeries.getSingleValuePerRowFromMatrix;
		return;
	end

	% --- compute returned value ...
	valueVec = nan*ones(1,size(valueMat,1));
	dt = mode(diff(obj.time));
	switch valueType
	  case 'mean' 
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmean(valueMat(r,:));
			end

	  case 'sumabs'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nansum(abs(valueMat(r,:)));
			end

	  case 'sum'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nansum(valueMat(r,:));
			end

	  case 'meanabs'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmean(abs(valueMat(r,:)));
			end

		case 'median'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmedian(valueMat(r,:));
			end

		case 'max'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmax(valueMat(r,:));
			end

		case 'min'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmin(valueMat(r,:));
			end

		case 'maxabs'
		  for r=1:size(valueMat,1);
			  valueVec(r) = nanmax(valueMat(r,:));
        if (abs(nanmin(valueMat(r,:))) > valueVec(r))
				  valueVec(r) = nanmin(valueMat(r,:));
				end
			end

		case 'deltamax'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
				valueVec(r) = nanmax(delta);
			end

		case 'deltamaxabs'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
			  valueVec(r) = nanmax(delta);
        if (abs(nanmin(delta)) > valueVec(r))
				  valueVec(r) = nanmin(delta);
				end
			end

		case 'deltamean'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
				valueVec(r) = nanmean(delta);
			end

		case 'deltameanabs'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
				valueVec(r) = nanmean(abs(delta));
			end

		case 'deltasum'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
				valueVec(r) = nansum(delta);
			end

		case 'deltasumabs'
		  for r=1:size(valueMat,1);
			  delta = diff(valueMat(r,:));
				valueVec(r) = nansum(abs(delta));
			end

		case 'duration'
		  for r=1:size(valueMat,1)
  		  ntp = length(find(~isnan(valueMat(r,:))));
	  		valueVec(r) = ntp*dt;
			end

		case 'first'
		  for r=1:size(valueMat,1)
			  validx = find(~isnan(valueMat(r,:)));
				if (length(validx) ==0)
				  valueVec(r) = nan;
				else
				  valueVec(r) = valueMat(r,min(validx));
				end
			end

		case 'summax' 
		  for r=1:size(valueMat,1)
			  validx = find(~isnan(valueMat(r,:)));
				if (length(validx) == 0)
				  valueVec(r) = nan;
				else
					dvi = diff(validx);
					dvib = find(dvi > 1);
					if (length(dvib) == 0) 
					  valueVec(r) = nanmax(valueMat(r,:)); 
					else 
					  vals(1) = nanmax(valueMat(r,validx(1):validx(dvib(1))));
					  for b=2:length(dvib)
					    vals(b) = nanmax(valueMat(r,validx(dvib(b-1)+1):validx(dvib(b))));
						end
						% last segment?
						if (length(validx) > dvib(b))
						  vals(b+1) = nanmax(valueMat(r,validx(dvib(b)+1):validx(end)));
						end
						% average
						valueVec(r) = sum(vals);
					end
				end
			end

		case 'summaxabs' 
		  for r=1:size(valueMat,1)
			  validx = find(~isnan(valueMat(r,:)));
				vals = [];
				if (length(validx) == 0)
				  valueVec(r) = nan;
				else
					dvi = diff(validx);
					dvib = find(dvi > 1);
					if (length(dvib) == 0) 
					  valueVec(r) = nanmax(valueMat(r,:)); 
					  if(abs(nanmin(valueMat(r,:))) > valueVec(r)) ;  valueVec(r) = nanmin(valueMat(r,:)); end
					else 
					  vec = valueMat(r,validx(1):validx(dvib(1)));
					  vals(1) = nanmax(vec);
						if (abs(nanmin(vec)) > vals(1)); vals(1) = nanmin(vec); end
					  for b=2:length(dvib)
					    vec = valueMat(r,validx(dvib(b-1)+1):validx(dvib(b)));
					    vals(b) = nanmax(vec);
						  if (abs(nanmin(vec)) > vals(b)); vals(b) = nanmin(vec); end
						end
						% last segment?
						if (length(validx) > dvib(b))
						  vec = valueMat(r,validx(dvib(b)+1):validx(end));
						  vals(b+1) = nanmax(vec);
						  if (abs(nanmin(vec)) > vals(b+1)); vals(b+1) = nanmin(vec); end
						end
						% average
						valueVec(r) = sum(vals);
					end
				end
			end

		case 'abssummaxabs' 
		  for r=1:size(valueMat,1)
			  validx = find(~isnan(valueMat(r,:)));
				vals = [];
				if (length(validx) == 0)
				  valueVec(r) = nan;
				else
					dvi = diff(validx);
					dvib = find(dvi > 1);
					if (length(dvib) == 0) 
					  valueVec(r) = nanmax(valueMat(r,:)); 
					  if(abs(nanmin(valueMat(r,:))) > valueVec(r)) ;  valueVec(r) = nanmin(valueMat(r,:)); end
					else 
					  vec = valueMat(r,validx(1):validx(dvib(1)));
					  vals(1) = nanmax(vec);
						if (abs(nanmin(vec)) > vals(1)); vals(1) = nanmin(vec); end
					  for b=2:length(dvib)
					    vec = valueMat(r,validx(dvib(b-1)+1):validx(dvib(b)));
					    vals(b) = nanmax(vec);
						  if (abs(nanmin(vec)) > vals(b)); vals(b) = nanmin(vec); end
						end
						% last segment?
						if (length(validx) > dvib(b))
						  vec = valueMat(r,validx(dvib(b)+1):validx(end));
						  vals(b+1) = nanmax(vec);
						  if (abs(nanmin(vec)) > vals(b+1)); vals(b+1) = nanmin(vec); end
						end
						% average
						valueVec(r) = sum(abs(vals));
					end
				end
			end



		otherwise
		  disp(['getSingleValuePerRowFromMatrix::' valueType ' is not a valid mode.']);
	end


 

