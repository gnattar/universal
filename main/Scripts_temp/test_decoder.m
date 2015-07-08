function []= test_decoder(pooled_contactCaTrials_locdep)
tk = cell2mat(cellfun(@(x) x.totalKappa_epoch_abs, pooled_contactCaTrials_locdep,'uniformoutput',0));
pl = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
resp = cell2mat(cellfun(@(x) x.sigpeak, pooled_contactCaTrials_locdep,'uniformoutput',0));

pl = pl(:,1);
[vals,plid,valsid] = unique(pl);
p = [ 18.0 12.0 10.5 9.0 7.5 6.0];
pos = p(valsid)';

num_tests = 1000;
dist_aligned = zeros(num_tests,1);
dist_shuffpos = zeros(num_tests,1);
figure;
%% distance for aligned test sets
for s = 1:num_tests
test = randperm(696,50)';
S = resp(test,:)./tk(test,:);
Y = resp./tk;
class = classify(S,Y,pos);
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_aligned (s ,1) = sum(dist);
% plot(actual); hold on; plot(class,'r'); hold off;
end

%% distance for shuff pos test sets
for s = 1:num_tests
test = randperm(696,50)';
shuff1 = randperm(696,696)';shuff2 = randperm(696,696)';
S = resp(test,:)./tk(test,:);
Y = resp(shuff1,:)./tk(shuff1,:);
class = classify(S,Y,pos(shuff2,1));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_shuffpos (s ,1) = sum(dist);
% plot(actual); hold on; plot(class,'r');hold off;
end

%% distance for tk test sets
for s = 1:num_tests
test1 = randperm(696,50)';
test2 = randperm(696,50)';
shuff3 = randperm(696,696)';shuff4 = randperm(696,696)';
S = resp(test1,:)./tk(test2,:);
Y = resp(shuff3,:)./tk(shuff4,:);
class = classify(S,Y,pos(shuff3,1));
actual = pos(test1,1);
dist = sqrt((actual - class).^2);
dist_shufftk (s ,1) = sum(dist);
% plot(actual); hold on; plot(class,'r');hold off;
end
figure;plot(dist_aligned); hold on; plot(dist_shuffpos,'g'); plot(dist_shufftk,'k');

