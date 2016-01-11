
trialind =i %; 452;%53 %436
xt=wSigTrials{1, trialind}.time{1,1};
theta=wSigTrials{1, trialind}.theta{1,1};
frinds = find((xt>.8)&(xt<2.7));
 colormap(othercolor('Mrainbow'));
 sc = get(0,'ScreenSize');
 h= figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); 
 plot(xt,theta,'k'); hold on;
  colormapline(xt(frinds),theta(frinds),[],colormap(othercolor('Mrainbow')));
  title(['Trial ' num2str(wSigTrials{1, trialind}.trialNum) ]);
   axis([.5 3.5, -30, 40]);
   set(gca,'FontSize',18); xlabel('Time (s)');ylabel('Whisker Angle (deg)');