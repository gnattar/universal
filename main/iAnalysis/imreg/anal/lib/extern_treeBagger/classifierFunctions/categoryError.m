function category  = categoryError (x,y)
%%
%-------------------------------------
% Goal :        It calculates some metrics of classification error. 
%
%         x : the data categories
%         y : the prediction
%
%   NOTE :  Check the odds metrics. 
%
%%
new_x = x(find(~isnan(x)));
new_y = y(find(~isnan(x)));
categories = unique(new_x);
N_cat = length (categories);
for i=1:N_cat,
    idx_x = find(new_x == categories(i));
    idx_y = find(new_y == categories(i));
    category.count.data(i) = length(idx_x);
    category.count.model(i) = length(idx_y);
    category.count.correct(i) = length(intersect(idx_x,idx_y));
    for j=1:N_cat,
        category.count.confusion(i,j) = length(intersect(idx_x,find(new_y == categories(j))));
    end
end
category.percentage.correct      = category.count.correct./category.count.data;
category.percentage.correctTotal = sum(category.count.correct)/length(new_x);
category.percentage.confusion    = category.count.confusion./repmat(category.count.data,N_cat,1);
category.percentage.data         = category.count.data / length(new_x);
category.names = categories;
category.N       = N_cat;


% Check this part!!
category.odds.correct           = (category.percentage.correct./category.percentage.data);
category.odds.correctTotal      = (category.percentage.correctTotal/sum(category.percentage.data.^2));    % Assuming it matches with the number of each category and selected randomly
category.odds.correctTotalOpt   = (category.percentage.correctTotal/max(category.percentage.data)); % I believe this is the optimal
