%
% After id 5, assigns random colors.  Id 0 is given black.  
%  1-5 are RGB mag cyan.  Rest is based on scramble of colormap jet.
%
function obj = assignRandomColors(obj)
	nColors = length(obj.whiskerIds);
	cm = jet(nColors); % use jet as basis

	obj.whiskerColors = cm(randperm(size(cm,1)),:); % Scramble it

	% assign the first few non-random
	widx = find(obj.whiskerIds == 0) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [0 0 0]; end
	widx = find(obj.whiskerIds == 1) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [1 0 0]; end
	widx = find(obj.whiskerIds == 2) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [0 1 0]; end
	widx = find(obj.whiskerIds == 3) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [0 0 1]; end
	widx = find(obj.whiskerIds == 4) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [1 0 1]; end
	widx = find(obj.whiskerIds == 5) ; if (length(widx) > 0) ; obj.whiskerColors(widx,:) = [0 1 1]; end
