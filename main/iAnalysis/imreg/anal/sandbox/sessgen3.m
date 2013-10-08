% SUPPLMENETAL:
an = 'POOP';
S = {};
fl=dir('*_sess.mat');
for f=1:length(fl) ; load(fl(f).name) ; S{f} = s; end
sA = session.sessionArray(S);
sA.saveToFile([an '_allDays.mat']);
sA.evalForAll('caTSA.generateActivityFreeImage();');
sA.evalForAll('saveToFile()');
