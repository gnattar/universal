function [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(src_data,sampling_time,threshold)
event_detected_data = zeros(size(src_data,1),floor(3/sampling_time) );
detected = zeros(size(src_data,1),1);
events= zeros(size(src_data,1),1);
events_septs = ones(size(src_data,1),2);
temp_events_amp = {};
temp_events_dur = {};
events_septs (:,2) = 2;
diffmem = zeros(2,1);
for i = 1:size(src_data,1)
    current_trace = src_data(i,:);
    windowSize = round(0.1/sampling_time);
    
    ct = filter(ones(1,windowSize)/windowSize,1, current_trace);
    %     ct = current_trace(1:round(3/sampling_time));
    %     rel_thr = current_trace(1:floor(.8/sampling_time))*1.25;
    thrcrossing =  find((ct> threshold));
    %         thrcrossing =  find( ct > mad(current_trace(1:floor(.8/sampling_time))*1.25) & (ct> threshold));
    d = [0,diff(thrcrossing)==1,0];
    startind = strfind(d,[0 1]); endind = strfind(d,[1 0]);
    % %     if(10>length(thrcrossing)) & (length(thrcrossing)> round(0.3/sampling_time))
    % %         i
    % %         length(thrcrossing)
    % %     end
    eventnum = find((endind-startind)>round(0.20/sampling_time));
   
    if length(eventnum) >1
        
        eventnum = eventnum(1);
    end
    eventscount =0;
    if(max(endind-startind) >round(0.20/sampling_time))
        
        if(eventnum>0)
            %          if(max(endind-startind) >3) %% there are points above 80% and the
            %         points are not just noise %% commented out to check for 1:365b
            %         data discrepancy
            found =1;eventscount = 1;
            detected(i) =1;
%             if i ==66
%                 i
%             end
            
            if  thrcrossing(startind(eventnum))>6
                temp = ct(thrcrossing(startind(eventnum))-5:thrcrossing(startind(eventnum)));
                dtemp = sign(diff(temp)) ;
                points = strfind(dtemp,[-1 1 ]);
                if isempty(points)
                 points =  1;  
                elseif length(points)>1
                    points=points(end);
                end
                points = thrcrossing(startind(eventnum))-(6-points);

                if points(end) >= thrcrossing(startind(eventnum))
                    event_index = thrcrossing(startind(eventnum));
                elseif points(end)< thrcrossing(startind(eventnum))
                    event_index = points(end);
                end
                
            else
                event_index = thrcrossing(startind(eventnum));
            end
            events_septs (i,1) = event_index ;
            events_septs (i,2) = thrcrossing(endind(eventnum));
            temp = current_trace(max(1,event_index - floor(.5/sampling_time)): min(length(current_trace),event_index + round(2.5/sampling_time)));
            leading_blank = event_index - floor(.5/sampling_time);
            offset = (leading_blank <0);
            event_detected_data (i, (offset*leading_blank*-1)+1 :length(temp)+(offset*leading_blank*-1)) = temp;
            inds = thrcrossing(startind(eventnum):endind(eventnum));
            ct_2 = ct(inds);
            ct_nonnan = ct_2(~isnan(ct_2));
            temp_events_amp {i,eventscount} = prctile(ct_nonnan,99);
            temp_events_dur {i,eventscount}  = (events_septs (i,2) -  events_septs (i,1)).*sampling_time;
            found = 0;inds = j;
            
            
            
            % % % % % % % % % %
            % % % % % % % % % %             [ind,hval] = hist(current_trace);
            % % % % % % % % % %             F0 = mean(hval(1:4));
            % % % % % % % % % %             Fmax = max(hval);
            % % % % % % % % % %             F1 = F0 * ones(round(.4/sampling_time),1);
            % % % % % % % % % %             F2 = F1;
            % % % % % % % % % %             F3 = F1;
            % % % % % % % % % %             F2 (floor(length(F1)/2)+1:end) = Fmax ;
            % % % % % % % % % %             F3 (1:floor(length(F1)/2)) = Fmax ;
            % % % % % % % % % %             found =0; eventscount = 0;
            % % % % % % % % % %             inds = 1;
            % % % % % % % % % %             for j = 1: length(current_trace)
            % % % % % % % % % %                 tp_trace = current_trace(j:j + length(F1)-1);
            % % % % % % % % % %
            % % % % % % % % % %                 lse1 = sum((tp_trace-F1').^2);
            % % % % % % % % % %                 lse2 = sum((tp_trace-F2').^2);
            % % % % % % % % % %                 lse3 = sum((tp_trace-F3').^2);
            % % % % % % % % % %
            % % % % % % % % % %                 if ((lse2<lse1)&(found == 0))
            % % % % % % % % % %                     found =1;
            % % % % % % % % % %                     detected(i) =1;
            % % % % % % % % % %                     event_index = j+round(length(F1)/2);
            % % % % % % % % % %                     events_septs (i,1) = event_index ;
            % % % % % % % % % %                     temp = current_trace(max(1,event_index - floor(.5/sampling_time)): min(length(current_trace),event_index + round(2.5/sampling_time)));
            % % % % % % % % % %                     leading_blank = event_index - floor(.5/sampling_time);
            % % % % % % % % % %                     offset = (leading_blank <0);
            % % % % % % % % % %                     event_detected_data (i, (offset*leading_blank*-1)+1 :length(temp)+(offset*leading_blank*-1)) = temp;
            % % % % % % % % % %                 elseif ((lse3<lse2) &(found ==1))
            % % % % % % % % % %                     if (lse3<lse1)
            % % % % % % % % % %
            % % % % % % % % % %                     else
            % % % % % % % % % %                         events_septs (i,2) = j+round(length(F1)/2) ;
            % % % % % % % % % %                         eventscount = eventscount+1;
            % % % % % % % % % %                         ct = current_trace(inds:j);
            % % % % % % % % % %                         ct_nonnan = ct(~isnan(ct));
            % % % % % % % % % % %                         temp_events_amp {i,eventscount} = prctile(current_trace(inds:j),99);
            % % % % % % % % % %                         temp_events_amp {i,eventscount} = prctile(ct_nonnan,99);
            % % % % % % % % % %                         temp_events_dur {i,eventscount}  = (events_septs (i,2) -  events_septs (i,1)).*sampling_time;
            % % % % % % % % % %                         found = 0;inds = j;
            % % % % % % % % % %                         break
            % % % % % % % % % %                     end
            % % % % % % % % % %
            % % % % % % % % % %                     if(j+1>length(current_trace)-length(F1)+1)
            % % % % % % % % % %                         events_septs (i,2) = length(current_trace);
            % % % % % % % % % %                         eventscount = eventscount+1;
            % % % % % % % % % %                         ct = current_trace(inds:end);
            % % % % % % % % % %                         ct_nonnan = ct(~isnan(ct));
            % % % % % % % % % %                         temp_events_amp {i,eventscount} = prctile(ct_nonnan,99);
            % % % % % % % % % %                         temp_events_dur {i,eventscount}  = (events_septs (i,2) -  events_septs (i,1)).*sampling_time;
            % % % % % % % % % %                         found = 0;
            % % % % % % % % % %                         break
            % % % % % % % % % %                     end
            % % % % % % % % % %                 elseif (found ==1) & j == length(current_trace)
            % % % % % % % % % %                     events_septs (i,2) = j ;
            % % % % % % % % % %                     eventscount = eventscount+1;
            % % % % % % % % % %                     ct = current_trace(inds:end);
            % % % % % % % % % %                     ct_nonnan = ct(~isnan(ct));
            % % % % % % % % % %                     temp_events_amp {i,eventscount} = prctile(ct_nonnan,99);
            % % % % % % % % % %                     temp_events_dur {i,eventscount}  = (events_septs (i,2) -  events_septs (i,1)).*sampling_time;
            % % % % % % % % % %                     found = 0;
            % % % % % % % % % %                     break
            % % % % % % % % % %                 end
            % % % % % % % % % %
            % % % % % % % % % %                 if(j+1>length(current_trace)-length(F1)+1)
            % % % % % % % % % %
            % % % % % % % % % %                     break
            % % % % % % % % % %                 end
            % % % % % % % % % %
            % % % % % % % % % %             end
            events(i) = eventscount;
            
            
        end
    end
    
    if (eventscount<1)
        events_septs(i,:) = [1,1];
        events_amp (i) = prctile(current_trace,50);
        events_dur (i)  = (0.*sampling_time);
    elseif (eventscount >1)
        events_amp (i) = sum(cell2mat(temp_events_amp(i,:)),2);
        events_dur (i)  = sum(cell2mat(temp_events_dur(i,:)),2);
    else
        events_amp (i) = temp_events_amp{i,1};
        events_dur(i)  =  temp_events_dur{i,1};
    end
    
end

end