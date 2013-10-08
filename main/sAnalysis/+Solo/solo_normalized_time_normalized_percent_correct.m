function [normalizedTrialNum, normalizedPC] = solo_normalized_time_normalized_percent_correct(y)
%
% 'y' is output from solo_moving_pc_concat()
%
% DHO, 9/07.
%


l = cellfun(@length,y);

ymean = zeros(max(l),1);

xmax = 0:(max(l)-1);
xmax = xmax./xmax(end);

for k=1:length(y)
    yi = y{k}./y{k}(1);
    x = 0:(length(yi)-1);
    x = x./x(end);
    yp = interp1(x,yi,xmax)';
    ymean = ymean+yp;
end

normalizedTrialNum = xmax;
normalizedPC = ymean./length(y);

    


