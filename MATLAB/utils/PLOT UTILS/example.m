%% USAGE EXAMPLE SCRIPT

% First we must prepare the data structures
% Each element of the array will be displayed in a separate subplot
DATA(1).xdata = linspace(1,10,100);
DATA(1).ydata = randn(100,3);
DATA(1).xlabel='$\mu$ (m)';
DATA(1).ylabel='Number of repetitions';
DATA(1).colors={'k','k','k'};
DATA(1).styles={'-','--','-*'};
DATA(1).legend={'$m=0$','$m=1$','$m=2$'};

DATA(2).xdata = linspace(1,10,100);
DATA(2).ydata = randn(100,2);
DATA(2).xlabel='$\kappa$ (s)';
DATA(2).ylabel='Height (m)';
DATA(2).colors={'r','g'};
DATA(2).styles={'-','-'};
DATA(2).legend={'with','without'};

easyplot(DATA, 'strong');