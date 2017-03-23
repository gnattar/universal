function [syncedData] = syncData(wSigTrials,solo_data,wsdatafolder,cellnum)
cd(wsdatafolder)
  fstr = ['cell_' sprintf('%.2d',cellnum) '_*.h5'];
% files=dir('cell_01_2016*.h5');
files=dir(fstr);
for f=1:size(files,1)
    d = ws.loadDataFile([pwd filesep files(f).name])
    sweepnames = fieldnames(d);
    sweepnames(1)=[];
    names_array=cellfun(@(x) x(7:10), sweepnames,'uni',0);
    ws_trialnums =str2num(char(names_array));

    whiskerID = 1;
    names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wSigTrials,'uniformoutput',false);
    wSig_trialnums =str2num(char(names)); % from trial filenames

    solo_trialnums = solo_data.trialNums;

    [common_trialnums,wstags,wtags]=intersect(ws_trialnums,wSig_trialnums);

    for n = 1:length(common_trialnums)
        i=common_trialnums(n);
    %     sprintf('%04d',ws_trialnums)
        
       obj(i).solo_trial = i;
       obj(i).wsTimeScale  = 1/d.header.Acquisition.SampleRate;
       obj(i).ephys  = d.(sweepnames{wstags(n)}).analogScans(:,1);
       obj(i).licks = d.(sweepnames{wstags(n)}).analogScans(:,5);
       obj(i).bitcode= d.(sweepnames{wstags(n)}).analogScans(:,6);

       obj(i).wTimeScale = wSigTrials{wtags(n)}.framePeriodInSec;
       obj(i).wTime = wSigTrials{wtags(n)}.time;
       obj(i).bar_pos_trial=wSigTrials{wtags(n)}.bar_pos_trial;
       obj(i).bar_pos_trial=wSigTrials{wtags(n)}.bar_pos_trial;
       obj(i).bar_time_win=wSigTrials{wtags(n)}.bar_time_win;
       obj(i).contacts=wSigTrials{wtags(n)}.contacts;
       obj(i).contact_direct=wSigTrials{wtags(n)}.contact_direct;
       obj(i).whisk_amplitude=wSigTrials{wtags(n)}.whisk_amplitude;
       obj(i).deltaKappa=wSigTrials{wtags(n)}.deltaKappa;
       obj(i).Setpoint=wSigTrials{wtags(n)}.Setpoint;
       obj(i).Amplitude=wSigTrials{wtags(n)}.Amplitude;
       obj(i).Velocity=wSigTrials{wtags(n)}.Velocity;
       obj(i).trajectoryIDs=wSigTrials{wtags(n)}.trajectoryIDs;
       obj(i).trackerFileName=wSigTrials{wtags(n)}.trackerFileName;
       obj(i).kappa=wSigTrials{wtags(n)}.kappa;
       obj(i).theta=wSigTrials{wtags(n)}.theta;

       obj(i).mouseName=wSigTrials{wtags(n)}.mouseName;
       obj(i).sessionName=wSigTrials{wtags(n)}.sessionName;

       obj(i).trialType = solo_data.trialTypes(find(solo_trialnums==i));
       obj(i).trialCorrects = solo_data.trialCorrects(find(solo_trialnums==i));
       obj(i).polePositions = solo_data.polePositions(find(solo_trialnums==i));
       
       ephys=obj(i).ephys;
       ephys_time=[1:length(ephys)].* obj(i).wsTimeScale;
       bandPassCutOffsInHz = [75 500];
       sampleRate = 1/ephys_time(1);
       W1 = bandPassCutOffsInHz(1) / (sampleRate/2);
       W2 = bandPassCutOffsInHz(2) / (sampleRate/2);
       [b,a]=butter(2,[W1 W2]);
       filt_ephys = filtfilt(b,a,ephys);
       obj(i).filt_ephys  = filt_ephys;
       obj(i).ephys_time  = ephys_time;
       
    end
end
bitCodeTrialNums = getBitCodes(obj);

syncedData=obj;

for i = 1:size(obj,2)
    if ~isempty(syncedData(i).solo_trial)
        syncedData(i).bitcodeTrialNum = bitCodeTrialNums(i); 
    else
        syncedData(i).bitcodeTrialNum = [];
    end
end


