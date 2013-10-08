%
% PRocesses key stroke from a ROI editing GUI. This should either be connected
%  to your gui figure via something like:
%
%	set(figRef,'KeyPressFcn', {@obj.guiKeyStrokeProcessor}), where figRef is the
%  reference to the figure handle, or you should call it in standard object format
%  with the event and source objects from an event handler.
% 
% Note that this only updates data in obj, it does *not* update the GUI, which
%  means you can use this inside other GUIs if you want and handle GUI updates
%  on your own.
%
% usage: guiKeyStrokeProcessor(src, evnt)
%        src: source structure for events
%        evnt: event data
%
function obj = guiKeyStrokeProcessor(obj, src, evnt)
  % --- get event data
	key = double(evnt.Character);
	mod = evnt.Modifier;

  % --- shift/control/alt states
	shift = 0; 
	alt = 0;
	control = 0;
	if (strcmp(mod,'shift')) ; shift = 1; end
	if (strcmp(mod,'control')) ; control = 1; end
	if (strcmp(mod,'alt')) ; alt = 1; end

  % filter out non-keyboard buttons -- shift etc. not allowed now
	if (length(key) ~= 1) ; return ; end

  % --- main switch ...
  switch key
	  case 63  % ? - help
			disp(' ');
		  disp('===== HELP FOR roiArray.guiKeyStrokeProcessor =====');
			disp(' ');
			disp('DISPLAY STUFF: ');
			disp('--------------');
			disp('(,9,0,): parenth for image navigation ; 9,0 for frame navigation');
			disp('b: border show');
			disp('f: fill pixel show');
			disp('#: ID number show');
			disp('ctrl/apple-z: enable zoom mode');
			disp('ctrl/apple-x: enable pan mode');
			disp(' ');
			disp('ROI BASICS: ');
			disp('-----------');
			disp('L,S: load/save ROI file');
			disp('m: select multiple ROIs via click');
			disp('a: select all');
			disp(',/.: select previous/next');
			disp('o: select complement');
			disp('del: delete ROI');
			disp(' ');
			disp('n: new ROI');
			disp('w: redraw selected ROI');
			disp('p: select ROIs via polygon');
			disp('d: done drawing polygon (with n,w,p)');
			disp(' ');
			disp('ROI MANIPULATION TOOLS: ');
			disp('-----------------------');
			disp('arrows: move ROI by 1; arrows+shift: by 10');
			disp('{,[,],}: remove 10,1/add 1, 10 darkest/brightest pixels in border');
			disp('D,E: dilate or erode border by 1 pixel');
			disp('control-d,e: dilate or erode indices by 1 pixel');
			disp('control-f: fill to border');
			disp('F: fill holes in ROI');
			disp('T: make border tight with pixels');
			disp('X: remove all but largest component');
			disp(' ');
			disp('ROI DETECTION TOOLS: ');
			disp('--------------------');
			disp('t: Turn on/off Tsai-Wen autodetector');
			disp('g: Turn on/off gradient autodetector');

    case 122 % z: zoom [do nothing]
		case 120 % x: pan [do nothing] 
	  case 110 % n: new ROI
		  obj.guiSelectedRoiIds = [];
		  obj.guiPolyCorners = [];
		  obj.guiMouseMode = 1;
			obj.updateImage();
    case 98 % b: border display toggle
		  obj.guiShowFlags=[~obj.guiShowFlags(1) obj.guiShowFlags(2) obj.guiShowFlags(3)];
	  case 102 % f  indices display toggle
		  obj.guiShowFlags=[obj.guiShowFlags(1) ~obj.guiShowFlags(2) obj.guiShowFlags(3)];
	  case 35 % #: toggle #s
		  if (shift)
				obj.guiShowFlags=[obj.guiShowFlags(1) obj.guiShowFlags(2) ~obj.guiShowFlags(3)];
			end
	  case 83  % S - save ROIs
			obj.saveToFile('', 1);
	  case 76  % L - load ROIs
			obj.loadFromFile('');
			obj.updateImage();
	  case 5 % control-e: erode indice
			obj.erodeRoiIndices(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 68 % D: dilate border
			obj.dilateRoiBorders(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 69 % E: erode border
			obj.erodeRoiBorders(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 100  % d: done with poly drawing ; shift-d: dilate borders ; ^d: dilate indices
			obj.guiDonePolyProcess();
    case 115  % s: select roi
		  obj.guiMouseMode = 2;
    case 111  % o : select complement
		  allIds = obj.roiIds;
			obj.guiSelectedRoiIds = setdiff(allIds,obj.guiSelectedRoiIds);
			obj.updateImage()
	  case 4 % control-d: dilate indice
			obj.dilateRoiIndices(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 5 % control-e: erode indice
			obj.erodeRoiIndices(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 68 % D: dilate border
			obj.dilateRoiBorders(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 69 % E: erode border
			obj.erodeRoiBorders(1,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 100  % d: done with poly drawing ; shift-d: dilate borders ; ^d: dilate indices
			obj.guiDonePolyProcess();
    case 115  % s: select roi
		  obj.guiMouseMode = 2;
    case 111  % o : select complement
		  allIds = obj.roiIds;
			obj.guiSelectedRoiIds = setdiff(allIds,obj.guiSelectedRoiIds);
			obj.updateImage();
    case 97  % a : select all
		  if (length(obj.guiSelectedRoiIds) == length(obj.roiIds)) % all selected? then deselct
			  obj.guiSelectedRoiIds = [];
			else
				obj.guiSelectedRoiIds = obj.roiIds;
			end
			obj.updateImage();
    case 109  % m: select multiple
		  obj.guiMouseMode = 3;
    case 112  % p : select multiple via a polygon
		  obj.guiPolyCorners = [];
		  obj.guiMouseMode = 4;
			obj.updateImage();
%    case 60  % < : prev
%    case 62  % > : next
	  case {127,8}  % delete
		  obj.removeRois(obj.guiSelectedRoiIds);
			if (length(obj.roiIds) > 0)
				obj.guiSelectedRoiIds = max(obj.roiIds);
			else
			  obj.guiSelectedRoiIds = [];
			end
			obj.updateImage();
    case 106  % j : join rois
		  obj.mergeRois(obj.guiSelectedRoiIds);
    case 119  % w: Redraw ROI
		  if (length(obj.guiSelectedRoiIds) ~= 1)
			  disp('Must select a single ROI to redraw.');
			else
	  	  obj.guiPolyCorners = [];
  		  obj.guiMouseMode = 1;
  			obj.updateImage();
			end
    case 30  % up arrow [shift = 10]
		  if (shift) ; dy = -10 ; else ; dy = -1 ; end
		  obj.moveBy(0,dy,obj.guiSelectedRoiIds);
			obj.updateImage();
    case 31 % down arrow [shift = 10]
		  if (shift) ; dy = 10 ; else ; dy = 1 ; end
		  obj.moveBy(0,dy,obj.guiSelectedRoiIds);
			obj.updateImage();
    case 29  % right arrow
		  if (shift) ; dx = 10 ; else ; dx = 1 ; end
		  obj.moveBy(dx,0,obj.guiSelectedRoiIds);
			obj.updateImage();
    case 28 % left arrow
		  if (shift) ; dx = -10 ; else ; dx = -1 ; end
		  obj.moveBy(dx,0,obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 6  % ctrl-f: fill-to-border
			obj.fillToBorder(obj.guiSelectedRoiIds);
			obj.updateImage();
		case 70  % F - fill holes in roi
		  obj.fillHolesInRoi(obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 84  % T - make border tight fit of pixels
		  obj.fitRoiBordersToIndices(obj.guiSelectedRoiIds);
			obj.updateImage();
	  case 91 % [ take away 1 next points in luminance
		  obj.changeIndicesBasedOnLuminance(obj.guiSelectedRoiIds, -1);
			obj.updateImage();
	  case 93 % ] add 1 next points in luminance
		  obj.changeIndicesBasedOnLuminance(obj.guiSelectedRoiIds, 1);
			obj.updateImage();
	  case 123 % { take away 10 next points in luminance
		  obj.changeIndicesBasedOnLuminance(obj.guiSelectedRoiIds, -10);
			obj.updateImage();
	  case 125% } add 10 next points in luminance
		  obj.changeIndicesBasedOnLuminance(obj.guiSelectedRoiIds, 10);
			obj.updateImage();
	  case 88  % X: remove all but largest component
		  obj.removeAllButLargestConnectedComponent(obj.guiSelectedRoiIds);
			obj.updateImage();
		case 44 % ,: previous
		  if (length(obj.guiSelectedRoiIds) == 1)
				idx = find(obj.roiIds == obj.guiSelectedRoiIds);
				idx = idx - 1;
				if (idx == 0) ; idx = length(obj.roiIds); end
				obj.guiSelectedRoiIds = obj.roiIds(idx);
				obj.updateImage();
			end
  	case 46 % .: next
		  if (length(obj.guiSelectedRoiIds) == 1)
				idx = find(obj.roiIds == obj.guiSelectedRoiIds);
				idx = idx + 1;
				if (idx > length(obj.roiIds)) ; idx = 1; end
				obj.guiSelectedRoiIds = obj.roiIds(idx);
				obj.updateImage();
			end
	  case 57 % 9 ; prev frame 
		  obj.prevWorkingImageFrame();
	  case 48 % 0 ; next frame 
		  obj.nextWorkingImageFrame();
	  case 40 % ( ; prev image
		  obj.prevWorkingImage();
	  case 41 % ) ; next image
		  obj.nextWorkingImage();
		case 116 % t: enable tsai-wen autodetector
		  if (obj.guiMouseMode ~=5) % disable other possible mouse modes, enable this
		    disp('roi.roiArray::enabling Tsai-Wen''s autodetector; hit t again to disable.');
		    disp('              While enabled, clicking on the center of a "donut" will');
 	      disp('              try to fit the border of the donut and auto-generate a ROI.');
  		  obj.guiMouseMode = 5;
		 	  obj.guiPolyCorners = [];
  			obj.updateImage();
			else
  		  obj.guiMouseMode = 0;
			  disp('roi.roiArray::exiting autodetector.');
			end
		case 103 % g: gradient dropoff autodetector
		  if (obj.guiMouseMode ~=6 & obj.guiMouseMode ~=7) % disable other possible mouse modes, enable this
		    disp('roi.roiArray::enabling gradient autodetector 1; hit g 2X to disable.');
		    disp('              While enabled, clicking anywhere will look for a drop');
 	      disp('              in nearby luminance to indicate cell border.');
  		  obj.guiMouseMode = 6;
				obj.settings.semiAutoGrad.radiusRange = [3 10];
				obj.settings.semiAutoGrad.edgeSign = -1;
				obj.settings.semiAutoGrad.postDilateBy = 0;
			  obj.settings.semiAutoGrad.dPosMax =2 ;
				obj.settings.semiAutoGrad.postFracRemove = 0;
		 	  obj.guiPolyCorners = [];
  			obj.updateImage();
			elseif (obj.guiMouseMode ==6) % unfilled cells
		    disp('roi.roiArray::enabling gradient autodetector 2; hit g to disable.');
		    disp('              While enabled, clicking anywhere will look for a rise');
 	      disp('              in nearby luminance to indicate nuc border.');
  		  obj.guiMouseMode = 7;
		 	  obj.guiPolyCorners = [];
				obj.settings.semiAutoGrad.radiusRange = [1 4];
				obj.settings.semiAutoGrad.edgeSign = 1;
				obj.settings.semiAutoGrad.postDilateBy = 0.5;
			  obj.settings.semiAutoGrad.dPosMax =0 ;
				obj.settings.semiAutoGrad.postFracRemove = 0.25;
  			obj.updateImage();
			elseif (obj.guiMouseMode == 7) % exit autodetector
  		  obj.guiMouseMode = 0;
			  disp('roi.roiArray::exiting autodetector.');
			end
		otherwise 
			disp(['Unrecognized key stroke: ' num2str(key)]);
	end
