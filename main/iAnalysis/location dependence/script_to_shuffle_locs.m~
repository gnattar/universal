%% script_to_shuffle_locs
load('pcopy')
temp=pcopy{1}.poleloc;
% temp2=temp(randperm(length(temp),length(temp)));
temp2 = round(1 + (4-1).*rand(length(temp),1));
for d = 1:size(pcopy,2)
pcopy{d}.poleloc = temp2;
end
save('pcopy_locshuffled','pcopy');
