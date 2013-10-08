for n=1:length(S)
	for i=1:length(S{n}.caTSAArray.caTSA); 

		disp([num2str(i) ' ' num2str(isobject(S{n}.caTSAArray.caTSA{i}.caPeakTimeSeriesArray))]);
		if(~isobject(S{n}.caTSAArray.caTSA{i}.caPeakTimeSeriesArray)) % needs fixin
			S{n}.caTSAArray.caTSA{i}.runBestPracticesDffAndEvdet();
			S{n}.saveToFile();
		end
	end
end
