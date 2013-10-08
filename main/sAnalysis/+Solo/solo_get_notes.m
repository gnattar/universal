function r = solo_get_notes(x)
%
% Returns notes (documentation entered at time of experiment into
% the Solo GUI) for session in x.
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.

s = x.saved.NotesSection_notes;

r = strcat(s{:});

% Can use char(s) too but newlines are still present.