function cfupdateylim
%CFUPDATEYLIM Update the y axis min/max values

%   Copyright 2001-2013 The MathWorks, Inc.

dminmax = [];                    % to indicate y data limits

% Check any datasets with a plotting flag on
a = cfgetalldatasets;
fitdb = getfitdb;
for j=1:length(a)
   b = a{j};
   if b.plot == 1
      dminmax = iCombineMinMax(dminmax,b.ylim);
   else
      flist = find(fitdb,'dataset',b.name,'plot',1);
      if ~isempty(flist)
         dminmax = iCombineMinMax(dminmax,b.ylim);
      end
   end
end

% Check y limits of all fits
havedata = ~isempty(dminmax);
pminmax = dminmax;              % limits to use for plot
dy = diff(dminmax);
a = cfgetallfits;
for j=1:length(a)
   b = a{j};
   if b.plot==1 && ~isempty(b.line) 
      fminmax = get(handle(b.line),'YLim');    %function limits
      if havedata && ~isempty(fminmax)
         if fminmax(2)<=dminmax(2)+dy && fminmax(1)>=dminmax(1)-dy
            % Expand range to include fit if extrapolation is reasonable
            pminmax(1) = min(pminmax(1),fminmax(1));
            pminmax(2) = max(pminmax(2),fminmax(2));
         else
            % Otherwise study the fit to see how much of it to plot
            ydata = sort(get(b.line,'YData'));
            ydata(isnan(ydata)) = [];
            n = length(ydata);
            if n>4
               n4 = ceil(n/4);
               q1 = ydata(n4);
               q3 = ydata(n+1-n4);
               iqr = max(q3-q1,dy);
               fmin = max(ydata(1), q1-iqr);
               fmax = min(ydata(end), q3+iqr);
               pminmax(1) = min(pminmax(1),fmin);
               pminmax(2) = max(pminmax(2),fmax);
            end
         end
      else
         pminmax = iCombineMinMax(pminmax,fminmax);
      end
   end
end

% Update main axis y limits
cfSetAxesLimits( 'YLim', pminmax );

% Update residual y axis if one exists
cffig = cfgetset('cffig');
ax2 = findall(cffig,'Type','axes','Tag','resid');
if ~isempty(ax2)
   iAutomaticallySetYLimits(ax2);
end

function bothmm = iCombineMinMax( oldmm, newmm )
% iCombineMinMax   Combine old and new minmax values
if isempty(oldmm)
   bothmm = newmm;
elseif isempty(newmm)
   bothmm = oldmm;
else
   bothmm = [min(oldmm(1),newmm(1)) max(oldmm(2),newmm(2))];
end

function iAutomaticallySetYLimits( anAxes )
set(anAxes,'YLimMode','auto');
[~] = get(anAxes,'YLim');
set(anAxes,'YLimMode','manual');
