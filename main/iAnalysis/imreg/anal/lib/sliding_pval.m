%
% SP May 2011
%
% For each *sequential* partition of vec, it will compute a nonparametric p-value
%  testing if the two sets (before & after partition) constitute statistically
%  independent sets.
%
% USAGE:
%
%   pval = sliding_pval(vec)
%
%   vec: vector of values you want to test on
%   pval: length of (length(vec)-1); pval(i) tells you p-value if partition is 
%         such that you group vec(1:i) and vec(i+1:end)
%
function pval = sliding_pval(vec)
  pval = nan*zeros(1,length(vec)-1);
  for i=1:length(vec)-1
	  G1=1:i;
		G2=i+1:length(vec);

		pval(i) = ranksum(vec(G1), vec(G2));
		disp(num2str([i length(vec)]));
	end
