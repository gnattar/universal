function [data,obj] = calc_whiskingparams(wSigTrials,sorted_CaTrials,str)

numtrials =size(wSigTrials,2);

for t= 1:numtrials
    t
    epochs = [];
    contacts=[];
    ph=[];
    thetah=[];
    amp=[];
    clean_theta=[];
    inv = [];
    preAmp=[];preAmpMean=[];
   postAmp=[];postAmpMean=[];
    
    sampleRate = 1/wSigTrials{t}.framePeriodInSec;
    trace =  wSigTrials{t}.theta;
    contacts = wSigTrials{t}.contacts{1};
    if ~isempty(contacts)
        
        data{t}.touchPhase =  cellfun(@(x) x.phaseCont,wSigTrials{t}.contact_params{1});
        data{t}.touchTheta =  cellfun(@(x) x.thetaCont,wSigTrials{t}.contact_params{1});
        data{t}.touchDur =  cellfun(@(x) x.contactDuration,wSigTrials{t}.contact_params{1});
        data{t}.touchAmp =  cellfun(@(x) mean(x.AmplitudeCont),wSigTrials{t}.contact_params{1},'uni',0);
        data{t}.touchVel =  cellfun(@(x) x.velocityCont,wSigTrials{t}.contact_params{1});
        data{t}.touchPeakDKappa =  cellfun(@(x) x.peakDeltaKappa,wSigTrials{t}.contact_params{1});
        data{t}.touchDir =  cellfun(@(x) x.cont_direc,wSigTrials{t}.contact_params{1});
        data{t}.trialno =  cellfun(@(x) x.trialNo,wSigTrials{t}.contact_params{1});
        data{t}.touchFrameInds =  cellfun(@(x) x.frameInds,wSigTrials{t}.contact_params{1},'uni',0);

        clean_theta = wSigTrials{t}.theta{1};
         
        touchinds = cell2mat(contacts);
        framesfor250ms = .25*sampleRate;
        f15ms = round(.015*sampleRate);
        temp = find(diff(touchinds)>f15ms);
        if ~isempty(temp)
            epochs = [];count= 0; f = 1;
            for l = 1:length(temp)
                epochs(l,1) = touchinds(f);
                epochs(l,2) = touchinds(temp(l));
                f = temp(l) +1;
            end
            epochs(l+1,1) = touchinds(f);
            epochs(l+1,2) = touchinds(end);
        else
            epochs(1,1) =  touchinds(1);
            epochs(1,2) =  touchinds(end);
        end
        
        data{t}.epochs = epochs;
        data{t}.touchInds = touchinds;
        
       
        
        BandPassCutOffsInHz = [6 60];  %%check filter parameters!!!
        W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
        W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
        [b,a]=butter(2,[W1 W2]);
        filteredSignal = filtfilt(b, a, clean_theta);
        [b,a]=butter(2, 6/ (sampleRate/2),'low');
        setpoint = filtfilt(b,a,clean_theta-filteredSignal);
        thetah=hilbert(filteredSignal);
        amp = abs(thetah);
        ph=atan2(imag(thetah),real(thetah));
        data{t}.phase = ph;
        data{t}.amp = amp;
        data{t}.theta = clean_theta;
        
        temp = diff(amp);
        inv=sign(temp);
        inds = [];
        inds=(findstr(inv,[1 1 1 1 -1 -1 -1 -1])) + 4;
        numframes = .3*500;
        %                 inds ( inds< touchinds(1)-numframes) = [];
        %                 inds ( inds> touchinds(end)+numframes) = [];
        
        for i =1: size(epochs,1)
            tempis = find(inds>(epochs(i,1)-numframes) & inds<epochs(i,1));
            preAmp {i}= amp(inds(tempis));
            preAmpMean (i) = nanmean(amp(inds(tempis)));
            tempis = find(inds>epochs(i,2) &  inds<(epochs(i,2)+numframes));
            postAmp {i}=  amp(inds(tempis));
            postAmpMean (i) =  nanmean(amp(inds(tempis)));
        end
        
         data{t}.epochs = epochs;
        data{t}.preAmp = preAmp;
         data{t}.postAmp = postAmp;
         data{t}.preAmpMean = preAmp;
         data{t}.postAmpMean = postAmp;
         data{t}.touchPhase_calc =  ph(epochs(:,1));
         data{t}.touchPhase_deg =  ph(epochs(:,1))*180/pi;
    else
    end
        
end

temptrialnum =  cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uni',0);
tempcontacts=cellfun(@(x) x.contacts{1},wSigTrials,'uni',0);
temptime=cellfun(@(x) x.time{1},wSigTrials,'uni',0);
tempdKappa=cellfun(@(x) x.deltaKappa{1},wSigTrials,'uni',0);
temptheta=cellfun(@(x) x.theta{1},wSigTrials,'uni',0);
tempamp=cellfun(@(x) x.Amplitude{1},wSigTrials,'uni',0);

lightTrials=zeros(length(sorted_CaTrials.lightstimTNames),1);
nolightTrials = zeros(length(sorted_CaTrials.nolightstimTNames),1);
ls =zeros(length(temptrialnum),1);
trialnames = str2num(cell2mat(temptrialnum'));
c=[];it=[];is=[];
[c,it,is] = intersect(trialnames,sorted_CaTrials.lightstimTNames);
lightTrials = it;
ls(it)=1;
% for i = 1: length(sorted_CaTrials.lightstimTNames)
%     ind = find(trialnames == sorted_CaTrials.lightstimTNames(i));
%     lightTrials(i) = ind;
%     ls(ind) = 1;
%     ind=[];
% end
c=[];it=[];is=[];
    [c,it,is] = intersect(trialnames,sorted_CaTrials.nolightstimTNames);
nolightTrials = it;
ls(it)=0;
% for i = 1: length(sorted_CaTrials.nolightstimTNames)
%     ind = find(trialnames == sorted_CaTrials.nolightstimTNames(i));
%     nolightTrials(i) = ind;
%     ls(ind)=0;
%     ind=[];
% end

touches = ~(cellfun(@isempty,tempcontacts))';
lightNtouch = (ls==1 & touches ==1);
nolightNtouch = (ls==0 & touches ==1);

obj.lT= find(lightNtouch);
obj.nlT=find(nolightNtouch);
obj.trialnum=temptrialnum;
obj.contacts=tempcontacts;
obj.time=temptime;
obj.dKappa=tempdKappa;
obj.theta=temptheta;
obj.amp=tempamp;
save ('data','data')
save('obj','obj')
%% Touch Amp
tA_L=cellfun(@(x) x.touchAmp,data(obj.lT),'uni',0);
tA_NL=cellfun(@(x) x.touchAmp,data(obj.nlT),'uni',0);

temp_l=cell2mat(cellfun(@(x) cell2mat(x)', tA_L,'uni',0)');
temp_nl=cell2mat(cellfun(@(x) cell2mat(x)', tA_NL,'uni',0)');
% ttrl_nl=cellfun(@(x) x.trialno,data(obj.nlT),'uni',0);
% ttrl_l = cellfun(@(x) x.trialno,data(obj.lT),'uni',0);
% trial_nl = cell2mat(ttrl_nl);
% trial_l = cell2mat(ttrl_l);

temp = cell2mat(cellfun(@size,tA_NL,'uni',0)');
num_nl = temp(:,2);
temp = cell2mat(cellfun(@size,tA_L,'uni',0)');
num_l = temp(:,2);
for i = 1:size(num_nl)
ttrl_nl{i} = repmat(i,1,num_nl(i));
end
for i = 1:size(num_l)
ttrl_l{i} = repmat(i,1,num_l(i));
end
trial_nl = cell2mat(ttrl_nl)';
trial_l = cell2mat(ttrl_l)';
trial_l=trial_l+max(trial_nl);

'ttest touchAmp'
[h,p]=ttest2(temp_nl,temp_l)

h1=figure; colordef(h1,'white');
subplot(2,1,1);plot(trial_nl,temp_nl,'o');hold on; plot(trial_l,temp_l,'ro'); title('Touch Amp')

temp_nl=cellfun(@(x) cell2mat(x)', tA_NL,'uni',0)';
temp_l=cellfun(@(x) cell2mat(x)', tA_L,'uni',0)';
% trial_nl = cell2mat(cellfun(@(x) mean(x.trialno),data(obj.nlT),'uni',0));
% trial_l = cell2mat(cellfun(@(x) mean(x.trialno),data(obj.lT),'uni',0));
text(length(trial_nl),25,['p=' num2str(p)]);
subplot(2,1,2);
for i = 1:length(temp_nl)
t= temp_nl{i};
% trl = repmat(trial_nl(i),length(t),1);
trl = ttrl_nl{i};
scatter(trl,t,60,winter(length(t)),'filled'); hold on;
end

hold on;
% cmap=autumn(35);
for i = 1:length(temp_l)
t= temp_l{i};
% trl = repmat(trial_l(i),length(t),1);
trl = ttrl_l{i}+max(trial_nl);
scatter(trl,t,60,autumn(length(t)),'filled'); hold on;
end
title(['Touch Amp sorted by time' str])
saveas(gca,'TouchAmp','fig');
%%%

%% Amp Evolution
n=max(length(num_nl),length(num_l))+10;
cmap_c=othercolor('Paired3',n);
cmap_l=othercolor('OrRd4',n);
figure
subplot(1,2,1);
for i = 1:length(num_nl)
plot(temp_nl{i},'color',cmap_c(i,:));hold on;
end
subplot(1,2,2);
for i = 1:length(num_l)
plot(temp_l{i},'color',cmap_l(i,:));hold on;
end

tA_nl=nan(length(num_nl),35);
tA_l=nan(length(num_l),35);

for i = 1:length(num_nl)
twave = temp_nl{i};
if length(twave)>1
tA_nl(i,1:length(twave)) = twave;
else
end
end
for i = 1:length(num_l)
twave = temp_l{i};
if length(twave)>1
tA_l(i,1:length(twave)) = twave;
else
end
end
subplot(1,2,1);
hold on;
e1=errorbar(nanmean(tA_nl),nanstd(tA_nl)./sqrt(sum(~isnan(tA_nl))),'bo-');
axis([0 20 -5 20]);
subplot(1,2,2);
hold on;
e2=errorbar(nanmean(tA_l),nanstd(tA_l)./sqrt(sum(~isnan(tA_l))),'ro-')
suptitle(['Touch Amp Evolution' str])
axis([0 20 -5 20]);
saveas(gca,'TouchAmp Evolution','fig');
print( gcf ,'-depsc2','-painters','-loose',['TouchAmp Evolution']);

figure;
e1=errorbar(nanmean(tA_nl),nanstd(tA_nl)./sqrt(sum(~isnan(tA_nl))),'ko-');hold on;
e2=errorbar(nanmean(tA_l),nanstd(tA_l)./sqrt(sum(~isnan(tA_l))),'ro-');
suptitle(['Touch Amp Evolution' str]);
 axis([0 20 0 10]);
saveas(gca,'TouchAmp Evolution NL L','fig');
print( gcf ,'-depsc2','-painters','-loose',['TouchAmp Evolution NL L']);

%%
 temp_l=cellfun(@(x) x.preAmp,data(obj.lT),'uni',0);
 tpreA_L=cellfun(@(x) cell2mat(x), temp_l,'uni',0);

 temp_nl=cellfun(@(x) x.preAmp,data(obj.nlT),'uni',0);
 tpreA_NL=cellfun(@(x) cell2mat(x), temp_nl,'uni',0);

  temp_l=cellfun(@(x) x.postAmp,data(obj.lT),'uni',0);
 tpostA_L=cellfun(@(x) cell2mat(x), temp_l,'uni',0);

 temp_nl=cellfun(@(x) x.postAmp,data(obj.nlT),'uni',0);
 tpostA_NL=cellfun(@(x) cell2mat(x), temp_nl,'uni',0);

% ttrl_nl=cellfun(@(x) mean(x.trialno),data(obj.nlT),'uni',0);
% ttrl_l = cellfun(@(x) mean(x.trialno),data(obj.lT),'uni',0);


figure;
% pre
temp = cell2mat(cellfun(@size,tpreA_NL,'uni',0)');
num_nl = temp(:,2);
temp = cell2mat(cellfun(@size,tpreA_L,'uni',0)');
num_l = temp(:,2);



for i = 1:length(num_nl)
% tempval = ttrl_nl{i};
tempval = i;
ttrl_nl{i} = repmat(tempval,1,num_nl(i));
end
for i = 1:length(num_l)
% tempval = ttrl_l{i};
tempval =i;
ttrl_l{i} = repmat(tempval,1,num_l(i));
end
trial_nl = cell2mat(ttrl_nl)';
trial_l = cell2mat(ttrl_l)';
trial_l=trial_l+max(trial_nl);

subplot(2,1,1);plot(cell2mat(ttrl_nl),cell2mat(tpreA_NL),'o'); hold on;
plot(cell2mat(ttrl_l)+max(trial_nl),cell2mat(tpreA_L),'ro'); title('Pre Amp')
'ttest PreAmp'
[h,p] = ttest2(cell2mat(tpreA_NL),cell2mat(tpreA_L))
text(length(ttrl_nl),25,['p=' num2str(p)])


% post
temp = cell2mat(cellfun(@size,tpostA_NL,'uni',0)');
num_nl = temp(:,2);
temp = cell2mat(cellfun(@size,tpostA_L,'uni',0)');
num_l = temp(:,2);
% ttrl_nl=cellfun(@(x) mean(x.trialno),data(obj.nlT),'uni',0);
% ttrl_l = cellfun(@(x) mean(x.trialno),data(obj.lT),'uni',0);
for i = 1:length(num_nl)
% tempval = ttrl_nl{i};
tempval = i;
ttrl_nl{i} = repmat(tempval,1,num_nl(i));
end
for i = 1:length(num_l)
% tempval = ttrl_l{i};
tempval = i;
ttrl_l{i} = repmat(tempval,1,num_l(i));
end
trial_nl = cell2mat(ttrl_nl)';
trial_l = cell2mat(ttrl_l)';
trial_l=trial_l+max(trial_nl);

subplot(2,1,2); plot(cell2mat(ttrl_nl),cell2mat(tpostA_NL),'o'); hold on;
plot(cell2mat(ttrl_l)+max(trial_nl),cell2mat(tpostA_L),'ro'); title('Post Amp')
'ttest PostAmp'
[h,p] = ttest2(cell2mat(tpostA_NL),cell2mat(tpostA_L))
text(length(ttrl_nl),25,['p=' num2str(p)])

saveas(gca,'Pre_Post_Amp','fig');

%%
%% Phase
tA_L=cellfun(@(x) x.touchPhase_deg,data(obj.lT),'uni',0);
tA_NL=cellfun(@(x) x.touchPhase_deg,data(obj.nlT),'uni',0);

temp_l=cell2mat(tA_L)';
temp_nl=cell2mat(tA_NL)';


temp = cell2mat(cellfun(@size,tA_NL,'uni',0)');
num_nl = temp(:,2);
temp = cell2mat(cellfun(@size,tA_L,'uni',0)');
num_l = temp(:,2);
for i = 1:size(num_nl)
ttrl_nl{i} = repmat(i,1,num_nl(i));
end
for i = 1:size(num_l)
ttrl_l{i} = repmat(i,1,num_l(i));
end
trial_nl = cell2mat(ttrl_nl)';
trial_l = cell2mat(ttrl_l)';
trial_l=trial_l+max(trial_nl);

'ttest touchPhase'
[h,p]=ttest2(temp_nl,temp_l)

h1=figure; colordef(h1,'white');
subplot(2,1,1);plot(trial_nl,temp_nl,'o');hold on; plot(trial_l,temp_l,'ro'); title('Touch Phase')

% temp_l=cell2mat(tA_L)';
% temp_nl=cell2mat(tA_NL)';

text(length(trial_nl),25,['p=' num2str(p)]);
subplot(2,1,2);
for i = 1:length(tA_NL)
t= tA_NL{i};
trl = ttrl_nl{i};
scatter(trl,t,60,winter(length(t)),'filled'); hold on;
end

hold on;
for i = 1:length(tA_L)
t= tA_L{i};
trl = ttrl_l{i}+max(trial_nl);
scatter(trl,t,60,autumn(length(t)),'filled'); hold on;
end
title('Touch Phase sorted by time')
saveas(gca,'TouchPhase','fig');

