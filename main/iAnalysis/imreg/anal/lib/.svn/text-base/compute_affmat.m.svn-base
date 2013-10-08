%
% S Peron Apr 2010
%
% Given a set of 3 point pairs - in source and target space - it will compute 
%  the affine matrix that, when applied to a set of coordinates, will take it
%  frou *source* space into *target* space.
%
% usage:
%
%  affmat = compute_affmat(p_s, p_t)
%
% affmat: your affine matrix
% p_s: source points [x1 y1 x2 y2 x3 y3]
% p_t: target points [x1 y1 x2 y2 x3 y3]
%
function affmat = compute_affmat(p_s, p_t)

	% setup linear system
	M = [p_s(1) p_s(2) 1 0 0 0 ; 0 0 0 p_s(1) p_s(2) 1 ; p_s(3) p_s(4) 1 0 0 0 ; ...
			 0 0 0 p_s(3) p_s(4) 1 ; p_s(5) p_s(6) 1 0 0 0 ; 0 0 0 p_s(5) p_s(6) 1];

	% solve it
	M_inv = inv(M);
	v_aff = M_inv*p_t';

	% construct affine matrix
	affmat = [v_aff(1:3)' ;  v_aff(4:6)' ; 0 0 1];

	% --- for your viewing pleasure, decompose the matrix into rotation, 
	%     translation, shear and scaling
	trans_x = affmat(7);
	trans_y = affmat(8);

	submat = [v_aff(1:2)' ; v_aff(4:5)'];
	[q r] = qr(submat);

	rot_ang = acosd(q(2,2)); % cw rotation 

	scal_x = r(1,1);
	scal_y = r(2,2);

	shear = r(1,2);

	disp(['Decomposed affine matrix: translation x,y: ' num2str(trans_x) ',' num2str(trans_y) ...
				 ' rotation angle (CW): ' num2str(rot_ang) ' scaling x,y: ' num2str(scal_x) ',' num2str(scal_y) ...
				 ' shearing factor: ' num2str(shear)]);
	
