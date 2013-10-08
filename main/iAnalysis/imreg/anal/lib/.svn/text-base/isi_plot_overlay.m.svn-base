%
% This will plot the ISI of 2 stimulation positions over the vasculature image.
%
% USAGE:
%
%  isi_plot_overlap(vasc_fname, isi_fnames, isi_nchunks, isi_tags)
%
% PARAMETERS:
%
%  vasc_fname: the file name of the vasculature image (or image itself)
%  isi_fnames: cell w/ two fnames (or 2 cell arrays for multiple/position)
%  isi_nchunks: 2 element vector with how many chunks per image (5 default)
%  isi_tags: labels to assign (default: 'c1','c2')
%
% S Peron Feb 2012
%
function isi_plot_overlap(vasc_fname, isi_fnames, isi_nchunks, isi_tags)
  % --- definitions
	um2pix = .18; % multiply by this to go from microns to pixels
	sdm = 1;


  % --- input parsing
  % default tags if not passed
  if (nargin < 4 || length(isi_tags) < 2)
    tags = {'c1', 'c2'};
  end
	if (nargin < 3 || length(isi_nchunks) < 2)
	  isi_nchunks = [5 5];
	end

  % --- meat

	% load vasculature image
	if (isstr(vasc_fname))
		mm = mean(extern_read_qcamraw([vasc_fname '.qcamraw'],1:5),3);
  else 
	  mm = vasc_fname;
	end
	mm = mm'/max(max(mm)); % orient and normalize 

	% load the two isi images
	isi_im1 = get_qcam_meanmap(isi_fnames{1}, isi_nchunks(1));
	isi_im2 = get_qcam_meanmap(isi_fnames{2}, isi_nchunks(2));
	rim1 = reshape(isi_im1,[],1);
	rim2 = reshape(isi_im2,[],1);
	idx1 = find(isi_im1 < (mean(rim1)-sdm*std(rim1)));
	idx2 = find(isi_im2 < (mean(rim2)-sdm*std(rim2)));

  idx1 = get_connected (isi_im1, idx1, 500);
  idx2 = get_connected (isi_im2, idx2, 500);

	% generate master image
	master_im = zeros(size(mm,1),size(mm,2),3);
  master_im(:,:,1) = mm;
  master_im(:,:,2) = mm;
  master_im(:,:,3) = mm;
	master_im(idx1+prod(size(mm))) = 1;
	master_im(idx2 + prod(size(mm))*2) = 1;
  figure;
	ax = axes;
	imshow(master_im, 'Parent', ax);

	% tags
	hold on;
	text(50,50,tags{1},'color',[0 1 0], 'BackgroundColor', [0 0 0]);
	text(50,100,tags{2},'color',[0 0 1], 'BackgroundColor', [0 0 0]);
	

	% cleanup
	set(ax, 'YDir', 'normal');
  

% returns connected
function idx = get_connected (im, idx, minsize)

	% generate bw images
	bw_im = 0*im ;
	bw_im(idx) = 1;

	% bw label it to get components
	bw_lab = bwlabel(bw_im);

	% take largest
	ul = unique(bw_lab);
	nl = zeros(length(ul),1);
	for l=1:length(ul)
		if(ul(l) > 0)
			nl(l) = length(find(bw_lab == ul(l)));
		end
	end

	good_lab = ul(find(nl > minsize));
  idx = find(ismember(bw_lab, good_lab));

