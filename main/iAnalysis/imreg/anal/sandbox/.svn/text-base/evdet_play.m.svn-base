function evdet_play(vec, noise)
  nPre = 2;
	nRise = 0;
	nDec = 100;
  
	taus = 2:2:50;

if (0)
  % build kernels ..
	kernMat = zeros(length(taus), nRise+nDec + nPre);
	for t=1:length(taus)
	  kernMat(t,:) =  [zeros(1,nPre-1) linspace(0,1,nRise+1) exp(-1*(1:nDec)/taus(t))];
  	kernMat(t,:) = kernMat(t,:)/sum(kernMat(t,:)) ; % normalize yo kernl fool
	end

	% iterative . . . 
	ks = size(kernMat,1);
	cvec = zeros(ks,length(vec));
	for k=1:ks
  	cvec(k,:) = conv(vec,kernMat(k,:),'same');
	end

	% pick largest ... take it out
end

% ITERATE THIS:

  % 1) find event starts 
	dvec = [0 diff(vec)];  
	ddvec = vec.*dvec; % this will find onsets of large amp events ; consider a 2 dt version

	% 2) starting at largest event, do best tau fit, and abandon once gof gets too crappy
	%    - you may want to use variable n-time points - so, e.g., tau + 1 s
	%    - only consider POST-PEAK for gof

	% 3) continue until you run out of SEPARATE peaks -- i.e., cannot work on overlap

	% 4) subtract the fits from the data

	% 5) repeat until no peaks above thresh (3 SD?)

