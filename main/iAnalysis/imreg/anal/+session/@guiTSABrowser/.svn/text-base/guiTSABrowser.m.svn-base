%
% SP Sept 2011
%
% Class for browsing timeSeriesArray objects.
%
% USAGE:
%
%  session.guiTSABrowser(trialIds, trialStartTimes, trialTypes, shownTrials, 
%                        trialType, trialTypeStr, trialTypeColor, params)
%
%    trialIds: id vector for trials (uses session.session.trialIds format)
%    trialStartTimes: start time of each trial (see session.session.trialStartTimes)
%    trialTypeMat: type matrix for each trial (see session.session.trialTypeMat)
%
%    shownTrials: vector with which trials to show ; will obey order.
%    
%    trialType, trialTypeStr, trialTypeColor: again, session.session variables 
%      that give a code, string ID, and color for each trial type.  The first
%      is a vector of #s, the second a cell array, and the third a matrix of 
%      3-element vectors.  The number of elements is equal in each.
%    
%    params: a structure with the following fields, used to call,
%            guiWrapper('startGui',params), so basically params for guiWrapper's
%            startGui function.  Fields:
%
%    params.leftListTSA: cell array of TSA objects on left
%    params.rightListTSA: cell array of TSA objects shown on right
%    params.ESList: event series objects to include as options to display
%    params.ESListOn: vector 0/1 same size as ESList specifyign who to actually
%                    plot intially ; don't pass if you dont want to
%
% EXAMPLE: (assuming you have a session object named s)
%
%   params.leftListTSA = s.caTSA.dffTimeSeriesArray;
%   params.rightListTSA = s.derivedDataTSA;
%   params.ESList = s.behavESA;
%   params.ESListOn= [0 0 0 0 1];
%   
%   gt = session.guiTSABrowser(s.trialIds, s.trialStartTimes, s.trialTypeMat, s.validTrialIds, ...
%                          s.trialType, s.trialTypeStr, s.trialTypeColor, params);
%
% PROPERTIES:
%
%   GUI STUFF:
%
%   figH: main display figure handle
%   ESListFigH: eventSereis selector handle
%   lineFigH: line plot display, if active, handle
%   trialPlotH: trial plot display, if active, handle
%  
%   left/rightIdx: 2 element vector, first tracks which TSA for left/right,
%                  second speciftying which timeSEries within that TSA is used/
%                  This is the active/displayed timeSeries.
%   right/leftAxisH: right/;eft axis handles
%   
%
%   ui: structure with links to all user interface elements
%  
%   ui.left/rightTitleH: handle for left/right panel title (one user scrolls)
%   ui.showLineCheckH: show line plot?
%   ui.showRoiGuiCheckH: show ROIs gui check
%   ui.showTrialGuiCheckH: show single-trial view checkbox
%
%   ESui: structure with links to eventSEries selector user interface
%
%   left/RightColorMap: string or matrix for colormap used on left/right UI
%   left/rightImageValueRange: string or numerical value specifying what
%      range colormap should span.  Note that the passed value is 'eval'ed, 
%      and that it is done in a context where m means minimum value and
%      M means maximal value while mu and sd mean mean and sd, so you can do 
%      something like [0 1], [m M], or [mu-2*sd mu+2*sd].  Eval'd only if 
%      string ; otherwise  must be #s.  Furthermore, med means median.
%   left/rightPlotValueRange: same as above, but for the plot if it is on
%
%   USER-SPECIFIED DATA:
%
%   ESList: event series cell array -- each member can either be an eventSeries
%           or an eventSeriesArray object
%   left/rightListTSA: data shown on right/left
%   ESListOn: vector of same size as ESList to track which ones are displayed,
%             which user can set to 1/0 to decide who is on/off
%
%   trialStartTimeMat, trialTypeMat: from session; hopefully gone sono.
%
%   INTERNAL VARIABLES:
%
%   shownTrials: which trials are shown?
%   left/rightListIdStr: quick-access to id strs of individual things - needed
%                        because you can pass multiple TSA objects to left/right
%   lastRoiFOV: if you have multiple fields-of-view, tracks which one was last
%               selected in case you have roi windows that need disabling.
%   updateRoiGuiFunction: callback for whenver ROI gui is updated; if you are 
%               wanting to hookup something else, this is how to do it.
%   imageMouseClickCallback: if you want a callback different than the default
%               single trial plotter, add it here.
%   trialPlotTrialNumber: which trial # to plot in single trial plot?
%   
%
classdef guiTSABrowser < handle
  % Properties
  properties 
	%	rAidx = 0; % whick roiArray is selected
  end

  % Since this is a gui class, most stuff is discarded ...
  properties(Transient = true) 
    figH = [];
		ESListFigH = [];
    lineFigH = [];
    trialPlotH = [];
  
    leftIdx = [];
		rightIdx = [];
    rightAxisH = [];
		leftAxisH = [];
   
    ui = [];
		ESui = [];

    leftColorMap = [];
		rightColorMap = [];
    leftImageValueRange = [];
		rightImageValueRange = [];
    leftPlotValueRange = [];
		rightPlotValueRange = [];

    ESList = [];
		leftListTSA = {}; 
		rightListTSA = {};
    ESListOn = [];
    leftListIdStr = [];
    rightListIdStr = [];
    lastRoiFOV = [];

    shownTrials = [];
		trialStartTimeMat = [];
		trialTypeMat = [];
    
    trialType = [];
    trialTypeStr = [];
    trialTypeColor = [];

		trialPlotTrialNumber = [];

		updateRoiGuiFunction = {};
		imageMouseClickCallback = {};

  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = guiTSABrowser(trialIds, trialStartTimes, trialTypeMat, newShownTrials, ...
                                  trialType, trialTypeStr, trialTypeColor, params)
		  % argument passed? assume it is params structure for startGui
			if (nargin == 8)

			  % setup stuff pertaining to trial timing etc -- session stuff
				obj.shownTrials = newShownTrials;
				obj.trialStartTimeMat = [trialIds ; trialStartTimes]';
				obj.trialTypeMat = 0*obj.trialStartTimeMat;
   			for t=1:size(trialTypeMat,2)
					obj.trialTypeMat(t,:) = [trialIds(t) min(find(trialTypeMat(:,t)))];
        end
        % parameters defining set of available trial types, their names, and colors
        obj.trialType = trialType;
        obj.trialTypeStr = trialTypeStr;
        obj.trialTypeColor = trialTypeColor;
       
				% --- prelims --> process inputs
				leftListTSAp = {}; 
				rightListTSAp = {};
				ESListOnp = [];
				ESListp = {};
				if (isstruct(params))
					if (isfield(params,'leftListTSA')) ; leftListTSAp = params.leftListTSA; end
					if (isfield(params,'rightListTSA')) ; rightListTSAp = params.rightListTSA; end
					if (isfield(params,'ESList')) ; ESListp= params.ESList; end
					if (isfield(params,'ESListOn')) ; ESListOnp= params.ESListOn; end
					if (~iscell(leftListTSAp)) ; leftListTSAp = {leftListTSAp}; end
					if (~iscell(rightListTSAp)) ; rightListTSAp = {rightListTSAp}; end
					if (~iscell(ESListp)) ; ESListp = {ESListp}; end
				end

				% ---  setup LEFT timeseries list
				obj.leftListTSA = {};
				obj.leftListIdStr = {};
				for lli=1:length(leftListTSAp)
					obj.leftListTSA{lli} = leftListTSAp{lli};
					for l=1:obj.leftListTSA{lli}.length() ; obj.leftListIdStr{length(obj.leftListIdStr)+1} = leftListTSAp{lli}.idStrs{l} ; end
				end

				% ---  setup RiGHT timeseries list
				obj.rightListTSA = {};
				obj.rightListIdStr = {};
				for rli=1:length(rightListTSAp)
					obj.rightListTSA{rli} = rightListTSAp{rli};
					for r=1:obj.rightListTSA{rli}.length() ; obj.rightListIdStr{length(obj.rightListIdStr)+1} = rightListTSAp{rli}.idStrs{r} ; end
				end

				% --- event series
				eli = 1;
				ESList = {};
				for e=1:length(ESListp)
					if (strcmp(class(ESListp{e}), 'session.eventSeries') | ...
							strcmp(class(ESListp{e}), 'session.calciumEventSeries') )
						ESList{eli} = ESListp{e}; 
						eli = eli+1;
					else
						esa = ESListp{e}.esa;
						for ee=1:length(esa)
							ESList{eli} = esa{ee};
							eli = eli+1;
						end
					end
				end
				ESListOn = zeros(1,length(ESList));
				if (length(ESListOnp) > 0) ; ESListOn = ESListOnp ; end

				obj.ESList = ESList;
				obj.ESListOn = ESListOn;

        %  --- kickoff the guy
		    obj.guiWrapper('startGui');
			elseif (nargin == 0) % nothing? do nothing.
			else
			  help('session.guiTSABrowser');
			  disp(' ');
			  disp('session.guiTSABrowser::incorrect parameters to constructor.');
			end
		end

    %
		% Start gui blankly
		%
		function startGui(obj)
		  obj.guiWrapper('startGui');
		end

		% wrapper for gui -- allows hooks KILL THIS!
		guiWrapper(obj, subFunction, subFunctionParams)

    % updates single trial plot
		updateSingleTrialPlot(obj)

		% updates all GUI elements
%		updateGui(obj, params)

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

