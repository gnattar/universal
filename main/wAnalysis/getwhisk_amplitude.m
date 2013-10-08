function value = getwhisk_amplitude(obj)
            % obj can be any WhiskerTrial or WhiskerSignalTrial class
            value = cell(1,length(obj.trajectoryIDs));
            for i = 1:length(value)
                if i > length(obj.theta)
                    continue
                else
                    th = obj.theta{i};
                    [lmn, indmin] = lmin_pw(th',15);
                    [lmx, indmax] = lmax_pw(th',15);
                    xi = 1:length(th);
                    indmin = unique(indmin);
                    lmn = th(indmin);
                    indmax = unique(indmax);
                    lmx = th(indmax);
                    lmni = interp1(indmin,lmn,xi);
                    lmxi = interp1(indmax,lmx,xi);
                    value{i} = abs(lmni)-abs(lmxi);
                end
            end

        
function [lmval,indd]=lmax_pw(xx, dx)
%   Find  piece-wise  local maxima in vector XX,where
%	LMVAL is the output vector with maxima values, INDD  is the 
%	corresponding indexes, DX is length of piece where maxima is searched, 
%   IMPORTANT:      FIRST and LAST point in vector are excluded
%   IMPORTANT:      XX must be single column vector
%   IMPORTANT:      Length of DX must be very carefully selected 
%	For example compare dx=30; and dx=1000;
%
%   dx=150; xx=[0:0.01:35]'; y=sin(xx .* cos(xx /4.5)) + cos(xx); 
%    plot(xx,y); grid; hold on;
%   %   Excluding first and last points
%   [b,a]=lmax_pw(y,dx); plot(xx(a),y(a),'r+')
%   % Way to include first and last points can be as:
%   y(1)=1.5; yy=[0; y; -1;];   % padd with smaller values
%   [b,a]=lmax_pw(yy,dx); a=a-1; plot(xx(a),y(a),'go')
%
%	see also LMIN, LMAX,  LMIN_PW, MATCH

% 	Sergei Koptenko, Applied Acoustic Technologies, Toronto, Canada
%   sergei.koptenko@sympatico.ca,  March/11/2003  

if nargin <2, 
	disp('Not enough arguments'); return
end

len_x = length(xx);
xx = [xx; xx(len_x); xx(len_x)]; 
nn=floor(len_x/dx);
ncount=1; lmval=[]; indd=[];
	for ii=1:nn,
        [lm,ind] = max(xx(ncount: ii*dx+2)) ;
        ind=ind+(ii-1)*dx;
                 if (ind ~=ncount) & (ind~=ii*dx+2),    
                    lmval=[lmval, lm]; indd=[indd, ind]; 
                end      
        ncount=ncount +dx;
	end
[lm,ind] = max(xx(ii*dx:len_x));
        if (ind ~=len_x) & (ind~=ii*dx),    
            lmval=[lmval, lm]; indd=[indd, (ind+ii*dx-1)]; 
        end
    
       if indd(end)==len_x,  
           indd=  indd(1:end-1); 
           lmval=lmval(1:end-1);    
       end
return

function [lmval,indd]=lmin_pw(xx, dx)
%   Find  piece-wise local minima in vector XX,where
%	LMVAL is the output vector with minima values, INDD  is the 
%	corresponding indexes, DX is scalar length of piece where minima is searched, 
%   IMPORTANT:      FIRST and LAST point in vector are excluded
%   IMPORTANT:      XX must be single column vector
%   IMPORTANT:      Length of DX must be very carefully selected 
%	For example compare dx=10; and dx=1000;
%
%   dx=150; xx=[0:0.01:35]'; y=sin(xx .* cos(xx /4.5)) + cos(xx); 
%   y(length(y))=-2; plot(xx,y); grid; hold on;
%   %   Excluding first and last points
%   [b,a]=lmin_pw(y,dx); plot(xx(a),y(a),'r+')
%   % Way to include first and last points can be as:
%   yy=[1.5; y; 0];         % padd with values higher than end values
%   [b,a]=lmin_pw(yy,dx); a=a-1; plot(xx(a),y(a),'go')
%
%	see also LMIN,LMAX, LMAX_PW, MATCH

% 	Sergei Koptenko, Applied Acoustic Technologies, Toronto, Canada
%   sergei.koptenko@sympatico.ca,  March/11/2003  

if nargin <2, 
	disp('Not enough arguments'); return
end

len_x = length(xx);
xx = [xx; xx(end)]; 
nn=floor(len_x/dx);
ncount=1; lmval=[]; indd=[];
for ii=1:nn,
    [lm,ind] = min(xx(ncount: ii*dx+1)) ;
        ind=ind+(ii-1)*dx;
         if (ind ~=ncount) & (ind~=ii*dx+1),    
         lmval=[lmval, lm]; indd=[indd, ind]; 
end      
ncount=ncount +dx;
end
[lm,ind] = min(xx(ii*dx:len_x));
    if (ind ~=len_x) & (ind~=ii*dx),    
    lmval=[lmval, lm]; indd=[indd, (ind+ii*dx-1)]; 
    end
    
     if indd(end)==len_x,
    indd=indd(1:end-1); lmval=lmval(1:end-1);
    end
return

