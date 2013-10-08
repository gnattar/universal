function [hit_rate, false_alarm_rate] = plot_hit_history(m)



ms=5;
figure;
for k=1:length(m)
    
    correct = m{k}.saved.poles_discobj_hit_history;
    s1 = (m{k}.saved.SidesSection_previous_sides(1:(end-1)) == 114)'; % 114 charcode for 'r', 108 for 'l'     

    if isfield(m{k}.saved,'SavingSection_headfixed')
        headfixed = m{k}.saved.SavingSection_headfixed;
    else
        headfixed = 'Not fixed';
    end
    trials = [s1 correct];
    
    % Trim trials from start and end if needed:
    trimmed = [];
    if m{k}.trim(1)>0 && m{k}.trim(2)>0
        trimmed = [(1:(1+m{k}.trim(1)))'; ((length(trials)-m{k}.trim(2)):length(trials))']; 
    elseif m{k}.trim(2)>0
        trimmed = ((length(trials)-m{k}.trim(2)):length(trials))';      
    elseif m{k}.trim(1)>0
        trimmed = (1:(1+m{k}.trim(1)))';  
    end
    
    fa = find(trials(:,1)==0 & trials(:,2)==0);    
    hit = find(trials(:,1)==1 & trials(:,2)==1);
    miss = find(trials(:,1)==1 & trials(:,2)==0);
    cr = find(trials(:,1)==0 & trials(:,2)==1);
    
    fa_rej = intersect(fa,trimmed);
    hit_rej = intersect(hit,trimmed);
    miss_rej = intersect(miss,trimmed);
    cr_rej = intersect(cr,trimmed);
    
    fa = setdiff(fa,trimmed);
    hit = setdiff(hit,trimmed);
    miss = setdiff(miss,trimmed);
    cr = setdiff(cr,trimmed);
    
    
    
%     subplot(3,3,k)
    if ~isempty(fa)
        plot(fa,ones(size(fa))+.1, 'ro', 'MarkerSize',ms); hold on % false alarms
    end
    if ~isempty(miss)
        plot(miss,zeros(size(miss))+.1, 'ro', 'MarkerSize',ms) % misses
    end
    if ~isempty(hit)
        plot(hit,zeros(size(hit))-.1, 'go', 'MarkerSize',ms) % hits
    end
    if ~isempty(cr)
        plot(cr,ones(size(cr))-.1, 'go', 'MarkerSize',ms) % correct rejections
    end
    
    if ~isempty(fa_rej)
         plot(fa_rej,ones(size(fa_rej))+.1, 'ko', 'MarkerSize',ms);  % false alarms
    end
    if ~isempty(miss_rej)
        plot(miss_rej,zeros(size(miss_rej))+.1, 'ko', 'MarkerSize',ms) % misses
    end
    if ~isempty(hit_rej)
        plot(hit_rej,zeros(size(hit_rej))-.1, 'ko', 'MarkerSize',ms) % hits
    end
    if ~isempty(cr_rej)
        plot(cr_rej,ones(size(cr_rej))-.1, 'ko', 'MarkerSize',ms) % correct rejections
    end    
    
    if isfield(m{k}.saved,'SavingSection_ratname')
        mouse = m{k}.saved.SavingSection_ratname;
    elseif isfield(m{k}.saved,'SavingSection_MouseName')
        mouse = m{k}.saved.SavingSection_MouseName;
    else
        mouse = '';
    end
    title([mouse ' ' m{k}.saved.SessionTypeSection_SessionType ' ' headfixed])
    ylim([-1 2])
    set(gca,'YTick',[0 1],'YTickLabel',{'S1','S0'})
    
%     num_s1 = length(hit) + length(miss);
%     num_s0 = length(fa) + length(cr);
%     
%     hit_rate = length(hit)/num_s1;
%     false_alarm_rate = length(fa)/num_s0;
%     
%     dp = dprime(hit_rate, false_alarm_rate, num_s1, num_s0);
%     text(1,0.5, ['hr=' num2str(hit_rate) ',far=' ...
%         num2str(false_alarm_rate) ',dp=' num2str(dp)])
    
    num_s1 = length(hit) + length(miss);
    num_s0 = length(fa) + length(cr);
    
    hit_rate = length(hit)/num_s1;
    false_alarm_rate = length(fa)/num_s0;
    pc = (length(hit) + length(cr))/(num_s1 + num_s0);
    
    text(1,0.5, ['hr=' num2str(hit_rate) ',far=' ...
        num2str(false_alarm_rate) ',pc=' num2str(pc)])
end


















