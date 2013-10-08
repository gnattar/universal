function [t_samp mjl SAT sats n] = readfile(N,n,i,A,filen,file)
% See also TEQCSPEC, CHECKFILE, SCANFILE
%
% History
% 22 Feb 2009 created using Matlab R2008b

SAT(1:N,1:32)=NaN;
k=0;
fid=fopen(file);
sats=A;
snyggfilen=strrep(filen,'_','-');
h=waitbar(0,['Please wait... Importing ' char(snyggfilen)]);
%while i<N-1;
while 1;
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    k=k+1;
    if k==3, t_samp=char(tline);end %% sample rate
    if k==4, mjl=char(tline);end    %% MJL
    if k > 5,
       i=i+1;
       waitbar(i/N,h);drawnow
        n=n+1;
        A=str2num(tline);
        if sats~=0;
            SAT(n,sats(2:end))=A;
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            A=str2num(tline);
        end
        if A~=-1;
            sats=A;
        end
    end
end
fclose(fid);
close(h);

