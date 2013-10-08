function breakup_multi

	an = 'an161322';
	an = 'an171215';
	an = 'an171923';
	an = 'an171925';
	an = 'an166558';
	an = 'an167951';

	%% ========== anTEMPLATE
	if (strcmp(an,'anTEMPLATE'))
	  hdid = '/media/anTEMPLATEa';
	  dates = {'2012_06_03','2012_06_04','2012_06_05','2012_06_06','2012_06_07','2012_06_10'};
		ordering = [1 4 7 2 5 8 3 6];
		ordering = [ordering ordering+8];
		[irr sidx] = sort(ordering);
		if (sum(strcmp(dates, '2012_06_03')) > 0)
		  di = find( strcmp(dates, '2012_06_03'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {}; 
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end
  end

	%% ========== an171923
	if (strcmp(an,'an171923'))
	  hdid = '/media/an171923a';
	  dates = {'2012_06_04','2012_06_05','2012_06_06','2012_06_07','2012_06_10', ...
	           '2012_06_11','2012_06_12','2012_06_13','2012_06_14','2012_06_15','2012_06_16'};
		dates = {dates{11}};
		ordering = [1 4 7 2 5 8 3 6];
		ordering = [ordering ordering+8];
		[irr sidx] = sort(ordering);

		if (sum(strcmp(dates, '2012_06_16')) > 0)
		  di = find( strcmp(dates, '2012_06_16'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1 START
  [45:65] , ... % 4
  [70:94] , ... % 7
  [99:119] , ... % 2
  [123:143] , ... % 5
  [147:172] , ... % 8
  [179:199] , ... % 3
  [202:222] , ... % 6
  [232:252] , ... % 2.1 (9)
  [255:275] , ... % 2.4 (12)
  [278:298] , ... % 2.7 (15)
  [302:322] , ... % 2.2 (10)
  [326:346] , ... % 2.5 (13)
  [349:369] , ... % 2.8 (16)
  [373:383] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_15')) > 0)
		  di = find( strcmp(dates, '2012_06_15'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [1:30] , ... % 5 START
  [33:63] , ... % 8
  [65:95] , ... % 3
  [98:128] , ... % 6
  [135:165] , ... % 2.1 (9)
  [167:202] , ... % 2.4 (12)
  [204:234] , ... % 2.7 (15)
  [238:268] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] ,... % 2.6 (14)
	[278:320] } % L5: z_mid=340 p0=35 pz=250 ; dz 120
			franges = franges([sidx 17]);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10  10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_14')) > 0)
		  di = find( strcmp(dates, '2012_06_14'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:45] , ... % 1 start
  [48:78] , ... % 4
  [82:112] , ... % 7
  [122:152] , ... % 2
  [153:186] , ... % 5
  [198:238] , ... % 8
  [247:269] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_13')) > 0)
		  di = find( strcmp(dates, '2012_06_13'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [314:334] , ... % 1
  [340:370] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:40] , ... % 2.1 (9) sTART
  [58:88] , ... % 2.4 (12)
  [92:122] , ... % 2.7 (15)
  [134:164] , ... % 2.2 (10)
  [168:198] , ... % 2.5 (13)
  [201:233] , ... % 2.8 (16)
  [238:268] , ... % 2.3 (11)
  [271:304] }; % 2.6 (14)



			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 12 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_12')) > 0)
		  di = find( strcmp(dates, '2012_06_12'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [156:186] , ... % 1
  [189:219] , ... % 4
  [221:261] , ... % 7
  [264:294] , ... % 2
  [296:326] , ... % 5
  [329:359] , ... % 8
  [364:394] , ... % 3
  [396:426] , ... % 6
  [433:440] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [1:42] , ... % 2.5 (13) START
  [48:78] , ... % 2.8 (16)
  [82:114] , ... % 2.3 (11)
  [117:147] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 5 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_11')) > 0)
		  di = find( strcmp(dates, '2012_06_11'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [1:41] , ... % 5 START
  [44:74] , ... % 8
  [81:111] , ... % 3
  [118:148] , ... % 6
  [159:189] , ... % 2.1 (9)
  [193:226] , ... % 2.4 (12)
  [230:260] , ... % 2.7 (15)
  [262:295] , ... % 2.2 (10)
  [298:328] , ... % 2.5 (13)
  [331:361] , ... % 2.8 (16)
  [369:402] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end





		if (sum(strcmp(dates, '2012_06_10')) > 0)
		  di = find( strcmp(dates, '2012_06_10'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [151:181] , ... % 1
  [187:217] , ... % 4
  [224:254] , ... % 7
  [264:294] , ... % 2
  [300:335] , ... % 5
  [339:369] , ... % 8
  [378:288] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [40:70] , ... % 2.5 (13) START
  [107:141] , ... % 2.8 (16)
  [75:105] , ... % 2.3 (11)
  [7:37] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    20];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_07')) > 0)
		  di = find( strcmp(dates, '2012_06_07'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [5:35] , ... % 2.1 (9) START
  [37:68] , ... % 2.4 (12)
  [71:106] , ... % 2.7 (15)
  [109:146] , ... % 2.2 (10)
  [149:181] , ... % 2.5 (13)
  [184:214] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_06_06')) > 0)
		  di = find( strcmp(dates, '2012_06_06'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [15:45] , ... % 1 START
  [50:80] , ... % 4
  [85:116] , ... % 7
  [121:151] , ... % 2
  [155:185] , ... % 5
  [189:219] , ... % 8
  [229:262] , ... % 3
  [265:310] , ... % 6
  [320:348] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_06_05')) > 0)
		  di = find( strcmp(dates, '2012_06_05'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [297:324] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:40] , ... % 2.1 (9) START
  [46:85] , ... % 2.4 (12)
  [89:119] , ... % 2.7 (15)
  [121:151] , ... % 2.2 (10)
  [155:185] , ... % 2.5 (13)
  [188:218] , ... % 2.8 (16)
  [223:253] , ... % 2.3 (11)
  [256:286] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 20    20 20 5 20 5    20];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_06_04')) > 0)
		  di = find( strcmp(dates, '2012_06_04'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges =  { [1:40] , ... % 1
  [57:90] , ... % 4
  [93:123] , ... % 7
  [125:155] , ... % 2
  [160:190] , ... % 5
  [193:223] , ... % 8
  [229:259] , ... % 3
  [261:291] , ... % 6
  [299:329] , ... % 2.1 (9)
  [333:363] , ... % 2.4 (12)
  [367:397] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

  end


	%% ========== an171925
	if (strcmp(an,'an171925'))
	  hdid = '/media/an171925a';
	  dates = {'2012_05_31','2012_06_01','2012_06_03','2012_06_04','2012_06_05','2012_06_06','2012_06_07', ...
	           '2012_06_11','2012_06_12','2012_06_13','2012_06_14','2012_06_15','2012_06_16'};
		dates = {dates{13}};
		ordering = [1 4 7 2 5 8 3 6];
		ordering = [ordering ordering+8];
		[irr sidx] = sort(ordering);




	if (sum(strcmp(dates, '2012_06_16')) > 0)
		  di = find( strcmp(dates, '2012_06_16'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:30] , ... % 1 START
  [34:56] , ... % 4
  [59:79] , ... % 7
  [82:102] , ... % 2
  [105:125] , ... % 5
  [129:149] , ... % 8
  [152:172] , ... % 3
  [175:195] , ... % 6
  [201:223] , ... % 2.1 (9)
  [226:245] , ... % 2.4 (12)
  [248:268] , ... % 2.7 (15)
  [271:291] , ... % 2.2 (10)
  [294:305] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




	if (sum(strcmp(dates, '2012_06_15')) > 0)
		  di = find( strcmp(dates, '2012_06_15'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [144:174] , ... % 1
  [181:213] , ... % 4
  [217:255] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [1:30] , ... % 2.5 (13) START
  [35:65] , ... % 2.8 (16)
  [70:100] , ... % 2.3 (11)
  [105:135] , ... % 2.6 (14)
	[270:320]} ; % L5: (dz 120 ; pz 250 ; p0:5 z_center:380 )
			franges = franges([sidx 17]);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10 10];
			breakup_single (franges, refimidx, hdid,an);
		end




	if (sum(strcmp(dates, '2012_06_14')) > 0)
		  di = find( strcmp(dates, '2012_06_14'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:40] , ... % 2.1 (9) start
  [44:74] , ... % 2.4 (12)
  [77:109] , ... % 2.7 (15)
  [113:143] , ... % 2.2 (10)
  [147:183] , ... % 2.5 (13)
  [189:228] , ... % 2.8 (16)
  [234:264] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




	if (sum(strcmp(dates, '2012_06_13')) > 0)
		  di = find( strcmp(dates, '2012_06_13'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [11:40] , ... % 1 START
  [44:78] , ... % 4
  [82:112] , ... % 7
  [114:150] , ... % 2
  [152:182] , ... % 5
  [185:222] , ... % 8
  [224:254] , ... % 3
  [257:287] , ... % 6
  [296:326] , ... % 2.1 (9)
  [330:360] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




	if (sum(strcmp(dates, '2012_06_12')) > 0)
		  di = find( strcmp(dates, '2012_06_12'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [311:341] , ... % 1
  [344:374] , ... % 4
  [378:411] , ... % 7
  [415:445] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:50] , ... % 2.1 (9) START
  [56:86] , ... % 2.4 (12)
  [90:121] , ... % 2.7 (15)
  [126:156] , ... % 2.2 (10)
  [161:200] , ... % 2.5 (13)
  [202:232] , ... % 2.8 (16)
  [238:268] , ... % 2.3 (11)
  [271:301] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




	if (sum(strcmp(dates, '2012_06_11')) > 0)
		  di = find( strcmp(dates, '2012_06_11'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [40:70] , ... % 1 START
  [71:105] , ... % 4
  [109:139] , ... % 7
  [144:194] , ... % 2
  [196:226] , ... % 5
  [229:265] , ... % 8
  [270:300] , ... % 3
  [305:335] , ... % 6
  [344:390] , ... % 2.1 (9)
  [397:400] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 2 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end



		if (sum(strcmp(dates, '2012_06_07')) > 0)
		  di = find( strcmp(dates, '2012_06_07'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [162:192] , ... % 1
  [195:205] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [11:41] , ... % 2.5 (13) START
  [44:78] , ... % 2.8 (16)
  [83:118] , ... % 2.3 (11)
  [121:158] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_06')) > 0)
		  di = find( strcmp(dates, '2012_06_06'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [7:37] , ... % 2.1 (9) START
  [43:74] , ... % 2.4 (12)
  [78:108] , ... % 2.7 (15)
  [118:180] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_05')) > 0)
		  di = find( strcmp(dates, '2012_06_05'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [5:40] , ... % 1 START
  [45:75] , ... % 4
  [79:109] , ... % 7
  [114:154] , ... % 2
  [159:189] , ... % 5
  [193:223] , ... % 8
  [230:260] , ... % 3
  [266:303] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_04')) > 0)
		  di = find( strcmp(dates, '2012_06_04'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:40] , ... % 2.1 (9) START OOPS
  [45:75] , ... % 2.4 (12)
  [77:107] , ... % 2.7 (15)
  [110:140] , ... % 2.2 (10)
  [142:172] , ... % 2.5 (13)
  [174:204] , ... % 2.8 (16)
  [213:243] , ... % 2.3 (11)
  [245:283] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_03')) > 0)
		  di = find( strcmp(dates, '2012_06_03'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [] , ... % 1
  [] , ... % 4
  [20:50] , ... % 7 START
  [56:86] , ... % 2
  [88:118] , ... % 5
  [120:154] , ... % 8
  [158:188] , ... % 3
  [193:223] , ... % 6
  [229:259] , ... % 2.1 (9)
  [263:293] , ... % 2.4 (12)
  [296:326] , ... % 2.7 (15)
  [328:345] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 12    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_01')) > 0)
		  di = find( strcmp(dates, '2012_06_01'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [317:347] , ... % 1
  [349:379] , ... % 4
  [382:412] , ... % 7
  [414:430] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [1:50] , ... % 2.1 (9) START
  [52:82] , ... % 2.4 (12)
  [87:117] , ... % 2.7 (15)
  [122:152] , ... % 2.2 (10)
  [156:206] , ... % 2.5 (13)
  [209:239] , ... % 2.8 (16)
  [247:276] , ... % 2.3 (11)
  [278:308] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 15 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_31')) > 0)
		  di = find( strcmp(dates, '2012_05_31'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1
  [74:104] , ... % 4
  [109:139] , ... % 7
  [42:72] , ... % 2
  [142:172] , ... % 5
  [176:210] , ... % 8
  [215:245] , ... % 3
  [259:289] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 11 5 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end
  end


	%% ========== an171215
	if (strcmp(an,'an171215'))
	  hdid = '/media/an171215a';
	  dates = {'2012_06_03','2012_06_04','2012_06_05','2012_06_06','2012_06_07','2012_06_10', ...
		         '2012_06_11', '2012_06_12', '2012_06_13'};
	  dates = {dates{9}};
		ordering = [1 4 7 2 5 8 3 6];
		ordering = [ordering ordering+8];
		[irr sidx] = sort(ordering);

  	if (sum(strcmp(dates, '2012_06_13')) > 0)
		  di = find( strcmp(dates, '2012_06_13'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:30] , ... % 1
  [36:56] , ... % 4
  [62:84] , ... % 7
  [87:107] , ... % 2
  [111:131] , ... % 5
  [135:160] , ... % 8
  [164:184] , ... % 3
  [188:208] , ... % 6
  [215:238] , ... % 2.1 (9)
  [243:265] , ... % 2.4 (12)
  [268:288] , ... % 2.7 (15)
  [292:312] , ... % 2.2 (10)
  [318:338] , ... % 2.5 (13)
  [341:361] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

  	if (sum(strcmp(dates, '2012_06_12')) > 0)
		  di = find( strcmp(dates, '2012_06_12'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [1:40] , ... % 2 START
  [45:75] , ... % 5
  [79:110] , ... % 8
  [113:144] , ... % 3
  [149:183] , ... % 6
  [191:234] , ... % 2.1 (9)
  [243:277] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] , ... % 2.6 (14)
	[303:353], ... % L5a_1 [center:470 below ; dz 120 ; p0 15 pz 250]
  [358:426], ... % L5a_2 [center is 500 below ; p0 20 pz 250]
  [429:465]};   % L5a_3 center is 485 below ; p0 20 pz 250]

	    nsidx = sidx; nsidx = [nsidx 17 18 19];
			franges = franges(nsidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10   10 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end

  	if (sum(strcmp(dates, '2012_06_11')) > 0)
		  di = find( strcmp(dates, '2012_06_11'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [321:351] , ... % 1
  [356:386] , ... % 4
  [389:429] , ... % 7
  [434:464] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... %
  [1:53] , ... % 2.1 (9) START
  [59:89] , ... % 2.4 (12)
  [94:124] , ... % 2.7 (15)
  [131:167] , ... % 2.2 (10)
  [173:203] , ... % 2.5 (13)
  [214:244] , ... % 2.8 (16)
  [249:279] , ... % 2.3 (11)
  [283:313] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end




		if (sum(strcmp(dates, '2012_06_10')) > 0)
		  di = find( strcmp(dates, '2012_06_10'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [20:52] , ... % 1 START
  [58:88] , ... % 4
  [92:125] , ... % 7
  [131:162] , ... % 2
  [165:195] , ... % 5
  [199:229] , ... % 8
  [231:261] , ... % 3
  [266:298] , ... % 6
  [305:335] , ... % 2.1 (9)
  [339:350] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_07')) > 0)
		  di = find( strcmp(dates, '2012_06_07'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [] , ... % 2.2 (10)
  [5:35] , ... % 2.5 (13) START
  [42:72] , ... % 2.8 (16)
  [77:109] , ... % 2.3 (11)
  [112:142] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_06')) > 0)
		  di = find( strcmp(dates, '2012_06_06'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1 START
  [84:116] , ... % 4
  [119:149] , ... % 7
  [152:182] , ... % 2
  [47:80] , ... % 5
  [185:215] , ... % 8
  [219:249] , ... % 3
  [256:286] , ... % 6
  [291:321] , ... % 2.1 (9)
  [326:356] , ... % 2.4 (12)
  [360:390] , ... % 2.7 (15)
  [393:423] , ... % 2.2 (10)
  [427:454] , ... % 2.5 (13)
  [] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_05')) > 0)
		  di = find( strcmp(dates, '2012_06_05'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [467:493] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [1:50] , ... % 5 START
  [52:82] , ... % 8
  [86:116] , ... % 3
  [118:151] , ... % 6
  [157:187] , ... % 2.1 (9)
  [195:225] , ... % 2.4 (12)
  [229:259] , ... % 2.7 (15)
  [263:293] , ... % 2.2 (10)
  [299:329] , ... % 2.5 (13)
  [333:363] , ... % 2.8 (16)
  [370:401] , ... % 2.3 (11)
  [405:459] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_06_04')) > 0)
		  di = find( strcmp(dates, '2012_06_04'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges ={ [207:240] , ... % 1
  [244:274] , ... % 4
  [277:307] , ... % 7
  [314:345] , ... % 2
  [350:380] , ... % 5
  [383:413] , ... % 8
  [416:444] , ... % 3
  [] , ... % 6
  [] , ... % 2.1 (9)
  [] , ... % 2.4 (12)
  [] , ... % 2.7 (15)
  [3:58] , ... % 2.2 (10) START
  [62:92] , ... % 2.5 (13)
  [99:129] , ... % 2.8 (16)
  [135:167] , ... % 2.3 (11)
  [170:202] }; % 2.6 (14)

			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    10 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end



		if (sum(strcmp(dates, '2012_06_03')) > 0)
		  di = find( strcmp(dates, '2012_06_03'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1 START
  [42:77] , ... % 4
  [81:111] , ... % 7
  [115:145] , ... % 2
  [150:181] , ... % 5
  [187:217] , ... % 8
  [220:256] , ... % 3
  [261:291] , ... % 6
  [295:325] , ... % 2.1 (9)
  [328:358] , ... % 2.4 (12)
  [371:391] , ... % 2.7 (15)
  [398:431] , ... % 2.2 (10)
  [435:485] , ... % 2.5 (13)
  [490:534] , ... % 2.8 (16)
  [] , ... % 2.3 (11)
  [] }; % 2.6 (14)
			franges = franges(sidx);
			refimidx = [10 10 10 10 10    10 10 10 10 10    11 10 10 10 10    10];
			breakup_single (franges, refimidx, hdid,an);
		end


  end
     
 	%% ========== an167951
	if (strcmp(an,'an167951'))
	  hdid = '/media/an167951a';
	  dates = {'2012_04_30','2012_05_01','2012_05_02','2012_05_03','2012_05_04','2012_05_06','2012_05_07', ...
		         '2012_05_08','2012_05_09','2012_05_10','2012_05_11',};
	  dates = {'2012_05_10'};
		ordering = [1 4 7 2 5 8 3 6];
		ordering = [ordering ordering+8];
		[irr sidx] = sort(ordering);

		if (sum(strcmp(dates, '2012_05_01')) > 0)
		  di = find( strcmp(dates, '2012_05_01'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [166:191] , ... % 1
  [195:223] , ... % 4
  [231:262] , ... % 7
  [269:294] , ... % 2
  [301:333] , ... % 5
  [339:370] , ... % 8
  [376:401] , ... % 3
  [405:430] , ... % 6
  [437:474] , ... % 1 FOV 2
  [477:502] , ... % 4
  [505:532] , ... % 7
  [2:27] , ... % 2
  [32:57] , ... % 5
  [60:87] , ... % 8
  [92:121] , ... % 3
  [130:160] }; % 6
			franges = franges(sidx);
			refimidx = [10 11 10 10 10 10 11 10 11 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end

		
		if (sum(strcmp(dates, '2012_04_30')) > 0)
		  di = find( strcmp(dates, '2012_04_30'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { 	[5:35] , ...
  [43:68] , ...
  [79:104] , ...
  [110:138] , ...
  [143:173] , ...
  [180:205] , ...
  [210:235] , ...
  [239:275] , ... 
  [283:308] , ...% FOV 2
  [311:343] , ...
  [345:372] , ...
  [376:401] , ...
  [] , ... % 5
  [] , ... %8
  [] , ... %3
  [] };
			franges = franges(sidx);
			refimidx = [10 11 10 10 10 10 11 10 11 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_02')) > 0)
		  di = find( strcmp(dates, '2012_05_02'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [244:274] , ... % 1
  [281:306] , ... % 4
  [311:336] , ... % 7
  [340:368] , ... % 2
  [370:395] , ... % 5
  [400:427] , ... % 8
  [430:450] , ... % 3
  [] ,... % 6
  [2:30] , ... % 1  ** START
  [33:58] , ... % 4
  [62:87] , ... % 7
  [90:116] , ... % 2
  [120:150] , ... % 5
  [154:179] , ... % 8
  [182:207] , ... % 3
  [213:238] }; % 6
			franges = franges(sidx);
			refimidx = [10 11 10 10 10 10 11 10 11 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_03')) > 0)
		  di = find( strcmp(dates, '2012_05_03'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [389:414] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [1:39] , ... % 5 START
  [42:67] , ... % 8
  [73:98] , ... % 3
  [102:127] , ... % 6
 [134:159] , ... % 1
  [163:188] , ... % 4
  [192:229] , ... % 7
  [233:258] , ... % 2
  [263:292] , ... % 5
  [296:321] , ... % 8
  [325:350] , ... % 3
  [358:383] }; % 6
			franges = franges(sidx);
			refimidx = [10 11 15 10 10 15 11 15 11 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_04')) > 0)
		  di = find( strcmp(dates, '2012_05_04'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1 START
  [49:80] , ... % 4
  [85:110] , ... % 7
  [114:144] , ... % 2
  [147:173] , ... % 5
  [180:205] , ... % 8
  [218:243] , ... % 3
  [245:270] , ... % 6
  [] , ... % 1 FOV 2
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] }; % 6

			franges = franges(sidx);
			refimidx = [10 11 10 10 10 10 11 10 11 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end


		if (sum(strcmp(dates, '2012_05_06')) > 0)
		  di = find( strcmp(dates, '2012_05_06'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [259:284] , ... % 1
  [287:315] , ... % 4
  [320:345] , ... % 7
  [352:377] , ... % 2
  [380:405] , ... % 5
  [408:441] , ... % 8
  [447:472] , ... % 3
  [475:500] ,... % 6 FOV 2
  [1:40] , ... % 1 START
  [46:71] , ... % 4
  [74:101] , ... % 7
  [106:131] , ... % 2
  [134:159] , ... % 5
  [164:189] , ... % 8
  [193:220] , ... % 3
  [227:252] }; % 6

			franges = franges(sidx);
			refimidx = [10 11 10 10 10 10 11 10 11 10 10 10 10 11 15 11];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_07')) > 0)
		  di = find( strcmp(dates, '2012_05_07'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [1:40] , ... % 1 START
  [43:68] , ... % 4
  [73:98] , ... % 7
  [138:163] , ... % 2
  [169:194] , ... % 5
  [198:223] , ... % 8
  [226:251] , ... % 3
  [255:280] , ... %6 FOV 2
  [287:313] , ... % 1
  [316:341] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] }; % 6

			franges = franges(sidx);
			refimidx = [10 15 10 10 10 10 11 10 11 10 12 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end


		if (sum(strcmp(dates, '2012_05_08')) > 0)
		  di = find( strcmp(dates, '2012_05_08'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {[235:277] , ... % 1
  [280:310] , ... % 4
  [316:341] , ... % 7
  [346:362] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [] , ... % 3
  [] , ... % 6
  [] , ... % 1
  [1:40] , ... % 4 START
  [43:68] , ... % 7
  [77:102] , ... % 2
  [105:130] , ... % 5
  [134:164] , ... % 8
  [174:199] , ... % 3
  [204:229]}; 

			franges = franges(sidx);
			refimidx = [10 15 10 11 10 10 11 10 11 10 12 10 10 11 11 12];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_09')) > 0)
		  di = find( strcmp(dates, '2012_05_09'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {[] , ... % 1
  [5:40] , ... % 4 START
  [44:70] , ... % 7
  [74:99] , ... % 2
  [103:140] , ... % 5
  [144:169] , ... % 8
  [174:200] , ... % 3
  [207:233], ... % 6
  [241:267] , ... % 1 FOV 2
  [270:295] , ... % 4
  [297:323] , ... % 7
  [328:353] , ... % 2
  [356:385] , ... % 5
  [388:413] , ... % 8
  [417:442] , ... % 3
  [452:477] }; 

			franges = franges(sidx);
			refimidx = [2 2 5 3 4 4 4 11 2 3 12 3 2 2 2 3];
			breakup_single (franges, refimidx, hdid,an, 160:250);
		end

		if (sum(strcmp(dates, '2012_05_10')) > 0)
		  di = find( strcmp(dates, '2012_05_10'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {[63:88] , ... % 1
  [92:117] , ... % 4
  [120:145] , ... % 7
  [148:173] , ... % 2
  [176:201] , ... % 5
  [208:233] , ... % 8
  [240:265] , ... % 3
  [269:294] , ...
 [] , ... % 1
  [] , ... % 4
  [] , ... % 7
  [] , ... % 2
  [] , ... % 5
  [] , ... % 8
  [1:30] , ... % 3 START
  [33:58], ... 
	[307:359], ... % L5 z 450 dz 120 p0 69 lambda 250
  [362:445]};  % l5  z 420 p0 80

			franges = franges([sidx 17 18]);
			refimidx = [10 15 10 10 10 10 11 10 11 10 12 10 10 11 10 11   10 10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_05_11')) > 0)
		  di = find( strcmp(dates, '2012_05_11'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {[1:43] , ... % 1 START
  [47:72] , ... % 4
  [78:103] , ... % 7
  [105:130] , ... % 2
  [132:157] , ... % 5
  [159:184] , ... % 8
  [186:211] , ... % 3
  [213:238] , ...
 [243:263] , ... % 1
  [265:285] , ... % 4
  [287:307] , ... % 7
  [310:330] , ... % 2
  [334:354] , ... % 5
  [356:376] , ... % 8
  [378:398] , ... % 3
  [400:420]}; 

			franges = franges(sidx);
			refimidx = [10 15 10 10 10 10 11 10 11 10 12 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end




	end

 	%% ========== an161322
	if (strcmp(an,'an161322'))
	  hdid = '/media/an161322b';
	  dates = {'2012_02_28','2012_02_29','2012_03_01','2012_03_02','2012_03_03','2012_03_04','2012_03_05','2012_03_06'};
	  dates = {'2012_03_03','2012_03_04','2012_03_05','2012_03_06'};
	  dates = {'2012_03_06'};
		ordering = [2 5 8 11   1 4 7 10   3 6 9 12];
		[irr sidx] = sort(ordering);

		if (sum(strcmp(dates, '2012_02_28')) > 0)
		  di = find( strcmp(dates, '2012_02_28'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [19:50] , ...
									 [51:80] , ...
									 [85:115], ...
									 [261:294] , ...
									 [117:146] , ...
									 [147:189] , ...
									 [191:230] , ...
									 [231:259] , ...
									 [297:329] , ...
									 [331:359] , ...
									 [365:396] , ...
									 [400:429]
								 };
			franges = franges(sidx);
			refimidx = [10 10 10 10 11 10 11 10 11 10 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end

		if (sum(strcmp(dates, '2012_02_29')) > 0)
		  di = find( strcmp(dates, '2012_02_29'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = { [ 343:370], ...
										[3:30 374:400], ...
										[32:61 403:430], ...
										[63:88], ...
										[92:119], ...
										[122:150], ...
										[153:180], ...
										[183:210], ...
										[219:250], ...
										[253:280], ...
										[283:310], ...
										[313:340]
								 };
			franges = franges(sidx);
			refimidx = [10 10 10 11 11 11 12 10 11 5 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end

		
		if (sum(strcmp(dates, '2012_03_01')) > 0)
		  di = find( strcmp(dates, '2012_03_01'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {	[  341:370], ...
   [375:410], ...
   [412:451], ...
   [3:35 454:482], ...
   [38:65], ...
   [70:99], ...
   [101:130], ...
   [133:162], ...
   [166:195 312:339], ...
   [200:229], ...
   [234:273], ...
   [276:307], 
   							 };
			franges = franges(sidx);
			refimidx = [10 10 10 12 11 11 10 10 4 4 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end
	
		if (sum(strcmp(dates, '2012_03_02')) > 0)
		  di = find( strcmp(dates, '2012_03_02'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {	 [   152:182], ...
    [185:215], ...
    [218:248], ...
    [253:283], ...
    [287:317], ...
    [320:350], ...
    [357:389], ...
    [], ...
    [1:40], ...
    [43:73], ...
    [78:110], ...
    [114:147 ]
   							 };
			franges = franges(sidx);
			refimidx = [10 10 10 12 11 11 10 10 4 4 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end
	
		if (sum(strcmp(dates, '2012_03_03')) > 0)
		  di = find( strcmp(dates, '2012_03_03'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {   			[  215:245], ...
  [248:302], ...
  [305:335 ], ...
  [340:370 ], ...
   [], ...
   [], ...
   [1:40], ...
   [43:73], ...
   [79:110 ], ...
   [115:145], ...
   [148:178], ...
   [181:211]				 };
			franges = franges(sidx);
			refimidx = [10 16 10 12 11 11 11 10 5 4 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end
			
		if (sum(strcmp(dates, '2012_03_04')) > 0)
		  di = find( strcmp(dates, '2012_03_04'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {   			[  282:312], ...
  [318:352], ...
   [354:384], ...
   [388:400], ...
  [1:40 ], ...
   [44:74 ], ...
   [77:107], ...
   [112:142], ...
    [145:175], ...
   [179:209], ...
   [213:243], ...
   [249:279] };
			franges = franges(sidx);
			refimidx = [10 10 10 12 11 11 10 10 4 4 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end


		if (sum(strcmp(dates, '2012_03_05')) > 0)
		  di = find( strcmp(dates, '2012_03_05'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {   			[1:55], ...
  [59:89], ...
  [91:121], ...
  [127:157], ...
   [160:190], ...
   [194:224], ...
   [230:270], ...
   [273:290], ...
  [], ...
  [], ...
  [], ...
  [] };
			franges = franges(sidx);
			refimidx = [10 10 10 12 11 11 10 10 4 4 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end


		if (sum(strcmp(dates, '2012_03_06')) > 0)
		  di = find( strcmp(dates, '2012_03_06'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {   				[  275:309], ...
  [315:345], ...
  [353:399], ...
  [404:440], ...
  [1:40], ...
  [43:63], ...
  [68:88], ...
  [97:121], ...
  [132:162], ...
  [166:196], ...
  [299:235], ...
  [237:268] };
			franges = franges(sidx);
			refimidx = [10 10 10 10 11 11 10 11 4 4 11 10];
			breakup_single (franges, refimidx, hdid,an);
		end


	end

 	%% ========== an160508
	if (strcmp(an,'an160508'))
	  hdid = '/media/an160508b';
	  dates = {'2012_02_10', '2012_02_09', '2012_02_11','2012_02_12','2012_02_13','2012_02_14','2012_02_15'};
	  dates = {'2012_02_15'};

		if (sum(strcmp(dates, '2012_02_10')) > 0)
			cd /media/an160508b/2012_02_10/scanimage
			franges = {[61:90 391:417] ,...
								 [91:120] ,...
								 [121:150] ,...
								 [151:180] ,...
								 [181:211] ,...
								 [212:240] ,...
								 [241:270] ,...
								 [271:303] ,...
								 [304:330], ...
								 [1:30 331:360], ...
								 [31:60 361:390] ,...
								 };
			refimidx = [10 10 10 10 10 10 10 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_02_09')) > 0)
			cd /media/an160508b/2012_02_09/scanimage
			franges = {[61:80 324:342], ...
								 [81:101],...
								 [103:122],...
								 [123:142],...
								 [143:160],... % 5
								 [161:180],...
								 [181:200],...
								 [201:221],...
								 [1:20 222:250],...
								 [21:40 251:280],... % 10
								 [41:60 281:310],...
								 };
			refimidx = [10 10 10 12 10 10 10 10 11 10 11];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_02_11')) > 0)
			cd /media/an160508b/2012_02_11/scanimage
			franges = {[1:30 331:370], ...
								 [31:60 371:390],...
								 [61:91],...
								 [92:120],...
								 [121:150],... % 5
								 [151:181],...
								 [182:210],...
								 [211:240],...
								 [241:270],...
								 [271:300],... % 10
								 [301:330],...
								 };
			refimidx = [12 10 10 10 10 10 12 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end
		if (sum(strcmp(dates, '2012_02_12')) > 0)
			cd /media/an160508b/2012_02_12/scanimage
			franges = {[311:341], ...
								 [282:310],...
								 [251:281],...
								 [221:250],...
								 [191:220],... % 5
								 [161:190],...
								 [131:160],...
								 [101:130],...
								 [71:100 401:415],...
								 [41:70 371:400],... % 10
								 [1:40 342:370],...
								 };
			refimidx = [12 10 10 10 10 10 10 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end	
		if (sum(strcmp(dates, '2012_02_13')) > 0)
			cd /media/an160508b/2012_02_13/scanimage
			franges = {[327:360], ...
								 [194:230],...
								 [71:100],...
								 [292:322],...
								 [160:192],... % 5
								 [41:70 401:430],...
								 [261:290],...
								 [131:159],...
								 [1:40 368:400],...
								 [231:260],... % 10
								 [101:130],...
								 };
			refimidx = [10 10 10 10 10 10 10 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end	
		if (sum(strcmp(dates, '2012_02_14')) > 0)
			cd /media/an160508b/2012_02_14/scanimage
			franges = {[301:334], ...
								 [185:213],...
								 [41:70 394:410],...
								 [271:300],...
								 [142:183],... % 5
								 [1:40 364:392],...
								 [241:270],...
								 [104:141],...
								 [335:363],...
								 [214:240],... % 10
								 [71:103],...
								 };
			refimidx = [10 10 10 10 10 10 10 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end	
	  if (sum(strcmp(dates, '2012_02_15')) > 0)
			cd /media/an160508b/2012_02_15/scanimage
			franges = {[174:195], ...
								 [40:74],...
								 [261:290],...
								 [142:170],...
								 [1:35 363:377],... % 5
								 [231:260],...
								 [106:140],...
								 [321:362],...
								 [195:230],...
								 [75:104],... % 10
								 [291:320],...
								 };
			refimidx = [10 10 10 10 10 10 10 10 11 10 10];
			breakup_single (franges, refimidx, hdid,an);
		end	
	end
 	%% ========== an160508 END

 	%% ========== an166558
	if (strcmp(an,'an166558'))
	  hdid = '/media/misc_data_1/Layer_4_imaging/an166558';
	  dates = {'2012_05_02'};
	  if (sum(strcmp(dates, '2012_05_02')) > 0)
		  di = find( strcmp(dates, '2012_05_02'));
			cd ([hdid filesep dates{di} filesep 'scanimage']);
			franges = {[2:30], ... % dz = 5
								 [32:60],... % dz  =10
								 [63:90],... % dz = 15
								 [93:120],... % dz = 20
								 [123:150],... % dz = 25
								 };
			refimidx = [15 10 10 10 10];
			breakup_single (franges, refimidx, hdid,an,150:250);
		end	
  end


function breakup_single (franges, refimidx, hdid,an, bifr)
  close all;
  o_str = hdid;
	f_str = ['/groups/svoboda/wdbp/imreg/perons/' an];
	if (nargin < 5) ; bifr = []; end % base image frame range

	fl = dir('*main*tif');
	rootname = fl(1).name(1:max(find(fl(1).name == '_')));
	basename = [rootname '%03d.tif'];
	offs = zeros(1,length(franges));
  
	if (length(strfind(pwd, o_str)) == 0) ; error ('Wrong o_str/f_str ; change!'); end

	for F=1:length(franges)
		flist = [];
		fnames = {} ; 
		for f=franges{F} 
			fnames{length(fnames)+1} = sprintf(basename, f); 
			flist = [flist ',' fnames{length(fnames)}];
		end 
		flist = flist(2:end);
		if (length(flist) > 1)
  		breakup_volume_images(pwd, flist, 4, 1, fnames{refimidx(F)}, offs(F), bifr, 2, ...
	  		0,strrep(pwd,o_str,f_str) , [], F);
		  set(gcf,'Name',['Volume ' num2str(F)]);
		else
		  disp(['breakup_single::skipping ' num2str(F)]);
		end
	end

