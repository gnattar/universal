function r = solo_get_session_consumed_volume(x)
%
% Returns difference in mouse weight between start and
% end of session. This equals water consumed in ml.
% By convention I added excrement weight to after-session
% weight value. Therefore, this difference is the consumed volume.
%
% x is a loaded-from-disk Solo file.
% 
%
% DHO, 9/07.

startWeight = x.saved.SavingSection_Weight;
finalWeight = x.saved.SavingSection_WeightAfterExp;

if ~isnumeric(startWeight) | ~isnumeric(finalWeight)
    r = NaN;
else
    r = finalWeight - startWeight;
end
    

     




    