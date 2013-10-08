%
% S Peron May 2010
%
% When you are done drawing a polygon in gui, call this to decide what, based 
%  on mouse mode, to do.
%
function guiDonePolyProcess(obj)
  
  % switch based on mouseMode
  switch obj.guiMouseMode
	  case 1 % draw ROI ; if selectedRoiId is something, you are replacing that ; otherwise, new
		  if (size(obj.guiPolyCorners,2) > 2)
			  if (length(obj.guiSelectedRoiIds) == 1)  
				  tRoi = obj.getRoiById(obj.guiSelectedRoiIds);
					tRoi.corners = obj.guiPolyCorners;
					tRoi.color = [1 0 0.5];
				else
					% add it
					tRoi = roi.roi(-1, obj.guiPolyCorners, [], [1 0 0.5], obj.imageBounds, []);
					obj.addRoi(tRoi);
				end
				% fill it
				obj.fillToBorder(tRoi.id);

				% select it
				obj.guiSelectedRoiIds = tRoi.id;
			end
			% update gui -- clear the polygon
			obj.guiPolyCorners = [];
			obj.guiMouseMode = 0;
			obj.updateImage();
		case 4 % polygon for selection ; find all that are in it
		  rois = obj.findRoisByPoly(obj.guiPolyCorners);
			obj.guiSelectedRoiIds = [];
			for r=1:length(rois)
			  obj.guiSelectedRoiIds = [obj.guiSelectedRoiIds rois{r}.id];
			end
			% update gui -- clear the polygon
			obj.guiPolyCorners = [];
			obj.guiMouseMode = 0;
			obj.updateImage();
	end


