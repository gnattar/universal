%
% SP May 2011
%
% Comptues d' from 2 distributions.  Basically, difference in means scaled by
%  SD, so IF the distributions are from the same normal PDF just different means,
%  equivalent to d'.  Obviously this is what d' assumes so ...
%
% USAGE:
%
%  dprime = dprime_frmo_distro(DVa, DVb)
%  
%  dprime: the d' value
%  
%  DVa, DVb: values in two distrbutions
%
function dprime = dprime_from_distro(DVa, DVb)
  dprime = abs(nanmean(DVa)-nanmean(DVb))/sqrt(nanstd(DVa)*nanstd(DVb));
  
