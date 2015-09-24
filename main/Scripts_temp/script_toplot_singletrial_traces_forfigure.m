t=50;
tca=[1:76]*pooled_contactCaTrials_locdep{1}.FrameTime;
tind = find(~isnan(pooled_contactCaTrials_locdep{1}.timews{t,1}));
ka=pooled_contactCaTrials_locdep{1}.touchdeltaKappa{t,1}(tind);
tw =pooled_contactCaTrials_locdep{1}.timews{t,1}(tind);
tw = tw - tw(1);
th =pooled_contactCaTrials_locdep{1}.touchTheta{t,1}(tind);

                clean_theta=th;

                sampleRate=1/.002;
                BandPassCutOffsInHz = [6 60];  %%check filter parameters!!!
                W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
                W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
                [b,a]=butter(2,[W1 W2]);
                filteredSignal = filtfilt(b, a, clean_theta);

                [b,a]=butter(2, 6/ (sampleRate/2),'low');
                setpoint = filtfilt(b,a,clean_theta-filteredSignal);

                hh=hilbert(filteredSignal);
                amp=abs(hh);


 sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)*1/6.75, sc(4)*1], 'color','w');
subplot(3,1,1);plot(tca,pooled_contactCaTrials_locdep{1}.filtdata(t,:));title(['t' num2str(t) ' Act Tr '  num2str(pooled_contactCaTrials_locdep{1}.trialnum(t))]);
axis([0.25 1.75 -50 500 ]);
subplot(3,1,2);plot(tw,ka);
axis([ 0.25 1.75 -.5 1]);
subplot(3,1,3);plot(tw,th,'k');hold on; plot(tw,setpoint,'b');
axis([ 0.25 1.75 -20 40]);