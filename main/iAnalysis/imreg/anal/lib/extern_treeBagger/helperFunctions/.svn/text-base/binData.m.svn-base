function [x_m y_m x_s y_s] = binData(xx,yy,N_bins)
x_m = zeros(N_bins+1,1);
y_m = zeros(N_bins+1,1);
x_s = zeros(N_bins+1,1);
y_s = zeros(N_bins+1,1);
x= xx;
y= yy;
xMode = mode(x);
idxMode   = find(x==mode(x));
aux_x   = x(idxMode);
aux_y   = y(idxMode);
valid_trials = intersect (find(~isnan(aux_x)),find(~isnan(aux_y)));
x_m(1) = mean(aux_x(valid_trials ));
y_m(1) = mean(aux_y(valid_trials ));
x_s(1) = std(aux_x(valid_trials ))/sqrt(length(valid_trials ));
y_s(1) = std(aux_y(valid_trials ))/sqrt(length(valid_trials ));    
x(idxMode) = [];
y(idxMode) = [];
min_x = min(x);
max_x = max(x);
N_points = length(x);
binSize = ceil(N_points/N_bins);
z(:,1) = x;
z(:,2) = y;
vals   = sortrows(z,1);

for i=1:N_bins,
    maxRange = min(i*binSize,size(vals,1));
    aux_x = vals((i-1)*binSize+1:maxRange,1);
    aux_y = vals((i-1)*binSize+1:maxRange,2);
    valid_trials = intersect (find(~isnan(aux_x)),find(~isnan(aux_y)));
    x_m(i+1) = mean(aux_x(valid_trials ));
    y_m(i+1) = mean(aux_y(valid_trials ));
    x_s(i+1) = std(aux_x(valid_trials ))/sqrt(length(valid_trials ));
    y_s(i+1) = std(aux_y(valid_trials ))/sqrt(length(valid_trials ));    
end
auxx(:,1)  = x_m;
auxx(:,2)  = [1:length(x_m)];
auxx       = sortrows(auxx,1);
x_m        = x_m(auxx(:,2));
y_m        = y_m(auxx(:,2));
x_s        = x_s(auxx(:,2));
y_s        = y_s(auxx(:,2));

