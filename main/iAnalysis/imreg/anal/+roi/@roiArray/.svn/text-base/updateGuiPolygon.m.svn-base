%
% S Peron 2010 May
%
% This will draw an x at the most recent addition to gui polygon and a line
%  connecting current to previous point if # points > 1.  This will NOT draw
%  the whole thing, so use only to update.  Draws on current axes.
%
function updateGuiPolygon(obj)
  % --- working image!!
	if (size(obj.workingImage,1) == 0)
	  disp('roiArray.startGui::requires valid workingImage.');
		return;
	end

	% --- need to do this even?
	if (length(obj.guiPolyCorners) > 0)
	  p=size(obj.guiPolyCorners,2);
	  draw_x(obj.guiPolyCorners(1,p), obj.guiPolyCorners(2,p), 1, [1 0 1]);
	  hold on; % draw x turns hold off!!
		if (p > 1)  
		  plot ([obj.guiPolyCorners(1,p-1) obj.guiPolyCorners(1,p)], ... 
		        [obj.guiPolyCorners(2,p-1) obj.guiPolyCorners(2,p)], '-', ...
						'Color', [1 0 1]); 
		end
	end
