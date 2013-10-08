function [ synced_sessObj ] = sync_all_session_data( sessObj)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes 
    
    if isfield(sessObj,'behavTrials')       
        bObj = sessObj.behavTrials;
        loaded =1;
    else        
        'Load behav trials in sessObj';
        return
    end
        
    if isfield(sessObj,'ephusTrials')       
        eObj = sessObj.ephusTrials;
        loaded =2;
    else        
        'Load ephus trials in sessObj';
        return
    end        
        
    if isfield(sessObj,'ephusTrials')       
        wObj = sessObj.wSigTrials;
        loaded =3;
    else        
        'Load wSig trials in sessObj';
        return
    end   

    if isfield(sessObj,'CaTrials')       
        cObj = sessObj.CaTrials;
        loaded =4;
    else        
        'Not Loaded CaSig trials in sessObj';       
    end
    
    obj = struct ('solo_trial',[],'trialtype',[],'trialCorrect',[],'barpos',[],'dff',{},'ts',{},'FrameTime',{},'nFrames',{},'nROIs',{},'CaSigTrialind',{},'FileName_prefix',{},'FileName',{},...
                'TrialName',{},'theta',{},'Setpoint',{},'Amplitude',{},'Velocity',{},'kappa',{},'deltaKappa',{},'ts_wsk',{},'contactdir',{},'contacts',{},...
                'licks',{},'poleposition',{},'ephuststep',{},'bitcode',{});

    bTrials = cell2mat(cellfun(@(x) x.trialNum, bObj,'Uniformoutput',false));
    eTrials = str2num(char(arrayfun(@(x) x.trialname,eObj,'Uniformoutput',false))) ;
    wTrials =str2num(char(cellfun(@(x) x.trackerFileName(length(x.trackerFileName)-21:length(x.trackerFileName)-18),wObj,'uniformoutput',false)));
    if (loaded >3)
        cTrials =str2num(char(arrayfun(@(x) strrep(strrep(x.FileName,x.FileName_prefix,''),'.tif',''), cObj,'Uniformoutput',false)));
    end
    
    obj = {};
    for i = 1:length(bTrials)
        obj(i).solo_trial = bTrials(i);
        obj(i).trialtype = bObj{i}.trialType;
        obj(i).trialCorrect = bObj{i}.trialCorrect;
        obj(i).barpos = (bObj{i}.goPosition * bObj{i}.trialType) +  (bObj{i}.nogoPosition * ~bObj{i}.trialType) ;
        if (loaded >3)
             c_ind = find(cTrials == bTrials(i));
        else
            c_ind=[];
        end
        w_ind = find(wTrials == bTrials(i));
        e_ind = find(eTrials == bTrials(i));

        if ~isempty(c_ind)
           obj(i).dff = cObj(c_ind).dff;
           obj(i).FrameTime = cObj(c_ind).FrameTime;
           obj(i).nFrames = cObj((c_ind)).nFrames;
           obj(i).ts = {[1: obj(i).nFrames]* obj(i).FrameTime};
           obj(i).nROIs = cObj(c_ind).nROIs;
           obj(i).CaSigTrialind = cObj(c_ind).TrialNo;
           obj(i).FileName_prefix = cObj(c_ind).FileName_prefix;
           obj(i).FileName = cObj(c_ind).FileName;
           obj(i).TrialName = strrep(strrep( obj(i).FileName,obj(i).FileName_prefix,''),'.tif','');      
        end



         if ~isempty(w_ind)
           obj(i).theta = wObj{w_ind}.theta;
           obj(i).Setpoint = wObj{w_ind}.Setpoint;
           obj(i).Amplitude = wObj{w_ind}.Amplitude;
           obj(i).Velocity = wObj{w_ind}.Velocity;
           obj(i).kappa = wObj{w_ind}.kappa;
            obj(i).deltaKappa = wObj{w_ind}.deltaKappa;
            obj(i).ts_wsk = wObj{w_ind}.time;
            obj(i).contactdir = wObj{w_ind}.contact_direct;
            obj(i).contacts = wObj{w_ind}.contacts;       
         end


         if ~isempty(e_ind)
           obj(i).licks = eObj(e_ind).licks;
           obj(i).poleposition = eObj(e_ind).poleposition;
           obj(i).ephuststep = eObj(e_ind).ephuststep;
           obj(i).bitcode = eObj(e_ind).bitcode;
         end

    end
    
    synced_sessObj = obj;
    sessObj.synced_sessObj = obj;
    save('sessObj.mat','sessObj');
    

