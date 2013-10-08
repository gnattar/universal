function s = deblankl(x)
%DEBLANKL Convert string to lowercase without blanks.
%       S = DEBLANKL(X) is the string X converted to lowercase 
%       without blanks.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:07:00 $

if ~isempty(x)
        s = lower(x);
        s = s(find(s~=32));
else
        s = [];
end