%
% SP Oct 2010
%
% This will compute whiskerPolys matrix.
%
function computeWhiskerPolys(obj)
  % --- prelims
	obj.whiskerPolysX = nan*ones(obj.numFrames, obj.numWhiskers*(obj.whiskerPolyDegree+1));
	obj.whiskerPolysY = nan*ones(obj.numFrames, obj.numWhiskers*(obj.whiskerPolyDegree+1));
	obj.lengthAtPolyXYIntersect = nan*ones(obj.numFrames, obj.numWhiskers);
  obj.enableWhiskerData();
  warning('off','all'); 

	% --- loop over frames
	if (obj.waitBar) ; wb = waitbar(0, 'Computing whisker polynomial fits ...'); end
  if (obj.messageLevel >= 1) ; disp(['computeWhiskerPolys::computing polynomials']); end
	val = 1:obj.numWhiskers;
	whiskerIds = 1:obj.numWhiskers;
	for f=1:obj.numFrames
	  if (obj.waitBar) ; waitbar(f/obj.numFrames, wb, 'Computing whisker polynomial fits ...'); end
	  pmi = find(obj.positionMatrix(:,1) == f);
		wi = obj.positionMatrix(pmi,2);
		val = 0*val;
		for w=1:obj.numWhiskers
      ti = find(wi == w);
			if (length(ti) > 0)
		    val(w) = ti;
		  end
		end
		sval = val(find(val > 0));
		swi = whiskerIds(find(val > 0));

	  % --- loop over whiskers-of-interest -- 1:obj.numWhiskers
		for v=1:length(sval)
		  whisker = obj.whiskerData(f).whisker(sval(v));
		  % by default we invert so that x(1),y(1) is our follicle
		  x = fliplr(whisker.x');
		  y = fliplr(whisker.y');

			% ensure that x(1),y(1) is follicle position (!) ; take advantage of our previous 
			%  measurement of the follicle site
			fxy = whisker.follicleXY;
      if (fxy(1) ~= x(1) | fxy(2) ~= y(1))
				x=fliplr(x);
				y=fliplr(y);
			end

      % 1) compute actual length, albeit crudely (using distance formula -- curve fit would be best)
			%    also store length @ poitn of polynomial intsersect so user can use mask
			%    in subsequent method invocations
      len = cumsum(sqrt([0 diff(x)].^2 + [0 diff(y)].^2));
			pixy = whisker.polynomialIntersectXY;
			intersectIdx = find(x == pixy(1) & y == pixy(2));
			if (length(intersectIdx) == 1)
				obj.lengthAtPolyXYIntersect(f,swi(v)) = len(intersectIdx);
			end

			% 2) derive parametrized representation based on length so that you can 
			%    be sure you fit functions - that is, we use c(l) = (x(l),y(l))
			%    since length increases monotonically, we know there will never be a
			%    repeat of a given length.  
      thisPolyX = polyfit(len,x,obj.whiskerPolyDegree);
      thisPolyY = polyfit(len,y,obj.whiskerPolyDegree);

			obj.whiskerPolysX(f,(swi(v)-1)*(obj.whiskerPolyDegree+1)+1:swi(v)*(obj.whiskerPolyDegree+1)) = thisPolyX;
			obj.whiskerPolysY(f,(swi(v)-1)*(obj.whiskerPolyDegree+1)+1:swi(v)*(obj.whiskerPolyDegree+1)) = thisPolyY;

%		  hold off;
%		  plot(len,x)
%			hold on;
%			X = linspace(0, max(len), 100);
%			plot (X,polyval(thisPolyX,X),'rx');
%		  pause;
		end
	end
	if (obj.waitBar) ; delete(wb) ; end

	% --- clear dependent arrays
	obj.kappas = [];
	obj.thetas = [];
	obj.deltaKappas = [];
	obj.whiskerContacts = [];
	obj.distanceToBarCenter = [];
	obj.whiskerAngleTSA = [];
	obj.whiskerCurvatureTSA = [];
	obj.whiskerBarContactESA = [];


