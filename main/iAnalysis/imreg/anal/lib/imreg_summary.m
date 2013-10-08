%
% S Peron 2010 Apr
%
% Gives a summary of image registration for a given directory and wildcard using
%  *{wildcard}*imreg_out files.  Default wildcard is 'Image_Registration_4'.
%
function imreg_summary(root_path, wildcard)

  % --- prelims
  if (nargin == 1)
	  wildcard = 'Image_Registration_4';
	elseif(length(wildcard) == 0)
	  wildcard = 'Image_Registration_4';
	end
	  
  % collect data and such..
  fl = dir([root_path filesep '*' wildcard '*imreg_out']);
	disp(['Found ' num2str(length(fl)) ' files...']);
	if (length(fl) == 0) ; return ; end

  % loop over files
  for f=1:length(fl) ; 
	  load([root_path filesep fl(f).name], '-mat'); 

		% echo if dtheta not 0 -- this is bad for step 4 and implies old data
		if (length(find(dtheta_r ~= 0)) > 0) ; disp('dtheta != 0') ; end

		% dx, dy ean
		mean_dx(f) = mean(mean(dx_r)) ; % in case multiple rows
		mean_dy(f) = mean(mean(dy_r)) ; % in case multiple rows
	end

	% analyze ...
	med_dx = median(mean_dx);
	sd_dx = std(mean_dx);
	med_dy = median(mean_dy);
	sd_dy = std(mean_dy);
	for f=1:length(fl)
	  if (mean_dx(f) > med_dx+3*sd_dx | mean_dx(f) < med_dx-3*sd_dx)
		  disp(['For ' fl(f).name ', dx was abberant.  Check plot.']);
		end
	  if (mean_dy(f) > med_dy+3*sd_dy | mean_dy(f) < med_dy-3*sd_dy)
		  disp(['For ' fl(f).name ', dy was abberant.  Check plot.']);
		end
  end

	% plot mean dx, dy
	figure ;
	subplot(2,2,1);
	plot(mean_dx);
	title('dx');
	subplot(2,2,2);
	plot(mean_dy);
	title('dy');
