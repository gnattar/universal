%
% SP Oct 2011
%
% Plots a summary of touch-triggered average for all whiskers, unique &
%  not, directional & not.
%
% USAGE:
%
%  s.plotTouchTriggeredAverage(params)
%
% PARAMS: An (optional) structure params with the following fields, or if it
%  is JUST a number, the roi ID.
%
%  roiId: ID of ROI to show 
%  ax: axes handle in which to plot -- give 4 (1: nondir/nonex, 2: nondir/ex, 
%      3: dir/nonex, 4: dir/ex)
%  barInReachOnly: if set to 1, will only nan epochs when bar is out of reach
%
function plotTouchTriggeredAverage(obj, params)

  % --- process params structure
	if (nargin < 2)  
	  help('session.session.plotTouchTriggeredAverage');
		return;
	end

	% preassign
	whColors = [1 0 0 ; 0 1 0 ; 0 0 1];
  if (length(obj.whiskerTag) > size(whColors,1))
	  whColors = jet(length(obj.whiskerTag));
	end
	whDirColors = zeros(2*size(whColors,1),3);
	for w=1:length(whColors)
	  whDirColors((w*2) - 1,:) = whColors(w,:); 
	  whDirColors(w*2,:) = 0.75*whColors(w,:);
  end

	timeRange = [-2 5];
	valRange = [-0.5 5];
	ax = [];
	barInReachOnly = 0;

	if ( isstruct(params))
	  roiId = params.roiId;
	  if(isfield(params,'ax')) ; ax = params.ax; end
	  if(isfield(params,'barInReachOnly')) ; barInReachOnly = params.barInReachOnly; end
	else
	  roiId = params;
	end

  % new figure?
	if (length(ax) == 0)
    figure;
		for i=1:4; ax(i) = subplot(2,2,i); end
	end

	% need bar in reach restriction?
	if (barInReachOnly)
  	barTS = session.eventSeries.deriveTimeSeriesS(obj.whiskerBarInReachES, obj.caTSA.time, obj.caTSA.timeUnit, [nan 1], 2);
	end

  % some prep work
	caTSA = obj.caTSA.dffTimeSeriesArray;
	roiIdx = find(obj.caTSA.ids == roiId);

	% --- non-directional, non-exclusive
	hold on;
	legStr = {};
	for w=1:length(obj.whiskerBarContactESA.esa)
	  allTouchTimes = obj.whiskerBarContactESA.esa{w}.getStartTimes();

    % bar-in-reach restriction
		caTS = caTSA.getTimeSeriesByIdx(roiIdx);
		if (barInReachOnly) 
			caTS = caTS.copy();
			caTS.value = caTS.value.*barTS.value ;
		end

    % main call to plotter
    session.session.plotEventTriggeredAverageS(caTS, [], ...
		  obj.whiskerBarContactESA.esa{w}, 1, [timeRange(1) timeRange(2) valRange(1) valRange(2)], ...
			[nan ax(1)], whColors(w,:));
		legStr{w} = strrep(obj.whiskerBarContactESA.esa{w}.idStr, 'Contacts for ', '');

		text(timeRange(1)+0.15*diff(timeRange), ...
		     valRange(1) + .8*(w/length(obj.whiskerBarContactESA.esa))*diff(valRange), ...
				 legStr{w}, 'Color', whColors(w,:));

	end
	title('all contacts');

	% --- non-directional, exclusive
	hold on;
	for w=1:length(obj.whiskerBarContactESA.esa)
	  allTouchTimes = obj.whiskerBarContactESA.esa{w}.getStartTimes();
		wid = obj.whiskerBarContactESA.esa{w}.id;

    % bar-in-reach restriction
		caTS = caTSA.getTimeSeriesByIdx(roiIdx);
		if (barInReachOnly) 
			caTS = caTS.copy();
			caTS.value = caTS.value.*barTS.value ;
		end

    % main call to plotter
    session.session.plotEventTriggeredAverageS(caTS, [], ...
		  obj.whiskerBarContactESA.esa{w}, 1, [timeRange(1) timeRange(2) valRange(1) valRange(2)], ...
			[nan ax(2)], whColors(w,:), [], ...
			obj.whiskerBarContactESA.getExcludedCellArray(wid), [-2 2]);
	end
	title('unique contacts');

	% --- directional, non-exclusive
	hold on;
	legStr = {};
	for w=1:length(obj.whiskerBarContactClassifiedESA.esa)
	  allTouchTimes = obj.whiskerBarContactClassifiedESA.esa{w}.getStartTimes();

    % bar-in-reach restriction
		caTS = caTSA.getTimeSeriesByIdx(roiIdx);
		if (barInReachOnly) 
			caTS = caTS.copy();
			caTS.value = caTS.value.*barTS.value ;
		end

    % main call to plotter
    session.session.plotEventTriggeredAverageS(caTS, [], ...
		  obj.whiskerBarContactClassifiedESA.esa{w}, 1, [timeRange(1) timeRange(2) valRange(1) valRange(2)], ...
			[nan ax(3)], whDirColors(w,:));
		legStr{w} = strrep(obj.whiskerBarContactClassifiedESA.esa{w}.idStr, 'contacts for ', '');
		legStr{w} = strrep(legStr{w}, 'Protraction ', 'P');
		legStr{w} = strrep(legStr{w}, 'Retraction ', 'R');

		text(timeRange(1)+0.15*diff(timeRange), ...
		     valRange(1) + .8*(w/length(obj.whiskerBarContactClassifiedESA.esa))*diff(valRange), ...
				 legStr{w}, 'Color', whDirColors(w,:));
	end

	% --- directional, exclusive
	hold on;
	for w=1:length(obj.whiskerBarContactClassifiedESA.esa)
	  allTouchTimes = obj.whiskerBarContactClassifiedESA.esa{w}.getStartTimes();
		wid = obj.whiskerBarContactClassifiedESA.esa{w}.id;

    % bar-in-reach restriction
		caTS = caTSA.getTimeSeriesByIdx(roiIdx);
		if (barInReachOnly) 
			caTS = caTS.copy();
			caTS.value = caTS.value.*barTS.value ;
		end

    % main call to plotter
    session.session.plotEventTriggeredAverageS(caTS, [], ...
		  obj.whiskerBarContactClassifiedESA.esa{w}, 1, [timeRange(1) timeRange(2) valRange(1) valRange(2)], ...
			[nan ax(4)], whDirColors(w,:), [], ...
			obj.whiskerBarContactClassifiedESA.getExcludedCellArray(wid), [-2 2]);
	end




