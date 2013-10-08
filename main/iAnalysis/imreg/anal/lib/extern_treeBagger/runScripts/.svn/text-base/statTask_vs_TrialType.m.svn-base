% Test for any modulation in Ca2++ response by task and trial_type
function [P1 P2 P3] = statTask_vs_TrialType (trial_type,y_trial,timeBlock,alpha)
% timeBlock:           is an array of vectors indicating the range of time to be considered as pre_task, task, post_task (for instance)
N_trials               = size(y_trial,1);
N_blocks               = length(timeBlock);
y_block                = zeros(N_trials,N_blocks);

for i=1:N_blocks,
    y_block(:,i)   = mean(y_trial(:,timeBlock{i}),2);
end
matrixX = zeros(N_trials*N_blocks,4);
for i=1:N_trials,
    for j=1:N_blocks
        matrixX((i-1)*N_blocks+j,1) = y_block(i,j);        
        matrixX((i-1)*N_blocks+j,2) = squeeze(trial_type(i));
        matrixX((i-1)*N_blocks+j,3) = j;        
        matrixX((i-1)*N_blocks+j,4) = i;

    end
end
[P1 P2 P3] = BWAOV2 (matrixX,alpha);