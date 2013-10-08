%
% stupid wrapper
%
function plot_multi_fov(ims, imrange)
  f=  figure('Position', [0 0 900 900]);
	spx = [0 .50 0 .50] ;
	spy = [.50 .50 0 0];

  if (nargin < 2)
	  imrange = [0 0];
	  for fov=1:4
		  infidx = find(isinf(ims{fov}));
		  notinfidx = find(~isinf(ims{fov}));
			ims{fov}(infidx) = max(reshape(ims{fov}(notinfidx),[],1));
		  imrange(1) = min(imrange(1),min(reshape(ims{fov},[],1)));
		  imrange(2) = max(imrange(2),max(reshape(ims{fov},[],1)));
		end
	end

	for fov=1:4
	  sp = subplot('Position',[spx(fov) spy(fov) 0.5 0.5]);
		imshow(ims{fov}, imrange, 'Parent', sp);
	end
