%% add trialtype and trialnum to wsArray and wSigTrials
%% 

function plot_SetAmp(d,wsArray,solo_data,restrictTime,mad_threshold,redo)

if(nargin < 2)
[filename1,path]= uigetfile('wsArray*.mat', 'Load wsArray.mat file');
load([path filesep filename1]);
[filename2,path]= uigetfile('solo_data*.mat', 'Load solo_data.mat file');
load([path filesep filename2]);
end
names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wsArray.ws_trials,'uniformoutput',false);
wSig_trialnums =str2num(char(names));
if redo
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

    list = dir('wsArray*.mat');
    filename1 = list(1).name;
    save(filename1,'wsArray');
end
%% plot CR trials whisker data
cd (d);
if(exist('wsArray'))
else
    [filename1,path]= uigetfile('wsArray*.mat', 'Load wsArray.mat file');
    load([path filesep filename1]);    
end
name = wsArray.sessionName';
mouseName = wsArray.mouseName;
name = [mouseName ' ' name];
wSigTrials = wsArray.ws_trials;
trialtypes = cellfun(@(x) x.trialType,wSigTrials);
CRtrials = find(trialtypes==3);

Set=cellfun(@(x) x.Setpoint{1}, wSigTrials(CRtrials),'Uniformoutput',false);
t = cellfun(@(x) x.time{1}, wSigTrials(CRtrials),'Uniformoutput',false);
Amp =cellfun(@(x) x.Amplitude{1}, wSigTrials(CRtrials),'Uniformoutput',false);
theta = cellfun(@(x) x.theta{1}, wSigTrials(CRtrials),'Uniformoutput',false);

sc = get(0,'ScreenSize');
h1b = figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
suptitle([name 'CR 11:30']);
for i = 11:30
    [tuenv, tlenv]  =  envelope(theta{i}); devepoch = find(Amp{i}>(mad_threshold*mad(Amp{i})));
    subplot(10,2,i-10);
    plot(t{i},Set{i},'linewidth',1,'color','b'); hold on; 
    plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on; 
    plot(t{i},tuenv,'linewidth',1, 'color','k');hold on; plot(t{i}(devepoch),tuenv(devepoch),'k.','MarkerSize',6); 
    axis([restrictTime(1) restrictTime(2) -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end
set(gcf,'PaperPositionMode','auto');
% saveas(gcf,[name 'CR 11_30'],'eps');
print(h1b,'-depsc2','-painters','-loose',[name 'CR 11_30'])
close(h1b);

h1b = figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
suptitle([name 'CR 31:50']);
for i = 31:50
    [tuenv, tlenv]  =  envelope(theta{i});    devepoch = find(Amp{i}>(mad_threshold*mad(Amp{i})));
    subplot(10,2,i-30);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');hold on; plot(t{i}(devepoch),tuenv(devepoch),'k.','MarkerSize',6); hold on;axis([restrictTime(1) restrictTime(2)  -30 30]);
    text(2.25,10,['T' num2str(CRtrials(i))]);
end
set(gcf,'PaperPositionMode','auto');
% saveas(gcf,[name 'CR 31_50'],'eps');
 print(h1b,'-depsc2','-painters','-loose',[name 'CR 31_50'])
close(h1b);

if(length(theta) > i) 
    h1b = figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
    suptitle([name 'CR 51:70']); 
    for i = 51:min(length(theta),70)
        [tuenv, tlenv]  =  envelope(theta{i});  devepoch = find(Amp{i}>(mad_threshold*mad(Amp{i})));
        subplot(10,2,i-50);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');hold on; plot(t{i}(devepoch),tuenv(devepoch),'k.','MarkerSize',6);axis([restrictTime(1) restrictTime(2)  -30 30]);
        text(2.25,10,['T' num2str(CRtrials(i))]);
    end
    set(gcf,'PaperPositionMode','auto');
%     saveas(gcf,[name 'CR 51_70'],'eps');
    print(h1b,'-depsc2','-painters','-loose',[name 'CR 51_70'])
    close(h1b);
end

if(length(theta) > i) 
    h1b = figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
    suptitle([name 'CR 71:90']); 
    for i = 71:min(length(theta),90)
        try
            [tuenv, tlenv]  =  envelope(theta{i});
            subplot(10,2,i-70);plot(t{i},Set{i},'linewidth',1,'color','b'); hold on;plot(t{i},Amp{i},'linewidth',1, 'color','r');hold on;plot(t{i},tuenv,'linewidth',1, 'color','k');hold on; plot(t{i}(devepoch),tuenv(devepoch),'k.','MarkerSize',6);axis([restrictTime(1) restrictTime(2)  -30 30]);
            text(2.25,10,['T' num2str(CRtrials(i))]);
        catch
            break
        end
    end
    set(gcf,'PaperPositionMode','auto');
%     saveas(gcf,[name 'CR 71_90'],'eps');
    print(h1b,'-depsc2','-painters','-loose',[name 'CR 71_90'])
    close(h1b);
end
cd ..

%% 
