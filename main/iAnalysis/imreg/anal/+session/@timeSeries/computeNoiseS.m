%
% Computes the noise for a vector or matrix based on various approaches.
%
% USAGE:
%
%   noise = session.timeSeries.computeNoiseS(time, valueMatrix, params)
%
%  Note that basically each method does its own thing ; this just is a wrapper
%   for easy packaging.
%
% ARGUMENTS:
%
%   time: vector with time values
%   valueMatrix: the data ; each row is processed 
%   params: structure of optional stuff
%     params.debug: if 1, some useful stuff appears
%     params.timeUnit: unit for time ; default is ms
%     params.method: what way to get noise? default is 'hfMAD'
%     params.prefiltSizeInSeconds: prefilt size 
%
% METHODS:
%
%   hfMAD: takes a prefiltSizeInSeconds low-pass filter, subtracts that from
%          the signal, then takes the MAD of the resulting trace - this is noise.
%   hfMADn: same, but only on negative part of trace (post-subtraction)
%
% RETURNS:
%
%  noise: vector with noise for each row of valueMatrix
%
% (C) July 2012 S Peron
%
function noise = computeNoiseS(time, valueMatrix, params)

  %% --- input parsing
	if (nargin < 2)
	  help('session.timeSeries.computeNoiseS');
		error('Must pass time and valueMatrix at least');
	end

	% defaults & params parse
	timeUnit = session.timeSeries.millisecond;
	method = 'hfMAD';
	prefiltSizeInSeconds = 1;
	debug = 0;
	if (nargin > 2 && isstruct(params))
  	eval(assign_vars_from_struct(params,'params'));
	end

  %% --- prep work

	% flip valueMatrix? ensure row-wise operation
	if (size(valueMatrix,2) == 1) ; valueMatrix = valueMatrix' ; end
  nRows = size(valueMatrix,1);
	noise = nan*zeros(nRows,1);

	% prefilt ...
	dt = mode(diff(time));
	pfs = ceil(session.timeSeries.convertTime(prefiltSizeInSeconds, session.timeSeries.second, timeUnit)/dt);

	%% --- the real
	switch method
	  case {'hfMAD','hfMADn'}

		  % first subtract a moving average (i.e., a low pass filter)
			kern = ones(1,pfs);
			kern = kern/sum(kern) ; % normalize the kernel
			for r=1:nRows
				vec = valueMatrix(r,:);
				vec = vec(find(~isnan(vec)));
				svec = conv(vec,kern,'same');

        nvec = vec-svec; 

        % take MAD
				if(strcmp(method,'hfMADn'))
				  negs = find(nvec < 0);
					noise(r) = mad(nvec(negs));
				else
					noise(r) = mad(nvec);
				end

				if (debug)
				  cla;
				  plot(vec,'k-');
					hold on;
				  plot(svec,'r-');
					plot([0 length(vec)], [1 1]*noise(r), 'k-');
				  plot(nvec-2,'b-');
					plot([0 length(vec)], [1 1]*noise(r)-2, 'k-');
					pause;
				end
			end



	  otherwise
		  disp(['computeNoiseS::method ' method ' not recognized.']);
	end

