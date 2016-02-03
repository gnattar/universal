function get_phase_at_loc(pooled_contactCaTrials_locdep,solo_data,wSigTrials)
%% get mean theta points of crossing pole locations
loc = pooled_contactCaTrials_locdep{1}.poleloc;
contactThetaMean = pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean;
contactTheta = pooled_contactCaTrials_locdep{1}.touchTheta;
contactind = pooled_contactCaTrials_locdep{1}.contacts;
numtrials=size(contactTheta,1);
for t= 1:numtrials
    trace =  contactTheta{t};
    touchind = (contactind{t}(1))/2;
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
                
    contactSetpoint(t) = setpoint(touchind);
    
end
contactSetpoint = contactSetpoint';

locs= unique(loc);
for l = 1:length(locs)
l_inds = find(loc == locs(l));
touch_theta{l}=contactThetaMean(l_inds);
touch_Setpoint{l}=contactSetpoint(l_inds);
end

mean_contact_theta = cellfun(@mean,touch_theta)';
std_contact_theta = cellfun(@std,touch_theta)';
num_contact_theta = cellfun(@length,touch_theta)';
sem_contact_theta = std_contact_theta./(sqrt(num_contact_theta));

band_contact_theta = [(mean_contact_theta+sem_contact_theta)';(mean_contact_theta-sem_contact_theta)']'

%%
nogoT= sort([ solo_data.falseAlarmTrialNums ,  solo_data.correctRejectionTrialNums ]);
wSigfilenames =str2num(char(cellfun(@(x) x.trackerFileName(29:32),wSigTrials,'uniformoutput',false)));
[TN wtag stag] = intersect(wSigfilenames,nogoT);
timewind=[1.35,2.5];

figure;
for i = 1:length(wtag)
   cw = wSigTrials{wtag(i)}.theta{1}; 
    tw = wSigTrials{wtag(i)}.time{1};
 inds = find(timewind(1)<tw & tw<timewind(2));
 theta=cw(inds);
 t = tw(inds);
 
 BandPassCutOffsInHz = [6 60];  %%[6 60]check filter parameters!!! 4 25 Hill Kleinfeld
 W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
 W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
 [b,a]=butter(4,[W1 W2]); %% 2 otherwise 4 pole butterworth Hill Kleinfeld
 filteredSignal = filtfilt(b, a, theta);
 
 
 thetah=hilbert(filteredSignal);
  
phase=atan2(imag(thetah),real(thetah)); 
subplot(2,1,1),plot(theta);hline(band_contact_theta(:,1));hline(band_contact_theta(:,2));
subplot(2,1,2),plot(phase)

for l = 1:length(locs)
    cross_inds = find(band_contact_theta(l,1) > theta & theta > band_contact_theta(l,2)); 
% cross_inds = find(theta == mean_contact_theta(l,1)) ; 
if (~isempty(cross_inds))
 phase_at_loc{i}{l} = phase(cross_inds);
end
end

end