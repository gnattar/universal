%
% Run after sessgen2 to update trials etc.
%
function sessgen2_supp(an)

  rootPath = ['/media/an' an '/an' an '/session2/']
	cd (rootPath);
	sessList = dir([rootPath filesep 'an' an '*sess.mat']);
	S = {};

	parfor si=1:length(sessList)
  	sessrun([rootPath filesep sessList(si).name]);
	end

	for si=1:length(sessList)
		load ([rootPath filesep sessList(si).name]);
		S{si} = s;
	end
	sA = session.sessionArray(S); 
	sA.saveToFile([rootPath filesep 'an' an '_allDays.mat']);


function sessrun(sessPath)
  load (sessPath);
  if (strcmp(s.mouseId,'an38596'))
		caTSA = s.caTSA;
		if (length(strfind(s.dateStr, '02-Feb')) > 0)
			caTSA.blankTrials(250, [22 62 63 73 87 95 107 114 117 122 125 129 142 144 152 153 159 160 171 59 68 77 82 102 175 176 184]);
		end
		if (length(strfind(s.dateStr, '03-Feb')) > 0)
			caTSA.blankTrials(250, 207:210);
			caTSA.blankTrials(159, [3:39 203:208]);
			caTSA.blankTrials(187, [201 203 202]);
			caTSA.blankTrials(186, 203);
			s.deleteCalciumTrials(207:215);
		end
		if (length(strfind(s.dateStr, '04-Feb')) > 0)
		  params.svdCorrelationPeakOffs = 0;
		end
		if (length(strfind(s.dateStr, '05-Feb')) > 0)
			s.deleteCalciumTrials([210 227 228]);
		end
		if (length(strfind(s.dateStr, '08-Feb')) > 0)
			caTSA.blankTrials(250, [320 316 315 314 313]);
		end
		if (length(strfind(s.dateStr, '09-Feb')) > 0)
			caTSA.blankTrials(250, [118 117 124]);
		end
		if (length(strfind(s.dateStr, '11-Feb')) > 0)
		  params.svdCorrelationPeakOffs = -1;
		end
		if (length(strfind(s.dateStr, '16-Feb')) > 0)
			caTSA.blankTrials(250, [315 325]);
		  params.svdCorrelationPeakOffs = -1;
		end
		if (length(strfind(s.dateStr, '17-Feb')) > 0)
			caTSA.blankTrials(250, [131 269:302]);
			s.deleteCalciumTrials([69:92]);
		end
		if (length(strfind(s.dateStr, '19-Feb')) > 0)
			caTSA.blankTrials(250, [24 26 80 20 81]);
		end
		if (length(strfind(s.dateStr, '20-Feb')) > 0)
			caTSA.blankTrials(72, 80:86);
			caTSA.blankTrials(250, [52 85 86] );
		  params.svdCorrelationPeakOffs = -1;
		end
		if (length(strfind(s.dateStr, '22-Feb')) > 0)
			caTSA.blankTrials(208, [304 308 235 153 340 293 257 245 242 183 203 171]);
		end
		if (length(strfind(s.dateStr, '01-Mar')) > 0)
			caTSA.blankTrials(250, [233 252] );
		end
		if (length(strfind(s.dateStr, '03-Mar')) > 0)
			caTSA.blankTrials(72, 162:165);
		end
	end

  if (strcmp(s.mouseId,'an107028'))
		caTSA = s.caTSA;
		if (length(strfind(s.dateStr, '04-Aug')) > 0)
			s.deleteCalciumTrials(49);
		end
		if (length(strfind(s.dateStr, '26-Aug')) > 0)
			caTSA.blankTrials(143, 88:89);
		end 
	end

  if (strcmp(s.mouseId,'an94953'))
		caTSA = s.caTSA;
		if (length(strfind(s.dateStr, '31-Mar')) > 0)
			s.deleteCalciumTrials([83:103]);
		end
		if (length(strfind(s.dateStr, '01-Apr')) > 0)
			caTSA.blankTrials(306,[165 169 188 223]);
		end
		if (length(strfind(s.dateStr, '05-Apr')) > 0)
			caTSA.blankTrials(306,[116 252 263 259 274 237 258]);
		end
		if (length(strfind(s.dateStr, '09-Apr')) > 0)
			s.deleteCalciumTrials(116);
		end
		if (length(strfind(s.dateStr, '14-Apr-2010 10:41:34')) > 0)
			caTSA.blankTrials(269, 245);
			caTSA.blankTrials(17, 245);
		end
		if (length(strfind(s.dateStr, '19-Apr-2010 14:49')) > 0)
			caTSA.blankTrials(306, [207 296 297]);
		end
	end

  if (strcmp(s.mouseId,'an107029'))
		caTSA = s.caTSA;
		if (length(strfind(s.dateStr, '03-Aug')) > 0)
			caTSA.blankTrials(327, 107:108);
		end
		if (length(strfind(s.dateStr, '06-Aug')) > 0)
			caTSA.blankTrials(219, 265:325);
			caTSA.blankTrials(190, [321 325] );
		end
		if (length(strfind(s.dateStr, '16-Aug')) > 0)
			caTSA.blankTrials(145, [10 11 13 15 17 21 127:183]);
		end
		if (length(strfind(s.dateStr, '19-Aug')) > 0)
			caTSA.blankTrials(318,[99:166]);
			caTSA.blankTrials(309,[99:166]);
		end
		if (length(strfind(s.dateStr, '20-Aug')) > 0)
			caTSA.blankTrials(145,[2:251]);
		end
		if (length(strfind(s.dateStr, '21-Aug')) > 0)
			caTSA.blankTrials(145,[28:125 150]);
		end
		if (length(strfind(s.dateStr, '22-Aug')) > 0)
			caTSA.blankTrials(145,[20:132]);
		end
	end

	% SVD thingy
	va = find(~isnan(s.derivedDataTSA.getTimeSeriesById(1).value));
	[irr ia ib] = intersect(s.derivedDataTSA.time(va), s.caTSA.time);
	params.svdIndicesVec = ib;
	params.svdCorrelationVec = s.derivedDataTSA.getTimeSeriesById(1).value(va(ia))';
	caTSA.runBestPracticesDffAndEvdet(params);

	% save
	s.saveToFile();
