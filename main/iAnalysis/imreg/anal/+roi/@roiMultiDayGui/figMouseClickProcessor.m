%
% SP Apr 2011
%
% For processing mouse clicks on the main figure ; processes natively then calls
%  roiArrays keystroke processor.
%
% USAGE:
%
%   Don't call this.  Seriously.
%
function figMouseClickProcessor(src, event, obj)
  % --- pull out the current object
  rA = obj.roiArrayArray{obj.rAidx};

	% --- do internal stuff [nothing now ...]

	% --- and pass to roiArrayArray.guiMouseClickProcessor
  rA.guiMouseClickProcessor(src, event);


