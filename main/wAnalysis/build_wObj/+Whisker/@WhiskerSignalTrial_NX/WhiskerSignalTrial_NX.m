classdef WhiskerSignalTrial_NX < Whisker.WhiskerSignalTrial
    %
    %
    %   WhiskerSignalTrial_NX < Whisker.WhiskerSignalTrial
    %
    %
    %
    %
    properties
        bar_pos_trial = [];
        bar_time_win = [];
        SoloTrial = [];
        contacts = {};
        contact_direct = {};
        mKappaNearBar = {};
        mThetaNearBar = {};
        imagePixelDimsXY = [];
        distToBar = {};
        tip_coords = {};
        totalTouchKappaTrial = {};
        maxTouchKappaTrial = {};
          
        %         touch_on = {};
        %         touch_off = {};
        
    end
    
    properties (Dependent = true)
        contact_params % physical parameters around contact times.
        whisk_amplitude
        %         dToBar % distance from whisker to bar, after trajectory extrapolation
        deltaKappa
        Setpoint
        Amplitude
        Velocity
        
    end
    
    methods (Access = public)
        function obj = WhiskerSignalTrial_NX(w, varargin)
            %
            if nargin==0
                ws_args = {};
            end
            
            if isa(w, 'Whisker.WhiskerTrial')
                ws_args = {w, varargin{1}};
            else
                ws_args = {};
            end
            obj = obj@Whisker.WhiskerSignalTrial(ws_args{:});
            
            if isa(w, 'Whisker.WhiskerSignalTrial')
                ws_prop = properties(w);
                for i=1:length(ws_prop),
                    obj.(ws_prop{i}) = w.(ws_prop{i});
                end
            end
            ntraj = length(obj.trajectoryIDs);
            %             obj.deltaKappa = cell(1,ntraj);
            obj.mKappaNearBar = cell(1,ntraj);
            obj.mThetaNearBar = cell(1,ntraj);
            obj.contacts = cell(1,ntraj);
        end
        
        function bar_pos_trial = get_bar_pos_trial(obj,bar_pos_trial)
            if nargin < 2
                bar_pos_trial = uigetfile('*.mat','Select bar coordinates file');
            elseif ischar(bar_pos_trial)
                x = load(bar_pos_trial);
                xx = fieldnames(x);
                bar_pos_trial = x.(xx)(obj.trialNum);
            end
            
            obj.bar_pos_trial = bar_pos_trial;
        end
        
        function tip_coords = get_tip_coords(obj,tid,varargin)
            % varargin{1}, restrictTime, [startTimeInSec endTimeInSec]
            w_ind = find(obj.trajectoryIDs == tid);
            
            t = obj.get_time(tid);
            if ~isempty(varargin) & ~isempty(varargin{1})
                restrictTime = varargin{1};
            else
                restrictTime = [min(t) max(t)];
            end
            
            tip_coords = nan(length(t),2);
            
            frameInds = find(t >= restrictTime(1) & t <= restrictTime(2));
            
            ind = find(obj.trajectoryIDs==tid);
            
            fittedX = obj.polyFits{ind}{1};
            fittedY = obj.polyFits{ind}{2};
            
            nframes = length(frameInds);
            %             x = cell(1,nframes);
            %             y = cell(1,nframes);
            %
            q = linspace(0,1);
            
            for k=1:nframes
                f = frameInds(k);
                
                px = fittedX(f,:);
                py = fittedY(f,:);
                x = polyval(px,q);
                y = polyval(py,q);
                tip_coords(f,1) = x(end);
                tip_coords(f,2) = y(end);
            end
            obj.tip_coords{w_ind} = tip_coords;
        end
        
        function dist = get_tip_bar_distance(obj, tid, varargin)
            % distance from traced whisker tip to bar center, no
            % extrapolation.
            if ~isempty(obj.bar_pos_trial)
                bc = obj.bar_pos_trial;
            else
                bc = obj.barPosClean;
            end
            t = obj.get_time(tid);
            if ~isempty(varargin) & ~isempty(varargin{1})
                restrictTime = varargin{1};
            else
                restrictTime = [min(t) max(t)];
            end
            
            dist = nan(length(t),1);
            
            frameInds = find(t >= restrictTime(1) & t <= restrictTime(2));
            
            tip_coords = obj.get_tip_coords(tid,restrictTime);
            
            for i = 1:length(frameInds)
                dist(frameInds(i)) = norm(tip_coords(frameInds(i),:) - bc(i,[2 3]));
            end
        end
        
        function ang_diff = get_whisker_bar_angular_difference(obj,tid,varargin)
            wid = find(obj.trajectoryIDs == tid);
            ang_bar = obj.get_bar_follicle_angle(obj,tid);
            % if ang_diff < 0, whisker is at more protracted postion than
            % bar location.
            ang_diff =  obj.theta{wid} - ang_bar;
        end
        
        function angle = get_bar_follicle_angle(obj,tid)
            % angle of the bar to the mean follicle coords.
            wid = find(obj.trajectoryIDs == tid);
            if ~isempty(obj.bar_pos_trial)
                bar_coord = obj.bar_pos_trial;
            else;
                bar_coord = obj.barPos(1000,[2 3]);
            end
            angle =  -atand((nanmean(obj.follicleCoordsX{wid})-bar_coord(1))/...
                abs(bar_coord(2) - nanmean(obj.follicleCoordsY{wid})));
            % if ang_diff < 0, whisker is at more protracted postion than
        end
        
        function contacts = get_contacts(obj,tid,varargin)
            % Contact time detection based on whisker tip to bar distance
            % and curvature change
            % INPUT: varargin{1}, the time window where bar is presented.
            %        Does not need to be precise, e.g., [1.01 3]
            if isempty(varargin)
                bar_time = obj.bar_time_win;
            else
                bar_time = varargin{1};
            end
            
            if isempty(bar_time)
                bar_time = input('Input bar time window [start end]: ');
            end
            w_ind = find(obj.trajectoryIDs == tid);
            bar_frames = find(obj.time{w_ind}>bar_time(1) & obj.time{w_ind}<bar_time(2));
            
            %              d0 = obj.get_tip_bar_distance(tid);
            
            contacts = whisker_touch_detection2(obj, tid, bar_frames);
            obj.contacts{w_ind} = contacts;
        end
        
        function [mTheta, mKappa, rROI] = mean_theta_kappa_near_bar(obj,tid, len_avg, proximity_threshold)
            % based on
            % [rNearest,thetaNearest,kappaNearest,yNearest,xNearest,dist,t] = get_r_theta_kappa_nearest_bar(obj,tid,proximity_threshold)
            %
            %
            % INPUTS:
            %       tid:  Trajectory ID (as an integer) starting with 0.
            %       len_avg:  the length (in mm) on the whisker near the bar over
            %               which to compute the mean kappa and theta.
            %       proximity_threshold:  Optional argument giving distance from nearest point on whisker
            %               to bar center, in units of bar radius, beyond which
            %               the whisker will be extrapolated along the last theta in
            %               order to determine distance between whisker and bar.
            %
            % OUTPUTS:
            %       rROI: Arc-length (radial) distance of points in the region near center of the bar. Units of pixels.
            %       mTheta: mean Theta of points in the region near the bar.
            %       mKappa: mean Kappa at the points within the region near the bar.
            %
            if nargin < 3,
                len_avg = 2; % default, 2 mm.
            end
            nPix = round(len_avg * obj.pxPerMm); % convert to number of pixels
            w_ind = find(obj.trajectoryIDs == tid);
            t = obj.time{w_ind};
            f = t / obj.framePeriodInSec;
            nframes = length(f);
            %             [rNearest,thetaNearest,kappaNearest,yNearest,xNearest,dist,t] = obj.get_r_theta_kappa_nearest_bar(tid);
            [R,THETA,KAPPA] = obj.arc_length_theta_and_kappa(tid);
            
            mTheta = zeros(1,nframes);
            mKappa = zeros(1,nframes);
            rROI = cell(1,nframes);
            for k=1:nframes
                inds = find(R{k} > R{k}(end)-nPix);
                rROI{k} = R{k}(inds);
                mTheta(k) = mean(THETA{k}(inds));
                mKappa(k) = mean(KAPPA{k}(inds));
            end
            obj.mKappaNearBar{w_ind} = mKappa;
            obj.mThetaNearBar{w_ind} = mTheta;
            
        end
        
        function out = get_position_extrema(obj, tid, varargin)
            w_ind = find(obj.trajectoryIDs == tid);
            th = obj.theta{w_ind};
            th_medfilt = medfilt1(th,3);
            if size(th_medfilt,1)==1
                th_medfilt = th_medfilt';
            end
            [lmaxval, lmaxind] = lmax_pw(th_medfilt, 3);
            [lminval, lminind] = lmin_pw(th_medfilt, 3);
            out.lmaxind = lmaxind;
            out.lminind = lminind;
        end
        
        function obj = get_distToBar(obj,tid)
            % Compute the shortest distance from whisker to bar center
            % Extrapolate whisker poly fit lines if necessary.
            
            dToBar = cell(1,length(obj.trajectoryIDs));
            if nargin<2
                tid = obj.trajectoryIDs;
            end
            for i = 1:length(tid);
                wNo = find(obj.trajectoryIDs == tid(i));
                t = obj.time{wNo};
                f = t / obj.framePeriodInSec;
                nframes = length(f);
                q = linspace(0,1); % This must be same as that used in obj.arc_length_theta_and_kappa().
                if length(obj.tip_coords) < wNo || isempty(obj.tip_coords{wNo})
                    tip_coords = obj.get_tip_coords(tid);
                else
                    tip_coords = obj.tip_coords{wNo};
                end
                xb = obj.bar_pos_trial(1);
                yb = obj.bar_pos_trial(2);
                
                xf = obj.follicleCoordsX{wNo}; % follicle coordinates
                yf = obj.follicleCoordsY{wNo};
                Lb = arrayfun(@(x,y) norm([xb-x yb-y]), xf,yf);
                
                Ltip = arrayfun(@(x1,y1,x2,y2) norm([x1-x2  y1-y2]), tip_coords(:,1), tip_coords(:,2),xf',yf');
                
                
                fittedX = obj.polyFits{wNo}{1};
                fittedY = obj.polyFits{wNo}{2};
                
                for k=1:nframes
                    %                 disp(['Computing nearest-point values for frame=' int2str(k)])
                   if(size(fittedX,1)==0)
                       disp('file')
                       
                       obj.trackerFileName
                   end
                    px = fittedX(k,:);
                    py = fittedY(k,:);
                    
                    x = polyval(px,q);
                    y = polyval(py,q);
                    
% % %                     if(k > 585)
% % %                     
% % %                         p = (0:0.1:2*pi);
% % %                         r = 6.5;
% % %                         barpos = obj.barPos(1,[2,3]);
% % %                         figure;plot(x,y,'color','b','linewidth',1.5); axis ([0 520 0 400]);hold on; plot(r*sin(p)+barpos(1,1),r*cos(p)+barpos(1,2),'linewidth',6,'color','red');
% % %                         set(gca,'YDir','reverse');
% % % 
% % %                     end
                    
                    
                    deltaL = abs(Lb(k) - Ltip(k));
                    
                    % extrapolate poly fit if whisker length is smaller
                    % than bar distance to follicle.
                    x_ex = []; y_ex=  [];
                    if Lb(k) > Ltip(k) & Lb(k) <= max(Ltip)
%                         q_ex = [q linspace(1, 1+deltaL/Ltip(k), round(deltaL/Ltip(k)*100))];
                        q_ex = 0:mean(diff(q)):1+deltaL/Ltip(k); 
                        x_ex = interp1(q,x,q_ex, 'linear', 'extrap');
                        y_ex = interp1(q,y,q_ex, 'linear', 'extrap');
%                         x_ex = polyval(px,q_ex);
%                         y_ex = polyval(py,q_ex);
                        x = x_ex;
                        y = y_ex;
                    end
                    
                    d = [];
                    for j=1:length(x)
                        d(j) = norm([x(j);y(j)] - [xb;yb]); % sqrt((x(j)-xb)^2 + (y(j)-yb)^2);
                    end
                    dToBar{wNo}(k) = min(d);
                end
                obj.distToBar{wNo} = dToBar{wNo};
            end
        end
        
        function h = plot_fitted_whisker_frameInds(obj, tid, frameInds, plot_color, varargin)
            %
            %   plot_fitted_whisker_time_projection(obj, tid, varargin)
            %
            % tid: trajectory ID.  Only a single ID is allowed.
            %
            % varargin{1}: Plot color/symbol string.
            %
            % varargin{2}: Optional 2 x 1 vector giving starting and ending times (in seconds) to include in
            %               returned image, inclusive, starting with 0.
            %               Of format: [startTimeInSec endTimeInSec]. Can be empty ([]) to allow
            %               access to varargin{3}.
            %
            % varargin{3}: Cell array with two elements. First element is a 1x2 vector giving radial distance
            %              beginning and end points (inclusive) to draw in the color given in
            %              varargin{1}, in format [startRadialDistance stopRadialDistance]. Radial distance
            %              is whisker arc length moving outward from follicle and is in units of pixels.
            %              The second element of the cell array is the plot color/symbol string to use when
            %              plotting the radial segment of the whisker between startRadialDistance and
            %              stopRadialDistance.
            %
            %
            %
            if numel(tid) > 1
                error('Only a single trajectory ID is alowed.')
            end
            
            if nargin > 4
                plotString = varargin{1};
            else
                plotString = 'k-';
            end
            if nargin > 5
                if ~iscell(varargin{2})
                    error('Wrong format for varargin{3}.')
                end
                plotString2 = varargin{3}{2};
                rstart = varargin{3}{1}(1);
                rstop = varargin{3}{1}(2);
            end
            
            hold on; axis ij
            
            ind = obj.trajectoryIDs==tid;
            if max(ind) < 1
                error('Could not find specified trajectory ID.')
            end
            
            if isempty(obj.polyFits)
                error('obj.polyFits is empty.')
            end
            
            fittedX = obj.polyFits{ind}{1};
            fittedY = obj.polyFits{ind}{2};
            
            nframes = length(frameInds);
            x = cell(1,nframes);
            y = cell(1,nframes);
            
            q = linspace(0,1);
            
            for k=1:nframes
                f = frameInds(k);
                
                px = fittedX(f,:);
                py = fittedY(f,:);
                x{k} = polyval(px,q);
                y{k} = polyval(py,q);
            end
            
            if nargin > 4
                [R,THETA,KAPPA] = obj.arc_length_theta_and_kappa(tid);
                for k=1:nframes
                    xx = x{k};
                    yy = y{k};
                    f = frameInds(k);
                    radDist = R{f};
                    h(k) = plot(xx,yy,plotString);
                    rind = radDist >= rstart & radDist <= rstop;
                    plot(xx(rind),yy(rind),plotString2)
                end
            else
                if length(frameInds) > 1
                    fr_color = color_mapping_nx(frameInds,[],jet);
                else
                    fr_color = 'r';
                end
                if ~isempty(plot_color)
                    for k=1:nframes
                        h(k) = plot(x{k},y{k},plotString,'Color',plot_color, 'LineWidth',2);
                    end
                else
                    for k=1:nframes
                        h(k) = plot(x{k},y{k},plotString,'Color',fr_color(k,:),'LineWidth',2);
                    end
                end
            end
        end
        
        
        
        function haxis = plot_wParams_with_contacts(obj,tid,varargin)
            % Plot multiple whisker param time series with contact time labled.
            %
            % varargin{1}, figure handle
            % varargin{2}, cell array of whisker param names, must be same
            %              as properties names.
            
            wNo = find(obj.trajectoryIDs == tid);
            contact_inds = obj.contacts{wNo};
            if length(contact_inds) < wNo
                error(sprintf('No contact for whisker No %d !', wNo));
            end
            
            if ~isempty(varargin) & ishandle(varargin{1})
                figure(varargin{1});
                clf;
            else
                fig_Cont_wParam = figure('Position',[440    34   660   750],'Name',sprintf('Trial %d,Whisker %d',obj.trialNum,wNo),'Color','w');
            end
            
            if nargin < 4
                wParams = {'deltaKappa','distToBar','theta'};
            else
                wParams = varargin{2};
            end
            
            %             haxis(1) = subaxis(3,1,1,'MT',0.05,'SV',0.03);
            %             haxis(2) = subaxis(3,1,2,'SV',0.03);
            %             haxis(3) = subaxis(3,1,3,'SV',0.03);
            
            ts = obj.time{wNo};
            if ~isempty(obj.bar_time_win)
                frInds = find(ts>obj.bar_time_win(1) & ts < obj.bar_time_win(2));
            else
                frInds = 1:length(ts);
            end
            n = length(wParams);
            
            for k = 1:n
                haxis(k) = subaxis(n,1,k,'SV',0.03);
                %                 axes(haxis(k));
                plot(frInds,obj.(wParams{k}){wNo}(frInds),'.-');
                
                for i=1:length(contact_inds)
                    x = [contact_inds{i}(1) contact_inds{i}(1) contact_inds{i}(end) contact_inds{i}(end)];
                    yl = get(gca,'YLim');
                    y = [yl(1) yl(2) yl(2) yl(1)];
                    % Coloring the patch based on contact direction
                    if nanmean(obj.deltaKappa{wNo}(contact_inds{i})) < 0, % protraction
                        clr = [0.5 1 0.5];
                    elseif nanmean(obj.deltaKappa{wNo}(contact_inds{i})) > 0
                        clr = [1 0.5 0.5];
                    else % unditermined
                        clr = [0.5 0.5 0.5];
                    end
                    hpch(i) = patch(x,y ,clr,'EdgeColor','none');
                end
                
                alpha(hpch,0.5);
                set(get(haxis(k),'YLabel'),'String',wParams{k},'FontSize',15);
                set(haxis(k),'FontSize',13, 'Box','off');
            end
        end
        
    end
    
    methods % Dependent property methods; cannot have attributes.
        
        function value = get.contact_params(obj)
            nTraj = length(obj.trajectoryIDs);
            value = cell(1,nTraj);
            for i = 1 : nTraj % whiskers
                if i > length(obj.contacts)
                    continue
                else
                    tid = obj.trajectoryIDs(i);
                    deltaKappa = medfilt1(obj.deltaKappa{i},5);
                    theta = obj.theta{i};
                    theta_LM = obj.get_position_extrema(tid);
                    ts = obj.get_time(tid);
                    vel = obj.get_velocity(tid);
                    setPoint = obj.Setpoint{i};
                    Amplitude = obj.Amplitude{i};
                    
                    for ii = 1:length(obj.contacts{i}) % loop through touch windows for the current whisker
                        inds = obj.contacts{i}{ii}; % 
                        contact_direct = obj.contact_direct{i}(ii); % 1 for protraction, 0 for retraction
                        
                        value{i}{ii}.cont_direc = contact_direct;
                        value{i}{ii}.trialNo = obj.trialNum;
                        
                        value{i}{ii}.frameInds = inds;
                        
                        value{i}{ii}.ts = ts(inds);
                        
                        value{i}{ii}.velocityCont = nanmean(vel(inds(1)-2 : inds(1))); % pre-contact velocity
                        
                        value{i}{ii}.AmplitudeCont = Amplitude(inds);
                        
                        deltaKappaCont = deltaKappa(inds);
                        
                        value{i}{ii}.deltaKappaCont = deltaKappaCont;
                        
                        %                         [maxDeltaKappa, I] = max(abs(deltaKappaCont));
                        temp = deltaKappaCont(2:end-1);
%                         [ylmax, ilmax] = lmax_pw(temp',3);
%                         [ylmin, ilmin] = lmin_pw(temp',3);
                        [ymin,Imin] = min(temp);
                        [ymax,Imax] = max(temp);
                        % if the min is above the baseline take the max as
                        % the peak, else if the max is below the baseline,
                        % take the min as the peak. Otherwise take the
                        % one that occurs first
%                         if ymin >= temp(1)
%                             peakDeltaKappa = ymax;
%                             value{i}{ii}.peakDeltaKappa_frInd = inds(Imax + 1);
%                         elseif ymax <= temp(1)
%                             peakDeltaKappa = ymin;
%                             value{i}{ii}.peakDeltaKappa_frInd = inds(Imin + 1);
%                         else
%                             peakDeltaKappa = temp(min(Imin,Imax));
%                             value{i}{ii}.peakDeltaKappa_frInd = inds(min(Imin,Imax) + 1);
%                         end
                        
                        if contact_direct == 1 % protraction
                            [Peak, IndAux] = min(deltaKappaCont);
                        elseif contact_direct == 0
                            [Peak, IndAux] = max(deltaKappaCont);
                        end
                        value{i}{ii}.peakDeltaKappa_frInd = inds(IndAux);
                        sumDeltaKappa = nansum(deltaKappaCont);
                        value{i}{ii}.sumDeltaKappaAbs = nansum(abs(deltaKappaCont));
%                         peakDeltaKappa = peakDeltaKappa - temp(1);
                        % maxDeltaKappa
                        value{i}{ii}.peakDeltaKappa = Peak; % - temp(1); % max curvature change in this touch window
                        if contact_direct == 1 % peakDeltaKappa < 0
                            value{i}{ii}.retPeakKappa = NaN;
                            value{i}{ii}.proPeakKappa = Peak;
                            value{i}{ii}.proKappaSum = sumDeltaKappa;
                            value{i}{ii}.retKappaSum = NaN;
                        elseif contact_direct == 0
                            value{i}{ii}.retPeakKappa = Peak;
                            value{i}{ii}.proPeakKappa = NaN;
                            value{i}{ii}.retKappaSum = sumDeltaKappa;
                            value{i}{ii}.proKappaSum  = NaN;
                        else % peakDeltaKappa == 0
                            value{i}{ii}.retPeakKappa = NaN;
                            value{i}{ii}.proPeakKappa = NaN;
                            value{i}{ii}.retKappaSum = NaN;
                            value{i}{ii}.proKappaSum  = NaN;
                        end
                        
                        value{i}{ii}.kappaSlope = (Peak - deltaKappaCont(1))/ ...
                            (value{i}{ii}.ts(min(Imin,Imax) + 1)-value{i}{ii}.ts(1));
                        
                        value{i}{ii}.kappa_dot = [0 diff(deltaKappaCont)]./[0 diff(ts(inds))];
                        
                        lm_inds = sort([theta_LM.lmaxind theta_LM.lminind]);
                        lm_ind_0 = lm_inds(find(lm_inds < inds(1), 1, 'last'));
                        lm_ind_1 = lm_inds(find(lm_inds > inds(1), 1, 'first'));
                        
                        theta_set = theta(lm_ind_0);
                        
                        value{i}{ii}.thetaCont = theta(inds(1)); % whisker position upon touch
                        
                        value{i}{ii}.deltaTheta = theta(inds(1)) - theta_set;
                        
                        value{i}{ii}.theta_slope = value{i}{ii}.deltaTheta / (ts(inds(1))-ts(lm_ind_0));
                        
                        value{i}{ii}.setPointCont = setPoint(inds(1));
                        
                        value{i}{ii}.setPointCont_mean = nanmean(setPoint(inds));
                        
                        value{i}{ii}.contactDuration = ts(inds(end)) - ts(inds(1) - 1);
                        
                        bs_setPoint = nanmean(setPoint(obj.contacts{i}{1}(1)-100 : obj.contacts{i}{1}(1)-50));
                        value{i}{ii}.deltaSetPoint = value{i}{ii}.setPointCont - bs_setPoint;
                        
                        % Compute the phase of initial contact in a whisking cycle.
                        if value{i}{ii}.thetaCont > theta_set  % protraction touch
                            value{i}{ii}.phaseCont = 180 * (abs(value{i}{ii}.thetaCont - theta_set)/(theta(lm_ind_1)-theta_set));
                        elseif value{i}{ii}.thetaCont < theta_set
                            value{i}{ii}.phaseCont = 180 * (1 + abs((value{i}{ii}.thetaCont - theta_set)/(theta(lm_ind_1)-theta_set)));
                        elseif value{i}{ii}.thetaCont == theta_set
                            if ismember(lm_ind_0, theta_LM.lmaxind)
                                value{i}{ii}.phaseCont = 180;
                            elseif ismember(lm_ind_0, theta_LM.lminind)
                                value{i}{ii}.phaseCont = 0;
                            end
                        else
                            error('Cannot decide contact Phase! ');
                        end
                        
                        
                    end
                end
            end
        end
        
        function value = get.whisk_amplitude(obj)
            value = cell(1,length(obj.trajectoryIDs));
            for i = 1:length(value)
                if i > length(obj.theta)
                    continue
                else
                    th = obj.theta{i};
                    [lmn, indmin] = lmin_pw(th',15);
                    [lmx, indmax] = lmax_pw(th',15);
                    xi = 1:length(th);
                    indmin = unique(indmin);
                    lmn = th(indmin);
                    indmax = unique(indmax);
                    lmx = th(indmax);
                    lmni = interp1(indmin,lmn,xi);
                    lmxi = interp1(indmax,lmx,xi);
                    value{i} = abs(lmni)-abs(lmxi);
                end
            end
        end
        
        function deltaKappa = get.deltaKappa(obj)
            % deltaKappa, is the kappa subtracted by the mean over a
            % baseline period define by a low velocity pre-bar period.
            % kappa is averaged over an arc length roi for each whiskers
            tids = obj.trajectoryIDs;
            
            %             if ~isempty(obj.bar_time_win)
            %                 baseline_window = [0 obj.bar_time_win(1)-0.4];
            %             else
            %                 baseline_window = [0 0.5]; % ad hoc, alwasy >0.5 sec deley before bar moves.
            %             end
            %             t = obj.get_time(tids);
            %             bs_win_ind = find(t< baseline_window(2) & t > baseline_window(1));
            
            w_ind = find(obj.trajectoryIDs == tids);
            
            % define the baseline
            for i = 1:length(tids)
                kappa = obj.kappa{w_ind(i)};
                 k0 = kappa - mean(kappa);
                
                poletime = obj.bar_time_win;
                if isempty(poletime)
                    poletime = [1,2.5];
                end
%                 k0 = kappa(obj.time> poletime(1) & obj.time < poletime(2));
                %                 vel = obj.get_velocity(tids(i));
                %                 ind = find ( abs(vel) < prctile(abs(vel),20 ) ) ;
                %                 baseline kappa is averaged across frames with low velocity,
                %                 but within defined time window, e.g., pre-bar time.
                %                 baseKappa = nanmean(kappa(ind(ismember(ind,bs_win_ind))));
                baseKappa = nanmean ( kappa ( ( abs(k0) < prctile(abs(k0),10 ) ) ) );
                %                 ts = obj.time{i};
                %                 barFrInds = find(ts > obj.bar_time_win(1) & ts < obj.bar_time_win(2));
                %                 dToBar = obj.distToBar{i};
                %                 dToBarThresh = 4*obj.barRadius; % in pixel
                %                 inds = barFrInds(dToBar(barFrInds) < dToBarThresh);
                %                 kappa = obj.kappa{i};
                %                 if length(inds) > 10
                %                     [N,X] = hist(kappa(inds),20);
                % %                     hist(kappa(inds),20);
                %                     baseKappa = mean(X(N==max(N)))
                %                 else
                %                     baseKappa = nanmean(kappa(ts>0 & ts<0.5));
                %                 end
                deltaKappa{i} = (kappa - baseKappa)*1000; % in 1/meter
            end
            
        end
        
        function value = get.Setpoint(obj)
            tids = obj.trajectoryIDs;
            value = cell(1,length(tids));
            sampleRate=  1/0.002;
            BandPassCutOffsInHz = [6 60];
            W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
            W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
            [b1,a1]=butter(2,[W1 W2]);
            [b2,a2]=butter(2, 6/ (sampleRate/2),'low');
            
            for i = 1:length(tids)
                theta = obj.theta{i};
                %                 value{i} = smooth(theta, 100,'moving');
                filteredSignal = filtfilt(b1, a1, theta);
                value{i} = filtfilt(b2, a2, theta - filteredSignal);
            end
        end
        
        function Amplitude = get.Amplitude(obj)
            tids = obj.trajectoryIDs;
            Amplitude = cell(1,length(tids));
            
            sampleRate=  1/0.002;
            [B,A] = butter(2,0.5,'low'); % bandpass filtering
            
            for i = 1:length(tids)
                theta = obj.theta{i};
                lowPass = filtfilt(B,A,theta);
                BandPassCutOffsInHz = [6 60]; % [6 100]; %  %%check filter parameters!!!
                W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
                W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
                [b,a] = butter(2,[W1 W2]);
                filteredSignal = filtfilt(b, a, lowPass);
                
                hh = hilbert(filteredSignal);
                Amplitude{i} = abs(hh);
            end
        end
        function Velocity = get.Velocity(obj)
            tids = obj.trajectoryIDs;
            
            Velocity = cell(1,length(tids));
            for i = 1:length(tids)
                %                     wNo = find( obj.trajectoryIDs(i) == tids(i));
                Velocity{i} = obj.get_velocity(tids(i));
            end
        end
        
        
    end
end
