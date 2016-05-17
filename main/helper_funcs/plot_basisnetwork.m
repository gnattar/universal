% figure;
% x = [-40:.1:40];
% y = [1:.1:50];
% ds = zeros(length(y),length(x));
% 
% xp = [ -25 -20 -20 -15 -15 -10 -10 -5 -5 0 0 5 5 10 10 15 15 20 20 25]+10;
% yp = [  25 22 28 19 31 16 34 13 37 10 40 13 37 16 34 19 31 22 28 25] + 20;
% 
% xp = [0 :2: 30];
% yp = [ 10:2:40]; 

load('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/mycmap3.mat');

figure;
clear;
x = [1:100];
y=[1:100];

ds = zeros(length(y),length(x));

% xp = [30.5:.5:70, 30:.5:69.5]';
% yp = [50:.5:70, 69.5:-.5:50, 49.5:-.5:30, 30.5:.5:49.5]';

xp = [32:2:70, 30:2:68]';
yp = [50:2:70, 68:-2:50, 48:-2:30, 32:2:48]';
count =1;
l=[1 10 20 30];
for i = 1:length(yp)
normL{i} = normpdf(x,xp(i),5);
normW{i} = normpdf(y,yp(i),5);

mult{i} = normW{i}'*normL{i};
mult{i} = mult{i}.*100000;

if max(ismember(l,i))>0
figure;
temp = mult{i};
temp_sub =temp-min(min(temp));
temp_norm = temp_sub./max(max(temp_sub));
surf(x,y,temp_norm,'edgecolor','none');colormap(jet);
count = count+1;
end

ds=ds+mult{i};
end

ds_sub = ds-min(min(ds));
ds_norm = ds_sub./max(max(ds_sub));
figure; surf(ds_norm,'edgecolor','none');colormap(jet);

%%OR
% 
% [X,Y] = meshgrid(-8:.5:8);
% R = sqrt(X.^2 + Y.^2);
% Z = sin(R)./R;
% 
% figure
% subplot(1,2,1);surf(Z)
% 
% w1=normpdf(X,0,2);
% mult = w1'*w1;
% subplot(1,2,2);surf(mult)
% 
% temp = Z-mult; 
% figure; surf(temp)