%
% SP Apr 2011
%
% For processing keystrokes on the main figure ; processes natively then calls
%  roiArrays keystroke processor.
%
% USAGE:
%
%   Don't call this.  Seriously.
%
function figKeyPressProcessor(src, event, obj)

  % --- pull out the current object
  rA = obj.roiArrayArray{obj.rAidx};

	% --- do internal stuff
	key = double(event.Character);
	if (length(key) == 0) ; key = -1 ; end
	switch key
    case {60,122}  % < : prev
			rAidx = obj.rAidx - 1;
			if (rAidx < 1 ) ; rAidx =  length(obj.roiArrayArray) ; end
			obj.setRAIdx(rAidx); 


    case {62,99}  % > : next
			rAidx = obj.rAidx + 1;
%%% TEMP %%%%
			if (rAidx > length(obj.roiArrayArray)) 
			  rA = obj.roiArrayArray{rAidx-1};
				pm = get(obj.roiArrayFigH,'Position');
				pz = get(obj.zoomFigH,'Position');
				pd = get(obj.crossDayFigH,'Position');
				% next roi
				if (length(rA.guiSelectedRoiIds == 1))
					idx = find(rA.roiIds == rA.guiSelectedRoiIds);
					idx = idx + 1;
					if (idx > length(rA.roiIds)) ; idx = 1; end
					rA.guiSelectedRoiIds = rA.roiIds(idx);

					disp(['Moving to next: ' num2str(rA.guiSelectedRoiIds)]);

					% fig wipe!
					close(obj.roiArrayFigH);
					close(obj.zoomFigH);
					close(obj.crossDayFigH);

				end
				% run sheet
				if (rAidx > length(obj.roiArrayArray)) ; rAidx = 1 ; end
				obj.setRAIdx(rAidx); 

				% reposition
				set(obj.roiArrayFigH,'Position',pm);
				set(obj.zoomFigH,'Position',pz);
				set(obj.crossDayFigH,'Position',pd);
				figure(obj.roiArrayFigH);
			else
%%% TEMP %%%%
				if (rAidx > length(obj.roiArrayArray)) ; rAidx = 1 ; end
				obj.setRAIdx(rAidx); 
			end

    otherwise
			% --- and pass to roiArrayArray.guiKeyStrokeProcessor
			rA.guiKeyStrokeProcessor(src, event);
	end

