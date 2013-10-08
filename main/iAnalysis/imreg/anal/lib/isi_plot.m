%
% Plotter for intrinsic imaging data.
%
% This will superimpose markers on top of an image, assuming they were 
%  acquired using the same system.  Specifically, you can give centers for
%  2 barrels (default c1,c2), their string ID, the position of the injector,
%  as well as shape of your injection grid.
%
% USAGE:
%
%  isi_plot(green_fname, c1, c2, tags, omark, show_inj, moffs, affmat, X, Y)
%
% PARAMETERS:
%
%  green_fname: path of file to use as background -- or image
%  c1, c2: 2 element vectors with x/y coordinates of the two barrels [pixels]
%  tags: cell array of what c1,c2 represent. default is {'c1','c2'}
%  omark: where you placed your injector (center coordinate, in pixels).  Note
%         that moffs and X,Y are *relative* to this (i.e., this is 0,0 in um).
%  show_inj: 1 means show injection pattern
%  moffs: additional offset to injection pattern [microns]
%  affmat: affine matrix to apply to all fiducial marks -- this is useful if,
%          e.g., you want to use the 2P image instead of the simultaneously 
%          acquired vasculature image.  All you need to do is compute the affine
%          transform between your two images (for this you need 3 pairs of 
%          points, and compute_affmat).  This variable is the output of
%          compute_affmat.
%  X, Y: coordinates of injectino sites (x and y) [microns]
% 
% Apr 2011 Simon Peron
%
function isi_plot(green_fname, c1, c2, tags, omark, show_inj, moffs, affmat, X, Y)
  % definitions
	um2pix = .18; % multiply by this to go from microns to pixels

  % default tags if not passed
  if (nargin < 4 || length(tags) < 2)
    tags = {'c1', 'c2'};
  end

  % load image
	if (isstr(green_fname))
		mm = mean(extern_read_qcamraw([green_fname '.qcamraw'],1:5),3);
%	imtool(mm'/4000)
  else 
	  mm = green_fname;
	end

  % setup the figure
  figure;
	h = imagesc(mm', [0 4000]) ; 
	ax = get(h, 'Parent');
	colormap gray;
	hold on ; 
  
	% apply affine transform to c1, c2 if needbe
  if (nargin >= 8 && length(affmat) > 0)
  	c1 = affmat*[c1(1) c1(2) 1]';
		c2 = affmat*[c2(1) c2(2) 1]';
  end

  % plot the c1, c2 fiducial marks
	plot(c1(1),c1(2),'mx','LineWidth',5) ; 
	text(c1(1),c1(2)-20,tags{1},'color',[1 0 1]);
  plot(c2(1),c2(2), 'rx', 'LineWidth',5); 
	text(c2(1),c2(2)-20,tags{2},'color',[1 0 0]);
  
	%  can we place the mark for where pipette center waS?
  if (nargin >= 5 && length(omark) == 2) % mark
	  if (nargin >= 8 && length(affmat) > 0)
		  mark = affmat*[omark(1) omark(2) 1]';
    else
      mark = omark;
    end
    plot(mark(1),mark(2), 'yx', 'LineWidth',5); 
  	text(mark(1),mark(2)+20,'(3.6M,1.4P)','color',[1 1 0]);
  end

  % draw injection pattern
  if (nargin >= 6 && show_inj && length(omark) == 2) % hypothetical 
	  if (nargin < 7 || length(moffs) == 0) ; moffs = [0 0]; end
    Y = omark(2) + um2pix*Y + um2pix*moffs(2);
    X = omark(1) + um2pix*X + um2pix*moffs(1);
    for x=1:length(X)
      for y=1:length(Y)
        xx = X(x); 
        yy = Y(y);
        if (nargin >= 8 && length(affmat) > 0)
          vec = affmat*[xx yy 1]';
          xx = vec(1); yy =vec(2);
        end
        plot(xx, yy, 'c.');
      end
    end
  end

	set(ax, 'YDir', 'normal');
  
	% plot line showing anterior and medial direction (based on standard camera
	%  setup in Svoboda Lab in ~2010/11; if this is not true, this is wrong.)
	pd = pwd;
	title(pd(max(find(pd == filesep))+1:end));
  if (nargin >= 8 && length(affmat) > 0)
    ml = affmat*[150 150 1 ; 150 200 1 ; 145 210 1]';
    plot([ml(1,1) ml(1,2)], [ml(2,1) ml(2,2)], 'b-', 'LineWidth', 3);
    text(ml(1,3),ml(2,3),'M', 'color', [0 0 1]);
    ap = affmat*[150 150 1 ; 200 150 1 ; 210 150 1]';
    plot([ap(1,1) ap(1,2)], [ap(2,1) ap(2,2)], 'b-', 'LineWidth', 3);
    text(ap(1,3),ap(2,3),'A', 'color', [0 0 1]);
  else
    plot([50 50], [50 100], 'b-', 'LineWidth', 3);
    text(45,110,'M', 'color', [0 0 1]);
    plot([50 100], [50 50], 'b-', 'LineWidth', 3);
    text(110,50,'A', 'color', [0 0 1]);
  end
