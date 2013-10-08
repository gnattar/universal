function r = load_solo(fn, trim)
%
% fn is file name of a solo file.
% trim has form: [begintrim endtrim]
%
% DHO, 9/07.

r = load(fn); r.trim = trim; 