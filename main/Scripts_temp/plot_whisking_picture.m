
function plot_whisking_picture(wSigTrials,z)
trialind =z;%452;%53 %436
xt=wSigTrials{1, trialind}.time{1,1};
theta=wSigTrials{1, trialind}.theta{1,1};
frinds = find((xt>.85)&(xt<2.7));
 colormap(othercolor('Mrainbow'));
 sc = get(0,'ScreenSize');
 h= figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)], 'color','w'); 
 subplot(2,1,1);
 plot(xt,theta,'k'); hold on;
  colormapline(xt(frinds),theta(frinds),[],colormap(othercolor('Mrainbow')));
  title(['Ind =' num2str(trialind) ' Trial ' num2str(wSigTrials{1, trialind}.trialNum) ]);
   axis([.5 3.5, -30, 40]);
   set(gca,'FontSize',18); xlabel('Time (s)');ylabel('Whisker Angle (deg)');

%    h2= figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/2], 'color','w'); 
subplot(2,1,2);
   t = xt;
   restrictTime = [.85, 2.7];            
   frameInds = find(t >= restrictTime(1) & t <= restrictTime(2));
   hold on; axis ij
   ind = 1;
    fittedX = wSigTrials{1, trialind}.polyFitsROI{ind}{1};
    fittedY = wSigTrials{1, trialind}.polyFitsROI{ind}{2};
    fittedQ = wSigTrials{1, trialind}.polyFitsROI{ind}{3};
 
    nframes = length(frameInds);
    colormap(othercolor('Mrainbow'));
    cmap = othercolor('Mrainbow',nframes);
%     cmap=jet(nframes);
%     colormap(cmap);
    x = cell(1,nframes);
    y = cell(1,nframes);
                       
            for k=1:nframes
                f = frameInds(k);             
                px = fittedX(f,:);
                py = fittedY(f,:);
                pq = fittedQ(f,:);             
                q = linspace(pq(1),pq(2));              
                x{k} = polyval(px,q);
                y{k} = polyval(py,q);               
                plot(x{k},y{k},'color',cmap(k,:))
            end
             title(['Ind =' num2str(trialind) ' Trial ' num2str(wSigTrials{1, trialind}.trialNum) ]);
end