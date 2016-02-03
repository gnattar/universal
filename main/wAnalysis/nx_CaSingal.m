nogoT= sort([ solo_data.falseAlarmTrialNums ,  solo_data.correctRejectionTrialNums ]);
wSigfilenames =str2num(char(cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false)));
[TN wtag stag] = intersect(wSigfilenames,nogoT);
tw=[1.35,2.5];

for i = 1:length(wtag)
   cw = wSigTrials{wtag(i)}.theta{1}; 
    
end