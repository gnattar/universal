%
% For comparing mp4 vs. seq files
%
%  seqDir and mp4Dir shoudl be matched cell arrays of directories, one with
%   seq files the other with MP4 files.
%
% EXAMPLE:
%
% mp4vseq({'2011_09_13-seq','2011_09_17-seq'},{'2011_09_13-MP4','2011_09_17-MP4'})
%
% difference values will then be seq-mp4 (i.e., negative means mp4 > seq)
%
function mp4vseq(seqDir, mp4Dir)

  %compareWT('/data/MP4vsseq/an148378/2011_09_17-s/WDBP_an148378-2011_09_17-s_0056_20111220092546127.mat', ...
	%          '/data/MP4vsseq/an148378/2011_09_17-m/WDBP_an148378-2011_09_17-m_0056_20111220092546127.mat');

  for d=1:length(seqDir)
	  mp4flist = dir([mp4Dir{d} filesep 'W*mat']);
		seqflist = dir([seqDir{d} filesep 'W*mat']);

		% find matches (assume some files missing in each)
		mp4id = nan*ones(1,length(mp4flist));
		seqid = nan*ones(1,length(seqflist));
		for f=1:length(mp4flist); mp4id(f) = str2num(mp4flist(f).name(max(find(mp4flist(f).name == '_'))+1:max(find(mp4flist(f).name == '.'))-1)); end
		for f=1:length(seqflist); seqid(f) = str2num(seqflist(f).name(max(find(seqflist(f).name == '_'))+1:max(find(seqflist(f).name == '.'))-1)); end

		[overlapid imp4 iseq] = intersect(mp4id,seqid);
	
		% loop over matches and run comparison
    for f=1:length(imp4)
      f1 = [mp4Dir{d} filesep mp4flist(imp4(f)).name];
      f2 = [seqDir{d} filesep seqflist(iseq(f)).name];
      disp(['Comparing ' f1 ' and ' f2]);
      [polyD{d}{f} maxD{d}{f} lenDiff{d}{f} thetaDiff{d}{f} kappaDiff{d}{f} kappaDiffRelMedian{d}{f}] =compareWT(f1, f2);
      mp4files{d}{f} = f1;
      seqfiles{d}{f} = f2;
    end
    
  end
  
  % save locally
  save('mp4vseq_output.mat', 'polyD', 'maxD', 'lenDiff', 'thetaDiff', 'kappaDiff', 'kappaDiffRelMedian', 'mp4files', 'seqfiles');



function [polyD maxD lenDiff thetaDiff kappaDiff kappaDiffRelMedian] = compareWT(f1, f2)
  npp = 100; % number of points along polynomial to consider

  wt1 = load(f1);
	wt2 = load(f2);
  
  wt1 = wt1.wt;
  wt2 = wt2.wt;

  % --- prelims
  fp1 = wt1.framesPresent;
	fp2 = wt2.framesPresent;
  if (length(fp1) ~= length(fp2)) ; polyD = nan ; maxD = nan; lenDiff = nan ; thetaDiff = nan ; kappaDiff = nan ; kappaDiffRelMedian = nan; return ; end
	fp = fp1.*fp2;

	nw = size(fp,1);

	wpd1 = wt1.whiskerPolyDegree;
	wpd2 = wt2.whiskerPolyDegree;

  polyD = nan*zeros(nw,wt1.numFrames);
  maxD = nan*zeros(nw,wt1.numFrames);
	lenDiff = nan*zeros(nw,wt1.numFrames);
	thetaDiff = nan*zeros(nw,wt1.numFrames);
	kappaDiff = nan*zeros(nw,wt1.numFrames);
	kappaDiffRelMedian = nan*zeros(nw,wt1.numFrames);

	% --- scores
  disp('000000');
	for w=1:nw
	  frames = find(fp(w,:));
    %if(0)
		for f=frames

			% --- polynomials
		  wpmi1 = find(wt1.positionMatrix(:,1) == f & wt1.positionMatrix(:,2) == w);
		  wpmi2 = find(wt2.positionMatrix(:,1) == f & wt2.positionMatrix(:,2) == w);
      
      if (length(wpmi1) + length(wpmi2) ~= 2) ; continue ; end

			L1 = linspace(1,wt1.lengthVector(wpmi1),npp);
			L2 = linspace(1,wt2.lengthVector(wpmi2),npp);

			% build the polynomial points
			i1 = (w-1)*(wpd1+1)+1;
			i2 = i1+wpd1;
			xPoly1 = wt1.whiskerPolysX(f,i1:i2);
			yPoly1 = wt1.whiskerPolysY(f,i1:i2);
			i1 = (w-1)*(wpd2+1)+1;
			i2 = i1+wpd2;
			xPoly2 = wt2.whiskerPolysX(f,i1:i2);
			yPoly2 = wt2.whiskerPolysY(f,i1:i2);

			% compute x,y
			X1 = polyval(xPoly1,L1);
			Y1 = polyval(yPoly1,L1);
			X2 = polyval(xPoly2,L2);
			Y2 = polyval(yPoly2,L2);

      % pairwise distance between all points
			dx = repmat(X1,npp,1)-repmat(X2',1,npp);
			dy = repmat(Y1,npp,1)-repmat(Y2',1,npp);

			D = sqrt(dx.^2 + dy.^2);
      minD1 = min(D,[],1);
      minD2 = min(D,[],2);
			polyD(w,f) = mean([minD1 minD2']);
			maxD(w,f) = max([minD1 minD2']);

      % --- length, theta, kappa difference
			lenDiff(w,f) = wt1.lengthVector(wpmi1) - wt2.lengthVector(wpmi2);
			%disp([num2str(f) ' ' num2str(polyD(w,f))]);
      
      disp([8 8 8 8 8 8 8 sprintf('%06d', f)]);
    end
    
    % --- kappa difference
  	kappaDiffRelMedian(w,:)  = (abs(wt1.kappas(:,w) - wt2.kappas(:,w))/nanmedian([wt1.kappas(:,w)' wt2.kappas(:,w)']))';
	end

  % --- length, theta, kappa difference
  kappaDiff  = wt1.kappas - wt2.kappas;
  thetaDiff  = wt1.thetas - wt2.thetas;
  
