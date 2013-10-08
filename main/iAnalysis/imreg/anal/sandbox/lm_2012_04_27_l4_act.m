if (0) % basic plot
	ax = figure_tight ;

	for f=1:3
		imshow(s.caTSA.roiArray{f}.masterImage, [0 500], 'Parent', ax{f}, 'Border', 'tight');
	end
	print('-depsc', '~/Desktop/an166555_FOV.eps');

  ax2=figure_tight; 
	s.plotColorRois('eventRate', [], [], [], [], [0 0.1], ax2);
	print('-depsc', '~/Desktop/an166555_act.eps');
end

% comparison across layers
if (0)
  figure;
	subplot(2,2,1);
	hist(freq_L1, 0:.01:1);
  title('Layer 1');
	a = axis;
	axis([0 1 0 a(4)]);
	set(gca,'TickDir','out');

	subplot(2,2,2);
	hist(freq_L23, 0:.01:1);
  title('Layer 2/3');
	a = axis;
	axis([0 1 0 a(4)]);
	set(gca,'TickDir','out');

	subplot(2,2,3);
	hist(freq_L4, 0:.01:1);
  title('Layer 4');
	a = axis;
	axis([0 1 0 a(4)]);
	set(gca,'TickDir','out');
	xlabel('Hz')

	subplot(2,2,4);
	hist(freq_L5, 0:.01:1);
  title('Layer 5');
	a = axis;
	axis([0 1 0 a(4)]);
	set(gca,'TickDir','out');

	xlabel('Hz');
  print('-dpng', '~/Desktop/cross_layer_activity_distros.png');

end

% modulation ...
if( 1)
  figure;
  pos_L1 = find(freq_pre_L1 < freq_pole_L1);
  neg_L1 = find(freq_pre_L1 > freq_pole_L1);

  pos_L23 = find(freq_pre_L23 < freq_pole_L23);
  neg_L23 = find(freq_pre_L23 > freq_pole_L23);

  pos_L5 = find(freq_pre_L5 < freq_pole_L5);
  neg_L5 = find(freq_pre_L5 > freq_pole_L5);

  pos_L4 = find(freq_pre_L4 < freq_pole_L4);
  neg_L4 = find(freq_pre_L4 > freq_pole_L4);

  pos_frac = [length(pos_L1)/length(freq_L1) length(pos_L23)/length(freq_L23) length(pos_L4)/length(freq_L4) length(pos_L5)/length(freq_L5)];
  neg_frac = [length(neg_L1)/length(freq_L1) length(neg_L23)/length(freq_L23) length(neg_L4)/length(freq_L4) length(neg_L5)/length(freq_L5)];

	bar([pos_frac ; neg_frac], 'group');
  legend ('L1','L23','L4','L5');
	set(gca,'TickDir','out','XTick',[]);
	ylabel('Fraction');
	text(.75,.7, 'Increase Response');
	text(1.75,.7, 'Decrease Response');
	axis([0.5 2.5 0 1]);

  figure;
	thresh_freq  = .01;
	dec = .8;
	inc = 1.25;
	act_L1 = find(freq_L1 > thresh_freq);
  pos_L1 = find(freq_pre_L1(act_L1)./freq_pole_L1(act_L1) < dec);
  neg_L1 = find(freq_pre_L1(act_L1)./freq_pole_L1(act_L1) > inc);
	act_L4 = find(freq_L4 > thresh_freq);
  pos_L4 = find(freq_pre_L4(act_L4)./freq_pole_L4(act_L4) < dec);
  neg_L4 = find(freq_pre_L4(act_L4)./freq_pole_L4(act_L4) > inc);
	act_L23 = find(freq_L23 > thresh_freq);
  pos_L23 = find(freq_pre_L23(act_L23)./freq_pole_L23(act_L23) < dec);
  neg_L23 = find(freq_pre_L23(act_L23)./freq_pole_L23(act_L23) > inc);
	act_L5 = find(freq_L5 > thresh_freq);
  pos_L5 = find(freq_pre_L5(act_L5)./freq_pole_L5(act_L5) < dec);
  neg_L5 = find(freq_pre_L5(act_L5)./freq_pole_L5(act_L5) > inc);


  pos_frac = [length(pos_L1)/length(act_L1) length(pos_L23)/length(act_L23) length(pos_L4)/length(act_L4) length(pos_L5)/length(act_L5)];
  neg_frac = [length(neg_L1)/length(act_L1) length(neg_L23)/length(act_L23) length(neg_L4)/length(act_L4) length(neg_L5)/length(act_L5)];

	bar([pos_frac ; neg_frac], 'group');
  legend ('L1','L23','L4','L5');
	set(gca,'TickDir','out','XTick',[]);
	ylabel('Fraction');
	text(.75,.9, 'Increase Response');
	text(1.75,.7, 'Decrease Response');
	axis([0.5 2.5 0 1]);

end

