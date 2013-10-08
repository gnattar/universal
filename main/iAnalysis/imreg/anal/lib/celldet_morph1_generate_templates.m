%
% S Peron Apr 2010
%
% This will generate a library of templates for celldet_morph1 to use --
%  specified by rad1, rad2, and rad3.
%
% rads is a n x 2 matrix with the inner-most radius of blackness for annuli, OR
%  of the cell if this is a disk.  ths is the thickness -- set to 0 for disks,
%  hals is the surround radius, which is set to -1, and is the "black" cell surround
%  required to match. ['radius', 'thickness', 'halo'].  Angs is the rotation angles
%  to use.
% 
% mat_size is how big each matrix should be.
%
% Returns dil_rads and dets ; dets is a mat_size(1) x mat_size(2) x number of templates
%  matrix containing the templates.  dil_rads gives, for each matrix, the maximal expected
%  radius of objects - good for constraining dilation.  det_rs is the actual detector
%  radius, for sorting by size. dets_str is a description of the detector
%
function [dets dil_rads det_rs dets_str] = celldet_morph1_generate_templates(rads, ths, hals, angs, mat_size)

	% center compute -- 1/2 of matrix
	cen = ceil(mat_size/2);

  % single rads vector? then all combos
	size(rads)
	if (min(size(rads)) == 1)
	  if (size(rads,1) ~= 1) ; rads = rads'; end
	  nrads (:,1) = repmat(rads,1,length(rads));
		nrads(:,2) = reshape(repmat(rads,length(rads),1),[],1)';
		rads = nrads
	end

  % final prep
	n_dets = length(angs)*size(rads,1)*length(ths)*length(hals);
	dets = zeros(mat_size(2), mat_size(1), n_dets);

  % the build loop
	n = 1;
	dil_rads = []; % dilation radii
%	figure;
	for r=1:size(rads,1)
	  rad1 = rads(r,:);
		for t=1:length(ths)
		  th = ths(t);
		  rad2 = rad1 + th;
			for h=1:length(hals)
			  hal = hals(h);
				rad3 = rad2+hal;
				for a=1:length(angs) 
				  % skip if uniform
					if (a > 1) 
					  if (rad1(1) == rad1(2))  
						  disp('celldet_morph1::no rotating circles'); 
							n_dets=n_dets-1; 
							continue ; 
						end
					end
					% customannularfilter takes things in a WIDTH,HEIGHT way ; the OPPOSITE of most MATLAB
					if (th(1) > 0) % annulus
						det = customannularfilter(mat_size, rad1 , rad2, rad3, cen, angs(a));
						dil_rads = [dil_rads rad1(2)];
						det_rs(n) = max(rad2);
						dets_str{n} = ['ANN in X,Y direction, inner rads: ' num2str(rad1(1)) ', ' num2str(rad1(2)) ' thick: ' num2str(th(1)) ' halo: ' num2str(hal(1)) ' ' num2str(angs(a))];
					else % disk
						det = customannularfilter(mat_size, [0 0] , rad1, rad3, cen, angs(a));
						dil_rads = [dil_rads 0];
						det_rs(n) = max(rad2);
						dets_str{n} = ['DISK in X,y direction, inner rads: ' num2str(rad1(1)) ', ' num2str(rad1(2)) ' halo: ' num2str(hal(1)) ' ' num2str(angs(a))];
				  end

					dets(:,:,n) = det;
					n = n+1;
				end
			end
		end
	end

  % drop the unused part
	fdets = zeros(mat_size(2), mat_size(1), n_dets);
	fdets = dets(:,:,1:n_dets);
	dets = fdets;
