%
% SP Apr 2011
%
% For plotting the ROI touch index across multiple sessions.
%
% USAGE:
%
%  sA.plotRoiTouchIndex(params)
%
%  params: structure with following fields
%
%    plotsShown (1=on 0=off): (1): touch index for individual whiskers,sessions
%                             (2): pool across days
%                             (3): color map showing each ROI's perfered whisker
%                             (4): roi touch index across days 
%    whiskerTags: which whiskers to include ; 'pool' is average idx across whiskers
%    sessions: vector of session indices to use, within sessionArray
%    scoreThresh: if plotmode(3), what is minimum touch score to count as pref. whisker?
%    maxVal, minVal: max and min values for color scalings (plot modes 1,2)
%    roiIds: if plotmode 4, which Rois to plot (1 figure/roi)
%    printDir: if specified, will print to this directory ...
%    printTag: added to print filename
%    
function plotRoiTouchIndex(obj, params)
	if (nargin < 2)
		help ('session.sessionArray.plotRoiTouchIndex');
	  disp('plotRoiTouchIndex::must specify params');
		return;
	end
 
  % --- process params
	plotsSHown = [1 1 1 0];
	whiskerTags = obj.whiskerTag;
	whiskerTags{length(whiskerTags)+1} = 'pool'; 
	sessions = 1:length(obj.sessions);
	scoreThresh = 0.01;
	maxVal = [];
	minVal = [];
	roiIds = [];
	printDir = [];
	printTag = [];
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'scoreThresh')) ; scoreThresh = params.scoreThresh; end
	if (isfield(params, 'maxVal')) ; maxVal = params.maxVal; end
	if (isfield(params, 'minVal')) ; minVal = params.minVal; end
	if (isfield(params, 'roiIds')) ; roiIds = params.roiIds; end
	if (isfield(params, 'printDir')) ; printDir = params.printDir; end
	if (isfield(params, 'printTag')) ; printTag = params.printTag; end
	
	% cell whiskerTAg
	if (~iscell(whiskerTags)) ; whiskerTags = {whiskerTags} ; end
	
	% sessions?
	if (length(sessions) == 0) ; sessions = 1:length(obj.sessions) ; end

  % are we dealing with directinoal whiskers?
	directional = 0;
	if (length(obj.sessions{sessions(1)}.whiskerTag)*2 == size(obj.sessions{sessions(1)}.touchIndex,1)) ; directional = 1; end

	% are we poolin? pool AWLAYS @ end
  poi = find(strcmp(whiskerTags, 'pool'));
	if (length(poi) > 0 & poi < length(whiskerTags)) 
	  whiskerTags{poi} = whiskerTags{end} ; 
		whiskerTags{end} = 'pool';
  	poi = length(whiskerTags);
	end

  % cross-session, whisker average
	if (directional & length(poi) > 0)
  	touchMatrix = nan*zeros(length(obj.roiIds), 2*length(whiskerTags)-1, length(obj.sessions));
		poi = 2*length(whiskerTags)-1;
	elseif (directional & length(poi) == 0)
  	touchMatrix = nan*zeros(length(obj.roiIds), 2*length(whiskerTags), length(obj.sessions));
	else
  	touchMatrix = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	end

  % print fname
	printFnameRoot = obj.mouseId;
	if (length(printTag) > 0) ; printFnameRoot = [printFnameRoot '_' printTag]; end
	if (directional) ; printFnameRoot = [printFnameRoot '_direct']; end

	% --- looop thru and build touchMatrix 
	for i=1:length(obj.sessions)
		nW = length(obj.sessions{i}.whiskerTag);

		for w=1:length(whiskerTags)
		  if (~strcmp(whiskerTags{w},'pool'))
  			wi = find(strcmp(lower(obj.sessions{i}.whiskerTag), lower(whiskerTags{w})));
				if (length(wi) > 0)
					% populate touchMatrix
					[sRoiIds sidx] = sort(obj.sessions{i}.caTSA.ids);
					val = find(ismember(obj.roiIds, obj.sessions{i}.caTSA.ids));
					if (~directional)
						touchMatrix(val, w,i) = obj.sessions{i}.touchIndex(wi,sidx);
					else
						touchMatrix(val, (2*w)-1,i) = obj.sessions{i}.touchIndex((2*wi)-1,sidx);
						touchMatrix(val, (2*w),i) = obj.sessions{i}.touchIndex(2*wi,sidx);
					end
				end
			end
		end

		% compute pooled touchMatrix
		if (length(poi) > 0)
			touchMatrix(:, poi,i) = nanmean(touchMatrix(:,1:poi-1,i),2);
		end
	end

	% directinoal? redo whiskertags
	if (directional)
	  nWhiskerTags = {};
		ew = 2*length(whiskerTags);
	  if (length(poi) > 0) ; nWhiskerTags{2*length(whiskerTags)-1} = 'pool' ; ew = 2*(length(whiskerTags)-1); end
	  for e=1:2:ew-1
      nWhiskerTags{e} =  ['Pro ' whiskerTags{ceil(e/2)}];
			nWhiskerTags{e+1} = ['Re ' whiskerTags{ceil(e/2)}];
		end
	  whiskerTags = nWhiskerTags;
	end

	% --- plot across sessions, whiskers
	if (plotsShown(1))
	  pparams.dataMat = touchMatrix;
	  pparams.sessions = sessions;
		pparams.plotMode = 1;
		if (length(maxVal) ==1 )
			pparams.varMax = maxVal*ones(1,length(whiskerTags));
		elseif (length(maxVal) == length(whiskerTags))
		  pparams.varMax = maxVal;
		end
		if (length(minVal) == 1)
			pparams.varMin = minVal;
		elseif (length(minVal) == length(whiskerTags))
		  pparams.varMin = minVal;
		end
		pparams.varLabel = whiskerTags;
	  obj.plotRoiMatrixCrossDays(pparams);

		% print?
		if (length(printDir) > 0)
      printFname = [printDir filesep printFnameRoot '_touch_index_FOV.pdf'];

		  set(gcf,'Position', [1 1 3840 1200]);
			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		end
	end

	% --- overall sensitivity plots GROUPED all sessions
	if (plotsShown(2))
		maxValU = 0;
		minValU = 1;
		for w=1:length(whiskerTags)
			wTMt = nanmedian(squeeze(touchMatrix(:,w,:)),2);
			maxValU = max(maxValU,nanmax(reshape(wTMt,[],1)));
			minValU = min(minValU,nanmin(reshape(wTMt,[],1)));
		end
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		for w=1:length(whiskerTags)
		  ax = subplot(nW, nW,w);
			wTM = squeeze(touchMatrix(:,w,:));
			obj.sessions{sessions(1)}.plotColorRois([],[],[],[],nanmedian(wTM,2),[minValU maxValU],ax,0);
			title(whiskerTags{w});
		end

  	if (length(printDir) > 0)
      printFname = [printDir filesep printFnameRoot '_touch_index_cross_session_FOV.pdf'];

		  set(gcf,'Position', [1 1 3840 1200]);
			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		end
	end

	% --- plots prefered whisker for each roi
	if (plotsShown(3))
	  figure('Name', 'Preferred whiskers', 'NumberTitle','off');
    nS = ceil(sqrt(length(sessions)));

    if (length(poi) > 0)
		  uWhiskerTags = whiskerTags(1:end-1);
		else
		  uWhiskerTags = whiskerTags;
		end

    % get matrix and plot en route
		prefWidx = nan*zeros(size(touchMatrix,1),size(touchMatrix,3));
    for i=1:length(sessions)
		  si = sessions(i);
      [values widx] = nanmax(touchMatrix(:,:,si),[],2);
			valid = find(values > scoreThresh);
      if (length(valid) > 0)
			  prefWidx(valid,i) = widx(valid);
			end

			% plot
      ax = subplot(nS,nS,i);
			cmap = [0 0 0 ; hsv(length(uWhiskerTags))];
			obj.sessions{sessions(1)}.plotColorRois([],[],[],cmap,prefWidx(:,i),[0 length(uWhiskerTags)],ax,0);

			% legendary
			if (i == 1)
			  A = axis ; Rx = A(2)-A(1) ; Ry = A(4)-A(3);
			  for w=1:length(uWhiskerTags)
				  text(A(1) + 0.1*Rx, 0.25*A(3) + 0.5*(w/length(uWhiskerTags))*Ry, uWhiskerTags{w}, 'Color', cmap(w+1,:));
				end
			end
			title(obj.dateStr{sessions(i)});
		end
	end

	% --- plot, for selected rois, touch index cross days
	if (plotsShown(4))
	  if (length(maxVal) == 1) ; MVal = maxVal; else ; MVal = 1; end
	  if (length(minVal) == 1) ; mVal = minVal; else ; mVal = 0; end
	  Rval = MVal - mVal;
    if (length(poi) > 0)
		  uWhiskerTags = whiskerTags(1:end-1);
		else
		  uWhiskerTags = whiskerTags;
		end
		cmap = [0 0 0; hsv(length(uWhiskerTags))];

		figure;
		nR = ceil(sqrt(length(roiIds)));
	  for r=1:length(roiIds)
		  subplot(nR,nR,r);
		  ri = find(obj.roiIds == roiIds(r));

      % plot it ...
			for w=1:length(uWhiskerTags)
				vals = squeeze(touchMatrix(ri,w,sessions));
				plot(1:length(sessions), vals, 'o-', 'Color', cmap(w,:), 'MarkerFaceColor', cmap(w,:));
				text (0.5, mVal + 0.5*Rval + 0.5*Rval*((w-1)/length(uWhiskerTags)), uWhiskerTags{w}, 'Color', cmap(w,:));
				hold on;
			end

			for i=1:length(sessions)
				si = sessions(i);

				% add session label
			  text(i,mVal - 0.2*Rval, obj.dateStr{si}(1:6) , 'Rotation', 90);
			end
			axis([0 length(sessions)+1 mVal-0.25*Rval MVal]);
			title(['Touch index for : ' num2str(roiIds(r))]);
		end

		% print?
		if (length(printDir) > 0)
      printFname = [printDir filesep printFnameRoot '_touch_index_line_per_ROI.pdf'];
		 
		  set(gcf,'Position', [1 1 3840 1200]);
			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		end
	end
