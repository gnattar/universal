function err = errargt(ndfct,var,type)
%ERRARGT Check function arguments type.
%       ERR = ERRARGT(NDFCT,VAR,TYPE)
%       is equal to 1 if any element of input vector or 
%       matrix VAR (depending on TYPE choice listed below) 
%       is not of type prescribed by input string TYPE.
%       Otherwise ERR = 0.
%
%       If ERR = 1, an error message is displayed in the command
%       window. In the header message, the string NDFCT is
%       displayed. This string contains the name of a function.
%
%       Available options for TYPE are :
%               'int' : strictly positive integers
%               'in0' : positive integers      
%               'rel' : integers            
%
%               'rep' : strictly positive reals  
%               're0' : positive reals     
%
%               'str' : string  
%
%               'vec' : vector        
%               'row' : row vector 
%               'col' : column vector 
%
%               'dat' : dates   AAAAMMJJHHMNSS
%                       with    0 <= AAAA <=9999  
%                               1 <= MM <= 12  
%                               1 <= JJ <= 31  
%                               0 <= HH <= 23  
%                               0 <= MN <= 59  
%                               0 <= SS <= 59 
% 
%               'mon' : months  MM
%                       with    1 <= MM <= 12  
%
%       A special use of ERRARGT is ERR = ERRARGT(NDFCT,VAR,'msg')
%       for which ERR = 1 and the string VAR is the error message.
%
%       See also ERRARGN.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:10:54 $

%       Uses WSHOWMSG.

[r,c] = size(var);
err = 0;

if      type == 'int'

        if (isstr(var) | any(var < 1) | any(var ~= fix(var)))
                err = 1; txt = 'integer(s) > 0 , expected';
        end

elseif  type == 'in0'

        if (isstr(var) | any(var < 0) | any(var ~= fix(var)))
                err = 1; txt = 'integer(s) => 0 , expected';
        end

elseif  type == 'rel'

        if (isstr(var) | any(var ~= fix(var)))
                err = 1; txt = 'integer(s) expected';
        end

elseif  type == 'rep'

        if (isstr(var) | any(var <= 0)) 
                err = 1; txt = 'real(s) > 0 , expected';
        end

elseif  type == 're0'

        if (isstr(var) | any(var < 0))
                err = 1; txt = 'real(s) => 0 , expected';
        end

elseif  type == 'str'

        if any(~isstr(var))
                err = 1; txt = 'string expected';
        end

elseif  type == 'vec'

        if r ~= 1 & c ~= 1
                err = 1; txt = 'vector expected';
        end

elseif  type == 'row'

        if r ~= 1
                err = 1; txt = 'row vector expected';
        end

elseif  type == 'col'

        if c ~= 1
                err = 1; txt = 'column vector expected';
        end

elseif  type == 'dat'

        if (rem(var,100)                < 0         |...
            rem(var,100)                > 59        |...
            rem(fix(var/100),100)       < 0         |...
            rem(fix(var/100),100)       > 59        |...
            rem(fix(var/10000),100)     < 0         |...
            rem(fix(var/10000),100)     > 23        |...
            rem(fix(var/1000000),100)   < 1         |...
            rem(fix(var/1000000),100)   > 31        |...
            rem(fix(var/100000000),100) < 1         |...
            rem(fix(var/100000000),100) > 12        |...
            fix(var/10000000000)        < 0         |...
            fix(var/10000000000)        > 9999)
            err = 1; txt = 'date expected';
        end

elseif  type == 'mon'

        if (any(var < 1) | any(var > 12)| any(var ~= fix(var)))
                err = 1; txt = 'month expected';
        end

elseif  type == 'msg'

        err = 1; txt = var;

else
        err = 1; txt = 'undefined type of variable';

end

if err == 1
        fcn   = 'errordlg';
        if size(txt,1) == 1
                msg   = [' ' ndfct ' ---> ' txt];
        else
                msg = str2mat([' ' ndfct ' ---> '],txt);
        end
        if type=='msg'
                title = 'ERROR ... ';
        else
                title = 'ARGUMENTS ERROR';
        end

        % if GUI is used messages are displayed in a window
        % else the Matlab command window is used.
        %--------------------------------------------------
        global Init_Globals
        if isempty(Init_Globals)
                clear global Init_Globals
                disp(' ')
                disp('****************************************');
                disp(title);
                disp('----------------------------------------');
                disp(msg);
                disp('****************************************');
                disp(' ')
        else
                if exist(fcn), feval(fcn,msg,title,'off');
                else, wshowmsg(msg,1);
                end
        end
end