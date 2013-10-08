% columnar plots

% activity
if (0)
  figure;
	base_depth = 70;
	ddepth = 45;
  for si = 1:length(S)
	  s = S{si};
	  evrate{si} = zeros(1,length(s.caTSA));
		for i=1:length(s.caTSA)
		  bt = s.caTSA.caPeakEventSeriesArray.esa{i}.getBurstTimes(1000);
		  evrate{si}(i) = length(bt);
		end

		% convert to rate
		dtMs = mode(diff(s.caTSA.time));
		nTimePoints = length(s.caTSA.time);
		numSeconds = nTimePoints*dtMs/1000;
    evrate{si}(:) = evrate{si}(:)/numSeconds;

		subplot(length(S),2,si*2 -1);
		hist(evrate{si},0:.001:2);
		axis([0 .2 0 500]);
		if (si < length(S))
		  set(gca, 'XTick', []);
		else
		xlabel('Event rate (Hz)');
		end
		ylabel([num2str(base_depth + (si-1)*ddepth) ' um']);
		ylabel(['Vol ' num2str(si)]);
		set(gca,'TickDir', 'out');

		subplot(length(S),2,si * 2);
		hist(evrate{si},0:.001:2);
		axis([0 .2 0 30]);
		if (si < length(S))
		  set(gca, 'XTick', []);
		else
			xlabel('Event rate (Hz)');
		end
		set(gca,'TickDir', 'out');
	end
end

% movie thru depth
if (1)
  if (0)
		% AUC:
		fname = 'ContactsForC2AUC';
		fname = 'ProtractionContactsForC2AUC';
		fname = 'RetractionContactsForC2AUC';
		colRange = [0.5 1];
	  color = [  1 0 1];
		thresh = 0.75;
	end

  if (0)
		% pprod:
		fname = 'RetractionContactsForC2PProd';
		fname = 'ProtractionContactsForC2PProd';
		fname = 'ContactsForC2PProd';
		colRange = [0 .1];
		thresh = 0.075;
	end

  if (0)
		% corr:
		fname = 'WhiskerSetpointCorr';
		fname = 'MeanWhiskerAmplitudeCorr';
		colRange = [0 .2];
		thresh = 0.1;
	end

  avion = 0;
	if (avion)
	  aviobj = avifile('~/Desktop/allcells.avi', 'fps', 3);
	end

  fig = figure;
	ax = axes;

  nV = length(S);
	nF = 3;
	count =  zeros(1,nF*nV);
	frac =  zeros(1,nF*nV);

  idx = 1;
	cidx = 1;
	aidx = 1;
	com = [];
	allcom = [];

	colRange = [0 0.1];
	thresh = .05;
	color = [ 0 1 1];

%  for v=1:nV
  for v=8;
	  s = S{v};
    
		if (1) % burstRate
		  feat = 0*s.caTSA.ids;
			dtMs = mode(diff(s.caTSA.time));
			nTimePoints = length(s.caTSA.time);
			numSeconds = nTimePoints*dtMs/1000;

			for i=1:length(s.caTSA)
				feat(i) = length(s.caTSA.caPeakEventSeriesArray.esa{i}.getBurstTimes(1000))/numSeconds;
			end
		else
    feat = s.cellFeatures.get(fname);
		end

%	  for f=1:nF
	  for f=2
				s.plotColorRois([],[],[],color,feat, colRange, ax,0,f);
		  if (avion)
				s.plotColorRois([],[],[],color,feat, colRange, ax,0,f);
				hold on ; 
				text(430, 20, sprintf('Vol %02d', idx),'Color', [1 0 0], 'FontWeight', 'bold', 'FontSize', 20);
				pause (0.1);
				aviobj = addframe(aviobj, getframe(fig));
			end

      % frac & count
      val = find(s.caTSA.roiFOVidx == f);
      valcells = find(feat(val) > thresh);
      count(idx) = length(valcells);
			frac(idx) = count(idx)/length(val);

			%cell COMs
%			cellidx = val(valcells);
			for c=1:length(valcells)
			  meanX = mean(s.caTSA.roiArray{f}.rois{valcells(c)}.corners(1,:));
			  meanY = mean(s.caTSA.roiArray{f}.rois{valcells(c)}.corners(2,:));

				com(cidx,:) = [meanX meanY];
				cidx = cidx+1;
			end
			for c=1:length(s.caTSA.roiArray{f}.rois)
			  meanX = mean(s.caTSA.roiArray{f}.rois{c}.corners(1,:));
			  meanY = mean(s.caTSA.roiArray{f}.rois{c}.corners(2,:));

				allcom(aidx,:) = [meanX meanY];
				aidx = aidx+1;
			end

			idx = idx+1;
	  end
	end
  
	if (avion)
	  aviobj = close(aviobj);
	end

	% plot the fraction stuff ...
	figure;
	subplot(1,5,1);
	plot(count, 1:nF*nV, '-', 'Color', color, 'LineWidth', 2);
	set(gca, 'YDir', 'reverse', 'TickDir', 'out');
	ylabel ('plane #');
	xlabel('count');

	subplot(1,5,2);
	plot(frac, 1:nF*nV, '-', 'Color', color, 'LineWidth', 2);
	set(gca, 'YDir', 'reverse', 'TickDir', 'out', 'YTick',[]);
	xlabel('fraction');

	% cell centers 
	xrange = 1:50:512;
	yrange = 1:50:512;

  thiscount = zeros(length(yrange),length(xrange));
  allcount = zeros(length(yrange),length(xrange));
  for x=1:length(xrange)-1
	  for y=1:length(yrange)-1
		  thiscount(y,x) = length(find(com(:,1) > xrange(x) & com(:,1) <= xrange(x+1) & ...
			                 com(:,2) > yrange(y) & com(:,2) <= yrange(y+1)));
		  allcount(y,x) = length(find(allcom(:,1) > xrange(x) & allcom(:,1) <= xrange(x+1) & ...
			                 allcom(:,2) > yrange(y) & allcom(:,2) <= yrange(y+1)));

		end
	end

	figure;
	imshow(S{1}.caTSA.roiArray{1}.masterImage, [0 1000]);
	hold on ;
	plot(com(:,1), com(:,2), 'o', 'Color', color, 'MarkerFaceColor', color);

	figure('Position',[0 0 900 300]);;
	ax1 = subplot('Position',[.05 .05 .3 .9]);
	ax2 = subplot('Position',[.375 .05 .3 .9]);
	ax3 = subplot('Position',[.7 .05 .3 .9]);
	imshow(thiscount, [0 5], 'Parent', ax1, 'Border', 'tight');
	imshow(allcount, [0 round(max(max(allcount))/10)*10], 'Parent', ax2, 'Border', 'tight');
	dens = (thiscount./(allcount+1));
	imshow(dens, [0 .1], 'Parent', ax3, 'Border', 'tight');
	colormap jet;
end
