function [idx ] = multiFlatBinData(x,y,N_bins,proportion,weights,propExclude)
N_points = length(x);
binSize = ceil(N_points/N_bins);
z(:,1)              = x;
z(:,2)             = [1:N_points];
aux_y = y;
targetY = nanmedian(y,1);
% Replace with the median the missing values
for i=1:size(y,2),
    aux_y(find(isnan(y(:,i))),i) = targetY(i);
end
z(:,3:size(y,2)+2) = aux_y;
vals   = sortrows(z,1);
maxIdx = floor(proportion*binSize);
x_p = [];

idx = [];
if (size(weights,1) == 1)
    weights = weights';
end
% for k=1:50,
    for i=1:N_bins,
        if i<N_bins
            aux_x = vals((i-1)*binSize+1:i*binSize,1);
            aux_y = vals((i-1)*binSize+1:i*binSize,3:end);
            aux_idx = vals((i-1)*binSize+1:i*binSize,2);
        else
            aux_x = vals((i-1)*binSize+1:end,1);
            aux_y = vals((i-1)*binSize+1:end,3:end);
            aux_idx = vals((i-1)*binSize+1:end,2);            
        end
        valid_trials = find(~isnan(aux_x));
        clear bin_points
        bin_points(:,1) = aux_x(valid_trials);
        bin_points(:,2) = aux_idx(valid_trials);
        bin_points(:,3:size(aux_y,2)+2) = aux_y(valid_trials,:);
        bin_points(:,size(aux_y,2)+3)   = ((aux_y(valid_trials,:)-repmat(targetY,length(valid_trials),1)).^2)*weights;  % Here to get as close as possible to the median
        orderBin        = sortrows(bin_points,size(aux_y,2)+3); %Sort by closest to the median
%         x_p = [x_p orderBin(1:maxIdx,1)'];
        idx = [idx orderBin(1:maxIdx,2)'];
    end
    if propExclude > 0
        varBin(:,1) = ((z(idx,3:end)-repmat(targetY,length(idx),1)).^2)*weights;
        varBin(:,2) = idx;
        varBin      = sortrows(varBin,1);
        exclude     = varBin(floor((1-propExclude)*length(idx)):end,2);
        idx_1       = setdiff(idx,exclude);
        nonIncl     = setdiff([1:size(z,1)],idx);
        clear varBin;
        varBin(:,1) = ((z(nonIncl,3:end)-repmat(targetY,length(nonIncl),1)).^2)*weights;
        varBin(:,2) = nonIncl;
        varBin      = sortrows(varBin,1);
        idx_2       = varBin(1:ceil(propExclude*length(idx)),2)';
        idx         = sort([idx_1 idx_2]);
    end
%     var_p(k,:) = nanvar(y(idx,:),1);    
%     targetY = nanmedian(y(idx,:),1);
%     idx = [];
%     bin_points = [];
% end