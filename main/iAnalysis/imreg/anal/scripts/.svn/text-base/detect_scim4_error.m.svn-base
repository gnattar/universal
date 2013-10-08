fl = dir('*main*tif');
hdr = {};
fi = 1;
nc = 0;
ci = [];
for f=1:length(fl)
  try
    [irr hdr{fi}] = load_image(fl(f).name,[]);
	  disp([num2str(f) ' of ' num2str(length(fl))]);
		fi = fi+1;
	catch
	  disp(['CORRUPT: ' fl(f).name]);
		ci = [ci f];
	end
end

if (length(ci) > 0)
  disp(['Detected ' num2str(length(ci)) ' CORRUPT files']);
	for c=1:length(ci)
	  disp(['  :: ' fl(ci).name]);
	end
end

% now look at timing
clear expected_nframes;
clear actual_nframes;
for f=1:length(hdr)-1
  expected_nframes(f) = ceil(((hdr{f+1}.startTimeMS - hdr{f}.startTimeMS)/1000)*hdr{f}.frameRate*hdr{f}.numPlanes);
	actual_nframes(f) = hdr{f}.nframes;
end

dnf = expected_nframes - actual_nframes;
figure; plot (dnf) ; title(pwd);

% OCCASIONAL big discrepancy okay -- block shift ; consistent SMALL discrepancy also okay.  
%  What is BAD is a systematic large discrepancy ( > 5)
