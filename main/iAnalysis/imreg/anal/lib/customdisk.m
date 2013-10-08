%
% S Peron MAr 2010
%
% Returns a strel-style structural element for an ellipse - contains 1s where
%  the disk is, 0s elsewhere
%
%  mat_size: 2-element vector specifying size of returned matrix
%  rad: radius of the disk in the two directions
%  center: center of the disk in x,y
%  ang: angle (in degrees) ; above 90 makes no sense since you control both radii
%
%  For mat_size. rad, and center the first number is in the HORIZONTAL (x) direction
%   ans the second is in the VERTICAL (y) direction.
%
% USAGE:
%  disk = customdisk(mat_size, rad, center, ang)
%
function disk = customdisk(mat_size, rad, center, ang)

  % --- prelims
  if (length(ang) > 0)
	  if (ang ~= 0)
			disp('customdisk::angle not yet implemented');
		end
	end

	% --- generate
	disk = zeros(mat_size);
	[x y] = meshgrid(1:mat_size(1), 1:mat_size(2));
	x = x';
	y = y';
	ell = ((x-center(1)).^2)/(rad(1)*rad(1)) + ((y-center(2)).^2)/(rad(2)*rad(2));
	disk(find(ell <= 1)) = 1;
	disk = disk';
%figure;  subplot(2,2,1);	imshow(x, [0 max(max(x))]); subplot(2,2,2);	imshow(y, [0 max(max(y))]); subplot(2,2,3); imshow(ell); subplot(2,2,4) ; imshow(disk);


