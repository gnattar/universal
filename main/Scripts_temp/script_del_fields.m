for d = 1:28
NAMES = fieldnames(pooled_contactCaTrials_locdep{d});
list =strfind(NAMES,'LP');
for l = 1: length(list)
    if isempty(list{l})
    else
        delfieldname = NAMES(l);
        pooled_contactCaTrials_locdep{d}= rmfield(pooled_contactCaTrials_locdep{d},delfieldname);
    end
end
end
