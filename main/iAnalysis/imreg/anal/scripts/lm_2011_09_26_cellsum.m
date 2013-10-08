%
% Various cell sumaries across FOVs
%
function lm_2011_09_26_cellsum(s)
  lm_data = '/data/an148378/lm_2011_09_26/';
  plotsShown = [0 0 1 0 0];

  % 'set ranges properly'
	if (0)
	  M = max(max(s.caTSA.roiArray{3}.workingImage)); 
		ci = find(s.caTSA.roiArray{3}.workingImage > M/3) ; 
		s.caTSA.roiArray{3}.workingImage(ci) = M/3;
	  M = max(max(s.caTSA.roiArray{4}.workingImage)) ; 
		ci = find(s.caTSA.roiArray{4}.workingImage > M/2) ; 
		s.caTSA.roiArray{4}.workingImage(ci) = M/2;
	end
  
  % 1) burst rate [0 1/30 -- once per 2 trials]
	if (plotsShown(1))
		plot_four(s,'burstRate', [0 1/30], 'burst rate');

		% colorbar
		f=figure; ax=axes;s.plotColorRois('burstRate', [],[],[],[],[0 1/30],ax,1,4);
	end
  
  % 2) touch index
	if (plotsShown(2))
		load ([lm_data 'touch_indices.mat']);

		% plot nondir
		touchIndex = nondirectionalExclusiveTouchIdx;
		touchIndex = nondirectionalNonExclusiveTouchIdx;
		mV = 0; MV = .05;
		touchIndex(find(touchIndex < 0.01)) = nan;
		plot_four(s,touchIndex(1,:), [mV MV], 'C1');
		plot_four(s,touchIndex(2,:), [mV MV], 'C2');
		plot_four(s,touchIndex(3,:), [mV MV], 'C3');

		% directional index
    dtouchIndex = 0*touchIndex;
		dti = directionalExclusiveTouchIdx;
		dti= directionalNonExclusiveTouchIdx;
		dtouchIndex(1,:) = dti(2,:)-dti(1,:);
		dtouchIndex(2,:) = dti(4,:)-dti(3,:);
		dtouchIndex(3,:) = dti(6,:)-dti(5,:);
		mV = -0.05; MV = .05;
		dtouchIndex(find(abs(dtouchIndex) < 0.01)) = nan;
		plot_four(s,dtouchIndex(1,:), [mV MV], 'C1 dir');
		plot_four(s,dtouchIndex(2,:), [mV MV], 'C2 dir');
		plot_four(s,dtouchIndex(3,:), [mV MV], 'C3 dir');

		% colorbar
%		f=figure; ax=axes;s.plotColorRois('', [],[],[],[],[0 1/30],s.touchIndex(1,:),1,4);
	end

	% 3) whisker setpoint, whisking amplitude, reward, and ople-in-reach correlations
	if (plotsShown(3))
	  if (1) % initial compute
		  % pole movement vector
			es = s.behavESA.esa{5}.copy();
			es.type = 1;
			ts = session.eventSeries.deriveTimeSeriesS(es, s.derivedDataTSA.time, s.caTSA.timeUnit, [0 1], 2);

      nolickMult = zeros(1,length(s.caTSA.time));
      nolickTrials = setdiff(unique(s.trialIds),unique(s.behavESA.esa{1}.eventTrials));
			nolickIdx = find(ismember(s.caTSA.trialIndices,nolickTrials));
			nolickMult(nolickIdx) = 1;

		  % go..
		  for r=1:length(s.caTSA.ids)
			  nolickTS = s.caTSA.dffTimeSeriesArray.getTimeSeriesByIdx(r).copy();
				nolickTS.value = nolickTS.value.*nolickMult;
				nolickTS.value(find(nolickTS.value == 0)) = nan;

			  corrs = session.timeSeries.computeCorrelationS(s.caTSA.getTimeSeriesByIdx(r), ...
				           s.derivedDataTSA.getTimeSeriesById(100),-7:7);
			  whiskerSetpointCorr(r) = max(corrs);

			  corrs = session.timeSeries.computeCorrelationS(s.caTSA.getTimeSeriesByIdx(r), ...
				           s.derivedDataTSA.getTimeSeriesById(200),-7:7);
			  whiskerAmplitudeCorr(r) = max(corrs);

			  corrs = session.timeSeries.computeCorrelationS(nolickTS, ...
				           s.derivedDataTSA.getTimeSeriesById(100),-7:7);
			  whiskerSetpointCorrNL(r) = max(corrs);

			  corrs = session.timeSeries.computeCorrelationS(nolickTS, ...
				           s.derivedDataTSA.getTimeSeriesById(200), -7:7);
			  whiskerAmplitudeCorrNL(r) = max(corrs);

			  rewardCorr(r) = session.timeSeries.computeCorrelationS(s.caTSA.getTimeSeriesByIdx(r), ...
				           s.derivedDataTSA.getTimeSeriesById(1003));
				lickCorr(r) = session.timeSeries.computeCorrelationS(s.caTSA.getTimeSeriesByIdx(r), ...
				           s.derivedDataTSA.getTimeSeriesById(1));
	  	  poleCorr(r) = session.timeSeries.computeCorrelationS(s.caTSA.getTimeSeriesByIdx(r), ...
				           ts,-2);
				disp(['Doing ' num2str(r)]);
			end
			save([lm_data 'misc_correlations.mat'],'whiskerSetpointCorr','whiskerAmplitudeCorr','rewardCorr','poleCorr', ...
			                                       'whiskerSetpointCorrNL','whiskerAmplitudeCorrNL','lickCorr');
		else % load
		  load ([lm_data 'misc_correlations.mat']);
		end

		% plot them
		plot_four(s,abs(whiskerSetpointCorr), [0 .75], 'Setpoint');
		plot_four(s,abs(whiskerSetpointCorrNL), [0 .75], 'Setpoint NL only');

		% colorbar [only 1 needed]
%		f=figure; ax=axes;s.plotColorRois('', [],[],[],abs(whiskerSetpointCorr),[0 .5],ax,1,4);

		plot_four(s,abs(whiskerAmplitudeCorr), [0 .75], 'Amplitude');
		plot_four(s,abs(whiskerAmplitudeCorrNL), [0 .75], 'Amplitude NL only');
		plot_four(s,abs(rewardCorr), [0 .25], 'Reward');
		plot_four(s,abs(lickCorr), [0 .5], 'Lick');
		plot_four(s,abs(poleCorr), [0 .25], 'Pole');

	%	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end

 
  % 4) discrim index
	if (plotsShown(4))
		mV = 0.5; MV = 1;
    di = s.discrimIndex;
		ndi = find(di < 0.5);
		di(ndi) = 1-(di(ndi));
		plot_four(s,di, [mV MV], 'discrim');
	end

function plot_four(s,valVec, valRange, titStr)
	[sp1 sp2 sp3 sp4 f] = get_four_panel;
	
	if (ischar(valVec))
		s.plotColorRois(valVec, [],[],[],[],valRange,sp1,0,1);
		s.plotColorRois(valVec, [],[],[],[],valRange,sp2,0,2);
		s.plotColorRois(valVec, [],[],[],[],valRange,sp3,0,3);
		s.plotColorRois(valVec, [],[],[],[],valRange,sp4,0,4);
	else
		s.plotColorRois('', [],[],[],valVec,valRange,sp1,0,1);
		s.plotColorRois('', [],[],[],valVec,valRange,sp2,0,2);
		s.plotColorRois('', [],[],[],valVec,valRange,sp3,0,3);
		s.plotColorRois('', [],[],[],valVec,valRange,sp4,0,4);
  end
	set(f, 'Name', titStr);
set(gcf, 'PaperPositionMode', 'auto');

  printon = 2;
  lm_data = '/data/an148378/lm_2011_09_26/';
  outFile = [lm_data 'allfovs_' strrep(titStr,' ','_') '.eps'];
	if (printon == 1) ; print(f, '-depsc2', '-noui', '-r300', outFile); end
  outFile = [lm_data 'allfovs_' strrep(titStr,' ','_') '.png'];
	if (printon == 2) ; print(f, '-dpng', '-noui', '-r300', outFile); end


function [sp1 sp2 sp3 sp4 f] = get_four_panel
  % setup the picture ...
  f= figure ('Position', [0 0 900 900]);
	sp1 = subplot('Position', [0 0.5 0.5 0.5]);
	sp2 = subplot('Position', [0.5 0.5 0.5 0.5]);
	sp3 = subplot('Position', [0 0 0.5 0.5]);
	sp4 = subplot('Position', [0.5 0 0.5 0.5]);

