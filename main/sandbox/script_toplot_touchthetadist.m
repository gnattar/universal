figure; hold on;
count = 1;totaldends = length(LPI);
thetabins = [-50:5:50];
tempdata= nan(totaldends,length(thetabins));
for sess = 1: size(data.NormSlopes_ctrl,2)
dends = size(data.NormSlopes_ctrl{sess},1);
for d = 1:dends
    touch_th = data.TouchTh_ctrl{sess}(d,:);
    Pref_touch_th = data.PTh_ctrl{sess}(d);
    temp = touch_th-Pref_touch_th;
    x = 5.*round(temp/5); % rounding to nearest 5
    y = data.NormSlopes_ctrl{sess}(d,:);
    
    plot(x,y,'o-','color',[.5 .5 .5],'linewidth',.2); hold on;
    for t = 1:length(x)        
        tempdata (count,find(thetabins==x(t))) = y(t);
    end
    count = count+1;
end
end
hold on;h= errorbar(thetabins,nanmean(tempdata),nanstd(tempdata)./sqrt(nansum(tempdata)),'ko-')
set(h,'linewidth',2,'markersize',6);
 axis([-50 50 0 6])
xlabel('dTheta (deg from max)');
ylabel('Norm. Slope dFF vs |dK|');