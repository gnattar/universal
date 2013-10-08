function [ r ] = nancorr(x,y,opt,corrType)
% Correlation with type : 'corrType'
trials = intersect (find(~isnan(x)),find(~isnan(y))); 
if (length(trials) == 0) % no data
  r = 0;
else
  r = corr (x(trials),y(trials),'type',corrType);
end

end

