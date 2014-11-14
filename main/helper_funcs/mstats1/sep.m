function [sep] = sep(p,n)
% function [sep] = sep(p,n)
% 
% computes the standard error for proportions
% this should not be confused with the standard deviation of the binomial distribution
% the variance of the binomial distribution is n*p*(1-p) (for a series of Bernoulli trials)
% 
% INPUT
% p     proportion
% n     total number of samples
% 
% Maik C. Stüttgen, July 2014
%% the (little) works
sep = sqrt((p*(1-p))/n);
