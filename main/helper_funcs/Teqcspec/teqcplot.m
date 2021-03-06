function out=teqcplot(files);

% TEQCPLOT  Read and plot TEQC report files
%
%   TEQC is the Toolkit for GPS/GLONASS/SBAS Data used to solve 
%   many pre-processing problems with GPS, GLONASS, and SBAS data:
%   TEQC stands for Translation, Editing, and Quality Check
%   More info here: http://facility.unavco.org/software/teqc/teqc.html
%
%   TEQCPLOT(FILENAME) returns the content of a TEQC reportfile in
%   a figure (and a struct variable).
%   Input argument FILENAME is optional. 
%
%   Valid TEQC report files are:
%  
%   FORMAT  DESCRIPTION
%   *.sn1   Signal to noise ratio (S/N) Carrier L1
%   *.sn2   Signal to noise ratio (S/N) Carrier L2
%   *.iod   Derivative of ionospheric delay observable (m/s)
%   *.ion   Ionospheric delay observable (m)
%   *.mp1   Multipath Carrier L1
%   *.mp2   Multipath Carrier L2
%   *.azi   Satellite azimuthal data (degrees)
%   *.ele   Satellite elevation data (degrees)
%
%   Jim Hedfors, Uppsala University, 2005
%   Comments and requests for more TEQC Matlab tools to:
%   jim.hedfors@gmail.com

% FUNCTION: READER & PLOTTER ++++++++++++++++++++++++++++++++++++++++++++++

if nargin==0
    [filen,path]=uigetfile('*.sn1;*.sn2;*.iod;*.ion;*.mp1;*.mp2;*.azi;*.ele',...
        'Pick your TEQC report file');
else
    [path,filen,ext]=fileparts(files);
    %path=[path '\'];
    fs=filesep;
    if ~isempty(path), path=[path fs]; end
    filen={[filen ext]};
end
file=char(filen);
[A]=importdata([path file],'\t');
SAT(1:length(A),1:32)=NaN;
n=0;i=5;
sats=str2num(A{i});
snyggfilen=strrep(filen,'_','-');
h=waitbar(0,['Please wait... Importing ' char(snyggfilen)]);
while i<length(A)-1;
    waitbar(i/length(A),h);drawnow
    n=n+1;
    i=i+1;
    if sats~=0;
        SAT(n,sats(2:end))=str2num(A{i});
        i=i+1;
    end
    if str2num(A{i})~=-1;
        sats=str2num(A{i});
    end
end
close(h);
sat=SAT(1:n+1,:);
t_samp=char(A(3));
mjl=char(A(4));
T_SAMP=str2num(t_samp(max(find(t_samp==' ')):end));
MJL_START=str2num(mjl(max(find(mjl==' ')):end));
MJL(1)=MJL_START;
for i=2:length(sat);
    MJL(i)=MJL_START+i*T_SAMP/60/60/24;
end
JD=mjl2jd(MJL);
[type,maxy,miny]=get_filetype(file);

figure;box on;hold on
pcolor(JD',1:32,sat')
set(gcf,'renderer','zbuffer');
shading flat
set(gca,'xticklabel',[JD]);
set(gca,'xlim',[JD(1) JD(end)])
%dateaxis('X',13)
datetick('x','HH:MM:SS','keeplimits','keepticks')
cbar('v',[miny maxy],type);
set(gca,'ylim',[1 33])
set(gca,'ytick',[1.5:1:32.5])
set(gca,'yticklabel',['S01';'S02';'S03';'S04';'S05';'S06';...
        'S07';'S08';'S09';'S10';'S11';'S12';...
        'S13';'S14';'S15';'S16';'S17';'S18';...
        'S19';'S20';'S21';'S22';'S23';'S24';...
        'S25';'S26';'S27';'S28';'S29';'S30';...
        'S31';'S32']);
set(gca,'fontsize',7);
colormap(flipud(jet));
caxis([miny maxy]);
xlabel([datestr(JD(1)) '   |--------  T Samp: ' num2str(T_SAMP) ' s  --------|    ' datestr(JD(end))])
ylabel('SVS')
timestr=secs2hms(length(sat));
T=title(['TEQC Report file: ' strrep(file,'_','-')]);
set(T,'fontsize',8)

out.(file(end-2:end))=sat;
out.T_samp=T_SAMP;
out.Start=datestr(JD(1));
out.Stop=datestr(JD(end));

% FUNCTION: MJL DAYS TO JULIAN DAYS +++++++++++++++++++++++++++++++

function [out]=mjl2jd(in)

out=in+678941.999999741;

% FUNCTION: GET FILETYPE INFO +++++++++++++++++++++++++++++++++++++

function [out,maxy,miny]=get_filetype(teqfile);

[path,name,ext,ver]=fileparts(teqfile);
switch ext
    case '.sn1'
        out='Signal to noise ratio S/N L1';
        maxy=10;
        miny=0;    
    case '.sn2'
        out='Signal to noise ratio S/N L2';
        maxy=10;
        miny=0;
    case '.mp1'
        out='Multipath L1';
        maxy=1;
        miny=-1;
    case '.mp2'
        out='Multipath L2';
        maxy=1;
        miny=-1;
    case '.iod'
        out='Derivative of ionospheric delay observable (m/s)';
        maxy=1;
        miny=-1;
    case '.ion'
        maxy=2;
        miny=-2;
        out='Ionospheric delay observable (m)';
    case '.ele'
        maxy=90;
        miny=0;
        out='Satellite elevation data';
    case '.azi'
        maxy=180;
        miny=-180;
        out='Satellite azimuthal data';
    otherwise
        disp('Somethings wrong..!')
end

% FUNCTION: PLACE A MODIFIED COLORBAR ++++++++++++++++++++++++++++++

function CB=cbar(loc,range,label);

% .............................................................
% CB = cbar(loc,range,label)
%   places a colorbar at:
%   loc = 'v' in vertical or 'h' in horizontal
%           position in current figure scaled between:
%   range = [min max] with a:
%   label = 'string'.
%
%   fontsize is reduced to 10 and width of bar is half default.
%   
%   Example:    [X,Y,Z]=peaks(25);
%               range=[min(min(Z)) max(max(Z))];
%               pcolor(X,Y,Z);
%               cbar('v',range,'Elevation (m)')
% .............................................................

caxis([range(1) range(2)]);
switch loc
    case 'v'
        CB=colorbar('vertical');
        set(CB,'ylim',[range(1) range(2)]);
        %POS=get(CB,'position');
        %set(CB,'position',[POS(1) POS(2) 0.03 POS(4)]);
        set(CB,'fontsize',8);
        set(get(CB,'ylabel'),'string',label);
        set(CB,'box','on')

    case 'h'
        CB=colorbar('horizontal');
        set(CB,'xlim',[range(1) range(2)]);
        %POS=get(CB,'position');
        %set(CB,'position',[POS(1) POS(2) POS(3) 0.03]);
        set(CB,'fontsize',8);
        set(get(CB,'xlabel'),'string',label)
end

% FUNCTION: SECONDS TO HOURS, MINUTES and SECONDS ++++++++++++++++

function timestr=secs2hms(SECS)

HOURS=SECS/60/60;
hours=floor(HOURS);
MINUTES=(HOURS-hours)*60;
minutes=floor(MINUTES);
seconds=(MINUTES-minutes)*60;
HH=num2str(hours);
MM=num2str(minutes);
SS=num2str(seconds);

if seconds<10;
    SS=['0' num2str(SS)];
else
    SS=num2str(SS);
end
if minutes<10;
    MM=['0' num2str(MM)];
else
    MM=num2str(MM);
end
timestr=[HH ':' MM ':' SS];

% EOF +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++