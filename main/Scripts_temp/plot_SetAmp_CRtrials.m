%% add trialtype and trialnum to wsArray and wSigTrials
%% 

[filename1,path]= uigetfile('wsArray*.mat', 'Load wsArray.mat file');
load([path filesep filename1]);
[filename2,path]= uigetfile('solo_data*.mat', 'Load solo_data.mat file');
load([path filesep filename2]);
names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wsArray.ws_trials,'uniformoutput',false);
wSig_trialnums =str2num(char(names));
for i = 1:wsArray.nTrials
    wsArray.ws_trials{i}.trialNum = wSig_trialnums(i);
    n=wSig_trialnums(i);
        switch solo_data.trialTypes(n)
            case 1
                if solo_data.trialCorrects(n)
                     wsArray.ws_trials{i}.trialType = 1; %Hit
                else
                    wsArray.ws_trials{i}.trialType = 2; %Miss
                end
            case 0            
                if solo_data.trialCorrects(n)
                     wsArray.ws_trials{i}.trialType = 3; %CR
                else
                    wsArray.ws_trials{i}.trialType = 4; %FA
                end
        end
end

save(filename1,'wsArray');

%% plot CR trials whisker data
wSigTrials = wsArray.ws_trials;
trialtypes = cellfun(@(x) x.trialType,wSigTrials);
CRtrials = find(trialtypes==3);

Set=cellfun(@(x) x.Setpoint{1}, wSigTrials(CRtrials),'Uniformoutput',false);
t = cellfun(@(x) x.time{1}, wSigTrials(CRtrials),'Uniformoutput',false);
Amp =cellfun(@(x) x.Amplitude{1}, wSigTrials(CRtrials),'Uniformoutput',false);
theta = cellfun(@(x) x.theta{1}, wSigTrials(CRtrials),'Uniformoutput',false);
figure; suptitle(['CR']);for i = 11:30
    [tuenv, tlenv]  =  envelope(theta{i});
    subplot(10,2,i-10);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');axis([.8 2.5 -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end

figure; suptitle(['CR']); for i = 31:50
    [tuenv, tlenv]  =  envelope(theta{i});
    subplot(10,2,i-30);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');axis([.8 2.5 -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end

figure; suptitle(['CR']); for i = 51:70
    [tuenv, tlenv]  =  envelope(theta{i});
    subplot(10,2,i-50);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');axis([.8 2.5 -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end

figure;  suptitle(['CR']); for i = 71:90
    [tuenv, tlenv]  =  envelope(theta{i});
    subplot(10,2,i-70);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');axis([.8 2.5 -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end
%% 
