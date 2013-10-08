function [event_detected_data,events_septs,detected] = detect_Ca_events(src_data,sampling_time,threshold)
    event_detected_data = zeros(size(src_data,1),floor(3/sampling_time) );
    detected = zeros(size(src_data,1),1);
    events_septs = ones(size(src_data,1),2);
    events_septs (:,2) = 2;
    diffmem = zeros(2,1);
    for i = 1:size(src_data,1)
       current_trace = src_data(i,:);
       
       if (std(current_trace) > threshold*mad(current_trace(1:floor(.5/sampling_time))))
           
           [ind,hval] = hist(current_trace);
           F0 = mean(hval(1:4));
           Fmax = max(hval);
           F1 = F0 * ones(round(.5/sampling_time),1);
           F2 = F1;
           F3 = F1;
           F2 (floor(length(F1)/2):end) = Fmax ;
           F3 (1:floor(length(F1)/2)) = Fmax ;
           found =0;
            for j = 1: length(current_trace)
               tp_trace = current_trace(j:j + length(F1)-1);
               
               lse1 = sum((tp_trace-F1').^2);
               lse2 = sum((tp_trace-F2').^2);
               lse3 = sum((tp_trace-F3').^2);
                            
               if ((lse2<lse1)&(found ==0))
                   found =1;
                   detected(i) =1;
                   event_index = j+round(length(F1)/2); 
                   events_septs (i,1) = event_index ;
                   temp = current_trace(max(1,event_index - floor(.5/sampling_time)): min(length(current_trace),event_index + round(2.5/sampling_time)));
                   leading_blank = event_index - floor(.5/sampling_time);
                   offset = (leading_blank <0);
                   event_detected_data (i, (offset*leading_blank*-1)+1 :length(temp)+(offset*leading_blank*-1)) = temp;
               elseif ((lse3<lse2) &(found ==1))
                   if (lse3<lse1) 
                       
                   else
                       event_index = j+round(length(F1)/2); 
                       events_septs (i,2) = event_index ;
                       break
                   end
               else
                   
               end

               if(j+1>length(current_trace)-length(F1)+1)
                   break
               end
     
            end

       end

    end
    
end