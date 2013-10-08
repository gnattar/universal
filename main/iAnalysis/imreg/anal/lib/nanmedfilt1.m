%
% 1-d median filter that ignores NaNs for median but "includes" them in window
%  size
%
% Works by building a matrix with as many columns as the input vector and as
%  many rows as the window, then taking nanmedian along each column.
%
% USAGE:
%
%   mfv = nanmedfilt1(v, windowSize)
%
% PARAMS:
%
%   v: input vector
%   windowSize: how big of a window, centered on a datapoint, to use?
%               For edges, pads with nans.  Note that it will be rounded UP
%               to nearest ODD number.
%
function mfv = nanmedfilt1 (v,windowSize)
  mfv = [];
	sizeLimit = 1000000000; % 1 billion elements

  % --- input checks
	% min inputs
  if (nargin < 2)
	  help ('nanmedfilt1');
		return; 
	end

	% windowSize odd
	if (rem(windowSize,2) == 0 ) ; windowSize = windowSize+1; end

	% enforce size limit
	if (length(v)*windowSize > sizeLimit)
	  disp(['nanmedfilt1::size limit of ' num2str(sizeLimit) ' exceeded; do median filtering in chunks.']);
  end

  % --- build matrix (ends are implicitly padded)
	L = length(v);
	M = nan*zeros(windowSize,L);
	ws = (windowSize-1)/2;
  for w=1:windowSize
	  offs = (ws-w)+1;
   
	  mi1 = max(1,1+offs);
	  mi2 = min(L,L+offs);

	  vi1 = max(1,1-offs);
	  vi2 = min(L,L-offs);

    M(w,mi1:mi2) = v(vi1:vi2);
	end

	% --- compute median 
	mfv = nanmedian(M);
   

