%
% SP Apr 2011
%
% Class for ROI editing across days
%
% USAGE:
%
%  session.roiMultiDayGui(invar)
%
%    invar: can be a cell array of roiArray objects OR a directory name in which 
%           case you are prompted to select files.
%
classdef roiMultiDayGui < handle
  % Properties
  properties 
	  roiArrayArray = {}; % roiArray storage
		rAidx = 0; % whick roiArray is selected
  end

  % Since this is a gui class, most stuff is discarded ...
  properties(Transient = true) 
	  mainControlH; % main control panel wiht buttons

	  roiArrayFigH; % roi array figure -- "main"
		roiArrayAxesH; % axes of this figure

		zoomFigH; % zoom view
		zoomAxesH; % zoom axes
		zoomOn = 0; % 1 if zoom is enabled

		crossDayFigH; % subregion across day viewer
		crossDayAxesH; % subregion across day viewer
		crossDayOn = 0; % 1 if multiday view on

		dayMenuH; % pulldown with days
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = roiMultiDayGui(roiArrays)
		  % argument passed?
			if (nargin == 1)
			  % is it a roi array array?
				if (iscell(roiArrays))
				  roiArrayArray = roiArrays;
				% is it a filename?
				else
          obj.loadData(roiArrays);
				end
			elseif (nargin == 0) % no arguments
			end
		end

    %
		% Start gui
		%
		function startGui(obj)
		  obj.guiWrapper('startGui');
		end

		%
		% Wrapper that will invoke a given method for all members of roiArrrayArray
		%  in the form rA = roiArrayArray{r} ; eval(['rA.' command]);
    %
		function evalForAll(obj, command)
			for r=1:length(obj.roiArrayArray) 
			  rA = obj.roiArrayArray{r};
				eStr = ['rA.' command];
				eval(eStr);
			end
		end
    
		% data loader
		loadData(obj, loadDir)

		% wrapper for gui -- allows hooks
		guiWrapper(obj, subFunction, subFunctionParams)

		% updates all GUI elements
		updateGui(obj, params)

		% updates zoom plot
		updateZoomPlot (obj)

		% updates cross day plot
		updateCrossDayPlot (obj)
    
		% sets the selected roiArrayArray
		setRAIdx(obj, rAidx)
	end

  % Methods -- statiX -- usually callbacks
	methods (Static = true)
		% callback for when KB buttons pressed when roiArray figure is active
    figKeyPressProcessor(src, event, obj)

		% callback for when mouse pressed when roiArray figure is active
    figMouseClickProcessor(src, event, obj)
	end

  % Methods -- set/get/basic variable manipulation stuff
%	methods 
%	end
end

