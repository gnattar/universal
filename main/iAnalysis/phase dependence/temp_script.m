files = dir('*_pooled_contactCaTrials_phasedep.mat')
count = 0
for fn = 1:10
    f = files(fn).name
    load (f)

    
    mResp_NL = [];
     mResp_L = [];
     pref_phase=[];
     phase_preference =[];
     slope_ctrl=[];
     intercept_ctrl=[];
     slope_light=[];
     intercept_light=[];
     
for d = 1: size(pooled_contactCaTrials_locdep,2)    
    mResp_NL(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_NL;
     mResp_L(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_L;
    [v,in] = max(mResp_NL(d,:));
    pref_phase(d) = in;
    phase_preference (d,:)= [1:5] - in;
    slope_ctrl(d,:) =pooled_contactCaTrials_locdep{d}.phase.fit.NL_fitparam(:,1)';
    intercept_ctrl(d,:) =pooled_contactCaTrials_locdep{d}.phase.fit.NL_fitparam(:,2)';
    
    slope_light(d,:) =pooled_contactCaTrials_locdep{d}.phase.fit.L_fitparam(:,1)';
    intercept_light(d,:) =pooled_contactCaTrials_locdep{d}.phase.fit.L_fitparam(:,2)';
end
n= size(pooled_contactCaTrials_locdep,2);
Ctrl_mResp (count+1:count+n,:) = mResp_NL;
Ctrl_pref_phase(count+1:count+n,:) = pref_phase';
Ctrl_phase_preference (count+1:count+n,:)= phase_preference;
Ctrl_slopes(count+1:count+n,:) = slope_ctrl(:,:);
Ctrl_intercept(count+1:count+n,:) = intercept_ctrl(:,:);
Light_mResp (count+1:count+n,:) = mResp_L;
Light_slopes(count+1:count+n,:) = slope_light(:,:);
Light_intercept(count+1:count+n,:) = intercept_light(:,:);
count =count+n;
end

save('Ctrl_intercept','Ctrl_intercept')
save('Ctrl_mResp','Ctrl_mResp')
save('Ctrl_phase_preference','Ctrl_phase_preference')
save('Ctrl_pref_phase','Ctrl_pref_phase')
save('Ctrl_slopes','Ctrl_slopes')
save('Light_intercept','Light_intercept')
save('Light_mResp','Light_mResp')
save('Light_slopes','Light_slopes')