%
% SP Jun 2011
%
% This will plot the RF for two stimuli + response, with response colored in 
%  as markerFaceColor.
%
% USAGE:
%
%   s.plotMultiStimRF(params1, params2, params)
%
% PARAMS:
%  
%   params1, params2: structures passed to getPeriWhiskerContactRF.  Must return
%                     same # of pairs.  Params1 goes on X-axis.
%   params: structure with all other variables --
%     st1, st2, re: explcitly pass stimulus1, 2 ; response thereto so as
%                         to avoid clal to getPeriWhiskerContactRF
%
function plotMultiStimRF(obj, params1, params2, params)
  if (nargin < 3)
	  help('session.session.plotMultiStimRF');
	end

	if (nargin >= 4)
	  if (isstruct(params))
		  if(isfield(params, 'st1')) ; st1 = params.st1 ; end
		  if(isfield(params, 'st2')) ; st2 = params.st2 ; end
		  if(isfield(params, 're')) ; re1 = params.re ; re2=params.re;end
		end
	end

	% --- get RFs
	if (~exist('st1','var'))
		[st1 re1] = obj.getPeriWhiskerContactRF(params1);
		[st2 re2] = obj.getPeriWhiskerContactRF(params2);
	end

	% --- plot
	if (length(re1) == length(re2))
    % colormap
    cm = jet(256);
		re = re1-min(re1); % [0 ...?
		re = re/max(re); % [0 1]
%re = re1;
%re = re/2; % [0 2]
    re (find(re < 0)) = 0;
		re (find(re > 1)) = 1;

		cmi = ceil(256*re);
		cmi(find(cmi == 0)) = 1;

		% plot loop
		hold on;
		for i=1:length(re)
			plot(st1(i), st2(i), 'o', 'MarkerEdgeColor' , cm(cmi(i),:), 'MarkerFaceColor', cm(cmi(i),:));
		end

		% plot cleanup
		xlabel(params1.stimTSId);
		ylabel(params2.stimTSId);
	end

