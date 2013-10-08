%
% S PEron Feb 2010
%
% This is basically a fancy wrapper for imwrite.  This way, all calls to imwrite
%  can be modified simultaneously when, e.g., the header is changed.
%
%  For now, it writes uint16 TIFF files only.
%
%  function save_image(stack, path, header)
%  
%      stack - the image stack ; can be single or multi frame
%      path - where to put it
%      header - this is put in Description by imwrite
%
function save_image(stack, path, header)
  
   % --- the write
	 imwrite(uint16(stack(:,:,1)), path, 'tif', 'Compression', 'none', 'WriteMode', 'overwrite', 'Description', header);
	 if (length(size(stack)) > 2) % multiframe?
		 for s=2:size(stack,3)
			 imwrite(uint16(stack(:,:,s)), path, 'tif', 'Compression', 'none', 'WriteMode', 'append');
		 end
	 end
	 disp(['save_image::stack saved to ' path]);

