%
% SP Jan 2011
%
% Plots event triggered average for any timeseries.  The default behavior/mode is
%  to plot dF/F as a function of contact (see plotMode).  To plot an arbitrary 
%  timeSeriesArray off of whisker contact, using plotMode 1 and/or 2, set displayedTSA
%  and displayedId.  To go real crazy and use a different event series for
%  the trigger, set plotMode(3/4) to 1, and assign triggeringESA, as well as 
%  triggeringESAIds.
%
% USAGE:
%
%  [avgFig barFig rawFig] = sA.plotEventTriggeredAverageCrossDays(params)
%
%  params: structure with parameters having any of the following fields 
%
%     avgFig: figure handle to figure with avg plots
%     barFig: figure handle for figure w/ bars
%     rawFig: figure handle for the raw
%
%     displayedId [mandatory]: which ID to show? Unless you are specifiyng
%                                 displayedTSA, this is just roiId you want
%                                 Can also be a string, in which case 
%                                 getTimeSeriesByIdStr is employed.
%     sessions: which sessions to do, in terms of indexing of sA.sessions
%     whiskerTags: which whiskers to do (if not given, does ALL)
%     valueRange: shown range of values ; default is [-0.25 .5] since this is
%                 good df/f
%     timeRange: shown time range ; default is [-2 5]
%     excludeOthers: if 1, will exclude all other members of the triggeringESA
%     plotAvg: default 1; enable average plot
%     avgType: 1 (default) - mean +/- SD ; 2: median +/- IQR
%     plotRaw: default is 0 ; if 1, will plot raw traces in a separate panel 
%              (grouped)
%     plotBar: default is 0 ; if 1, will plot bars of mean responses in sep panel
%     plotBarX: if specified, 1 x should be given per trigerringESAIds, telling
%               where on the barPlot to go ...
%     plotBarAxes: if passed, axes on which bar is plotted ; vector w/ 1/session
%     plotMode: default [1 0 0 0] ; first 1/0: plot/don't all touches ; 
%               second 1/0: ret/protract 
%               third 1/0: use triggeringESA  ; turns off plotMode(1), (2)
%               final 1/0: use triggeringESA, but plot all on ONE figure
%     displayedTSA: uses obj.sessions{x}.displayedTSA ; note that this is a 
%                   STRING whose defautl is caTSA.dffTimeSeriesArray.
%     triggeringESA: if yuo want a custom plot trigger, use plotMode(3/4) = 1
%                    and pass your ESA here.  Again, pass STRING name within
%                    session.  (e.g., 'behavESA' for session.behavESA)
%     triggeringESAIds: IDs within triggeringESA to include in plot ; again, can
%                       be a cell array of strings in which case getEventSeriesByIdStr
%                       is employed.
%     triggeringESACols: colors to use ; if you provide 2 ids or more, you must
%                        give colors.  [r g b ; r g b ; r g b  ... ] matrix
%      
%
% EXAMPLE 1:
%
%  Plotting pro/re/avg for roi ID 225:
%
%    eparams.displayedId = 225;
%    eparams.plotMode = [1 1 0 0];
%    sA.plotEventTriggeredAverageCrossDays(eparams)
%
%  Now don't exclude based on overlapping events:
%  
%    eparams.excludeOthers = 0;
%    sA.plotEventTriggeredAverageCrossDays(eparams)
%
%  And restrict to only c2:
%
%    eparams.whiskerTags = 'c2';
%    sA.plotEventTriggeredAverageCrossDays(eparams)
%
%
% EXAMPLE 2:
%
%  Plot puff and lick-triggered average for roi ID 209
%
%    eparams.displayedId = 208;
%    eparams.plotMode = [0 0 1 0];
%    eparams.valueRange = [-0.25 2];
%    eparams.excludeOthers = 0;
%    eparams.triggeringESA = 'behavESA';
%    eparams.triggeringESAIds = [2 4]; 
%    eparams.triggeringESACols = [0 0 1; 1 0 0];
%    sA.plotEventTriggeredAverageCrossDays(eparams)
%
% EXAMPLE 3:
%
%  Plot C2 curvature change during C2 whisker contacts
%
%    eparams.whiskerTags = 'c2';
%    eparams.timeRange = [-0.1 0.5];
%    eparams.excludeOthers = 0;
%    eparams.displayedId = 'c2';
%    eparams.valueRange = [-.005 .005];
%    eparams.displayedTSA = 'whiskerCurvatureChangeTSA';
%    eparams.plotMode = [0 1 0 0];
%    sA.plotEventTriggeredAverageCrossDays(eparams)
%  
%
function [avgFig barFig rawFig] = plotEventTriggeredAverageCrossDays(obj, params)
 
  rawFig = [];
	avgFig = [];
	barFig = [];

  % --- inputs
	if (nargin < 2)
		help ('session.sessionArray.plotEventTriggeredAverageCrossDays');
	  disp('plotEventTriggeredAverageCrossDays::must specify params');
		return;
	end
  
	displayedId = params.displayedId; % will break if not given -- because you HAVE to give this!
	whiskerTags = obj.whiskerTag;
	sessions=1:length(obj.sessions);
	triggeringESAIds = 1:length(whiskerTags);
	valueRange = [-0.25 .5];
	timeRange = [-2 5];
	excludeOthers = 1;
  plotRaw = 0;
  plotBar = 0;
	plotBarX = [];
	plotBarAxes = [];
	plotMode = [1 0 0];
	plotAvg = 1;
	avgType = 1;
	displayedTSA = 'caTSA.dffTimeSeriesArray';
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'valueRange')) ; valueRange = params.valueRange; end
	if (isfield(params, 'timeRange')) ; timeRange = params.timeRange; end
	if (isfield(params, 'excludeOthers')) ; excludeOthers = params.excludeOthers; end
	if (isfield(params, 'plotAvg')) ; plotAvg = params.plotAvg; end
	if (isfield(params, 'avgType')) ; avgType = params.avgType; end
	if (isfield(params, 'plotRaw')) ; plotRaw = params.plotRaw; end
	if (isfield(params, 'plotBar')) ; plotBar = params.plotBar; end
	if (isfield(params, 'plotBarX')) ; plotBarX = params.plotBarX; end
	if (isfield(params, 'plotBarAxes')) ; plotBarAxes = params.plotBarAxes; end
	if (isfield(params, 'plotMode')) ; plotMode = params.plotMode ; end
	if (isfield(params, 'displayedTSA') && length(params.displayedTSA) > 0) ; displayedTSA = params.displayedTSA; end
	if (isfield(params, 'triggeringESA')) ; triggeringESA = params.triggeringESA; end
	if (isfield(params, 'triggeringESAIds')) ; triggeringESAIds = params.triggeringESAIds; end
	if (isfield(params, 'triggeringESACols')) ; triggeringESACols = params.triggeringESACols; end

  % --- sanity checks

  % plotmode
	if (plotMode(3)) ; plotMode = [0 0 1 0]; end
	if (plotMode(4)) ; plotMode = [0 0 0 1]; end
   
	% whiskertag cell ensure
  if (~iscell (whiskerTags)) ; whiskerTags = {whiskerTags}; end

	% plot mode sensical?
	if (sum(plotMode) == 0) ; dis('plotEventTriggeredAverageCrossDays::must plot SOMETHING!'); return; end

	% displayedTSA string?
	if (~ischar(displayedTSA)) ; disp('plotEventTriggeredAverageCrossDays::displayedTSA must be a STRING naming the array, not a pointer to the object.'); return ;end

	% showN coords
	showNCoords(1) = min(timeRange) + 0.05*range(timeRange);
	valueRR = range(valueRange);
	showNCoords(2) = min(valueRange) + 0.5*valueRR;

	% triggeringESAIds
	if (plotMode(1) | plotMode(2)) ; triggeringESAIds = 1:length(whiskerTags); end

  % --- loop over whiskers
	for t=1:length(triggeringESAIds)
	  if (plotMode(1) | plotMode(2)) 
		  wTag = whiskerTags{triggeringESAIds(t)}; 
			plotTitleStr = wTag;
		end

    % --- setup figures for this whikser
		NSessions = length(sessions);
		Np = ceil(sqrt(NSessions));

		% generate subplots
		if (~(plotMode(4) & t > 1))
			if (plotRaw)  % submethods decide wht to plot based on presence of figure ; if spRaw is nan, w/n plot
				rawFig = figure('Name', ['Raw ' displayedTSA ' ' num2str(displayedId)], 'NumberTitle','off');
				for d=1:NSessions
					spRaw(d) = subplot(Np,Np,d);
				end
			else
				for d=1:NSessions
					spRaw(d) = nan;
				end
			end

			if (plotBar)  
			  if (length(plotBarAxes) == 0)
	  			barFig = figure('Name', ['Bar ' displayedTSA ' ' num2str(displayedId)], 'NumberTitle','off');
		  		for d=1:NSessions
			  		spBar(d) = subplot(Np,Np,d);
				  end
				else
		  		for d=1:NSessions
			  		spBar(d) = plotBarAxes(d);
					end
				end
			else
				for d=1:NSessions
					spBar(d) = nan;
				end
			end
     
		  if (plotAvg)
				avgFig = figure('Name', [displayedTSA ' ' num2str(displayedId)], 'NumberTitle','off');
				for d=1:NSessions
					spMean(d) = subplot(Np,Np,d);
				end
			else
				for d=1:NSessions
					spMean(d) = nan;
				end
			end
		end

		% --- loop over days
		for d=1:NSessions
			s = obj.sessions{sessions(d)};
			baseTSA = eval(['s.' displayedTSA]);
			tESi = [];
      if (plotMode(3) | plotMode(4))
			  trigESA = eval(['s.' triggeringESA]);
				if (isnumeric(triggeringESAIds))
					tESi = find(trigESA.ids == triggeringESAIds(t));
				else
				  es = trigESA.getEventSeriesByIdStr(triggeringESAIds{t});
					if (isobject(es))
						tESi = find(trigESA.ids == es.id);
					end
				end
				if (length(tESi) > 0)
					plotTitleStr = trigESA.esa{tESi}.idStr;
        end
			end

			% get roi ID
			di = [];
			if (isnumeric(displayedId))
				di = find (baseTSA.ids == displayedId);
			else
				for ix=1:length(baseTSA.idStrs)
	  		  if(strfind(baseTSA.idStrs{ix},displayedId)) ; di= ix ; break ; end
  			end
			end

			if (length(di) > 0)

        mumax = [];  
				medmax = [];
				iqrmedmax = [];
        semumax = [];
        nev = [];  
 
				% --- plot mode 1: ALL contacts for whisker
				if (plotMode(1))
          mumax(1) = 0; semumax(1) = 0; nev(1) = 0; medmax(1) = 0; iqrmedmax(1) = 0;
					ndESi = 0;
					for e=1:length(s.whiskerBarContactESA)
						if(length(strfind(lower(s.whiskerBarContactESA.esa{e}.idStr),wTag)) > 0)
							ndESi = e;
						end
					end
					% non-dir?
					if (ndESi > 0)
						ndEx = {};
						if (excludeOthers & s.whiskerBarContactESA.length() > 1)
						  id = s.whiskerBarContactESA.ids(ndESi);
							ndEx = s.whiskerBarContactESA.getExcludedCellArray(id);
						end
						[mmt smmt medmt iqmt net] = s.plotEventTriggeredAverage(baseTSA, di, s.whiskerBarContactESA.esa{ndESi}, ...
							1, [timeRange(1) timeRange(2) valueRange(1) valueRange(2)], [spRaw(d) spMean(d)], [0 0 0], ...
							timeRange, ndEx, timeRange, showNCoords, avgType);
            if (length(mmt) > 0) ; mumax(1) = mmt ; semumax(1) = smmt; nev(1) = net; medmax(1) = medmt ; iqrmedmax(1) = iqmt;end
					end
	    	end

				% --- plot mode 2: pro/ret contacts
				if (plotMode(2))
          mumax(2:3) = 0; semumax(2:3) = 0; nev(2:3) = 0; medmax(2:3) = 0; iqrmedmax(2:3) = 0;
					prESi = 0;
					reESi = 0;
					for e=1:length(s.whiskerBarContactClassifiedESA)
						if (length(strfind(lower(s.whiskerBarContactClassifiedESA.esa{e}.idStr),'protract')) > 0 & ...
								length(strfind(lower(s.whiskerBarContactClassifiedESA.esa{e}.idStr),wTag)) > 0)
							prESi = e;
						elseif (length(strfind(lower(s.whiskerBarContactClassifiedESA.esa{e}.idStr),'retract')) > 0 & ...
								length(strfind(lower(s.whiskerBarContactClassifiedESA.esa{e}.idStr),wTag)) > 0)
							reESi = e;
						end
					end
				  if (prESi > 0 & reESi > 0)
						prEx = {};
						reEx = {};
						if (excludeOthers & s.whiskerBarContactClassifiedESA.length() > 1)
						  id = s.whiskerBarContactClassifiedESA.ids(prESi);
							prEx = s.whiskerBarContactClassifiedESA.getExcludedCellArray(id);
						  id = s.whiskerBarContactClassifiedESA.ids(reESi);
							reEx = s.whiskerBarContactClassifiedESA.getExcludedCellArray(id);
						end
						[ mmt smmt medmt iqmt net] = s.plotEventTriggeredAverage(baseTSA, di, s.whiskerBarContactClassifiedESA.esa{prESi}, ...
							1, [timeRange(1) timeRange(2) valueRange(1) valueRange(2)], [spRaw(d) spMean(d)], [1 0 0], ...
							timeRange, prEx, timeRange, [showNCoords(1) showNCoords(2) + 0.2*valueRR], avgType);
            if (length(mmt) > 0) ; mumax(2) = mmt ; semumax(2) = smmt; nev(2) = net; medmax(2) = medmt ; iqrmedmax(2) = iqmt; end
						[ mmt smmt medmt iqmt net] = s.plotEventTriggeredAverage(baseTSA, di, s.whiskerBarContactClassifiedESA.esa{reESi}, ...
							1, [timeRange(1) timeRange(2) valueRange(1) valueRange(2)], [spRaw(d) spMean(d)], [0 0 1], ...
							timeRange, reEx, timeRange,  [showNCoords(1) showNCoords(2) + 0.4*valueRR], avgType);
            if (length(mmt) > 0) ; mumax(3) = mmt ; semumax(3) = smmt; nev(3) = net; medmax(3) = medmt ; iqrmedmax(3) = iqmt; end
					end
				end

  			% --- plot mode 3 : custom ESA, separate figure
				if (plotMode(3))
					if (tESi > 0)
						tEx = {};
						if (excludeOthers & trigESA.length() > 1)
						  id = trigESA.ids(tESi);
							tEx = trigESA.getExcludedCellArray(id);
						end
						[ mumax semumax medmax iqrmedmax nev] = s.plotEventTriggeredAverage(baseTSA, di, trigESA.esa{tESi}, ...
							1, [timeRange(1) timeRange(2) valueRange(1) valueRange(2)], [spRaw(d) spMean(d) ], triggeringESACols(t,:), ...
							timeRange, tEx, timeRange, showNCoords, avgType);
					end
	    	end

				% --- plot mode 4: custom ESA, all on one
				if (plotMode(4))
	        showNCoords(2) = min(valueRange) + (t/length(trigESA.esa))*valueRR;
					if (tESi > 0)
						tEx = {};
						if (excludeOthers & trigESA.length() > 1)
						  id = trigESA.ids(tESi);
							tEx = trigESA.getExcludedCellArray(id);
						end
						[ mumax semumax medmax iqrmedmax nev] = s.plotEventTriggeredAverage(baseTSA, di, trigESA.esa{tESi}, ...
							1, [timeRange(1) timeRange(2) valueRange(1) valueRange(2)], [spRaw(d) spMean(d) ], triggeringESACols(t,:), ...
							timeRange, tEx, timeRange, showNCoords, avgType);
					end
          if (d == 1) % label
					  selected = 0;
						if (~isnan(spMean(d)))
						  selected = 1;
							axes(spMean(d));
						elseif (~isnan(spRaw(d)))
						  selected =1;
							axes(spRaw(d));
						end
						if (selected)
							A = axis;
							R = A(4)-A(3);
							R2 = A(2)-A(1);
							X = A(1)+0.25*R2;

							istr = trigESA.esa{tESi}.idStr;
							istr = strrep(istr,'Contacts for ', '');
							istr = strrep(istr,'Coincidence of', 'C ');
							istr = strrep(istr,'contacts for ', '');
							istr = strrep(istr,'Protraction','P');
							istr = strrep(istr,'Retraction','R');
				
							text(X,A(3)+(t/length(trigESA.esa))*R, istr, 'Color', triggeringESACols(t,:));
						end
					end
					plotTitleStr = '';
	    	end

        % --- bar plotting
        if (plotBar)
				  if (length(plotBarX) > 0)
					  pbX = plotBarX(t);
					else 
					  pbX = t;
					end
					axes(spBar(d));
          hold on;
          A = axis;
          R = diff(valueRange);
          nx = 0;
          if (plotMode(1)) ; nx = nx+ 1; end
          if (plotMode(2)) ; nx = nx + 2; end
          if (plotMode(3) | plotMode(4)) nx = length(triggeringESAIds); end

          % mumax vs medmax
					if (avgType == 1)
					  avgmax = mumax;
						avgmaxerr = semumax;
					elseif (avgType == 2)
					  avgmax = medmax;
						avgmaxerr = iqrmedmax;
					end
 
          if (plotMode(1) & length(avgmax) > 0)
            plot_bar_error(1, avgmax(1), avgmaxerr(1), 0.8, [0 0 0]);
						text(.1,A(3)+0.7*R,['(' num2str(nev(1)) ') All ' wTag],'Color',[0 0 0]); 
          end
          if (plotMode(2)& length(avgmax) > 0)
            plot_bar_error(2, avgmax(2), avgmaxerr(2), 0.8, [1 0 0]);
            plot_bar_error(3, avgmax(3), avgmaxerr(3), 0.8, [0 0 1]);
						text(.1,A(3)+0.1*R,['(' num2str(nev(2)) ') Pro ' wTag],'Color',[1 0 0]);
						text(.1,A(3)+0.4*R,['(' num2str(nev(3)) ') Ret ' wTag],'Color',[0 0 1]);
          end
          if ((plotMode(3) | plotMode(4))& length(avgmax) > 0)
            plot_bar_error(pbX, avgmax, avgmaxerr, 0.8, triggeringESACols(t,:));
						istr = trigESA.esa{tESi}.idStr;
						istr = strrep(istr,'Contacts for ', '');
						istr = strrep(istr,'Coincidence of', 'C ');
						istr = strrep(istr,'contacts for ', '');
						istr = strrep(istr,'Protraction','P');
						istr = strrep(istr,'Retraction','R');
					  text(pbX-.25,valueRange(1)+0.95*R, [ istr ' (n=' num2str(nev) ')' ], ...
                   'Color', [0 0 0], 'Rotation', -90);
						set(spBar(d),'XTick',[]);
          end
        end


				% --- figure cleanup
				
				% adjust individual panels to be right size etc.
				if (~isnan(spRaw(d))) % raw
					axes(spRaw(d));
					axis([timeRange(1) timeRange(2) valueRange(1) valueRange(2)]);
					title([plotTitleStr ' ' obj.dateStr{d}]);
				end
				if (~isnan(spBar(d))) % bar
					axes(spBar(d));
          nx = 0;
					if (length(plotBarX) > 0)
					  nx = max(plotBarX);
					else
						if (plotMode(1)) ; nx = nx+ 1; end
						if (plotMode(2)) ; nx = nx + 2; end
						if (plotMode(3) | plotMode(4)) nx = length(triggeringESAIds); end
					end
 
					axis([0 nx+1 valueRange(1) valueRange(2)]);
          plot([0 nx+1], [0 0], 'k-');
					title([plotTitleStr ' ' obj.dateStr{d}]);
				end
				if (~isnan(spMean(d))) % mean
					axes(spMean(d));
					axis([timeRange(1) timeRange(2) valueRange(1) valueRange(2)]);
					title([plotTitleStr ' ' obj.dateStr{d}]);
				end

				% legend
				if (plotMode(2) & d == 1) % only makes sense if more than 1 plotted
				  selected = 0;
				  if (~isnan(spMean(d)))
					  selected = 1;
					  axes(spMean(d));
					elseif (~isnan(spRaw(d)))
					  selected = 1;
		  			axes(spRaw(d));
	  			end
					if (selected)
						A = axis;
						R = A(4)-A(3);
						R2 = A(2)-A(1);
						X = A(1)+0.1*R2;
						text(X,A(3)+0.1*R,'Protraction','Color',[1 0 0]);
						text(X,A(3)+0.4*R,'Retraction','Color',[0 0 1]);
						if (plotMode(1)) ;	text(X,A(3)+0.7*R,'All contacts','Color',[0 0 0]); end
						legendShown = 1;
					end
				end
			else
			  if (length(di) == 0)
					disp(['plotEventTriggeredAverageCrossDays::ID ' num2str(displayedId) ' is not present in session ' obj.dateStr{d} '(# ' num2str(d) ')']);
				end
			end
		end
  end
