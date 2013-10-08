%
% SP Mar 2011
%
% Computes d' given hit rate (hr), false alarm rate (far),
%  number of hits&misses (n1) and number of fa/correct rejects (n2)
% 
% Adapted from DHO (without permission HA!)
%
function dp = dprime(hr,far,n1,n2)

	% sanity checks -- cannot have 1 or 0
	if hr==1
		hr = hr-1/(2*n1);
	end
	if far==0
		far = 1/(2*n2);
	end
	if hr==0
		hr=1/(2*n1);
	end
	if far==1
		far = far-1/(2*n2);
	end

	% actual magic
	dp = norminv(hr,0,1) + norminv(1-far,0,1);


