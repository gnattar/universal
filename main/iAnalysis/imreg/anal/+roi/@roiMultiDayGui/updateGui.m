%
% SP Apr 2011
%
% For updating the GUI.  
%
% USAGE:
%
%   mdg.updateGui()
%
function updateGui(obj, params)
	rA = obj.roiArrayArray{obj.rAidx};
  % --- event hooks update
  if(ishandle(rA.guiHandles(3))) ; set(rA.guiHandles(3), 'KeyPressFcn', {@roi.roiMultiDayGui.figKeyPressProcessor, obj}); end
	if(ishandle(rA.guiHandles(1))) ;set(rA.guiHandles(1),'ButtonDownFcn', {@roi.roiMultiDayGui.figMouseClickProcessor, obj}); end
  obj.updateZoomPlot();
  obj.updateCrossDayPlot();

