%
% pulls ca time constatns for a set of session files, rois using various methods.
%
function ca_time_constants
%  doDirectory('/media/an107028/an107028/session2/');
%  doDirectory('/media/an38596/an38596/session2/');
%  doDirectory('/media/an94953/an94953/session2/');
%  doDirectory('/media/an93098/an93098/session2/');
%  doDirectory('/media/an107029/an107029/session2/');
%  doDirectory('/media/Copy_SP/DOM3_results_new/jf100601/');
  doDirectory('/media/Copy_SP/DOM3_results_new/jf25607/');
  doDirectory('/media/Copy_SP/DOM3_results_new/jf25609/');  
  doDirectory('/media/Copy_SP/DOM3_results_new/jf26707/');  
  doDirectory('/media/Copy_SP/DOM3_results_new/jf27332/');

function doDirectory(dirName)
  disp(['DOING: ' dirName]) 
	flist = dir([dirName '*caTSA.mat*']);
	cd (dirName);
	%flist = [];
	%flist(1).name = 'an107029_2010_08_09_sess.caTSA.mat';

	for f=1:length(flist)
		disp(['Processing ' flist(f).name]);

		load(flist(f).name);
		obj = saveVar;
   
	  % tag/name
		out.fname{f} = flist(f).name;

    % luminance stuff
		[isFilled ceLumRatios csLumRatios maxMedianRatios] = obj.roiArray.detectFilledRois();
		out.lumStats{f}.isFilled = isFilled;
		out.lumStats{f}.ceLumRatios = ceLumRatios;
		out.lumStats{f}.csLumRatios = csLumRatios;
		out.lumStats{f}.maxMedianRatios = maxMedianRatios;

		% MAD thresh evdet for now -- not working with vogel
		obj.evdetOpts.evdetMethod = 1; % SD thresh via MAD
		obj.evdetOpts.threshMult = 4; % event must be this much greater 
		obj.evdetOpts.threshStartMult =2;
		obj.evdetOpts.threshEndMult =2;
		obj.evdetOpts.minEvDur = 500; % ms
		obj.evdetOpts.minInterEvInterval = 500; 
		obj.evdetOpts.madPool = 2; % use inactive cells
		obj.evdetOpts.filterType = 2; % prefilter with median
		obj.evdetOpts.filterSize = 10; % in s

		% first, use t1/2
		obj.evdetOpts.riseDecayMethod = 1;  % fast DH style
		obj.updateEvents();

		% pull the data per roi
		nRois = length(obj.caPeakEventSeriesArray.esa);
		out.t12decayTau{f}.roiMeanTau = nan*ones(1,nRois);
		out.t12decayTau{f}.roiMedianTau = nan*ones(1,nRois);
		out.t12decayTau{f}.roiSdTau = nan*ones(1,nRois);
		out.t12decayTau{f}.roiModeTau = nan*ones(1,nRois);
		for r=1:nRois
			esa = obj.caPeakEventSeriesArray.esa{r};
			dtc = esa.decayTimeConstants;
			out.t12decayTau{f}.roiTaus{r} = dtc;
			if (length(dtc) > 0 & length(find(isnan(dtc))) < length(dtc))
				out.t12decayTau{f}.roiMeanTau(r) = nanmean(dtc);
				out.t12decayTau{f}.roiMedianTau(r) = nanmedian(dtc);
				out.t12decayTau{f}.roiSdTau(r) = nanstd(dtc);
				[fv xi] = ksdensity(dtc);
				[irr idx] = max(fv);
				out.t12decayTau{f}.roiModeTau(r) = xi(idx);
			end
		end

		% session averages
		out.t12TauMeanMean(f) = nanmean(out.t12decayTau{f}.roiMeanTau);
		out.t12TauMeanSD(f) = nanstd(out.t12decayTau{f}.roiMeanTau);
		out.t12TauMedianMean(f) = nanmean(out.t12decayTau{f}.roiMedianTau);
		out.t12TauMedianSD(f) = nanstd(out.t12decayTau{f}.roiMedianTau);
		out.t12TauModeMean(f) = nanmean(out.t12decayTau{f}.roiModeTau);
		out.t12TauModeSD(f) = nanstd(out.t12decayTau{f}.roiModeTau);

		% next do with rise-decay method
		obj.evdetOpts.riseDecayMethod = 2; % exponential fit of decay time
		obj.updateEvents();

		% pull the data ...
		out.gofTau{f}.roiMeanTau = nan*ones(1,nRois);
		out.gofTau{f}.roiMedianTau = nan*ones(1,nRois);
		out.gofTau{f}.roiSdTau = nan*ones(1,nRois);
		out.gofTau{f}.roiModeTau = nan*ones(1,nRois);
		out.gofTau{f}.roiMinTau = nan*ones(1,nRois);
		for r=1:nRois
			esa = obj.caPeakEventSeriesArray.esa{r};
			dtc = esa.decayTimeConstants;
			out.gofTau{f}.roiTaus{r} = dtc;
			dtcv = dtc(find(dtc > 0)); % good taus
			if (length(dtcv) > 0 & length(find(isnan(dtcv))) < length(dtcv))
				out.gofTau{f}.roiMeanTau(r) = nanmean(dtcv);
				out.gofTau{f}.roiMedianTau(r) = nanmedian(dtcv);
				out.gofTau{f}.roiSdTau(r) = nanstd(dtcv);
				out.gofTau{f}.roiMinTau(r) = nanmin(dtcv);
				[fv xi] = ksdensity(dtcv);
				[irr idx] = max(fv);
				out.gofTau{f}.roiModeTau(r) = xi(idx);
			end
		end

		% session averages
		out.gofTauMeanMean(f) = nanmean(out.gofTau{f}.roiMeanTau);
		out.gofTauMeanSD(f) = nanstd(out.gofTau{f}.roiMeanTau);
		out.gofTauMedianMean(f) = nanmean(out.gofTau{f}.roiMedianTau);
		out.gofTauMedianSD(f) = nanstd(out.gofTau{f}.roiMedianTau);
		out.gofTauModeMean(f) = nanmean(out.gofTau{f}.roiModeTau);
		out.gofTauModeSD(f) = nanstd(out.gofTau{f}.roiModeTau);
		out.gofTauMinMean(f) = nanmean(out.gofTau{f}.roiMinTau);
		out.gofTauMinSD(f) = nanstd(out.gofTau{f}.roiMinTau);
	end

	save([dirName filesep 'ca_time_constants_output.mat'],'out');
