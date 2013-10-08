%% plot wdatasummary
load('wSig_summary.mat')
u=(blocks.nogo_setpoint_trials_width{1,1}(:,2))';
l=(blocks.nogo_setpoint_trials_width{1,1}(:,1))';
y=(blocks.nogo_setpoint_trials_med{1,1}(:,1))';
x=[1:60];
[fillhandle,msg]=jbfill(x,u,l,rand(1,3),rand(1,3),0,rand(1,1))

fillhandle =

   30.0187


msg =

     ''


hold on; plot(x,y,'r')
