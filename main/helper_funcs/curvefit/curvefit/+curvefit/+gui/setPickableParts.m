function setPickableParts(pickableElements, onOrOff)
% setPickableParts   changes the value for the PickableParts property if
% one exists in a array of handles.

elementsToModify = pickableElements(isprop(pickableElements, 'PickableParts'));

if strcmp(onOrOff, 'on')
    set(elementsToModify, 'PickableParts', 'visible')
else
    set(elementsToModify, 'PickableParts', 'none')
end
end