temptrialnum =  cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uni',0)

tempcontacts=cellfun(@(x) x.contacts{1},wSigTrials,'uni',0)
temptime=cellfun(@(x) x.time{1},wSigTrials,'uni',0)
tempdKappa=cellfun(@(x) x.deltaKappa{1},wSigTrials,'uni',0)
temptheta=cellfun(@(x) x.theta{1},wSigTrials,'uni',0)
tempamp=cellfun(@(x) x.Amplitude{1},wSigTrials,'uni',0)

lightTrials=zeros(length(sorted_CaTrials.lightstimTNames),1);
nolightTrials = zeros(length(sorted_CaTrials.nolightstimTNames),1);
ls =zeros(length(temptrialnum),1);
trialnames = str2num(cell2mat(temptrialnum));
for i = 1: length(sorted_CaTrials.lightstimTNames)
    ind = find(trialnames == sorted_CaTrials.lightstimTNames(i));
    lightTrials(i) = ind;
    ls(ind) = 1;
    ind=[];
end
    
for i = 1: length(sorted_CaTrials.nolightstimTNames)
    ind = find(trialnames == sorted_CaTrials.nolightstimTNames(i));
    nolightTrials(i) = ind;
    ls(ind)=0;
    ind=[];
end

touches = ~(cellfun(@isempty,tempcontacts));
lightNtouch = (ls==1 & touches ==1);
nolightNtouch = (ls==0 & touches ==1);

lT= find(lightNtouch)
nlT=find(nolightNtouch)




tt =[210;212;213;215;217]
figure; 
for i = [1:5]
    t = tt(i);
subplot(5,1,i);

[AX,H1,H2] =plotyy(temptime{t},temptheta{t},temptime{t},tempamp{t});
set(H1,'linewidth',2);set(H2,'linewidth',2)
title([num2str(t) ' trial' temptrialnum(t)])
AX(1).XLim = [1.0 3];AX(2).XLim = [1.0 3];
temptouch = cell2mat(tempcontacts{t});
vline(temptouch/500); 
end

suptitle('NL')

tt =[160;163;164;168;172]
figure; 
for i = [1:5]
    t = tt(i);
subplot(5,1,i);

[AX,H1,H2] =plotyy(temptime{t},temptheta{t},temptime{t},tempamp{t});
set(H1,'linewidth',2,'color',[.1 .7 .6]);set(H2,'linewidth',2,'color','r')
title([num2str(t) ' trial' temptrialnum(t)])
AX(1).XLim = [1.0 3];AX(2).XLim = [1.0 3];
temptouch = cell2mat(tempcontacts{t});
vline(temptouch/500,{'LineWidth', .005}); hold on;
end

suptitle('L')
