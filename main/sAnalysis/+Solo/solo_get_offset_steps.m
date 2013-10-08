function r = solo_get_offset_steps(x)
%
% Returns offset of pin's two positions in steps.
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.

no_go_position = x.saved.MotorsSection_nogo_position;
go_position = x.saved.MotorsSection_go_position;

r = abs(no_go_position - go_position); 