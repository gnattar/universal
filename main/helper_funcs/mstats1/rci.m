function [cilohi,p] = rci(r,n,alpha,doplot)
% function [cilohi,p] = rci(r,n,alpha,doplot)
% 
% computes and optionally plots confidence intervals (CI) for Pearson correlation coefficient
% 
% INPUTS
% r         Pearson correlation value (may range from -1 to +1)
% n         total sample size (should be at least 2)
% alpha     desired confidence level (usually, 0.05, which will yield a 1-alpha = 0.95 -> 95% CI
% doplot    0 = no plot, 1 = plot
% 
% OUTPUTS
% cilohi    lower and upper confidence bounds
% p         p value of correlation coefficient (bi-directional test)
% 
% EXAMPLE
% [ci,p] = rci(0.5,20,0.05,1)
% The correlation of 0.5, obtained with 20 data points, is significant at the 0.05 level, p = 0.025.
% However, the confidence interval is quite wide, ranging from 0.07 to 0.77, showing that, with
% just 20 sample values, the 'true' (i.e. population) correlation value cannot be pinned down exactly,
% but is probably to be found within the specified bounds.
% 
% COMPUTATIONAL STEPS: 
% 1) compute Fisher's z' from correlation coefficient
% 2) compute confidence intervals
% 3) convert z'-values back to correlation coefficients
% 
% FORMULAS TAKEN FROM: 
% Diehl and Arbinger, Einführung in die Inferenzstatistik (2nd edition), Chapter 16
% 
% conversion of r into Fisher's z:        z' = ln((1+r)/(1-r)) / 2
% standard error of r in Fisher's z:  SE(z') = 1 / sqrt(n-3)
% 
% Maik C. Stüttgen, July 2014
%% input check
if r<-1 || r>+1
  error('r is out of bounds')
elseif n<2
  error('sample size is <2')
elseif alpha<0 || alpha>1
  error('alpha is out of bounds')
end
%% compute confidence interval
fz = log((1+r)/(1-r)) / 2;
ser = 1/sqrt(n-3);        % standard error of correlation's z-value
crit_z = norminv(alpha/2,0,1);

lolim = fz - abs(crit_z) * ser;
uplim = fz + abs(crit_z) * ser;
lolim_r = (exp(1)^(2*lolim)-1) / (exp(1)^(2*lolim)+1);
uplim_r = (exp(1)^(2*uplim)-1) / (exp(1)^(2*uplim)+1);

cilohi = [lolim_r uplim_r];
%% compute p-value
t = r * sqrt((n-2)/(1-r^2));      % Diehl and Arbinger, pp. 373
p = 2 * (1 - tcdf(t,n-2));        % non-directional p value
%% plot if requested
if doplot == 1
  figure('units','normalized','position',[0.4 0.4 0.2 0.2]);
  hold on
  errorbar(0,r,r-lolim_r,uplim_r-r,'Marker','o','Color','b')
  plot([-1 1],[0 0],'LineStyle',':','Color','b');
  axis([-.5 .5 -1 1]);set(gca,'XTickLabel',[])
end