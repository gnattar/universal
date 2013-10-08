%
% SP May 2011
%
% This will plot contact-evoked fluorescence change for all days,  whisker 
%   contacts.
%
% USAGE:
%
%  sA.plotContactTriggeredImagesCrossDays(params)
%
%  params - structure with variables:
%
%    whiskerTags: which whiskers to include (default all)
%    sessions: vector of session indices to use, within sessionArray
%    nPanels: [nCols nRows] ; by default, both are ceil(sqrt(length(sessions)))
%    printDir: if specified, will print to this directory ...
%
function plotContactTriggeredImagesCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) ; params = []; end

	% dflts
  whiskerTags = obj.whiskerTag;
	sessions=1:length(obj.sessions);
	nPanels = [];
  printDir = [];

	if (isfield(params,'whiskerTags')) ; whiskerTags = params.whiskerTags ; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'nPanels')) ; nPanels = params.nPanels; end
	if (isfield(params, 'printDir')) ; printDir = params.printDir; end

	% --- input sanity checks
	
	% cell whiskertags
	if (~iscell(whiskerTags)) ; whiskerTags = {whiskerTags} ; end

	% sessions?
	if (length(sessions) == 0) ; sessions = 1:length(obj.sessions) ; end

  % figure setup
	if (length(nPanels) == 0)
		nc = ceil(sqrt(length(sessions)));
		nr = ceil(sqrt(length(sessions)));
	else
	  nc = nPanels(1);
		nr = nPanels(2);
	end

  % prepare list of contact classes
	contactList = {};
  for w=1:length(whiskerTags)
	  contactList{length(contactList)+1} = ['Protraction contacts for ' whiskerTags{w}];
	  contactList{length(contactList)+1} = ['Retraction contacts for ' whiskerTags{w}];
	end

	% pooled images
  maxImages = {};
	meanImages = {};
	nim = zeros(1,length(sessions));
 
	% print name
	printFnameRoot = obj.mouseId;

	% --- actual plotting
  for c=1:length(contactList)
	  figure('Name',contactList{c}, 'NumberTitle', 'off');
		ri = 1; ci = 1;
		for i=1:length(sessions)
		  % vars
			si = sessions(i);
			s = obj.sessions{si};

			% subplot
			axRef = subplot('Position', [(ci-(1/2))/(nc+1) (nr-ri)/nr 1/(nc+2) 0.8/nr]);

			% look for image in roiArray
			rA = s.caTSA.roiArray;
			im = [];
			for ai=1:length(rA.accessoryImagesRelPaths)
			  if(length(strfind(rA.accessoryImagesRelPaths{ai}, contactList{c})) > 0)
				  impath = rA.accessoryImagesRelPaths{ai};
          pIdx = find(impath == '#');
					imIdx = str2num(impath(pIdx(1)+1:pIdx(2)-1));
					im = rA.permanentAccessoryImages{imIdx};
					break;
				end
      end
      
      % if found do plot
			if (length(im) > 0)
        % pooled images
				if (length(maxImages) < i)
				  maxImages{i} = im;
					meanImages{i} = im;
          nim(i) = nim(i) + 1;
				else
				  if (size(maxImages{i},2) == 0)
						maxImages{i} = im;
						meanImages{i} = im;
						nim(i) = nim(i) + 1;
					else
						maxImages{i} = nanmax(maxImages{i},im);
						meanImages{i} = meanImages{i} + im;
						nim(i) = nim(i) + 1;
				  end
				end
			  
				% detailed plotter
        plotIm (im, axRef, obj, si);
			end

		  % increment figure stuff
			ci = ci+1;
			if (ci > nc) ; ci = 1; ri = ri+1 ; end
		end
		% print?
		if (length(printDir) > 0)
      printFname = [printDir filesep printFnameRoot '_contact_triggered_by_' contactList{c} '.pdf'];

		  set(gcf,'Position', [1 1 3840 1200]);
			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
		end
	end

	% --- average images
	maxf = figure('Name','Max Image', 'NumberTitle', 'off');
	muf = figure('Name','Mean Image', 'NumberTitle', 'off');
	ri = 1; ci = 1;
	for i=1:length(meanImages)
		% vars
		si = sessions(i);
		s = obj.sessions{si};

		% mean image
		figure(muf);
		im = meanImages{i}/nim(i);
		axRef = subplot('Position', [(ci-(1/2))/(nc+1) (nr-ri)/nr 1/(nc+2) 0.8/nr]);
    plotIm (im, axRef, obj, si);

		% max image
		figure(maxf);
		im = maxImages{i};
		axRef = subplot('Position', [(ci-(1/2))/(nc+1) (nr-ri)/nr 1/(nc+2) 0.8/nr]);
    plotIm (im, axRef, obj, si);


		% increment figure stuff
		ci = ci+1;
		if (ci > nc) ; ci = 1; ri = ri+1 ; end
	end

	% print?
	if (length(printDir) > 0)
	  figure(maxf);
    printFname = [printDir filesep printFnameRoot '_max_contact_triggered.pdf'];
	  set(gcf,'Position', [1 1 3840 1200]);
	  set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
    print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
	  figure(muf);
    printFname = [printDir filesep printFnameRoot '_mean_contact_triggered.pdf'];
	  set(gcf,'Position', [1 1 3840 1200]);
	  set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
    print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
	end

%
% plots a single image ...
% 
function plotIm (im, axRef, obj, si)
	% image cleanup
	nidx = find(isnan(im));
	im(nidx) = 0;
	lim = reshape(im,[],1);
	topVal = quantile(lim,.9975);
	botVal = quantile(lim,.0025);
	im(find(im >= topVal)) = topVal;
	im(find(im <= botVal)) = botVal;

	% min/max
	lim = reshape(im,[],1);
	cim = nanmedian(lim);
	im = im-cim; % center at PDF peak
	mim = min(min(im));
	Mim = max(max(im));
	Rim = Mim-mim;
	imshow(im, [mim Mim], 'Parent', axRef, 'Border', 'tight');
	axis square;

	% make relevant colormap
	nneg = ceil(256*abs(mim)/Rim);
  npos = ceil(256*abs(Mim)/Rim);
  
  if (length(nneg) == 0 | length(npos) == 0) ; return ; end
  
	nVec = 1:(-1/nneg):0;
	pVec = 0:(1/npos):1;
	cmap = zeros(256,3);
	cmap(1:length(nVec),3) = nVec;
	cmap(256-length(pVec)+1:256,1) = pVec;
	colormap(cmap);
	extern_freezeColors(axRef);
	% set lims etc.
	title([obj.dateStr{si}]);

