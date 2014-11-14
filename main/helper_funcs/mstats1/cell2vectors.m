function y = cell2vectors(x)
% function y = cell2vectors(x)
% 
% accepts a one-dimensional cell array containing numbers, concatenates all numbers and
% constructs a second vector indicating the identity of each numbers cell
% 
% function comes in handy when using e.g. anova or kruskalwallis with unequal sample sizes
% per group
% 
% EXAMPLE
% load mstats_exampledata
% for i = 1:3
%   disp(x{i})
% end
% y = cell2vectors(x)
% anova1(y(:,1),y(:,2))
% 
% Maik C. Stüttgen, February 2014
%% check whether x is one-dimensional
if numel(x)~=max(size(x))
  error('input cell array is not one-dimensional')
end
%% determine total number of elements across all cells and check whether they are all numeric
n = 0;
for i = 1:numel(x)
  if ~isnumeric(x{i})
    error(['cell no. ' num2str(i) ' is not numeric'])
  end
  n = n+numel(x{i});
end
%% extract values
y = nan(n,2);
c = 1;
for i = 1:numel(x)
  y(c:c+numel(x{i})-1,:) = [x{i} i*ones(numel(x{i}),1)];
  c = c + numel(x{i});
end