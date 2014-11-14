function [H,P, STATS] = fishertest(M, alpha)
% FISHERTEST - Fisher Exact test for 2-x-2 contingency tables
%
%   H = FISHERTEST(M) performs the non-parametric Fisher exact probability
%   test on a 2-by-2 contingency table described by M, and returns the
%   result in H. It calculates the exact probability of observing the given
%   and more extreme distributions on two variables.  H==0 indicates that
%   the null hypothesis (H0: "the score on one variable is independent from
%   the score on the other variable") cannot be rejected at the 5%
%   significance level.  H==1 indicates that the null hypothesis can be
%   rejected at the 5% level. For practical convenience, the variables can
%   be considered as "0/1 questions" and each observation is casted in
%   one of the cells of the 2-by-2 contingency table [1/1, 1/0 ; 0/1, 0/0].
%
%   If M is a 2-by-2 array, it specifies this 2-by-2 contingency table
%   directly. It holds the observations for each of the four possible
%   combinations.
%   If M is a N-by-2 logical or binary array, the 2-by-2 contingency table
%   is created from it. Each row of M is a single observation that is
%   casted in the appropriate cell of M. 
%
%   [H,P,STATS] = FISHERTEST(..) also returns the exact probability P of
%   observing the null-hypothesis and some statistics in the structure
%   STATS, which has the following fields:
%     .M    - the 2-by-2 contingency table
%     .P    - a list of probabilities for the original and all more extreme
%             observations
%     .phi  - the phi coefficient of association between the two attributes
%     .Chi2 - the Chi Square value for the 2-by-2 contingency table
%
%   H =FISHERTEST(M, APLHA) performs the test at the significance level
%   (100*ALPHA)%.  ALPHA must be a scalar between 0 and 1.
%
%   Example:
%     % We have measured the responses of 15 subjects on two 0-1
%     % "questions" and obtained the following results:
%     %         Q1: 1   0
%     %   Q2: 1     5   1
%     %       0     2   7
%     % (so 5 subjects answered yes on both questions, etc.)
%     M = [ 5 1 ; 2 7] 
%     % Our null-hypothesis is that the answers on the two questions are
%     % independent. We apply the Fisher exact test, since the data is
%     % measured on an ordinal scale, and we have far to few observations to
%     % apply a Chi2 test. The result of ...
%     [H,P] = fishertest(M)
%     % (-> H = 1, P = 0.0350)
%     % shows that the probability of observing this distribution M or the
%     % more extreme distributions (i.e., only one in this case: [6 0 ; 1
%     8]) is 0.035. Since this is less than 0.05, we can reject our
%     null-hypothesis indicated by H being 1. 
%
%   The Fisher Exact test is most suitable for small numbers of
%   observations, that have been measured on a nominal or ordinal scale.  
%   Note that the values 0 and 1 have only arbitray meanings, and do
%   reflect a nominal category, such as yes/no, short/long, above/below
%   average, etc. In matlab words, So, M, M.', flipud(M), etc.  all give
%   the same results.
%
%   See also SIGNTEST, RANKSUM, KRUSKALWALLIS, TTEST, TTEST2 (Stats Toolbox)
%            PERMTEST, COCHRANQTEST (File Exchange)
%
%   This file does not require the Statistics Toolbox.

% Source: Siegel & Castellan, 1988, "Nonparametric statistics for the
%         behavioral  sciences", McGraw-Hill, New York
%
% Created for Matlab R13+
% version 1.0 (feb 2009)
% (c) Jos van der Geest
% email: jos@jasen.nl
%
% File history:
%   1.0 (feb 2009) - created

error(nargchk(1,2,nargin)) ;

if islogical(M) || all(M(:)==1 | M(:)==0) 
    if ndims(M)==2 && size(M,2)== 2    
        % each row now holds on observation which can be casted in a 2-by-2 contingency table
        M = logical(M) ;
        A = sum(M(:,1) & M(:,2)) ;
        B = sum(M(:,1) & ~M(:,2)) ;
        C = sum(~M(:,1) & M(:,2)) ;
        D = size(M,1) - (A+B+C) ;
        M = [A B ; C D] ;
    else
        error('For logical or (0,1) input, M should be a N-by-2 array.') ;
    end
elseif ~isnumeric(M) || ~isequal(size(M),[2 2]) || any(M(:)~=fix(M(:))) || any(M(:)<0)
    error ('For numerical input, M should be a 2-by-2 matrix with positive integers.')
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('Fishertest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

% what is the minimum value in the input matrix
[minM, minIDX] = min(M(:)) ;

if minM > 20,
    warning(sprintf(['Minimum number of observations is larger than 20.\n' ...
        'Other statistical tests, such as the Chi-square test may be more appropriate.'])) ;
end

% We will move observations from this cell, and from the cell diagonal to
% it, to the other two. This leaves the sum along rows and columns intact,
% but it will make the matrix more extreme. There will be minM matrixes
% that are more extreme than the original one.
% We can do that by summing with the matrix dM (created below) until the
% cell with the least number of observations has become zero (which takes
% minM steps).  
% dM will be either [-1 1 ; 1 -1] or [1 -1 ; -1 1]
dM = ones(2) ;
dM([minIDX (4-minIDX+1)]) = -1 ;

% The row and column sums are always the same
SRC = [sum(M,2).' sum(M,1)] ; % row and column sums
N = SRC(1) + SRC(2) ;          % total number of obervations

if nargout > 2,
    STATS.M = M ; % original matrix
    dt = abs(det(M)) ;
    PRC = prod(SRC) ;       % product of row and column sums
    STATS.phi = dt / sqrt(PRC) ; % Phi coefficient of association
    STATS.Chi2 = (N * (dt - (N/2)).^2) / PRC ; % Chi2 value of independence
end

% pre-allocate the P values for each matrix (the original one and the ones
% more extreme than the original one)
STATS.P = zeros(minM+1,1) ;

% now calculate the probality for observing the matrix M and all the
% matrices that have more extreme distributions. In
for i = 0:minM
    % calculate P value
    STATS.P(i+1) = local_factratio(SRC,[M(:) ; N]) ;    
    % make M more extreme
    M = M + dM ;
end

P = sum(STATS.P) ; % Total probability
H = P < alpha ;    % Is it less then our significance level?, 
                   % If so, we can reject our null-hypothesis 

% END OF MAIN FUNCTION

function FR = local_factratio(A,B)
% See FACTORIALRATIO for detailed help and comments
% http://www.mathworks.com/matlabcentral/fileexchange/23018
A = A(A>1) - 1 ;
B = B(B>1) - 1 ;
maxE = max([A(:) ; B(:) ; 0]) ;
if maxE > 1 && ~isequal(A,B),
    R = sparse(A,1,1,maxE,2) + sparse(B,2,1,maxE,2) ;
    R = flipud(cumsum(flipud(R))) ;    
    R = (R(:,1) - R(:,2)).' ;    
    X = 2:(maxE+1) ;             
    q = find(R) ;     
    FR = prod(X(q).^R(q)) ; 
else
    FR = 1 ;
end

