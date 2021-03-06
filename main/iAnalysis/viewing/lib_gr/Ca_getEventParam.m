function event = Ca_getEventParam(y,t,plot_flag)
% y, CaValues
% t, TimeStamp
% 

if nargin < 3
    plot_flag = 0;
end

% event.value = y;
% event.ts = t;
event.onset = t(1);
event.offset = t(end);
event.peak = max(y);
event.peak_time = t(y==max(y));

lm_dx = 3; % length of the piece for local maxima searching
if size(y,1)==1
    y = y';
end
lmval = [];
try
    [lmval, lm_ind] = lmax_pw(y, lm_dx);
catch
end

ind = find(lmval> max(y)*0.6); % only consider local maxima that exceed the half maximum
% if isempty(ind)
%     ind = find(lmval>=prctile(lmval,70));
% end
if ~isempty(lmval)&& ~isempty(ind)
    event.local_max = lmval(ind);
    event.local_max_time = t(lm_ind(ind));
else
    event.local_max = NaN;
    event.local_max_time = NaN;
end
t1 = t(find(y >= event.peak/2, 1,'first'));
t2 = t(find(y >= event.peak/2, 1,'last'));
event.fwhm_t1 = t1;
event.fwhm_t2 = t2;
event.fwhm = t2-t1;
event.area = trapz(t,y);

% Single expoential fit for decay and rise time
t_rise = t((t>=t(1) & t<= event.local_max_time(1)));
y_rise = y(ismember(t,t_rise));
try
    st_rise = [max(min(y_rise),0) t_rise(end)-t_rise(1)];
%     paramRise = exp2fit(t_rise, y_rise, 1);
    [cf1,gof1] = expfit_single(t_rise', y_rise, st_rise); 
catch ME
%     paramRise = [];
    cf1 = [];
end
if ~isempty(cf1)
    event.yfit_rise = cf1.a * exp(t_rise*(-cf1.b));
    event.tauRise = -1/cf1.b;
    event.gof_rise = gof1; 
else
    event.yfit_rise = NaN;
    event.tauRise = NaN;
    event.gof_rise = NaN;
end

t_decay = t(t>=event.local_max_time(end) & t<=t(end));
if length(t_decay)<=2 && length(event.local_max)>2 % if the last local maximum is too close to the end
    t_decay = t(t>=event.local_max_time(end-1) & t<t(end));
end
y_decay = y(ismember(t,t_decay));
if ~isempty(y_decay) && y_decay(end)< y_decay(1) % otherwise it's not really decay
%     try
%         paramDecay = exp2fit(t_decay, y_decay, 1);
%     catch ME
%         paramDecay = [];
%     end
    st_decay = [max(y_decay) t_decay(end)-t_decay(1)];
    [cf2, gof2] = expfit_single(t_decay', y_decay, st_decay);
else
    cf2 = [];
end
if ~isempty(cf2)
    event.yfit_decay = cf2.a * exp(t_decay*(-cf2.b));
    event.tauDecay = 1/cf2.b;
    event.gof_decay = gof2; % goodness of fit
else
    event.yfit_decay = NaN;
    event.tauDecay = NaN;
    event.gof_decay = NaN;
end
event.t_rise = t_rise;
event.y_rise = y_rise;
event.t_decay = t_decay;
event.y_decay = y_decay;

if plot_flag == 1
    if ~isempty(paramRise)
        f_rise = paramRise(1) + paramRise(2)*exp(-t_rise/paramRise(3));
    else
        f_rise = NaN;
    end;
    if ~isempty(paramDecay)
        f_dec = paramDecay(1) + paramDecay(2)*exp(-t_decay/paramDecay(3));
    else
        f_dec = NaN;
    end;
    if ishandle(gcf)
        figure(gcf)
        hold on;
        plot(t,y,'r');
        plot(event.local_max_time,event.local_max,'c*');
        if ~isnan(f_rise)
        plot(t_rise, f_rise,'g');
        end
        if ~isnan(f_dec)
            plot(t_decay,f_dec,'g');
        end
        plot([t1 t2], [event.peak/2 event.peak/2], 'y');
        hold off;
       
    end
end
% rise_t1 = t(find(y >= event.local_max(1)*0.1 ...
%     & t < event.local_max_time(1), 1, 'first'));
% rise_t2 = t(find(y >= event.local_max(1)*0.9 ...
%     & t < event.local_max_time(1), 1, 'first'));
% decay_t1 = t(find(y >= event.local_max(end)*0.9 ...
%     & t > event.local_max_time(end), 1, 'last'));
% decay_t2 = t(find(y >= event.local_max(end)*0.1 ...
%     & t > event.local_max_time(end), 1, 'last'));
% event.rise_time = rise_t2 - rise_t1;
% event.decay_time = decay_t2 - decay_t1;