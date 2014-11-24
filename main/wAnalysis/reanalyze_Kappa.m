function pooled_contactCaTrials_thetadep_Silenced_SW_RE = reanalyze_Kappa(pooled_contactCaTrials_thetadep_Silenced_SW)

pooled_contactCaTrials_thetadep_Silenced_SW_RE = pooled_contactCaTrials_thetadep_Silenced_SW;

for n = 1:length(pooled_contactCaTrials_thetadep_Silenced_SW)
    
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.AbstotalKappa_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;
    pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata;
    
   
    a = []; ac = {};
    a(:,1) = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.lightstim;
    a(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.poleloc;
    a(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa;
    a(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;
    a(:,5)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.trialnum;

    RE = zeros(size(a,1),3);
    
    ac(:,1)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.touchdeltaKappa;
    ac(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contacts';
    ac(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contactdir;
    ac(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.timews;
    ploc = unique(a(:,2));
    
    numtrials = size(a,1);
    
    for j = 1:numtrials
        
        
        touchind =unique(ac{j,2}(:));
        temp = unique(round(ac{j,4}*500));
        [ri,ti,ci]= intersect(temp,touchind);
        t = unique(ac{j, 2});
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
        FrameTime = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.FrameTime;
        npts = 1:floor(0.5/FrameTime);
        if abs(nanmean(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata(j,npts)))>15
            rebase = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata(j,:);
            rebase = rebase - nanmean(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata(j,npts));
            pooled_contactCaTrials_thetadep_Silenced_SW{n}.rawdata_RE_RE (j,:) = rebase;
        else
        end
        smag = nansum(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,:));
        RE(j,1) = Peakpercontact;
        RE(j,2) = Peakpercontact_abs;
        RE(j,3) = smag;
    end
pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag_RE = RE(:,3);
pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.AbstotalKappa_RE = RE(:,2);
pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa_RE = RE(:,1);
end