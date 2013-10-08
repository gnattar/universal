%
% Hack for plotting across days
%

% assemble
S = {};
if ( 1 == 1 )
	fl = dir('*_sess.mat');
	F = [1 2 3 4 7 8 9 11 12 13 14 15 16 17 18 19]; % 38596
%	F = [2 3 4 5 6 7 8 9 10 14]; %107029
	for f=1:length(F) ; load(fl(F(f)).name) ; S{f} = s; end
end

sA = session.sessionArray(S);


