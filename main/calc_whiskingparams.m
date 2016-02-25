function [data,obj] = calc_whiskingparams(wSigTrials,sorted_CaTrials)

numtrials =size(wSigTrials,2);

for t= 1:numtrials
    t
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
        
        if t == 63
            'pause'
        end
        
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
            epochs(l,1) = touchinds(f);
            epochs(l,2) = touchinds(end);
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
        
        
        temp = diff(amp);
        inv=sign(temp);
        inds=(findstr(inv,[1 1 1 1 -1 -1 -1 -1])) + 4;
        numframes = .3*500;
        %                 inds ( inds< touchinds(1)-numframes) = [];
        %                 inds ( inds> touchinds(end)+numframes) = [];
        
        for i =1: size(epochs,1)
            tempis = find(inds>(epochs(1,1)-numframes) & inds<epochs(1,1));
            preAmp (i) = nanmean(amp(inds(tempis)));
            tempis = find(inds>epochs(1,2) &  inds<(epochs(1,2)+numframes));
            postAmp (i) =  nanmean(amp(inds(tempis)));
        end
        
         data{t}.epochs = epochs;
        data{t}.preAmp = preAmp;
         data{t}.postAmp = postAmp;
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

