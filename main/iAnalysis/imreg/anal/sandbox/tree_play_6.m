% decoder individual data compiler
  if (0) % an166555
		% load session
%		load ('an166555_2012_04_23_sess.mat');
		load(sprintf('tree_output_an166555_vol_%02d.mat', 1));
	end

  if (0) % an166558
		% load session
		cd ('../../an166558/session');
%		load ('an166558_2012_04_23_sess.mat');
		tmp = load(sprintf('tree_output_an166558_vol_%02d.mat', 1));

    for a=1:length(allR)
		  allR{a} = [allR{a} tmp.allR{a}];
		end

		allR_L4 = allR;
		varName_L4 = varName;
		save('tree_results_L4.mat', 'allR_L4', 'varName_L4');
	end


  if (0) % an160508
		cd ('/media/an160508b/session_merged');
		allR = {};
		varName = {};
%		allIds = [];
	  for v=1:11
			% load session
%			load (sprintf('an160508_vol_%02d_sess.mat', v));
%			allIds = [allIds s.caTSA.ids];
			tmp = load(sprintf('tree_output_an160508_vol_%02d.mat', v));

      if (v == 1) 
			  allR = tmp.allR;
			else
        for a=1:length(allR)
	  	    allR{a} = [allR{a} tmp.allR{a}];
		    end
			end

			
		end
		save('tree_results_all.mat', 'allR', 'varName', 'allIds');
	end

L1i = find(allIds >= 0 & allIds <= 1999);
L23i = find(allIds >= 2000 & allIds <= 18999);
L5i = find(allIds >= 29000 & allIds <= 40000);

%% Histogram of whisking and touch Rs across layers ... 
if(0)
	figure;
	whV = 5;
	tV = 6;

	% L1: first 2 [0 1999]
	subplot(2,4,1);
	hist(allR{whV}(L1i), 0:.01:1);
	axis([0 1 0 10]);
	text(0.5,8, ['n=' num2str(length(L1i))]);
	set(gca,'TickDir','out');
	title('L1 setpoint R');

	subplot(2,4,2);
	hist(allR{tV}(L1i), 0:.01:1);
	axis([0 1 0 10]);
	set(gca,'TickDir','out');
	title('L1 kappa R');

	% L23: 3-18: [2000 18999]
	subplot(2,4,3);
	hist(allR{whV}(L23i), 0:.01:1);
	axis([0 1 0 100]);
	text(0.5,8, ['n=' num2str(length(L23i))]);
	set(gca,'TickDir','out');
	title('L23 setpoint R');

	subplot(2,4,4);
	hist(allR{tV}(L23i), 0:.01:1);
	axis([0 1 0 100]);
	set(gca,'TickDir','out');
	title('L23 kappa R');


	% L4
	subplot(2,4,5);
	hist(allR_L4{whV}, 0:.01:1);
	axis([0 1 0 10]);
	text(0.5,8, ['n=' num2str(length(allR_L4{whV}))]);
	set(gca,'TickDir','out');
	title('L4 setpoint R');

	subplot(2,4,6);
	hist(allR_L4{tV}, 0:.01:1);
	axis([0 1 0 10]);
	set(gca,'TickDir','out');
	title('L4 kappa R');


	% L5: 29-33 [29000 40000]
	subplot(2,4,7);
	hist(allR{whV}(L5i), 0:.01:1);
	axis([0 1 0 50]);
	text(0.5,8, ['n=' num2str(length(L5i))]);
	set(gca,'TickDir','out');
	title('L5 setpoint R');

	subplot(2,4,8);
	hist(allR{tV}(L5i), 0:.01:1);
	axis([0 1 0 50]);
	set(gca,'TickDir','out');
	title('L5 kappa R');

end


%% Histogram of best whisking or touch Rs across layers ... 
if (0)
  bestW = 0*allR{1};
%  bestW_L4 = 0*allR_L4{1};
	for vi=1:5
	  bestW = max(bestW, allR{vi});
%	  bestW_L4 = max(bestW_L4, allR_L4{vi});
	end

  bestT = 0*allR{1};
 % bestT_L4 = 0*allR_L4{1};
	for vi=6:8
	  bestT = max(bestT, allR{vi});
	%  bestT_L4 = max(bestT_L4, allR_L4{vi});
	end

	figure;

	% L1: first 2 [0 1999]
	subplot(2,4,1);
	hist(bestW(L1i), 0:.01:1);
	axis([0 1 0 10]);
	text(0.5,8, ['n=' num2str(length(L1i))]);
	set(gca,'TickDir','out');
	title('L1 whisking R');

	subplot(2,4,2);
	hist(bestT(L1i), 0:.01:1);
	axis([0 1 0 10]);
	set(gca,'TickDir','out');
	title('L1 touch R');

	% L23: 3-18: [2000 18999]
	subplot(2,4,3);
	hist(bestW(L23i), 0:.01:1);
	axis([0 1 0 100]);
	text(0.5,8, ['n=' num2str(length(L23i))]);
	set(gca,'TickDir','out');
	title('L23 whisking R');

	subplot(2,4,4);
	hist(bestT(L23i), 0:.01:1);
	axis([0 1 0 100]);
	set(gca,'TickDir','out');
	title('L23 touch R');


	% L4
	subplot(2,4,5);
	hist(bestW_L4, 0:.01:1);
	axis([0 1 0 10]);
	text(0.5,8, ['n=' num2str(length(bestW_L4))]);
	set(gca,'TickDir','out');
	title('L4 whisking R');

	subplot(2,4,6);
	hist(bestT_L4, 0:.01:1);
	axis([0 1 0 10]);
	set(gca,'TickDir','out');
	title('L4 touch R');


	% L5: 29-33 [29000 40000]
	subplot(2,4,7);
	hist(bestW(L5i), 0:.01:1);
	axis([0 1 0 50]);
	text(0.5,8, ['n=' num2str(length(L5i))]);
	set(gca,'TickDir','out');
	title('L5 whisking R');

	subplot(2,4,8);
	hist(bestT(L5i), 0:.01:1);
	axis([0 1 0 50]);
	set(gca,'TickDir','out');
	title('L5 touch R');

end

%% Positional plot for touch/whisking in L4
if (0)
  an = 'an166555';
  cd (['/data/' an '/session']);
	load([an '_2012_04_23_sess']);
  tmp = load (['tree_output_' an '_vol_01.mat']);

  bestW = 0*tmp.allR{1};
	for vi=1:5
	  bestW = max(bestW, tmp.allR{vi});
	end

  bestT = 0*tmp.allR{1};
	for vi=6:8
	  bestT = max(bestT, tmp.allR{vi});
	end

  figure ('Position', [0 0 900 600]);
	ax{1} = subplot('Position', [0 0 1/3 1/2]);
	ax{2} = subplot('Position', [1/3 0 1/3 1/2]);
	ax{3} = subplot('Position', [2/3 0 1/3 1/2]);
	ax{4} = subplot('Position', [0 1/2 1/3 1/2]);
	ax{5} = subplot('Position', [1/3 1/2 1/3 1/2]);
	ax{6} = subplot('Position', [2/3 1/2 1/3 1/2]);
  s.plotColorRois('', '', [], [1 0 0], bestT, [0 1], ax(1:3), 0); 
  s.plotColorRois('', '', [], [0 1 0], bestW, [0 1], ax(4:6), 0); 
	print('-dpng' ,['~/Desktop/' an '_touch_whisk.png']);

  figure ('Position', [0 0 900 600]);
	ax{1} = subplot('Position', [0 0 1/3 1/2]);
	ax{2} = subplot('Position', [1/3 0 1/3 1/2]);
	ax{3} = subplot('Position', [2/3 0 1/3 1/2]);
	ax{4} = subplot('Position', [0 1/2 1/3 1/2]);
	ax{5} = subplot('Position', [1/3 1/2 1/3 1/2]);
	ax{6} = subplot('Position', [2/3 1/2 1/3 1/2]);
  s.plotColorRois('', '', [], [0 1 1], tmp.allR{7}, [0 1], ax(1:3), 0); 
  s.plotColorRois('', '', [], [1 0 1], tmp.allR{8}, [0 1], ax(4:6), 0); 
	print('-dpng' ,['~/Desktop/' an '_pro_ret.png']);

end

%% Pooled positional plot for ret/pro for an160508
if (0)
  % get X, Y for *everyone*
	X = 0*allIds;
	Y = 0*allIds;
	for v=1:11
		load (sprintf('an160508_vol_%02d_sess.mat', v));
	  for f=1:3
		  for r=1:length(s.caTSA.roiArray{f}.rois)
		    roi = s.caTSA.roiArray{f}.rois{r};

				idx = find(allIds == roi.id);
				X(idx) = mean(roi.corners(1,:));
				Y(idx) = mean(roi.corners(2,:));
			end
		end
	end
end
if (1)
  figure('Position',[0 0 400 400]);
	ax = axes;
	imshow(s.caTSA.roiArray{1}.masterImage, [0 1000], 'Parent', ax, 'Border', 'tight');
		hold on;

	for i=1:length(allIds)
		if (allR{7}(i) > .4)
			color = [0 1 1]*allR{7}(i);
  	  plot(X(i)-3, Y(i), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
		end
		if (allR{8}(i) > .6)
			color = [1 0 1]*allR{8}(i);
  	  plot(X(i)+3, Y(i), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
		end
	end
end

