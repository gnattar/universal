%
% [im_c affmat_r E] = imreg_affine(im_s, im_t, fit_opt, opt)
%
% Given two images, finds optimal affine transform to maximize image
%  correlation.
%
%  Returns the corrected image -- im_s is source image, im_t is 
%   target image (i.e., shifts source so it fits with target). 
%   Note that im_s can be a stack; in this case, the affine fit is
%   performed frame-by-frame, with the previous frame serving as the
%   intial guess for the next frame.  im_c will also be a stack.
%
%  Also returns the affine transform matrix/matrices, where affmat_r(:,:,n)
%   is the affine transform matrix for the nth frame (3x3).
%
%  E is an error metric.
%
% fit_opt - structure defining the optimization:
%    lb, ub: for each element (top 2 rows only!) of affine matrix,
%            lower and upper bounds, respectively.  If lb == ub, then
%            this implies that the particular element should be fixed (e.g.,
%            to do pure translation, set lb = [1 0 mx 0 1 my] and ub
%            to [1 0 Mx 0 1 My] where mx, Mx are min and max x; same for y.
%            Note that lb(1:3) and lb(4:6) are the first and second row
%            of the affine transform matrix.
%    nsteps: how many steps to take AT MOST
%    ndivs: how many divisions used for each variable FOR EACH STEP
%    optim_type: 1 - use a brute search of parameter space, using ndivs per variable
%                    this results in ndivs^nvars tests PER STEP
%                2 - use a gradient descent method (2^nvars tests per step)
%    err_thresh: since correlation is currently used as the error metric, this
%                is the value ABOVE which it will stop convergence regardless
%                of whether nsteps is reached
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.
%        debug: set to 1 to get messages out the wazoo (default = 0)
%        wb_on: set to 1 to have a waitbar (default = 0)
%
function [im_c affmat_r E] = imreg_affine(im_s, im_t, fit_opt, opt)

  % opt check:
  if (length(opt) == 0) % defaults
	  opt.debug = 0;
	  opt.wb_on = 0;
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'debug') == 0)
		  opt.debug = 0;
		end
	  if (isfield(opt,'wb_on') == 0)
		  opt.wb_on= 0;
		end
	end

	% --- variable defaults 
	o_lb = fit_opt.lb;
	o_ub = fit_opt.ub;
	o_rng = (o_ub-o_lb); % size of our parameter sampling
	nsteps = fit_opt.nsteps;
	ndivs = fit_opt.ndivs;
	optim_type = fit_opt.optim_type;
	err_thresh = fit_opt.err_thresh;
	E = [];
	wb_on = opt.wb_on; % wait abr?
  sim = size(im_s); % size
	im_c = zeros(size(im_s)); % final image
	affmat_r = zeros(3,3,size(im_s,3)); % final affine matrix
	aaopt.debug = 0; % no debug in apply_afine
	aaopt.interp = 0; % no interpolation for finakl image
	if (length(sim) == 3) 
	  nframes = sim(3);
	else 
	  nframes = 1;
	end

  % --- main loop -- do this frame-by-frame
	used = ~ (o_lb == o_ub); % if they are same, NOT used ; if different, USED
	if (wb_on) ; wb = waitbar(0, 'Performing affine image registration...'); end
	ub = o_ub;
	lb = o_lb;
	best_vals = [];
	for f=1:nframes

		% setup the 'center' of your test space using last step, if possible
		if (length(best_vals) > 0) % after step 1 this is true
			for l=1:6
				lb(l)=best_vals(l)-(o_rng(l)/2);
				ub(l)=best_vals(l)+(o_rng(l)/2);
			end
		end

		% show the seed lb/ub
		if (opt.debug == 1)
			disp(['Initial guess for frame ' num2str(f) ' LB: ' num2str(reshape(lb,1,[])) ' UB: ' num2str(reshape(ub,1,[]))]);
		end

		% --- intra-frame loop === where the magic happens
    for s=1:nsteps
		  if (optim_type == 1) % 'brute force' search o

				% the number of tests is determined by the number of free parameters raised to the power of number of divisions per parameter
				ntests = ndivs^length(find(used == 1));

				% precompute a matrix with ALL the values you will try
				test_val_mat = zeros(6,ntests);

				% determine candidate values for each field
				vals = zeros(6,ndivs);
				for l=1:6
					if (used(l))
						vals(l,:) = linspace(lb(l),ub(l),ndivs);
						uni(l).vals = vals(l,:);
					else
						vals(l,:) = lb(l);
						uni(l).vals = lb(l);
					end
				end

				% initial guess for step output
				if (opt.debug == 1)
					disp(['Initial guess for step ' num2str(s) ' LB: ' num2str(reshape(lb,1,[])) ' UB: ' num2str(reshape(ub,1,[]))]);
				end


				% construct your matrix of values to test
				mi = 1;
				for f1=1:length(uni(1).vals)
					f1_val = vals(1,f1);
					for f2=1:length(uni(2).vals)
						f2_val = vals(2,f2);
						for f3=1:length(uni(3).vals)
							f3_val = vals(3,f3);
							for f4=1:length(uni(4).vals)
								f4_val = vals(4,f4);
								for f5=1:length(uni(5).vals)
									f5_val = vals(5,f5);
									for f6=1:length(uni(6).vals)
										f6_val = vals(6,f6);
										test_val_mat(:,mi) = [f1_val f2_val f3_val f4_val f5_val f6_val];
										mi = mi+1;
									end
								end
							end
						end
					end
				end

				% --- run the tests!!
				err_v = zeros(1,size(test_val_mat,2));
				if(opt.debug == 1) ; tic; end
				ctime = 0;
				for m=1:size(test_val_mat,2)
          err_v(m) = compute_affine_err(im_s(:,:,f), im_t, test_val_mat(:,m));
					if (opt.debug == 1) 
					  disp(['values: ' num2str(test_val_mat(:,m)') ' err_v: ' num2str(err_v(m))]);
						ctime = ctime + toc;
						tic;
						tstep = (ctime/m)*size(test_val_mat,2);
					 % disp(['Time elapsed this step: ' num2str(ctime) ' seconds. Est. length THIS step (min)' num2str(tstep/60)]);
					 % disp(['TOTAL est. time (hours): ' num2str(tstep*nsteps*nframes/60/60)]);
					end
					if (err_v(m) >= err_thresh) % break if met
					  if (opt.debug) ; disp('****THRESHOLD SATISFIED; terminating step'); end
					  break;
					end
				end

				% --- based on results, re-jigger your parameter space for next step
				[best_corr best_idx] = max(err_v);
				
				best_vals = test_val_mat(:,best_idx);
	      if (best_corr >= err_thresh) % error threshold met? then we are done for this frame
				  break;
				else % setup next step otherwise
					dv = (ub-lb)/(ndivs-1);
					for l=1:6
						if (used(l)) % simply re-apportion the lb/ub so that now you sample 1.5 division around the best value
							lb(l)=best_vals(l)-1.5*dv(l);
							ub(l)=best_vals(l)+1.5*dv(l);
						end
					end
				end
			end % steps end
		end % frames end

		% assign final variables
	  if (wb_on) ; waitbar(f/nframes,wb); end
		E(f) = best_corr;
		if (opt.debug == 1)
		  disp(['********** BEST values: ' num2str(best_vals') ' corr: ' num2str(best_corr)]);
		end
		affmat_r(:,:,f) = [best_vals(1:3)' ; best_vals(4:6)' ;  0 0 1]; % construct final affine matrix to build im_c
		im_c(:,:,f) = apply_affmat(im_s(:,:,f), affmat_r(:,:,f), aaopt);
	end
	if (wb_on) ; delete(wb); end

	% --- send to imreg_wrapup 
  [im_c E] = imreg_wrapup (im_s, im_t, [], [], [], affmat_r, [], []);

%
% This function will compute the affine transform, affmat, for the image im_s, 
%  then compute an error metric versus im_t. (im_s -- source image ; im_t -- target
%  in traditional image registration parlance.)
%
% Notethat affmat_v is a VECTOR representation of the first TWO rows of a 3x3 2d
%  affine transform matrix used for multiplication.
%
function err = compute_affine_err(im_s, im_t, affmat_v)
  % --- build a true blue affine matrix
	affmat = [affmat_v(1:3)' ; affmat_v(4:6)' ; 0 0 1];
 

  % --- get the transformed image ; construct options for apply affmat
  opt.debug = 0;
  opt.interp = 0;
  im_a = apply_affmat(im_s, affmat, opt);

	% --- compute error metric ...
	imsl = reshape(im_t,1,[]);
	imcl = reshape(im_a,1,[]);
	val = find(imcl ~= 0);
	if (length(val) < 2)
	  err = 0;
	else 
		R = corrcoef(imsl(val),imcl(val));
		err = R(1,2);
	end

	if (isnan(err)) ; err = 0 ; end % not-a-number? ZERO corelation



