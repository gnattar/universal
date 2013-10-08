%
% SP May 2011
%
% Method to plot a matrix across sessions for a series of parameters.  For intance,
%  if you want a color-coded plot, where color intensity indicates how strong a
%  ROI is sensitive to a particular whisker's touch, with each column being a 
%  session and each row being a whisker.  
%  
%  Can also generate bar graphs for a *single* ROI across featuers.
%
%  USAGE:
%
%    sA.plotRoiMatrixCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    dataMat: tensor, with (r,v,s) representing session s for variable
%             v at ROI r (session is indexed as sA.sessiosn; roi as 
%             sA.roiIds).  IF matrix, (r,s) --> assumed there is only 1 v.
%    plotMode: 1: (default) each row is a variable, column session
%              2: 1 figure per variable, square set for days
%              3: bar -- in this case, pass a set of rois, and for each ROI, 
%                 a separate figure with bars (1/var) is generated
%
%    sessions: vector of session indices to use, within sessionArray
%    roiIds: which roi Ids to plot? default all
%
%    varLabel: cell array of variable names, if you want it
%    varMaxColor: matrix where (v,:) is RGB triplet for variable v when
%                 that variable is at max
%    varMax: vector with max values for variables; if not provided, varMax
%            is max over ENTIRE matrix.
%    varMin: vector with min values for variables; if not provided, varMin
%            is min over ENTIRE matrix.
%
function plotRoiMatrixCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotRoiMatrixCrossDays');
		return;
	end

	% dflts
	sessions=1:length(obj.sessions);
	roiIds = obj.roiIds;
	varLabel = {};
	varMax = [];
	varMin = [];
	varMaxColor = [];
	plotMode = 1;

  dataMat = params.dataMat; % must be passed
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'roiIds')) ; roiIds = params.roiIds; end
	if (isfield(params, 'varLabel')) ; varLabel = params.varLabel; end
	if (isfield(params, 'plotMode')) ; plotMode = params.plotMode; end
	if (isfield(params, 'varMax')) ; varMax = params.varMax; end
	if (isfield(params, 'varMin')) ; varMin = params.varMin; end
	if (isfield(params, 'varMaxColor')) ; varMaxColor = params.varMaxColor; end

	% --- input sanity checks
  if (length(size(dataMat)) == 2)
	  tdataMat(:,1,:) = dataMat;
    dataMat = tdataMat;
	end

	if (length(varMaxColor) == 0) 
	  varMaxColor = hsv(size(dataMat,2));
	end

	if (length(varMax) == 0)
	  for v=1:size(dataMat,2)
		  varMax(v) = nanmax(nanmax(dataMat(:,v,:)));
		end
	elseif (length(varMax) == 1)
	  varMax = varMax*ones(1,size(dataMat,2));
	end

	if (length(varMin) == 0)
	  for v=1:size(dataMat,2)
		  varMin(v) = nanmin(nanmin(dataMat(:,v,:)));
		end
	elseif (length(varMin) == 1)
	  varMin = varMin*ones(1,size(dataMat,2));
	end

	% --- session x variable plotter for ALL rois
	if (plotMode == 1)
	  figure;

    % size constraints
		dr = 1/size(dataMat,2);
		dc = 1/length(sessions);
		sx = 0.8/length(sessions);
		sy = 0.8/size(dataMat,2);

	  % loop
    for v=1:size(dataMat,2)
		  % colormap generate
			startCol = [0 0 0];
      cmap = [linspace(startCol(1),varMaxColor(v,1),256)' linspace(startCol(2),varMaxColor(v,2),256)' linspace(startCol(3),varMaxColor(v,3),256)'];

			% session looop
	    for si=1:length(sessions)
			  axRef = subplot('Position', [(si-0.8)*dc 1-((v-0.1)*dr) sx sy]);
  		  obj.sessions{sessions(si)}.plotColorRois([],[],[],cmap,dataMat(:,v,sessions(si)),[varMin(v) varMax(v)],axRef,0);

				% date?
				if (v == 1)
				  title(obj.dateStr{sessions(si)});
				end

				% variable name?
				if (si == 1)
				  if (length(varLabel) > 0)
					  ylabel(varLabel{v});
					end
				end
			end
		end
	end

	% --- session plotter for ALL rois,1 figure / variable
	if (plotMode == 2)
    % size constraints
		Ns = ceil(sqrt(length(sessions)));

	  % loop over variables
    for v=1:size(dataMat,2)
		  if (length(varLabel) > 0)
        figure('Name', varLabel{v}, 'NumberTitle','off');
			end

		  % colormap generate
			startCol = [0 0 0];
      cmap = [linspace(startCol(1),varMaxColor(v,1),256)' linspace(startCol(2),varMaxColor(v,2),256)' linspace(startCol(3),varMaxColor(v,3),256)'];

			% session looop
			ci = 1;
			ri =1;
	    for si=1:length(sessions)
			  axRef = subplot('Position', [(ci-0.8)*(1/Ns) 1-((ri-0.1)*(1/Ns)) 0.8/Ns 0.8/Ns]);
  		  obj.sessions{sessions(si)}.plotColorRois([],[],[],cmap,dataMat(:,v,sessions(si)),[varMin(v) varMax(v)],axRef,0);

				% date?
			  title(obj.dateStr{sessions(si)});
        
				% increment col
				ci = ci+1 ; if (ci > Ns) ; ci = 1; ri = ri + 1; end
			end
		end
	end
	
