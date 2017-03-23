function contact_trig = make_contact_trig(syncedData)

whiskerID = 1;
pxlpermm = 24.38;
T = {'Single touch';'Multi touch'};
[Selection,ok] = listdlg('PromptString','Select mode of touch','ListString',T,'SelectionMode','single','ListSize',[160,100])
selected_contact_mode = T{Selection};

obj=syncedData;
temp = arrayfun(@(x) x.contacts,syncedData,'uniformoutput',false);
nodata = cellfun(@isempty, temp)
obj(nodata)=[];
temp = arrayfun(@(x) x.contacts{whiskerID},obj,'uniformoutput',false);
nocontact = cellfun(@isempty, temp);
obj(nocontact)=[];
contacttimes=arrayfun(@(x) x.contacts{whiskerID}, obj,'uniformoutput',false);
thetavals=arrayfun(@(x) x.theta{whiskerID}, obj,'uniformoutput',false);
kappavals=arrayfun(@(x) x.kappa{whiskerID}, obj,'uniformoutput',false);
Setpoint=arrayfun(@(x) x.Setpoint{whiskerID}, obj,'uniformoutput',false);
Amplitude=arrayfun(@(x) x.Amplitude{whiskerID}, obj,'uniformoutput',false);
deltaKappa=arrayfun(@(x) x.deltaKappa{whiskerID}, obj,'uniformoutput',false);
wTime=arrayfun(@(x) x.wTime{whiskerID}, obj,'uniformoutput',false);
contact_direct=arrayfun(@(x) x.contact_direct{whiskerID}, obj,'uniformoutput',false);
ephys= arrayfun(@(x) x.ephys, obj,'uniformoutput',false);
ephys_time= arrayfun(@(x) x.ephys_time, obj,'uniformoutput',false);
licks= arrayfun(@(x) x.licks, obj,'uniformoutput',false);


baseline = 0.5;
dur = 2.5;
wTimeScale = obj(1).wTimeScale;
wsTimeScale =  obj(1).wsTimeScale;

num_w_pts = ceil((dur+baseline)/wTimeScale);
num_ws_pts = ceil((dur+baseline)/wsTimeScale);

numcontacts =0;
contact_trig=struct('solo_trial',[],'ephys',{},'filt_ephys',{},'licks',{},'wstime',{},'bar_pos_trial',{},'contacts',{},'contact_direct',{},'deltaKappa',{},'Amplitude',{},'Setpoint',{},...
    'kappa',{},   'theta', {},'mouseName',{},'sessionName',{},'trialType',{},'trialCorrects',{},'bitcodeTrialNum',{},'total_touchKappa',{},'max_touchKappa',{});
count=0;

for i = 1:numtrials
    allcontacts = size(contacttimes{i},2);
    
    contacttimes_mat = cell2mat(contacttimes{i});
    contactdir_mat = [];count1 = 0 ;
    temp_dir= contactdir{i};
    temp_contacts = contacttimes{i};
    for c = 1: length(contacttimes{i})
        num_fr_touch = temp_contacts{c};
        contactdir_c =temp_dir(c);
        temp_contactdir_c = repmat(contactdir_c,1,length(num_fr_touch));
        contactdir_mat(count1+1:count1+length(num_fr_touch)) = temp_contactdir_c;
        count1 = count1 + length(num_fr_touch);
    end
    
    
    if strcmp(selected_contact_mode,'Single touch')
        discreet_contacts=[1,(find(diff(contacttimes_mat)> 5.0/wTimeScale)+1)]; %% making it ridiculously long so all contacts gets counted together
        contactind = contacttimes_mat(1);
        numcontacts =1;
    elseif strcmp(selected_contact_mode,'Multi touch')
        discreet_contacts= [1,(find(diff(contacttimes_mat)> 0.5/wTimeScale)+1)];
        numcontacts = length(discreet_contacts);
        contactind = zeros(numcontacts,1);
        contactind = contacttimes_mat(discreet_contacts);
    end
    
    
    extractedephys = zeros(1,num_ws_pts);
    extractedlicks = zeros(1,num_ws_pts);
    extractedephystime = zeros(1,num_ws_pts);
    extractedTheta=nan(1,num_ws_pts);
    extractedKappa=nan(1,num_ws_pts);
    extractedSetpoint=nan(1,num_ws_pts);
    extractedAmplitude=nan(1,num_ws_pts);
    extracteddeltaKappa=nan(1,num_ws_pts);
    extractedwTime=nan(1,num_ws_pts);
    
    
    for j= 1:numcontacts
        
        temp_ts_wsk = round([0:.002:6]*1000)/1000;
        
        if mismatch
            temp_ts_wsk = temp_ts_wsk +.5;
        end
        timepoint = round((contacttimes_mat(discreet_contacts(j))*wTimeScale)*1000)/1000; %% temporariliy increasing to 2x wSigframerate for #136
        
        st_round = round((timepoint-baseline)*1000)/1000;
        fin_round = round((timepoint+dur)*1000)/1000;
        ideal_indtimes = round([(st_round + wTimeScale) : wTimeScale :(fin_round)].*1000)/1000; %% temporariliy increasing to 2x wSigframerate for #136
        wdata_indtimes = temp_ts_wsk((st_round < temp_ts_wsk ) & (temp_ts_wsk <= fin_round));
        wdata_indtimes = round(wdata_indtimes .*1000)/1000;
        [val,id,wd]= intersect(ideal_indtimes,wdata_indtimes);
        temp_src_inds = find((st_round < temp_ts_wsk ) & (temp_ts_wsk <= fin_round));
        %% make sure it's unique vals
        [c,ia,ic]= unique(temp_ts_wsk(temp_src_inds));
        if( length(ia) < length(ic))
            wdata_src_inds = temp_src_inds(ia);
        else
            wdata_src_inds = temp_src_inds(ia);
        end
        wdata_dest_inds = id;
        temp=thetavals{i};
        filler_nan_inds=find(wdata_src_inds>length(temp));
        if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extractedTheta (wdata_dest_inds)=  temp(wdata_src_inds);
        Theta_at_contact_mean =  thetavals{i}( find(temp_ts_wsk == timepoint));
        
        temp=kappavals{i};  if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extractedKappa(wdata_dest_inds)= temp(wdata_src_inds);
        
        temp=Setpoint{i};if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extractedSetpoint(wdata_dest_inds)= temp(wdata_src_inds);
        
        temp=Amplitude{i};if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extractedAmplitude(wdata_dest_inds)= temp(wdata_src_inds);
        
        temp=deltaKappa{i};  if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extracteddeltaKappa(wdata_dest_inds)= temp(wdata_src_inds);
        
        temp=wTime{i};if ~isempty(filler_nan_inds) temp(wdata_src_inds(filler_nan_inds))=nan; end
        extractedwTime(wdata_dest_inds)= temp(wdata_src_inds);
        
        if (j < numcontacts)
            extractedcontacts=contacttimes_mat(discreet_contacts(j): discreet_contacts(j+1)-1);
            extractedcontactdir=contactdir_mat(discreet_contacts(j): discreet_contacts(j+1)-1);
        else
            extractedcontacts=contacttimes_mat(discreet_contacts(j):end);
            extractedcontactdir=contactdir_mat(discreet_contacts(j):end);
        end
        
        % % % % % % %
        % % % % % % %
        % % % % % % %             ephysattimepoint = ceil(timepoint/wsTimeScale);
        % % % % % % %             if( ephusattimepoint< ceil(.5/wsTimeScale))
        % % % % % % %                 diffephus=ceil(.5/wsTimeScale) - ephusattimepoint;
        % % % % % % %                 newbaseline=ephusattimepoint*wsTimeScale;
        % % % % % % %                 ephussamples(1:diffephus)=1;
        % % % % % % %                 ephussamples(diffephus+1:diffephus+ceil((newbaseline+dur)/wsTimeScale)+1) =(ephusattimepoint-ceil(newbaseline/wsTimeScale)+1):( ephusattimepoint+ceil(dur/wsTimeScale)+1);
        % % % % % % %             else
        % % % % % % %                 ephussamples =(ephusattimepoint-ceil(baseline*ephussamplerate)): min(( ephusattimepoint+ceil(dur*ephussamplerate)),length(CaTrials(i).ephusTrial.ephuststep));
        % % % % % % %             end
        
        if(timepoint<=.5)
            strwspt=1;
            diff_t=ceil((0.5-timepoint)*wsTimeScale);
        else
            strwspt=ceil((timepoint-baseline)*wsTimeScale);
        end
        
        endwspt = strframe + num_ws_pts-1;
        
        temp_ephys = ephys{i};
        temp_ephystime = ephys_time{i};
        temp_licks = licks{i};
        
        if(endwspt>size(ephys,2))
            extractedephys(:,1:size(temp_ephys,2)-strwspt+1) = temp_ephys(:,strwspt:size(temp_ephys,2),i);
            extractedephystime(:,1:size(temp_ephys,2)-strwspt+1) = temp_ephystime(:,strwspt:size(temp_ephystime,2),i);
            extractedlicks(:,1:size(temp_licks,2)-strwspt+1) = temp_licks(:,strwspt:size(temp_licks,2),i);
        elseif(timepoint<=baseline)
            
            extractedephys(:,diff_t+strwspt:diff_t+endwspt)= temp_ephys(:,strwspt:endwspt,i);
            extractedephystime(:,diff_t+strwspt:diff_t+endwspt)= temp_ephystime(:,strwspt:endwspt,i);
            extractedlicks(:,diff_t+strwspt:diff_t+endwspt)= temp_licks(:,strwspt:endwspt,i);
        else
            extractedephys = temp_ephys(:,strframe:endframe,i);
            extractedephystime = temp_ephystime(:,strframe:endframe,i);
            extractedlicks = temp_licks(:,strframe:endframe,i);
        end
        
        %% recompute total touch dKappa and theta at touch
        
        [tval,touchind,contactind] = intersect(ideal_indtimes,temp_ts_wsk(unique(extractedcontacts)));
        timeind = wdata_src_inds;
        
        %         [ri,ti,ci]= intersect(timeind,touchind);
        discreet_contacts_2= unique([1;find(diff(touchind)>2.0)]);
        
        
        Peakpercontact=0;Peakpercontact_abs=0;
        Theta_at_contact = [];cT=0;
        
        for p = 1:length(discreet_contacts_2)
            
            if(p == length(discreet_contacts_2))
                vals = extracteddeltaKappa(touchind(discreet_contacts_2(p):end)) ;
                valsTheta = extractedTheta(touchind(discreet_contacts_2(p):end)) ;
            else
                vals = extracteddeltaKappa(touchind( discreet_contacts_2(p): discreet_contacts_2(p+1)-1) );
                valsTheta = extractedTheta(touchind( discreet_contacts_2(p): discreet_contacts_2(p+1)-1) );
            end
            
            contdir = (abs(max(vals)) > abs(min(vals))) *0 +   (abs(max(vals)) < abs(min(vals)))  *1;
            
            if (contdir)
                Peakpercontact = Peakpercontact + min(vals );
                Peakpercontact_abs = Peakpercontact_abs + abs(min(vals));
                
            else
                Peakpercontact = Peakpercontact + max(vals );
                Peakpercontact_abs = Peakpercontact_abs + abs(max(vals));
            end
            Theta_at_contact(cT+1:cT+length(vals)) = valsTheta;
            cT=cT+length(vals);
        end
        tempT=Theta_at_contact;
        tempT=tempT(tempT~=0);
        
        if contdir
            re_totaldK = Peakpercontact./pxlpermm;
        else
            re_totaldK = Peakpercontact./pxlpermm;
        end
        
        if touchdir(maxind) == 1
            re_maxdK = (maxval * -1)./pxlpermm;
            
        elseif touchdir(maxind) == 0
            re_maxdK = (maxval)./pxlpermm;
        end
        %          if ~isempty(tempT)
        %              Theta_at_contact_mean =  tempT(1);  % mean(tempS(1,1:2),2); % just the first frame, no means
        %          else
        %             Theta_at_contact_mean = nan ;
        %
        %             waitforbuttonpress%
        %          end
        
        count = count +1;
        % % %             contact_CaTrials{count}=struct{'dff',{extractedCaSig},'FrameTime',CaTrials(CaSig_tags(i)).FrameTime,'nFrames',numframes,...
        % % %                                        'Trialind', CaTrials(CaSig_tags(i)).TrialNo,'TrialNo',trialnums(i),'nROIs',numrois};
        
        contact_trig(count).solo_trial = str2num(TrialName);
        contact_trig(count).ephys = extractedephys;
        contact_trig(count).licks = extractedlicks;
        contact_trig(count).wsTime = [strwspt:endwspt].*wsTimeScale;
        contact_trig(count).theta = {extractedTheta};
        contact_trig(count).kappa = {extractedKappa};
        contact_trig(count).Setpoint = {extractedSetpoint};
        contact_trig(count).Amplitude = {extractedAmplitude};
        contact_trig(count).deltaKappa = {extracteddeltaKappa};
        contact_trig(count).wTime={extractedwTime};
        contact_trig(count).contactdir = {extractedcontactdir};
        contact_trig(count).contacts = {extractedcontacts};
        contact_trig(count).contacts_shifted = {touchind};
        contact_trig(count).contacts={horzcat(contacttimes{i}{:})};
        contact_trig(count).barpos = obj{i}.bar_pos_trial(1,1);
        %         contact_trig(count).total_touchKappa_epoch = Peakpercontact;
        %         contact_trig(count).total_touchKappa_epoch_abs = Peakpercontact_abs;
        contact_trig(count).re_totaldK = re_totaldK;
        contact_trig(count).Theta_at_contact= {Theta_at_contact};
        %         contact_trig(count).Theta_at_contact_Mean = {Theta_at_contact_mean};
        
        temp_sortedCa(count).touchtimes = ts_wsk{i}(horzcat(contacttimes{i}{:}));
        
        temp_trialtype = obj{i}.trialType;
        temp_trialCorrect = obj{i}.trialCorrects;
        
        contact_trig(count).trialCorrect = temp_trialCorrect;
        
        if (temp_trialtype & temp_trialCorrect)
            contact_trig(count).trialtype = 'Hit';
        elseif (temp_trialtype & ~temp_trialCorrect)
            contact_trig(count).trialtype = 'Miss';
        elseif (~temp_trialtype & temp_trialCorrect)
            contact_trig(count).trialtype = 'CR';
        elseif (~temp_trialtype & ~temp_trialCorrect)
            contact_trig(count).trialtype = 'FA';
        end
        
        
        contact_trig(count).licks = extractedlicks;
        contact_trig(count).ephys = extractedephys;
        contact_trig(count).ephusttime = extractedephystime;
        
        
    end
end

end
