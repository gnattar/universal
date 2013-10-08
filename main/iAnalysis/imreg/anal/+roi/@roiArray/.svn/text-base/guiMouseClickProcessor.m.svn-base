%
% PRocesses mouse click from a ROI editing GUI -- depends on guiMouseMode,
%  and position clicked.  To connect this to your GUI, do something like:
%
%	set(figRef,'KeyPressFcn', {@obj.guiKeyStrokeProcessor}), 
%
%  where figRef is the reference to the figure handle, or you should call 
%  it in standard object format with the event and source objects from an event 
%  handler as passed parameters.
% 
% Note that this only updates data in obj, it does *not* update the GUI, which
%  means you can use this inside other GUIs if you want and handle GUI updates
%  on your own.  src should be the handle to the IMAGE object where the mouse
%  is clicked, so it will get its parent which is the axes it wants.
%
% USAGE:
%
%   rA.guiMouseClickProcessor(src, evnt)
%
% PARAMS:
%
%   src: source structure for events
%   evnt: event data
%
function guiMouseClickProcessor(obj, src, evnt)

  % -- extract event data
  mousePos = get(get(src,'Parent'),'CurrentPoint');
  x = mousePos(1,1);
	y = mousePos(1,2);

  % switch
  switch obj.guiMouseMode
		case {1,4} % 1: draw roi ; 2: polygon for selection draw
		  np = size(obj.guiPolyCorners,2);
			obj.guiPolyCorners(:,np+1) = [x y];
			axes(obj.guiHandles(2));
			obj.updateGuiPolygon();
		case 2 % select SINGLE roi
		  tRoi = obj.findRoiByPoint(x,y);
			if (length(tRoi) > 0)
				obj.guiSelectedRoiIds = tRoi.id;
				obj.updateImage();
			end
		case 3 % select multiple ROIs
		  tRoi = obj.findRoiByPoint(x,y);
			if (length(tRoi) > 0) % found one
			  if (length(find(obj.guiSelectedRoiIds == tRoi.id)) == 0) % not yet selected - add
					obj.guiSelectedRoiIds = [obj.guiSelectedRoiIds tRoi.id];
				else % deselect
					obj.guiSelectedRoiIds = setdiff(obj.guiSelectedRoiIds, tRoi.id);
        end
				obj.updateImage();
			end
		case 5 % tsai-wen autodetector ...
      obj.roiGenSemiautoTsaiWen(round([x y]));
		case {6,7} % gradient autodetector
		  obj.roiGenSemiautoGradient(round([x y]));
		otherwise
		  if (obj.guiMouseMode ~= 0)
				disp(['roi.roiArray.guiMouseClickProcessor::unrecognized mouse mode selected (' num2str(obj.guiMouseMode) ')']);
			end
	end


