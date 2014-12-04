function [collected_data,collected_summary] = Collect_CaTrials_data()
% global collected_data
% global collected_summary
collected_data = {};
collected_summary = {};
% basedatapath = get(handles.contact_Sig_datapath,'String');
% if(length(basedatapath)<10)
%     basedatapath = '/Volumes/';
% end
% cd (basedatapath);
count=0;
  def={'88','140714','1','1','1,19'};
while(count>=0)

    [filename,pathName]=uigetfile('CaTrial*.mat','Load CaTrials*.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end

    load( [pathName filesep filename], '-mat');

    
    f=find(pathName == filesep);
    wSig_dest = pathName(1: f(length(f) - 3) -1 );
    cd(wSig_dest);
    [file,path]=uigetfile('wSigTrials*.mat','Load wSigTrials*.mat file');
    load( [path filesep file], '-mat');
    
    
    count=count+1;
    %     set(handles.wSigSum_datapath,'String',pathName);
    cd (pathName);
    prompt={'Mouse name','Session name','Reg','Fov','Enter the dends to collect'};
    name='Dends to collect';
    numlines=5;
   
    d = inputdlg(prompt,name,numlines,def) ;
    def=d;
    collected_summary{count}.mousename = d{1}; 
	collected_summary{count}.sessionname = d{2}; 
    collected_summary{count}.reg = str2num(d{3}); 
	collected_summary{count}.fov = str2num(d{4}); 
    collected_summary{count}.dends =str2num(d{5}); 
    
    dends =  str2num(d{5});
    all = [1:size(CaTrials(1).dff,1)];
    rem = setxor(all,dends);
  
    

    
    names=arrayfun(@(x) x.FileName(length(x.FileName)-6:length(x.FileName)-4), CaTrials,'uniformoutput',false);%%FileName_prefix removes everything but the trial counter
    CaSig_trialnums = str2num(char(names));%from trial filenames
    names=cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wSigTrials,'uniformoutput',false);
    wSig_trialnums =str2num(char(names)); % from trial filenames
    [common_trialnums,ctags,wtags]=intersect(CaSig_trialnums,wSig_trialnums);

    
indorder = [1:length(ctags)];
Y = [1:length(ctags)];
CaSig_tags = ctags(indorder);
wSig_tags=wtags(indorder);
trialnums=common_trialnums(indorder);% wrt CaTrials indices
trialinds = 1:length(trialnums);
whiskerID = 1
contacttimes=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
thetavals=cellfun(@(x) x.theta{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
kappavals=cellfun(@(x) x.kappa{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Velocity=cellfun(@(x) x.Velocity{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Setpoint=cellfun(@(x) x.Setpoint{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
Amplitude=cellfun(@(x) x.Amplitude{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
deltaKappa=cellfun(@(x) x.deltaKappa{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
ts_wsk=cellfun(@(x) x.time{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
contactdir=cellfun(@(x) x.contact_direct{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
contacts=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
contacts=cellfun(@(x) x.contacts{whiskerID}, wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
barpos=cellfun(@(x) x.bar_pos_trial(1,1), wSigTrials(wSig_tags(trialinds)),'uniformoutput',false);
CaTrials_data  = arrayfun(@(x) x.dff,CaTrials(CaSig_tags),'uniformoutput',false);
numtrials = length(CaTrials_data);
numrois = size(CaTrials_data{1},1);
numframes =size(CaTrials_data{1},2);
CaSig = zeros(numrois,numframes,numtrials);


for i = 1:numtrials
    obj_currtrial = CaTrials(CaSig_tags(i));
    temp(i).solo_trial = trialnums(i);
    temp(i).TrialName = num2str(trialnums(i));
    tempdff =  CaTrials_data{i}; 
    tempdff(rem,:) = [];
    temp(i).dff = tempdff(:,:);
    temp(i).FrameTime = obj_currtrial .FrameTime(1);
    temp(i).ts = [1:size(CaTrials_data(i),2)].* temp(i).FrameTime;
    if (obj_currtrial.behavTrial.trialType)
        if (obj_currtrial.behavTrial.trialCorrect)
            temp(i).trialtype = 'H';
        else
            temp(i).trialtype = 'M';
        end
    elseif ~(obj_currtrial.behavTrial.trialType)
        if (obj_currtrial.behavTrial.trialCorrect)
            temp(i).trialtype = 'C';
        else
            temp(i).trialtype = 'F';
        end
    end
    
    temp(i).licks = obj_currtrial.ephusTrial.licks;
    temp(i).theta = thetavals(i);
    temp(i).kappa = kappavals(i);
    temp(i).deltaKappa = deltaKappa(i);
    temp(i).ts_wsk = ts_wsk(i);
    temp(i).contactdir = contactdir(i);
    temp(i).contacts = contacts(i);
    temp(i).barpos = barpos(i);
    temp(i).Setpoint = Setpoint(i);
    temp(i).Amplitude = Amplitude(i);
    temp(i).Velocity = Velocity(i);
    temp(i).total_touchKappa = [];
    temp(i).max_touchKappa = [];
    temp(i).nframes = obj_currtrial.nFrames;
    temp(i).CaSigTrialind = CaSig_tags(i);
    temp(i).lightstim =  obj_currtrial.lightstim;
    temp(i).ephuststep = obj_currtrial.ephusTrial.ephuststep;
end
    collected_data{count} = temp;
   temp =[];
end
folder = uigetdir;
cd (folder);
save('collected_data','collected_data');
save ('collected_summary','collected_summary');