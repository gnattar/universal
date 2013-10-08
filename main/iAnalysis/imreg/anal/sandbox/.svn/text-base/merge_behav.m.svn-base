%
% For merging two behavior files
%
s1 = sessgen_beh('data_@pole_detect_twoport_spobj_an167951_120509a.mat');
s2 = sessgen_beh('data_@pole_detect_twoport_spobj_an167951_120509b.mat');

d2ms = 24*60*60*1000; 

s1_start = datenum(s1.dateStr)*d2ms;
s2_start = datenum(s2.dateStr)*d2ms;

s1_trialTimes = s1.behavESA.trialTimes;
s1_trialTimes(:,2:3) = s1_trialTimes(:,2:3) + s1_start;
for e=1:length(s1.behavESA)
  s1.behavESA.esa{e}.eventTimes = s1.behavESA.esa{e}.eventTimes + s1_start;
end
for e=1:length(s2.behavESA)
  s2.behavESA.esa{e}.eventTimes = s2.behavESA.esa{e}.eventTimes + s2_start;
end

s1.behavESA.esa{1}.plot;
s2.behavESA.esa{2}.plot([0 0 1], [1 2]);

% DO IT OFF OF EPHUS 

% manually make bitcodes non-repetitive...

