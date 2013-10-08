function err = errargn(ndfct,nbargin,argin,nbargout,argout)
%ERRARGN Check function arguments number.
%       ERR = ERRARGN('function',NUMARGIN,ARGIN,NUMARGOUT,ARGOUT)
%       is equal to 1 if either the number of input
%       ARGIN or output (ARGOUT) arguments of the specified
%       function do not belong to the vector of allowed values
%       (NUMARGIN and NUMARGOUT, respectively). 
%       Otherwise ERR = 0.
%
%       If ERR = 1, ERRARGN displays an error message in the
%       command window. The header of this error message contains
%       the string 'function'.
%
%       See also ERRARGT.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:10:48 $

%       Uses ERRARGT.

if isempty(find(argin==nbargin)) | isempty(find(argout==nbargout))
        err = errargt(ndfct,'invalid number of arguments','msg');
else
        err = 0;
end