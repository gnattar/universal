%
% SP Apr 2011
%
% For plotting the ROI discrimination index across multiple sessions.
%
% USAGE:
%
%  sA.plotDiscrim(params)
%
%  params: structure with following fields
%    sessions: vector of session indices to use, within sessionArray
%    nPanels: [nCols nRows] ; by default, both are ceil(sqrt(length(sessions)))
%    roiIds: if plotsShown(3), these are the rois focused on
%    plotsShown (1): show color-coded field of view for all animals
%               (2): show a plot with a line for EACH roi across days
%               (3): show a plot with a line for roiIds across days
%               3 element vector with aforementinoed elements having values 
%               of 0 (dont show) or 1 (show)
%    printDir: if specified, will print to this directory ...
%
function plotDiscrim(obj, params)
  if (nargin < 2)
	  params = [];
	end
 
  % --- process params
	sessions = 1:length(obj.sessions);
	nPanels = [];
	roiIds = [];
	plotsShown = [1 1 0];
	printDir = [];
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'nPanels')) ; nPanels = params.nPanels; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'roiIds')) ; roiIds = params.roiIds; end
	if (isfield(params, 'printDir')) ; printDir = params.printDir; end

	
	% sessions?
	if (length(sessions) == 0) ; sessions = 1:length(obj.sessions) ; end

	% print name
	printFnameRoot = obj.mouseId;

  % --- figure setup for FOV
	if (length(nPanels) == 0)
		nCols = ceil(sqrt(length(sessions)));
		nRows = ceil(sqrt(length(sessions)));
	else
	  nCols = nPanels(1);
		nRows = nPanels(2);
	end
   
	% --- determine roi vector
	allRoiIds = obj.roiIds;
	discrimMat = nan*zeros(length(allRoiIds), length(sessions));

	% --- looop thru sessions, gathering data, plotting as needbe
	for i=1:length(obj.sessions)
    % populated discrimMat
		for r=1:length(allRoiIds)
		  ri = find(obj.sessions{i}.caTSA.ids == allRoiIds(r));
			if (length(ri) > 0)
			  discrimMat(r,i) = obj.sessions{i}.discrimIndex(ri);
			end
	  end
	end
	idx = find(discrimMat < 0.5);
	discrimMat(idx) = 1-discrimMat(idx);
global dm
dm = discrimMat;

	if (plotsShown(1))	
		figure('Name', 'Discrimination', 'NumberTitle','off');
		pparams.dataMat = discrimMat;
		pparams.sessions = sessions;
		pparams.plotMode = 2;
		pparams.varMax = 1;
		pparams.varMin = 0.5;
		pparams.varLabel = {};
		pparams.varMaxColor = [1 1 0];
		obj.plotRoiMatrixCrossDays(pparams)

		% print?
		if (length(printDir) > 0)
      printFname = [printDir filesep printFnameRoot '_discrim_FOV.pdf'];

%		  set(gcf,'Position', [1 1 3840 1200]);
			print(gcf, '-depsc2',printFname);
%			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
%      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		end
	end

	% --- line plots across days
	if (plotsShown(2) | plotsShown(3)) ; figure ; end
	if (plotsShown(2))
	  subplot(2,1,1);
		hold on;
		plot(discrimMat(:,sessions)');
		set (gca, 'TickDir', 'out');
		xlabel('time (days)');
		ylabel('ROC area');
		for s=1:length(sessions)
			text(s,0.1, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		end
		plot ([0 length(sessions)+1], [0.5 0.5], 'k:');
		axis([0 length(sessions)+1 0 1]);
	end

	if (plotsShown(3))
	  subplot(2,1,2);
		hold on;
		colors = jet(length(roiIds));
		for r=1:length(roiIds)
		  ri = find(allRoiIds == roiIds(r));
		  plot(discrimMat(ri,sessions), 'o-', 'Color', colors(r,:), 'MarkerFaceColor', colors(r,:));
			text(0.8*length(sessions), 1-(r/10), num2str(roiIds(r)), 'Color', colors(r,:));
		end
		set (gca, 'TickDir', 'out');
		xlabel('time (days)');
		ylabel('ROC area');
		for s=1:length(sessions)
			text(s,0.1, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		end
		plot ([0 length(sessions)+1], [0.5 0.5], 'k:');
		axis([0 length(sessions)+1 0 1]);
	end

	% print 2/3
	if ((plotsShown(2) | plotsShown(3)) & length(printDir) > 0)
    printFname = [printDir filesep printFnameRoot '_discrim_rois.pdf'];

%	  set(gcf,'Position', [1 1 3840 1200]);
%		set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
 %   print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		print(gcf, '-depsc2',printFname);
	end
