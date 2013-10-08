%
% S Peron 2010 Mar
%
% Applies an affine transform matrix to an image, returning transformed image.
%
% USAGE:
%
%  im_a = apply_affmat(im_s, affmat, opt)
%
% im_a is the transformed image and im_s is the original image.  affmat is the 3x3 
%  affine transform matrix (the bottom 0 0 1 row is required).  The image is the same
%  size as im_a and, in fact, only the coordinates populated are returned - that is,
%  if you move the image "off" the original image via transform, those pixels will be
%  set to a value of 0.
%
% opt.debug: 1 = on
% opt.interp: 0 = none ; 1 = linear
% 
function im_a = apply_affmat(im_s, affmat, opt)

  % - prelims
	S = size(im_s);
  im_a = zeros(size(im_s));

	% - determine coordinate transform
  xrow = repmat(1:S(2), 1, S(1));
  yrow = reshape(repmat(1:S(1),S(2),1),1,[]);
  orow = ones(size(yrow));

	% - apply it
	new_coord_mat = affmat*[xrow;yrow;orow];
	new_x = new_coord_mat(1,:);
	new_y = new_coord_mat(2,:);

	% - convert to indices to make new image ...
  val = find (new_x <= S(2) & new_x > 0 & new_y > 0 & new_y <= S(1));
	old_idx = yrow + S(1)*(xrow-1);
	new_idx = new_y + S(1)*(new_x-1);

  % - for now, this ; if linear interpolation is implemented this iwll change
	new_idx = round(new_idx); 
	old_idx = round(old_idx); 

  % - and also constrain indices
  oi_val = find(old_idx > 0);
  ni_val = find(new_idx > 0);
	val = intersect(val,oi_val);
	val = intersect(val,ni_val);

  % - and do it
	im_a (old_idx(val)) = im_s(new_idx(val));




