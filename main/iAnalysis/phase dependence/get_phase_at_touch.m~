function [pooled_contactCaTrials_locdep] = get_phase_at_touch(pooled_contactCaTrials_locdep)
%% get mean theta points of crossing pole locations
loc = pooled_contactCaTrials_locdep{1}.poleloc;
contactThetaMean = pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean;
contactTheta = pooled_contactCaTrials_locdep{1}.touchTheta;
contactind = pooled_contactCaTrials_locdep{1}.contacts;
numtrials=size(contactTheta,1);
for t= 1:numtrials
    trace =  contactTheta{t};
    touchind = round((contactind{t}(1))/2);
    notnan = find(~isnan(trace));
    clean_theta = trace(notnan);
    
                    sampleRate=500;
                BandPassCutOffsInHz = [6 60];  %%check filter parameters!!!
                W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
                W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
                    [b,a]=butter(2,[W1 W2]);
                filteredSignal = filtfilt(b, a, clean_theta);
                [b,a]=butter(2, 6/ (sampleRate/2),'low');
                setpoint = filtfilt(b,a,clean_theta-filteredSignal);
                thetah=hilbert(filteredSignal);
                ph=atan2(imag(thetah),real(thetah)); 
                contactSetpoint(t) = setpoint(touchind-1);
                contactPhase(t) = ph(touchind-1);
    
end
contactSetpoint = contactSetpoint';
contactPhase = contactPhase';
numcells = size(pooled_contactCaTrials_locdep,2);
for i = 1:numcells
    pooled_contactCaTrials_locdep{i}.contactSetpoint = contactSetpoint;
    pooled_contactCaTrials_locdep{i}.contactPhase = contactPhase;
end


