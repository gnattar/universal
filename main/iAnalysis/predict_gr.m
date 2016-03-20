
function [label] = predict_gr(Y,train_label,S,cells_contrib)

mu=[];Xtrain=[];Xtrain_centered=[];
Xtest =[];d=[];
logP=[];P=[];

Xtest = S(:,cells_contrib);
Xtrain = Y(:,cells_contrib);

Ytrain = train_label;
[v,ia,ib]=unique(Ytrain);

for t = 1:length(v)
mu(t,:) = mean(Xtrain(find(ib==t),:));
end

for t = 1:length(v)
Xtrain_centered(find(ib==t),:) = bsxfun(@minus,Xtrain(find(ib==t),:), mu(t,:));
end

d = std(Xtrain_centered);
LogDetSig = 2*sum(log(d(d>0)));


d_nc = std(Xtrain);
invD_nc = 1./d_nc;
for t = 1:length(v)
A = bsxfun(@times,bsxfun(@minus,Xtest,mu(t,:)),invD_nc);
mah_dist(:,t)=sum((A.*A),2);
end

logP  = bsxfun(@minus,-LogDetSig'/2,mah_dist/2);
maxlogP = max(logP,[],2);
P = exp(bsxfun(@minus,logP,maxlogP));

[v2,i2] = max(P,[],2);

label=v(i2);