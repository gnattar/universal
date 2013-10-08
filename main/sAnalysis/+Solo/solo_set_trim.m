function r = solo_set_trim(x, btrim, etrim)
%
% Returns x but with new values with x.trim field.
%
% btrim: either string 'btrim' to not modify, or numeric value of number of samples to trim from start.
% etrim: either string 'etrim' to not modify, or numeric value of number of samples to trim from end.
% x: a loaded-from-disk Solo file.
%
% DHO, 9/07.

r = x;

if ischar(btrim)
    if ~strcmp(btrim,'btrim')
        error('Wrong input for argument btrim')
    end
else
    r.trim(1) = btrim;
end

if ischar(etrim)
    if ~strcmp(etrim,'etrim')
        error('Wrong input for argument etrim')
    end
else
    r.trim(2) = etrim;
end

