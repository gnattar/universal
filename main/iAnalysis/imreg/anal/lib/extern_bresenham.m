function [X,Y] = extern_bresenham(mycoordinates)

% EXTERN_BRESENHAM: MODIFIED to return the x,y coordinates of *every point*
%  that lies on the line assuming a bresenham rendering of a line.
%
% [X,Y] = extern_bresenham(mycoordinates)
%
% - mycoordinates is coordinate of the form: [x1, y1; x2, y2]
%   which can be obtained from ginput function
%
% - X and Y are the coordinates of your line
%
% Author: N. Chattrapiban
%
% Ref: nprotech: Chackrit Sangkaew; Citec
% Ref: http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
% 
% See also: tut_line_algorithm

mycoords = mycoordinates;

x = round(mycoords(:,1));
y = round(mycoords(:,2));
steep = (abs(y(2)-y(1)) > abs(x(2)-x(1)));

if steep, [x,y] = swap(x,y); end

if x(1)>x(2), 
    [x(1),x(2)] = swap(x(1),x(2));
    [y(1),y(2)] = swap(y(1),y(2));
end

delx = x(2)-x(1);
dely = abs(y(2)-y(1));
error = 0;
x_n = x(1);
y_n = y(1);
if y(1) < y(2), ystep = 1; else ystep = -1; end 
for n = 1:delx+1
    if steep,
        X(n) = y_n;
        Y(n) = x_n;
    else
        X(n) = x_n;
        Y(n) = y_n;
    end    
    x_n = x_n + 1;
    error = error + dely;
    if bitshift(error,1) >= delx, % same as -> if 2*error >= delx, 
        y_n = y_n + ystep;
        error = error - delx;
    end    
end
% -> a(y,x)
%plot(1:delx,myline)

function [q,r] = swap(s,t)
% function SWAP
q = t; r = s;
