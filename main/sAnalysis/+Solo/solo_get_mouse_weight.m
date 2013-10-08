function r = solo_get_mouse_weight(x)
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.

r = NaN;
if isfield(x.saved,'SavingSection_weight')
    if ~ischar(x.saved.SavingSection_weight) % ie, not value 'Not recorded'
        r = x.saved.SavingSection_weight;
    end
elseif isfield(x.saved,'SavingSection_Weight')
    if ~ischar(x.saved.SavingSection_Weight) % ie, not value 'Not recorded'
        r = x.saved.SavingSection_Weight;
    end
elseif isfield(x.saved,'SavingSection_WeightBeforeExp')
    if ~ischar(x.saved.SavingSection_WeightBeforeExp) % ie, not value 'Not recorded'
        r = x.saved.SavingSection_WeightBeforeExp;
    end
end
