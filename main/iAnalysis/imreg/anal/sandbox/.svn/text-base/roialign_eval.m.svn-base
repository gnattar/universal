clear all;
clear all classes; 
load roialign_scores.mat;
if (iscell(scores))
	scores = cell2mat(scores);
end

if (exist('roialign_accept.mat','file'))
  load('roialign_accept.mat');
else
  accept = -1 + 0*scores;
end

[sscores sidx] = sort(scores,'descend');

for i=sidx
  if (accept(i) > -1) ; continue ; end % SKIP DONE
  base_fn = base{i};
	[a b c] = fileparts(tested{i});
	tested_fn{i} = [b '.mat'];

	load(base_fn);
	rBase = obj;
	load(tested_fn{i});
	rTested = obj;

  outlierIds = rBase.getAlignmentOutliers(rTested);
	outlierIdx = find(ismember(rBase.roiIds,outlierIds));
	for r=outlierIdx ; rBase.rois{r}.color = [1 1 0]; end

	rBase.plotInterdayTransform(rTested);
	set(gcf, 'Position' , [5 1 1916 1128]);
	for r=outlierIdx ; rBase.rois{r}.color = [1 0 0.5]; end
	
	disp(['============================ ' num2str(length(find(accept > -1))) ' / ' num2str(length(accept)) ' done ; ' num2str(length(find(accept == 0))) ' rejections ===================']);
	disp(['Considering: ' rTested.idStr ' Score: ' num2str(scores(i)) ' # outliers: ' num2str(length(outlierIds))]);
	if (length(outlierIds) > 0) ; beep ; end
	resp = lower(input('Accept (just hit enter), fix outliers (f), or reject (input a letter)? ', 's'));
	accept(i) = 0;
  if (length(resp) == 0)  
	  accept(i) = 1; 
	elseif (resp == 'f')
	  rTested.correctAlignmentOutliers(rBase);
		rTested.saveToFile(rTested.roiFileName(max(find(rTested.roiFileName == '/'))+1:end));
	else 
	  disp ([tested_fn{i} ' REJECTED!']); 
	end
	close all;
	
  save('roialign_accept.mat', 'tested_fn', 'accept');
end

% rejection stats . . . 
ubase = unique(base);
for f=1:length(ubase)
  fi = strfind(ubase{f},'fov');
  mi = strfind(ubase{f},'.mat');
  fov{f} = ubase{f}(fi+4:mi-1);

  match = [];
	for t=1:length(tested)
	  if(length(strfind(tested{t},['fov_' fov{f}])) == 1)
		  match = [match t];
		end
	end
  fov_list{f} = match;
end

for t=1:length(tested)
  ui = find(tested{t} == '_');
  date_t{t} = tested{t}(ui(1)+1:ui(4)-1);
end
dates = unique(date_t);
for d=1:length(dates)
  date_list{d} = find(strcmp(date_t, dates{d}));
end

accept_idx = find(accept);

% rejections by FOV
figure;
n_accept = zeros(1,length(fov_list));
n_reject = zeros(1,length(fov_list));
for f=1:length(fov_list);
  n_accept(f) = length(find(ismember(fov_list{f}, accept_idx)));
  n_reject(f) = length(find(~ismember(fov_list{f}, accept_idx)));
end
frac_accepted = n_accept./(n_accept + n_reject);
plot(frac_accepted, 1:length(fov_list), 'b.');

text_x = min(frac_accepted) - 0.3*range(frac_accepted);
for f=1:length(fov_list)
  text(text_x, f, fov{f});
end

axis([ min(frac_accepted) - 0.4*range(frac_accepted) min(frac_accepted) + 1.1*range(frac_accepted) 0 length(fov_list)+1]);
set (gca,'TickDir','out', 'YTick',[], 'YDir' ,'reverse');
xlabel('Fraction of days kept');

% rejections by FOV
figure;
plot(n_accept, 1:length(fov_list), 'r.');

text_x = min(n_accept) - 0.3*range(n_accept);
for f=1:length(fov_list)
  text(text_x, f, fov{f});
end

axis([ min(n_accept) - 0.4*range(n_accept) min(n_accept) + 1.1*range(n_accept) 0 length(fov_list)+1]);
set (gca,'TickDir','out', 'YTick',[], 'YDir' ,'reverse');
xlabel('Number of days kept');

% rejections by date
figure;
n_accept = zeros(1,length(date_list));
n_reject = zeros(1,length(date_list));
for d=1:length(date_list);
  n_accept(d) = length(find(ismember(date_list{d}, accept_idx)));
  n_reject(d) = length(find(~ismember(date_list{d}, accept_idx)));
end
frac_accepted = n_accept./(n_accept + n_reject);
plot(1:length(date_list), frac_accepted, 'b.');

text_y = min(frac_accepted) - 0.3*range(frac_accepted);
for d=1:length(date_list)
  text(d, text_y, strrep(dates{d},'_','-'), 'Rotation' , -90);
end

axis([0 length(dates)+1  min(frac_accepted)-0.7*range(frac_accepted) min(frac_accepted)+1.1*range(frac_accepted)]);
set (gca,'TickDir','out', 'XTick',[]);
ylabel('Fraction of planes kept');









