function pooled_contactCaTrials_thetadep_Silenced_SW_RE= reanalyze_Ca_Kappa(pooled_contactCaTrials_thetadep_Silenced_SW,tag)

pooled_contactCaTrials_thetadep_Silenced_SW_RE = pooled_contactCaTrials_thetadep_Silenced_SW;

for n = 1:length(pooled_contactCaTrials_thetadep_Silenced_SW)
    
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.AbstotalKappa_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE =  pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigpeak_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;
   
    a = []; ac = {};
    a(:,1) = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.lightstim;
    a(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.poleloc;
    if(~isempty(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa))
      a(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    end
    a(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;
    a(:,5)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.trialnum;

    RE = zeros(size(a,1),6);
    
    ac(:,1)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.touchdeltaKappa;
    ac(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contacts';
    ac(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contactdir;
    ac(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.timews;
    ploc = unique(a(:,2));
    
    numtrials = size(a,1);
    
    for j = 1:numtrials
        Peakpercontact =0;
        Peakpercontact_abs =0;
        smag =0;
        if(isempty(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contacts{j}))
            RE(j,5) = 1;
        else
            if tag
               touchind =unique(cell2mat(ac{j,2})); 
            else
                touchind =unique(ac{j,2}(:));
            end
            temp = unique(round(ac{j,4}*500));
            [ri,ti,ci]= intersect(temp,touchind);
            t = unique(touchind);
            ind=find(diff(t)~=1);
            count =0;Peakpercontact=0;Peakpercontact_abs=0;
            
            for p = 1:(length(ind)+1)
                
                if(p >length(ind))
                    vals = ac{j,1}(ti(count+1:end)) ;
                else
                    vals = ac{j,1}(ti(count+1:ind(p))) ;
                end
                
                contdir = (abs(max(vals)) > abs(min(vals))) *0 +   (abs(max(vals)) < abs(min(vals)))  *1;
                if (contdir &  min(vals )<.3)
                    Peakpercontact = Peakpercontact + min(vals );
                    Peakpercontact_abs = Peakpercontact_abs + abs(min(vals));
                elseif(max(vals)>.3)
                    Peakpercontact = Peakpercontact + max(vals );
                    Peakpercontact_abs = Peakpercontact_abs + abs(max(vals));
                end
                if(p>length(ind))
                else
                    count = ind(p);
                end
                
            end
        end
        FrameTime = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.FrameTime;

        temp_Ca = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata(j,:);
        pt = round(ac{j,4}(1)./FrameTime);
        spt = pt.*FrameTime;
        ept = ((length(temp_Ca)-1).* FrameTime)+spt;
        ts_Ca =[spt:FrameTime:ept]; 
        Ca_poleperiod = find((ts_Ca>1.3) & (ts_Ca<2.55));

        smag = nansum(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,Ca_poleperiod));
        RE(j,1) = Peakpercontact;
        RE(j,2) = Peakpercontact_abs;
        RE(j,3) = smag;
        RE(j,6) = nanmean(prctile(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,Ca_poleperiod),95));
        RE(j,4) = ac{j,4}(ti(1));
    end
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag_RE = RE(:,3);
     pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigpeak_RE = RE(:,6);
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.AbstotalKappa_RE = RE(:,2);
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa_RE = RE(:,1);
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.time_firsttouch_RE =RE(:,4);
end