barr_cen = [];

if (length(strfind(pwd, '167951')) == 1)
	barr_cen = [320 200];
	d_2to1 = [294 165];
elseif (length(strfind(pwd, '171923')) == 1)
	barr_cen = [230 270];
	d_2to1 = [93 -267];
end

fov_1 = find(roi_vol(:,1) < 9);
fov_2 = find(roi_vol(:,1) >= 9);

n_roi_centers = roi_centers;
n_roi_centers(fov_2,:) = n_roi_centers(fov_2,:) + repmat(d_2to1,length(fov_2),1);

if (0) % DEBUG
  figure ; 
	plot(n_roi_centers(:,1), n_roi_centers(:,2), 'r.');
  set(gca,'YDir','reverse');
end

d_cen = 0*roi_ids;
for r=fov_1'
  d_cen(r) = sqrt((n_roi_centers(r,1) - barr_cen(1))^2 + (n_roi_centers(r,1) - barr_cen(1))^2 );
end


for r=fov_2'
  d_cen(r) = sqrt((n_roi_centers(r,1) - barr_cen(1))^2 + (n_roi_centers(r,1) - barr_cen(1))^2 );
end

feat_value = abs(feat_value);
vals = find(feat_value > .025);
if (length(strfind(feat_name, 'AUC')) > 0)
	vals = find(feat_value > .5);
end
if (length(strfind(feat_name, 'PProd')) > 0)
	vals = find(feat_value > .035);
end

figure('Position',[0 0 600 1200]);;
subplot(2,1,1);
plot(d_cen, feat_value,'r.');
hold on;
plot(d_cen(fov_2), feat_value(fov_2),'b.');
plot(d_cen(vals), feat_value(vals),'ko');
title(['Raw data: ' feat_name]);

subplot(2,1,2);
hold on;
ws = 25;
d_bins = 0:ws:floor(max(d_cen)/ws)*ws;

mus = 0*d_bins(1:end-1);
meds = 0*d_bins(1:end-1);
sds = 0*mus;
q25 = 0*mus;
q75 = 0*mus;
q05 = 0*mus;
q95 = 0*mus;
for b=1:length(d_bins)-1
  val_ds = find(d_cen >= d_bins(b) & d_cen < d_bins(b+1));
	val = intersect(vals,val_ds);

	mus(b) = mean(feat_value(val));
	meds(b) = median(feat_value(val));
	sds(b) = std(feat_value(val));
	ses(b) = std(feat_value(val))/sqrt(length(val));
	q25(b) = quantile(feat_value(val),.25);
	q75(b) = quantile(feat_value(val),.75);
	q05(b) = quantile(feat_value(val),.05);
	q95(b) = quantile(feat_value(val),.95);
end

color = [1 0 0];
plot_with_errorbar(d_bins(1:end-1)+ws/2, mus,ses, color);
%plot_with_errorbar2(d_bins(1:end-1)+ws/2, mus,q95-mus,mus-q05, color);
plot(d_bins(1:end-1)+ws/2, mus, 'Color', color);
title(['Binned data: ' feat_name]);

