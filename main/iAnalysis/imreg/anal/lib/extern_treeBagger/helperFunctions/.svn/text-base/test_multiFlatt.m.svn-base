set = [1:12];
for i=1:12,
    xx = xz_train(:,i);
    yy = xz_train(:,setdiff(set,i));
    [xp idx] = multiFlatBinData(xx,yy,20,0.25,ones(1,size(yy,2)));
    redVar(i,:) = nanstd(xz_train(idx,set));
end