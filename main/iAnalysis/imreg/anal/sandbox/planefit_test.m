stack_name = 'an167951_2012_05_10_dz1_FOV1_001_AVG';

cd /Volumes/an167951a/rois_L5/
load an167951_2012_05_10_fov_18002
rA = obj; clear obj;
cd ..
delete('mapping_18002_planar_fits.mat');
clear params;
params.rootOutName = [pwd filesep 'mapping_18002'];
%params.preprocessedVimPath = 'mapping_18004_preprocessed_images.mat';
params.guessZ = 390; % 580: 18004 ; 390: 18002
params.fpvParams.skip_plotting = 0;
params.fpvParams.init_step_size = [5 5 5 1 .25];
params.fpvParams.rx_range = [0 15];
params.fpvParams.dz_vol = 150;
params.fpvParams.subim_ublb_offs = [0 0 60 0 0];
params.fpvParams.init_fit_frac = [0.9 0.9];
params.fpvParams.subim_size = [.15 .15];
params.fpvParams.n_subim = [10 10];
roi.roiArray.registerToRefStackS(stack_name,rA,params);


vim = load_image(stack_name);
% plot 
if (0)
	X = rA.refStackMap.X;
	Y = rA.refStackMap.Y;
	Z = rA.refStackMap.Z;
	X = round(X) ; Y = round(Y) ; Z = round(Z);
  figure;
	imshow(rA.masterImage, [0 1000]);
	nim = 0*rA.masterImage; for x=1:512 ; for y=1:512 ; if (X(x,y) > 0 & X(x,y) < 512 & Y(x,y) > 0 & Y(x,y) < 513) ; nim(x,y) = vim(round(Y(x,y)), round(X(x,y)), round(Z(x,y))) ; end ; end ;  end
	figure ;
	imshow(nim, [0 500]);
end
