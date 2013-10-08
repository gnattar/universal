function touch_crossday_2(sA, roiId, sessions,whiskers, dffRange)
  mode = 1; % 1: kappa ; 2 : theta 3: dtheta
  showPlots = [0 0 1];

	if (nargin < 3) ; sessions = 1:length(sA.sessions); end
	if (nargin < 4) ; whiskers = {'c1','c2','c3'}; end
	if (nargin < 5) ; dffRange = [-0.25 2]; end

  % for kappa:
	if (mode == 1) 
		stimMode = 'sumabs';
		trialEventNumber = 'max';
		stimTSA = 'whiskerCurvatureChangeTSA';
		stimTSIdLead = 'Curvature change for ';
		stimValRange = [-0.05 1];
  elseif (mode == 2)
		% for theta:
		stimMode = 'mean';
		trialEventNumber = 'max';
		stimTSA = 'whiskerAngleTSA';
		stimTSIdLead = 'Angle for ';
		stimValRange = [-50 50];
  elseif (mode == 3)
		% for dtheta:
		mode = 2;
		stimMode = 'deltasumabs';
		trialEventNumber = 'max';
		stimTSA = 'whiskerAngleTSA';
		stimTSIdLead = 'Angle for ';
		stimValRange = [-10 300];
  end

	% ===========================================
	% pre-evaluate various modes, for best whisker

if (showPlots(1))
	% -------------------------------------------
	% 1) 
	for w=1:length(whiskers)
		clear pparams;
		pparams.sessions = sessions;
		pparams.respTSA = 'caTSA.dffTimeSeriesArray';
		pparams.respTSId = roiId;
		pparams.respTimeWindow = [0 2];
		pparams.respMode = 'max';
		pparams.respValueRange = [-0.25 3];
		pparams.stimTSA = stimTSA;
		pparams.stimTSId = [stimTSIdLead whiskers{w}];
		pparams.stimTimeWindow = [-0.1 0.5];
		pparams.stimValueRange = stimValRange;
		pparams.stimMode = stimMode;
		pparams.ESA = 'whiskerBarContactClassifiedESA';
		pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
		pparams.ESColor = [1 0 0 ; 0 0 1];
		pparams.trialEventNumber = [];
	  if (mode == 1) ;	
		  explore_params_kappa (pparams, sA, 'all'); 
		elseif (mode == 2)
		  explore_params_theta (pparams, sA, 'all'); 
		end

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
	  if (mode == 1) ;	
		  explore_params_kappa (pparams, sA, 'exclusive' );
		elseif (mode == 2)
		  explore_params_theta (pparams, sA, 'exclusive' );
		end
	end
end

	% ===========================================
	% nitty gritty
if (showPlots(2))
	% -------------------------------------------
	% 2) RF all whiskers 
	for w=1:length(whiskers)
		clear pparams;
	  pparams.sessions = sessions;
		pparams.respTSA = 'caTSA.dffTimeSeriesArray';
		pparams.respTSId = roiId;
		pparams.respTimeWindow = [0 2];
		pparams.respMode = 'max';
		pparams.respValueRange = [-0.25 3];
		pparams.stimTSA = stimTSA;
		pparams.stimTSId = [stimTSIdLead whiskers{w}];
		pparams.stimTimeWindow = [-0.1 0.5];
		pparams.stimValueRange = stimValRange;
		pparams.stimMode = stimMode;
		pparams.ESA = 'whiskerBarContactESA';
		pparams.ESId = ['Contacts for ' whiskers{w}];
		pparams.ESColor = [0 0 0];
		pparams.trialEventNumber = trialEventNumber; 

pparams.labelMode = 'ESA';
pparams.labelClasses = 'getCoincidentWhiskerContactESA({''c1'',''c2'', ''c3''}, 2)';
pparams.labelClassId = 1:3;
pparams.labelColors =  [1 0 0 ; 0 0 1 ;  0 0 0];
pparams.labelESOverlapWindow = [-0.2 0.2];

		sA.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);


		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		sA.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' exclusive']);
  end
end


if (showPlots(3))
	% -------------------------------------------
	% 3) RF all dir whiskers 
	for w=1:length(whiskers)
		clear pparams;
	  pparams.sessions = sessions;
		pparams.respTSA = 'caTSA.dffTimeSeriesArray';
		pparams.respTSId = roiId;
		pparams.respTimeWindow = [0 2];
		pparams.respMode = 'max';
		pparams.respValueRange = [-0.25 3];
		pparams.stimTSA = stimTSA;
		pparams.stimTSId = [stimTSIdLead whiskers{w}];
		pparams.stimTimeWindow = [-0.1 0.5];
		pparams.stimValueRange = stimValRange;
		pparams.stimMode = stimMode;
		pparams.ESA = 'whiskerBarContactClassifiedESA';
		pparams.ESId = {['Protraction contacts for ' whiskers{w}] ,['Retraction contacts for ' whiskers{w}]};
		pparams.ESColor = [1 0 0 ; 0 0 1];
		pparams.trialEventNumber = trialEventNumber; 

%    pparams.labelMode = 'trialType';
%		pparams.labelClasses = {'Hit', 'CR', 'Miss', 'FA'};
%		pparams.labelColors = [0 0 1; 1 0 0 ; 0 0 0 ; 0 1 0];

%    pparams.labelMode = 'trialFrac';
%		pparams.labelClasses = {[0 0.25], [0.25 0.5] , [0.5 0.75], [ 0.75 1]};
%		pparams.labelColors = [1 0 1 ; 0.5 0 1; 0 0.5 1 ; 0 1 1];

%pparams.labelMode = 'lickRate';
%pparams.labelClasses = {[0 .5], [.5 1.5], [1.5 3], [3 Inf]};
%pparams.labelColors = [1 0 1; 0 1 1 ; 0 1 0 ; 0 0 0];

pparams.labelMode = 'ESA';
pparams.labelClasses = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3'', ''Pc1'', ''Pc2'', ''Pc3''}, 2)';
pparams.labelClassId = [1 2 6 4 5 9];
pparams.labelColors =  [0 1 0.75 ; 0 0.75 1 ; 0 0 1; 1 0.75 0 ; 0.75 1 0; 1 0 0];
pparams.labelESOverlapWindow = [-0.2 0.2];


		sA.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);
		 
		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		sA.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' exclusive']);
  end
end

	% -------------------------------------------




%
%    stimMode      trialEventNumber
% {maxabs, sumabs} x {[], 1, 'max'} 
%
% for a given set of pparams, loop thru above
%
function explore_params_kappa (pparams, sA, ftit)
  pparams.stimMode = 'maxabs';
	pparams.stimValueRange = [-0.025 .025];

	pparams.trialEventNumber = [];
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs all touches ' ftit]);

	pparams.trialEventNumber = 1;
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs max touch ' ftit]);

  pparams.stimMode = 'sumabs';
	pparams.stimValueRange = [-0.05 1];

	pparams.trialEventNumber = [];
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs all touches ' ftit]);

	pparams.trialEventNumber = 1;
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs max touch ' ftit]);


%
%    stimMode      trialEventNumber
% {mean, deltasumabs} x {[], 1, 'max'} 
%
% for a given set of pparams, loop thru above
%
function explore_params_theta(pparams, sA, ftit)
  pparams.stimMode = 'mean';
	pparams.stimValueRange = [-50 50];

	pparams.trialEventNumber = [];
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean all touches ' ftit]);

	pparams.trialEventNumber = 1;
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean max touch ' ftit]);

  pparams.stimMode = 'deltasumabs';
	pparams.stimValueRange = [-10 200];

	pparams.trialEventNumber = [];
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs all touches ' ftit]);

	pparams.trialEventNumber = 1;
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	sA.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs max touch ' ftit]);




