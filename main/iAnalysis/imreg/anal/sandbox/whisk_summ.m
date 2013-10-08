fl = dir('2012*-1');
rootDir = pwd;
for f=1:length(fl)
  cd ([rootDir filesep fl(f).name]);
	if (~exist([pwd filesep 'whiskingSummary.pdf'],'file'))
		session.whiskerTrial.generateSummaryPDF();
	end
end
