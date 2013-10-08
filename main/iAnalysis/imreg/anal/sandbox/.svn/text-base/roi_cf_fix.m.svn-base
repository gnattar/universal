%
fl = dir('an*fov*mat'); 
if (1)
	redo = zeros(1,length(fl));
	for f=1:length(fl)
		load(fl(f).name);
		di = zeros(1,length(obj.rois));
		for i=1:length(obj.rois)
			[x y] = get_xy_from_idx(obj.rois{i}.borderIndices, obj.imageBounds);
			meanBx = nanmean(x) ; meanBy = nanmean(y);
			[x y] = get_xy_from_idx(obj.rois{i}.indices, obj.imageBounds);
			meanIx = nanmean(x) ; meanIy = nanmean(y);

			di(i) = sqrt((meanBx - meanIx)^2 + (meanBy - meanIy)^2);
		end
		
		disp([fl(f).name ': ' num2str(nanmean(di)) ]);

		if (nanmean(di) > 2) 
			disp('REJECTING!');
			redo(f) = 1;
		end
	end
end
return
redos = find(redo);
for r=1:length(redos)
  fn = fl(redos(r)).name;
  uidx = find(fn == '_');
  midx = strfind(fn, '.mat');
	bfl = dir(['*based*' fn(uidx(end)+1:midx-1) '.mat']);
  load(bfl(1).name) ; 
	rBase=obj; 

	load (fn);
	rDer = obj;

	for i=1:length(rDer.rois)
		[x y] = get_xy_from_idx(rDer.rois{i}.borderIndices, rDer.imageBounds);
		meanDx = nanmean(x) ; 
		meanDy = nanmean(y);	
		[x y] = get_xy_from_idx(rBase.rois{i}.borderIndices, rBase.imageBounds);
		meanBx = nanmean(x) ; 
		meanBy = nanmean(y);	

		dx = meanDx - meanBx;
		dy = meanDy - meanBy;

    nRoi = rBase.rois{i}.copy();
		nRoi.moveBy(round(dx),round(dy));
		rDer.rois{i} = nRoi;
	end

	rDer.saveToFile(fn);
end
