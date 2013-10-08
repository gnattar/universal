%
% SP Apr 2011
%
% Updates cross-day plot.
%
% USAGE:
%
%   mdg.updateCrossDayPLot()
%
function updateCrossDayPlot(obj)


  % draw at all?
	if (~ obj.crossDayOn) 
	  if (length(obj.crossDayFigH ~= 0))
		  if (ishandle(obj.crossDayFigH))
			  delete(obj.crossDayFigH);
			end
		end
		return;
	end

  % generate figure or use existing?
	newFig = 0;

  if (length(obj.crossDayFigH) == 0)
	  newFig = 1;
	elseif(~ishandle (obj.crossDayFigH))
	  newFig = 1;
	end

	% pull current roiArray
	rACurrent = obj.roiArrayArray{obj.rAidx};
	selRoi = rACurrent.guiSelectedRoiIds;

	% draw new
	if (newFig)
	  obj.crossDayFigH = figure ('Position', [50 50 800 600]);
		
		switch computer % computer-dependent renderer
			case {'MACI', 'MACI64'}
				renderer = 'opengl';
			case {'GLNXA64', 'GLNX86'}
				renderer = 'opengl';
			otherwise
				renderer = 'opengl';
		end

		set(obj.crossDayFigH,'RendererMode', 'manual', 'Toolbar', 'none', 'DockControls', 'off', ...
		                           'Renderer', renderer, 'MenuBar', 'none', 'NumberTitle', 'off', 'name', ...
															 ['ROI ' num2str(selRoi) ' over days; click panel to select day']);

    % plot setup
		N = ceil(sqrt(length(obj.roiArrayArray)));
		nr = N;
		nc = N;
		c=1;
		r=1;

		for n=1:length(obj.roiArrayArray)
			% obj.crossDayAxesH(n) = subplot(N,N,n);
			obj.crossDayAxesH(n) = subplot('Position', [(c-(1/2))/(nc+1) (nr-r)/nr 1/(nc+2) 0.8/nr]);
			title(strrep(obj.roiArrayArray{n}.idStr,'_','-'));
			c=c+1;
			if (c > nc) ; c = 1; r = r+1 ; end
		end
	end

  % and now actualy do everything(!)
	if (length(selRoi) == 1)
	  for n = 1:length(obj.roiArrayArray)
			rA = obj.roiArrayArray{n};

			s1 = rA.imageBounds(2)/max(rA.imageBounds);
			s2 = rA.imageBounds(1)/max(rA.imageBounds);

			idx = find(rA.roiIds == selRoi);
      if (length(idx) > 0) % sometimes not present if, e.g., new roi
        roi = rA.rois{idx};

        % get the zoomed image and the roi outline in it
        if (length(roi.indices) > 0)
          [zim rzim]= rA.generateZoomedRoiImage(selRoi, rACurrent.guiShowFlags(1), rACurrent.guiShowFlags(2), 10);
					lzim = reshape(zim,[],1);
          zim = 0.5*zim/median(lzim);

          % if this is the selected one outline in white
          if (n == obj.rAidx)
            sz = size(zim);
            zim([1:2 sz(1)-1:sz(1)],:) = 1; %max(max(zim));
            zim(:, [1:2 sz(2)-1:sz(2)]) = 1; %max(max(zim));
          end

          % plot it
          imshow(zim,'Parent', obj.crossDayAxesH(n), 'Border','tight','InitialMagnification','fit'); 
          greenim = cat(3, roi.color(1)*ones(size(zim)), roi.color(2)*ones(size(zim)), roi.color(3)*ones(size(zim)));
          hold(obj.crossDayAxesH(n), 'on'); 
          ih = imshow(greenim,'Parent', obj.crossDayAxesH(n)); 
          hold(obj.crossDayAxesH(n), 'off'); 
          set(ih, 'AlphaData',0.20*rzim); 
          set(ih,'ButtonDownFcn', {@crossDayFigProcessor, n, obj}); 
          set(obj.crossDayAxesH(n), 'DataAspectRatio', [s1 s2 1]);
          set(get(obj.crossDayAxesH(n), 'Title'), 'String' , strrep(rA.idStr,'_','-'));
        end
      end
		end
		set (obj.crossDayFigH, 'name', ['ROI ' num2str(selRoi) ' over days; click panel to select day']);
	else
	  disp('Select a *single* ROI to do mutliday zoom');
	end


%
% when you click on any panel of the mutliday figure it goes here
%
function crossDayFigProcessor(src, event, selectDay, obj)
  % select the day if not already selected
	if (selectDay ~= obj.rAidx)
		obj.setRAIdx(selectDay); 
	end


