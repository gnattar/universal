function new=copyfit(original)

% Copyright 2001-2011 The MathWorks, Inc.


% it may be coming in with a java bean wrapper
original=handle(original);

% Determine a new, unique name.
name = original.name;
taken = 1;
i=1;

% keep from prepending multiple "copy x of"'s.
ind=findstr(name,' copy ');
if ~isempty(ind)
    name=name(1:(ind(end)-1));
end

% search for first unique name
fitdb=getfitdb;
while taken
   newName = getString(message('curvefit:cftoolgui:NameCopyNumber',name,i));
   if isempty(find(fitdb,'name',newName))
      taken = 0;
   else
      i=i+1;
   end
end

new = constructorhelper(cftool.fit,newName);

% copy all fields from the old to the new, but
% skip any of the ones on the toskip list.
fields = fieldnames(new);
toskip = {
    'equationname', 'fitoptions', 'listeners', 'name', 'plot', 'line', ...
    'rline', 'ColorMarkerLine'
    };
for i=1:length(fields)
   if ~ismember(fields{i},toskip)
      set(new,fields{i},get(original,fields{i}));
   end
end
new.fitoptions=copy(original.fitoptions);

connect(new,fitdb,'up');

% restore other properties
if original.plot
   new.plot=1;
end

