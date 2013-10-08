
function [contact_inds, contact_direction] = whisker_contact_detector_auto_thresh(dToBar, deltaKappa, barFrame_inds, kappaThresh_prior, threshDist0, threshDist_rough,time)
% Use combination of whisker to bar distance and curvature
% change for contact detection.

% dToBar, distance from whisker to bar center, 1 x nFrames, in mm.
% deltaKappa, mean kappa of an roi, subtracted by a baseline, 1 x nFrames, in 1/mm.
% bar_frame_range, frame index where bar is presented.
% threshold, a value of dToBar/deltaKappa, in mm2, below which consider as contact.
%
%
% OUTPUT: touch_windows, cell array with each elt being the frame index of
%         touch.
% kappaThresh_init: a single scaler, minial requirement for Kappa change.
%
% NX, Nov 2010.


contact_inds = {};
contact_direction = [];

% after reach criteria, search extra frames before and after to
% include light touch frames
nExtraFrames = 10;

%% step 1, find contact inds with more restricted Kappa threshold
% Use d2Bar of these data to set the new boundary of d2Bar
% threshold.
%             deltaKappa = medfilt1(deltaKappa,3);

d0 = dToBar(barFrame_inds);
k0 = medfilt1(deltaKappa(barFrame_inds),5);

% baseline for detaKappa in bar frames, using mode
[N,X] = hist(k0,20);
[~,ImaxN] = max(N);
ka_bs = mean(X(ImaxN));

% find the mode of distToBar, constrained between 2x and 0.5 of bar radius
if isempty(threshDist0)
    threshDist0 = 2.5;%1.2; % in mm, ~2x of bar radius, which is  17/25.7 = 0.6615. changed for thin bar 13/25.7 = .51
end
[N,X] = hist(d0 ( d0 > 0.125 &  d0< threshDist0 ),20);
[~,ImaxN] = max(N);
d0_mode = X(ImaxN);
% sd_dist = mad(d0,1)*1.4826;
ka_putative_tch = k0( d0 <= d0_mode);
% Use median absolute deviation to estimate the standard deviation, and use
threshKappa = mad(abs(ka_putative_tch),1)*1.4826;
if threshKappa < kappaThresh_prior(1)
    threshKappa = kappaThresh_prior(1);
end
if threshKappa > kappaThresh_prior(2)
    threshKappa = kappaThresh_prior(2);
end
%  fprintf('Kappa Threshold: %.3f\n', threshKappa);

ka_diff_mean = mean(abs(diff(ka_putative_tch)));

inds_prot = barFrame_inds(d0>threshDist_rough(1) & d0<threshDist_rough(2) & k0 < -threshKappa); % protraction Contact with certain

inds_retr = barFrame_inds(d0>threshDist_rough(1) & d0<threshDist_rough(2) & k0 > threshKappa); % retraction Contact with certain

count = barFrame_inds(1) - 1;
ind = 0;
touch_windows = {};
nContacts = 0;
p1 = 0; p2 = 0; 
r1 =0;
stop_count = 0;
while count < barFrame_inds(end) - 1
    count = count + 1;
    if ismember(count, [inds_prot inds_retr]) && stop_count==0 % && deltaKappa(count) < threshKappa(1)
        if p1 == 0 % start a new contact period
            p1 = count;
            % Assign an initial value of touch direction
            p2 = count;
%             count = count + 1;
        else
            % Check if the new point is with the same touch direction with p1.
            % Deal with the rebound following a strong Kappa change.
            prevframeby2 = find(barFrame_inds==max(count-2,barFrame_inds(1)) );
            
            k0_overlastframes = k0( prevframeby2:  min(prevframeby2+4,length(barFrame_inds)));
            dkappa_deflection = find(diff(k0_overlastframes)==0);
            if (ismember(p1, inds_prot) == ismember(count, inds_prot)) || (~isempty(dkappa_deflection))
                p2 = count;
            else
                % roll back, and ready for the end-of-touch check
                count = count - 1;
                stop_count = 1;
            end
        end
    elseif p1 > 0 && p2 > 0
        % Got putative touch period: p1:p2, check consistency
        % This putative touch should last at least 2 frames.
        stop_count = 0;
        % Length criteria before relaxation. Number of point with Kappa
        % change crossing threshold >=3, or the distance to bar vary within
        % 2 pixels
        if length(p1:p2) >= 2 || sum(abs(diff(dToBar(p1-1:p2+1))) <= 0.0389*2) >=2,   
            % determine touch direction, 1 for protraction, 0 for retraction
            touch_direc = mean(ismember(p1:p2, inds_prot)) > mean(ismember(p1:p2, inds_retr));
% % %             if touch_direc == 1 
% % %                 % For protraction, make sure p1 is NOT on the ascending
% % %                 % phase, and p2 is NOT on the descending phase
% % %                 if (deltaKappa(p1) < deltaKappa(p1+1) && deltaKappa(p1) > deltaKappa(p1-1)) ...
% % %                         || (deltaKappa(p2) > deltaKappa(p2+1) && deltaKappa(p2) < deltaKappa(p2-1))
% % %                     p1 = 0;
% % %                     continue
% % %                 end
% % %             else % for retraction the begining kappa should be ascending, the ending kappa should desending
% % % %                 if mean(diff(deltaKappa(p1-2:p1))) < 0 || mean(diff(deltaKappa(p2-1:p2+1))) > 0
% % %                   if (deltaKappa(p1) > deltaKappa(p1+1) && deltaKappa(p1) < deltaKappa(p1-1)) ...
% % %                       || (deltaKappa(p2) < deltaKappa(p2+1) && deltaKappa(p2) > deltaKappa(p2-1))
% % %                     p1 = 0;
% % %                     continue
% % %                 end
% % %             end
            % end of contact period, relax upto nExtraFrames
            for k = 1: nExtraFrames
                % relax a few frames but make sure not
                % overlaping with other contact periods.
                if (nContacts <1 && p1>=1) 
                    
                    % Criteria 1, change in deltaKappa
                    if touch_direc == 1 && (deltaKappa(p1) < deltaKappa(p1+1) && deltaKappa(p1) > deltaKappa(p1-1))
                        p1 = p1-1;
%                         aux_criteria1 = (deltaKappa(p1-1) - deltaKappa(p1) >= ka_diff_mean) && (deltaKappa(p1-1) < ka_bs);
                    elseif touch_direc == 0 && (deltaKappa(p1) < deltaKappa(p1+1) && deltaKappa(p1) > deltaKappa(p1-1))
                        p1 = p1-1;
%                         aux_criteria1 = (deltaKappa(p1-1) - deltaKappa(p1) <= -ka_diff_mean) && (deltaKappa(p1-1) > ka_bs);
                    end
                    
                    
                elseif  (p1-1>contact_inds{nContacts}(end))
              
                    % Criteria 1, change in deltaKappa
                    if touch_direc == 1 && (deltaKappa(p1) < deltaKappa(p1+1) && deltaKappa(p1) > deltaKappa(p1-1))
                        p1 = p1-1;
%                         aux_criteria1 = (deltaKappa(p1-1) - deltaKappa(p1) >= ka_diff_mean) && (deltaKappa(p1-1) < ka_bs);
                    elseif touch_direc == 0 && (deltaKappa(p1) < deltaKappa(p1+1) && deltaKappa(p1) > deltaKappa(p1-1))
                        p1 = p1-1;
%                         aux_criteria1 = (deltaKappa(p1-1) - deltaKappa(p1) <= -ka_diff_mean) && (deltaKappa(p1-1) > ka_bs);
                    end
                    
                    % Criteria 2, stability in distance
%                     aux_criteria2 = dToBar(p1-1) - dToBar(p1) <= 0.0389*2 && dToBar(p1-1) - dToBar(p1) > -0.0389*10;
%                     aux_criteria3 = dToBar(p1-1) - dToBar(p1) < 0.3;
%                     if (aux_criteria1 || aux_criteria2) && aux_criteria3 % && ~ismember(p1-1, [inds_prot inds_retr])% 2 pixels
                        
%                     end
                end
            end
            for k = 1: nExtraFrames
                % if next point cross threshold with a different touch
                % direction, then stop extending, and start a new touch.
                if ismember(p2 + 1,[inds_prot inds_retr])
%                     if ismember(p1, inds_prot) ~= ismember(p2+1, inds_prot)
                        count = p2;
                        break;
%                     end
                end
                % Criteria for extending p2.
                % aux_criteria_b1, make the whisker is close to the bar and
                % relatively stable.
                aux_criteria_b1 = dToBar(p2+1) - mean(dToBar(p2)) <= 0.0389*2 && dToBar(p2+1) - mean(dToBar(p2)) >= -0.0389*10;
                aux_criteria_b2 = (touch_direc == 1 && mean(diff(deltaKappa(p2:p2+2)))>0) || (touch_direc == 0 && mean(diff(deltaKappa(p2:p2+2)))<0);
                aux_criteria_b3 = (touch_direc == 1 && deltaKappa(p2+1)-deltaKappa(p2)>2*ka_diff_mean) || ...
                    (touch_direc == 0 &&  deltaKappa(p2)-deltaKappa(p2+1) > 2*ka_diff_mean);
                if (aux_criteria_b1 && aux_criteria_b2) || aux_criteria_b3
                    p2 = p2+1;
                end
            end
            % length criterion after relaxation
            if length(p1:p2) < 4
                p1 = 0;
                continue;
            end
            
            % Restrict contact period to > 6 ms
            
            nContacts = nContacts + 1;
            inds = p1:p2;
            FrameTime = time(2)-time(1);
            contact_inds{nContacts} = round(time(inds)/FrameTime);
            contact_direction(nContacts) = touch_direc;
            % if the current detected contact overlap with the previous one,
            % then append the current to the previus one. But constrained
            % by being the same touch direction
%             if nContacts > 1 && p1-1 <= contact_inds{nContacts-1}(end) && touch_direc == contact_direction(nContacts-1)
%                 contact_inds{nContacts-1} = [contact_inds{nContacts-1}  contact_inds{nContacts}];
%                 contact_inds(nContacts) = [];
%                 contact_direction(nContacts) = [];
%                 nContacts = nContacts - 1;
%             end
        end
        p1 = 0; % End of one contact period, reset p1
    end

end

