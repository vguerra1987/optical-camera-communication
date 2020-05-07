function easyplot(data, style, output_image)
% This function plots and optionally exports an image using a simple
% configuration interface. data is an array of registers. Each position
% must define xdata, ydata, xlabel, ylabel, legend, colors and linestyles.
% ydata can be a matrix with the information to be plot introduced as
% columns. Since data is an array itself, one subplot per position will be
% displayed. style defines the overall appearance of the plot, it can be
% one of the following: light, strong or sexy. output_image defines the
% name of the generated image (must include extension).

%% Argument control
if nargin == 2
    output_image = 'none';
end

%% Style definition
if strcmp(style, 'light')
    box = 'off';
    linewidth = 1.0;
    plotlinewidth = 1.0;
    xgrid = 'on';
    ygrid = 'on';
    fontsize = 16;
    axesfontsize = 14;
elseif strcmp(style, 'strong')
    box = 'on';
    linewidth = 2.0;
    plotlinewidth = 1.5;
    xgrid = 'on';
    ygrid = 'on';
    fontsize = 16;
    axesfontsize = 16;
elseif strcmp(style, 'sexy')
    box = 'on';
    linewidth = 1.5;
    plotlinewidth = 1.0;
    xgrid = 'off';
    ygrid = 'off';
    fontsize = 14;
    axesfontsize = 14;
else
    error('Must define one of the following styles: light, strong or sexy');
end

%% Plot generation

figure('color','white');

% Organizing plot locations
L = length(data);

plotsPerRow = ceil(sqrt(L));
numRows = ceil(L/plotsPerRow);
lastRowCols = rem(L,plotsPerRow);

padding_top  = 0.05;
padding_bottom = 0.15;
padding_left = 0.1;
padding_right = 0.05;
padding_central = 0.1;

height = (1 - padding_top - padding_bottom - (numRows-1)*padding_central)/numRows;
width = (1 - padding_left - padding_right - (plotsPerRow-1)*padding_central)/plotsPerRow;

% Now we plot the data itself except the final row
count = 1;
for I = 1:numRows-double(lastRowCols ~= 0)
    for J = 1:plotsPerRow
        
        xdata = data(count).xdata;
        ydata = data(count).ydata;
        colors = data(count).colors;
        styles = data(count).styles;
        leg = data(count).legend;
        
        posX = padding_left + width*(J-1) + padding_central*(J-1)
        posY = padding_bottom + height*(I-1) + padding_central*(I-1)
        subplot('position', [posX, posY, width, height]);
        hold on
        for K = 1:size(ydata,2)
            plot(xdata, ydata(:,K), [colors{K} styles{K}], 'LineWidth', plotlinewidth);
        end
        hold off
        
        xlabel(data(count).xlabel, 'Interpreter', 'latex', 'FontSize', fontsize);
        ylabel(data(count).ylabel, 'Interpreter', 'latex', 'FontSize', fontsize);
        
        set(gca,'box',box,'linewidth',linewidth, ...
            'xgrid',xgrid, 'ygrid',ygrid,'fontsize',axesfontsize);
        
        legend(leg, 'Interpreter', 'latex', 'FontSize', fontsize);
        
        count = count + 1;
    end
end

% Finally we plot the final row
posY = padding_bottom + height*(numRows-1) + padding_central*(numRows-1);
lastRowLeftMargin = (1 - lastRowCols*width - (lastRowCols-1)*padding_central)/2;
for J = 1:lastRowCols
    
    posX = lastRowLeftMargin + width*(J-1) + padding_central*(J-1);
    subplot('position', [posX, posY, width, height]);
    hold on
    for K = 1:size(data(count),2)
        plot(xdata, ydata(:,K), [colors{K} styles{K}], 'LineWidth', plotlinewidth);
    end
    hold off
    
    xlabel(data(count).xlabel, 'Interpreter', 'latex', 'FontSize', fontsize);
    ylabel(data(count).ylabel, 'Interpreter', 'latex', 'FontSize', fontsize);
    
    set(gca,'box',box,'linewidth',linewidth, ...
        'xgrid',xgrid, 'ygrid',ygrid,'fontsize',axesfontsize,...
        'tickLabelInterpreter','latex');
    
    legend(leg, 'Interpreter', 'latex', 'FontSize', fontsize);
    
    count = count + 1;
end

%% Final export
if strcmp(output_image, 'none')
    return
else
    splitstr = strsplit(output_image, '.');
    extension = splitstr{end};
    
    % Name conformation allowing '.' character in the filename
    name = [];
    for I = 1:length(splitstr)-1
        name = [name splitstr{I}];
    end
    
    % Paper size and PaperPosition control must be controlled yet
    set(gcf, 'PaperSize', [20*plotsPerRow 20*numRows]);
    % set(gcf, 'PaperPositionMode','auto');
    set(gcf, 'PaperPosition', [0 0 20*plotsPerRow 20*numRows]);
    set(gcf,'Position',[0 0 20*plotsPerRow 20*numRows]);

    print(name, ['-d' extension]);
end