function r = solo_set_trim_all(xcell, btrim, etrim)
%
% Returns xcell but with new values with x.trim field.
%
% btrim: either string 'btrim' to not modify, or numeric value of number of samples to trim from start.
% etrim: either string 'etrim' to not modify, or numeric value of number of samples to trim from end.
% xcell: cell array of Solo files.
%
% DHO, 9/07.

r = cellfun(@solo_set_trim, xcell, repmat({btrim},size(xcell)), ...
    repmat({etrim},size(xcell)),'UniformOutput',false); % Uniform output doesn't need to be false, 
                                                        % but we want returned value to be a cell array 
                                                        % instead of a array of structs