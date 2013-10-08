%
% SP Mar 2011
%
% This will apply guiWorkingImageControl's settings to the workingImage.
%
% USAGE:
%
%   rA.applyWorkingImageControl();
%
function applyWorkingImageControl(obj)
  % --- is thre even a gui present?
  if (isstruct(obj.guiData) && isfield(obj.guiData, 'workingImageControl'))
	  if (ishandle(obj.guiData.workingImageControl.figH) && ...
		    ishandle(obj.guiData.workingImageControl.panelH))


		  % --- GUI gather params
			figH = obj.guiData.workingImageControl.figH;
			uiElements = obj.guiData.workingImageControl.uiElements;
			tmpWorkingImage = obj.baseWorkingImage;

			% --- tweak baseWorkingImage to make workingImage

			% divide by gaussian?
			gaussFracSize = str2num(get(uiElements.gaussFracSizeH, 'String'));
			if (gaussFracSize > 0 & gaussFracSize < 1)
			  M = single(max(max(tmpWorkingImage)));
				m = single(min(min(tmpWorkingImage)));
			  tmpWorkingImage = normalize_via_gaussconvdiv(tmpWorkingImage, gaussFracSize);
				tmpWorkingImage = tmpWorkingImage - min(min(tmpWorkingImage));
				tmpWorkingImage = tmpWorkingImage/max(max(tmpWorkingImage));
				tmpWorkingImage = (M-m)*tmpWorkingImage + m;
      end
			
			% min & max pixel values
		  maxVal = str2num(get(uiElements.maxPixValH, 'String'));
		  minVal = str2num(get(uiElements.minPixValH, 'String'));
			if (minVal < maxVal)
				tmpWorkingImage(find(tmpWorkingImage < minVal)) = minVal;
				tmpWorkingImage(find(tmpWorkingImage > maxVal)) = maxVal;
			end

			% colormap
			cmIdx = get(uiElements.cmMenuH,'Value');
			switch cmIdx  
			  case 1 % greyscale
				  obj.workingImageColorMap = [];

        case 2 % jet
				  obj.workingImageColorMap = jet(obj.maxImagePixelValue);

				case 3 % red/blue centered @ median
					nidx = find(isnan(tmpWorkingImage));
					tmpWorkingImage(nidx) = 0;
					lim = reshape(tmpWorkingImage,[],1);
					cim = nanmedian(lim);
					tmpWorkingImage = tmpWorkingImage-cim;
					mim = min(min(tmpWorkingImage));
					Mim = max(max(tmpWorkingImage));
					Rim = Mim-mim;

					% make relevant colormap
					nneg = ceil(obj.maxImagePixelValue*abs(mim)/Rim);
					npos = ceil(obj.maxImagePixelValue*abs(Mim)/Rim);
					nVec = 1:(-1/nneg):0;
					pVec = 0:(1/npos):1;
					cmap = zeros(obj.maxImagePixelValue,3);
					cmap(1:length(nVec),3) = nVec;
					cmap(obj.maxImagePixelValue-length(pVec)+1:obj.maxImagePixelValue,1) = pVec;
					obj.workingImageColorMap = cmap;
			end

			% --- assign workingImage 
			obj.workingImage = tmpWorkingImage;
		end
	end
