
function plot_dist_sessions(anm,numSess)
global wSigSummary
if(iscell(anm))
    anm=anm{1};
end
temp = cell2mat(cellfun(@(x) x.nogo_biased_barpos{1}{1},wSigSummary,'uniformoutput',false));
biased_bartheta = mean(temp);
temp = cell2mat(cellfun(@(x) x.nogo_baseline_barpos{1}{1},wSigSummary,'uniformoutput',false));
baseline_bartheta = mean(temp);
% anm = 'gr199201';
% numSess = 8;
 sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*3/4], 'color','w');
suptitle ([anm 'Normalized Thetaenv_distributions from Sessions']);
for i = 1:numSess
    dist = wSigSummary{1, i}.nogo_dist{1, 1}{1, 1};
    bins = wSigSummary{1, i}.nogo_bins{1, 1}{1, 1} ;
   subplot(numSess,1,i);set(gcf,'DefaultAxesColorOrder',copper(size(dist,1)));
   plot( bins,dist','linewidth',1);set(gca,'XTick',[-50 : 5 :50]);
   axis([ -30 20 0 1]);
%    vline(wSigSummary{1, i}.nogo_thetaenv_biased_barpos{1, 1}{1},{'r', 'Linewidth',1.5});
   vline(biased_bartheta,{'r', 'Linewidth',1.5});   
   vline(wSigSummary{1, i}.nogo_mean_barpos{1,1}{1},{'r--', 'Linewidth',1.5});
%    vline(wSigSummary{1, i}.nogo_thetaenv_baseline_barpos{1, 1}{1},{'k', 'Linewidth',1.5});
 vline(baseline_bartheta,{'k', 'Linewidth',1.5});
end

xlabel ('Theta env (deg)');
fnam = [ anm '_NormThetadist'];
set(gcf,'PaperPositionMode','auto');
saveas(gcf,[pwd,filesep,fnam],'tif');

d1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*3/4], 'color','w');
c =copper(i);suptitle ([anm 'Cumulative Thetaenv_distributions from Sessions']);
for i = 1:numSess
%      bins = wSigSummary{1, i}.nogo_thetaenv_bins{1, 1}{1, 1} ;
    bins = [-30:2.5:30];
   temp = wSigSummary{1, i}.nogo_thetaenvtrials{1, 1}{1, 1};
	temp = reshape(temp,1,prod(size(temp)));
    dist=histnorm(temp,bins);
   subplot(numSess,1,i);
   plot( bins,dist','linewidth',2,'color',c(i,:));set(gca,'XTick',[-50 : 5 :50]);
   axis([ -30 20 0 .075]);
%    vline(wSigSummary{1, i}.nogo_thetaenv_biased_barpos{1, 1}{1},{'r', 'Linewidth',1.5});
%     vline(wSigSummary{1, i}.nogo_thetaenv_baseline_barpos{1, 1}{1},{'k', 'Linewidth',1.5});
      vline(wSigSummary{1, i}.nogo_mean_barpos{1,1}{1},{'r--', 'Linewidth',1.5});
      vline(biased_bartheta,{'r', 'Linewidth',1.5});   
     vline(baseline_bartheta,{'k', 'Linewidth',1.5});
end


xlabel ('Theta env (deg)');
fnam = [ anm '_CummNormThetadist'];
set(gcf,'PaperPositionMode','auto');
saveas(gcf,[pwd,filesep,fnam],'tif');
close(d1);

d2 = figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*1], 'color','w');
c =copper(i);suptitle ([anm 'Cumulative totalTouchKappa_distributions from Sessions']);
for i = 1:numSess
%      bins = wSigSummary{1, i}.nogo_thetaenv_bins{1, 1}{1, 1} ;
    bins = [-15:1:15];
   totalTouchKappa = wSigSummary{1, i}.go_totalTouchKappa{1, 1}{1, 1};
   temp = totalTouchKappa(:,2);
   temp(temp==0) = [];
   subplot(numSess,1,i);
    if(~isempty(temp))
        totalkappa_dist = histnorm(temp,bins);
        plot([-15:15],totalkappa_dist,'color','k','Linewidth',1.5); xlabel('Kappa'); ylabel('Norm freq');  title('Kappa Dist Cummulative ');
        axis([-15 15 0 .75]);
        text(.5,.5,['Contacts ' num2str(length(temp)) '/' num2str(length(totalTouchKappa)) ],'VerticalAlignment','top','HorizontalAlignment','center');
    else
        axis([-15 15 0 .25]);
        text(.5,.2,['Contacts ' num2str(length(temp)) '/' num2str(length(totalTouchKappa)) ],'VerticalAlignment','top','HorizontalAlignment','center');
    end

end


xlabel ('Total Touch Kappa Dist (m_(-1))');
fnam = [ anm '_CummNormKappadist'];
set(gcf,'PaperPositionMode','auto');
saveas(gcf,[pwd,filesep,fnam],'tif');
close(d2);




