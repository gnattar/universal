%
% S Peron 2010 Mar
% 
% This generates a custom annular filter for convolutions ; 1, 0, and -1
%  Specifically, annulus is between rad1 and rad 2, and is 1, while rad3
%  lets you specify a 'halo' of also -1 (which is what is in rad1).  If you
%  set rad1 to 0, no inside; if you set rad3=rad2, no halo.
%
%  mat_size: size of the returned matrix in x,y (width, height)
%  rad1,2,3: see above; in x y (i.e., radius does not need to be symmetric)
%  center: center, in x,y ; default is dead middle (if [])
%  ang: angle (CW) rotated before return, about center
%
% Note: ALL parameters are in (width, height) // x,y, which is basically the opposite
%  of standard matrix row,column -- what MATLAB uses -- so if you are doing this
%  with imshow, be aware!
%
% USAGE:
%  ann = customannularfilter(mat_size, rad1, rad2, rad3, center, ang)
%
function ann = customannularfilter(mat_size, rad1, rad2, rad3, center, ang)
  % --- prelims
  if (length(center) == 0)
	  center = floor(mat_size/2)+1;
	end

	% --- compute the individual disks
	if (rad1(1) > 0 ) 
		disk1 = customdisk(mat_size, rad1, center, 0);
	else % no inside - a disk then
	  disk1 = zeros(mat_size)';
	end
  disk2 = customdisk(mat_size, rad2, center, 0);
  disk3 = customdisk(mat_size, rad3, center, 0);

  % --- construct annulus
	ann = zeros(mat_size)';
	if(sum(rad2 == rad3) ~= 2) % outside halo
	  ann(find(disk3 == 1)) = -1;
  end
	ann(find(disk2 == 1)) = 1;
	ann(find(disk1 == 1)) = -1;

	% --- rotate it 
	if (length(ang) > 0)
	  if (ang ~= 0)
		  ann = imrotate(ann, -1*ang, 'crop'); % ensure CW rotation
		end
	end
