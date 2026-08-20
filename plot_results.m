function figures = plot_results(results,p)
%PLOT_RESULTS Create deterministic, publication-quality result figures.

% Windows accessibility text scaling can force Scrollable='on' even for
% fixed-size invisible figures. It does not affect exported axes content.
warningState = warning('off','MATLAB:uicontainer:ScrollableOnWithTextScaling');
warningCleanup = onCleanup(@() warning(warningState));

labels = cellfun(@(s) sprintf('$D = %d$',s.D),results, ...
    'UniformOutput',false);
activationTime = p.id.Nid*p.plant.Ts;

if p.output.save && ~exist(p.output.folder,'dir')
    mkdir(p.output.folder);
end

figures.stateTracking = plot_state_tracking(results,p,activationTime);
figures.trackingError = plot_tracking_error(results,p,labels,activationTime);
figures.segmentError = plot_segment_error_bars(results,p);

if p.plot.showControlInput
    figures.controlInput = plot_control_input(results,p,labels,activationTime);
end

if p.plot.showJacobianComparison
    figures.jacobianComparison = plot_jacobian_comparison(results,p);
end
end


function fig = plot_state_tracking(results,p,activationTime)

mainDegrees = [1 5];
fig = new_figure('State tracking main comparison',p);
ax = axes(fig);
hold(ax,'on');

plot(ax,results{1}.time,results{1}.reference,'k--','LineWidth',1.9, ...
    'DisplayName','Reference');

for d = mainDegrees
    idx = find(cellfun(@(s) s.D == d,results),1);
    if isempty(idx)
        continue;
    end

    width = 1.1;
    if d == 1
        width = 1.6;
    elseif d == 5
        width = 1.0;
    end

    plot(ax,results{idx}.time,results{idx}.x,'LineWidth',width, ...
        'DisplayName',sprintf('$D = %d$',d));
end

yline(ax,p.constraints.xMax,':','HandleVisibility','off');
yline(ax,-p.constraints.xMax,':','HandleVisibility','off');
xline(ax,activationTime,':','MPC on','HandleVisibility','off', ...
    'LabelOrientation','horizontal');
xlabel(ax,'$t$ (s)');
ylabel(ax,'$x$');
grid(ax,'on');
legend(ax,'Location','northeast');
configure_axes(ax);
save_figure(fig,p,'state_tracking_D1_D5.png');
end


function fig = plot_control_input(results,p,labels,activationTime)

fig = new_figure('Control input',p);
ax = axes(fig);
hold(ax,'on');

for i = 1:numel(results)
    stairs(ax,results{i}.time,results{i}.u,'LineWidth',1.1, ...
        'DisplayName',labels{i});
end

yline(ax,p.constraints.uMax,':','HandleVisibility','off');
yline(ax,-p.constraints.uMax,':','HandleVisibility','off');
xline(ax,activationTime,':','MPC on','HandleVisibility','off', ...
    'LabelOrientation','horizontal');
xlabel(ax,'$t$ (s)');
ylabel(ax,'$u$');
grid(ax,'on');
legend(ax,'Location','best');
configure_axes(ax);
save_figure(fig,p,'control_input.png');
end


function fig = plot_tracking_error(results,p,labels,activationTime)

fig = new_figure('Absolute tracking error',p);
ax = axes(fig);
ax.YScale = 'log';
hold(ax,'on');

for i = 1:numel(results)
    if ~ismember(results{i}.D,p.plot.errorDegrees)
        continue;
    end

    errorMagnitude = abs(results{i}.reference - results{i}.x);
    width = 1.1;
    if results{i}.D == 1
        width = 1.6;
    elseif results{i}.D == 5
        width = 1.0;
    end

    plot(ax,results{i}.time,errorMagnitude + 1e-8, ...
        'LineWidth',width,'DisplayName',labels{i});
end

xline(ax,activationTime,':','MPC on','HandleVisibility','off', ...
    'LabelOrientation','horizontal');
xlabel(ax,'$t$ (s)');
ylabel(ax,'$|r-x|$');
ylim(ax,[1e-8 1]);
grid(ax,'on');
legend(ax,'Location','northeast');
configure_axes(ax);
assert(strcmp(ax.YScale,'log'),'Tracking-error axes must be logarithmic.');
save_figure(fig,p,'tracking_error_log.png');
end


function fig = plot_segment_error_bars(results,p)

if ~(isfield(p.reference,'type') && strcmpi(p.reference.type,'amp_sine'))
    fig = gobjects(0);
    return;
end

degrees = cellfun(@(s) s.D,results);
ampLevels = p.reference.ampLevels(:);
errorTable = NaN(numel(ampLevels),numel(degrees));

for i = 1:numel(results)
    current = results{i};
    k = current.k;
    error = current.x - current.reference;

    for j = 1:numel(ampLevels)
        segmentStart = p.id.Nid + (j-1)*p.reference.Kr;
        segmentStop = segmentStart + p.reference.Kr;
        periodSamples = round(1/(p.reference.frequencyHz*p.plant.Ts));
        evaluationStart = min(segmentStart + periodSamples,segmentStop-1);
        mask = k >= evaluationStart & k < segmentStop;
        errorTable(j,i) = mean(abs(error(mask)));
    end
end

fig = new_figure('Per-amplitude evaluated error',p);
ax = axes(fig);
bar(ax,ampLevels,errorTable);
xlabel(ax,'Sine amplitude');
ylabel(ax,'Evaluated mean absolute error');
grid(ax,'on');
legend(ax,arrayfun(@(d) sprintf('$D = %d$',d),degrees, ...
    'UniformOutput',false),'Location','best');
configure_axes(ax);
save_figure(fig,p,'per_amplitude_abs_error.png');
end


function fig = plot_jacobian_comparison(results,p)

selected = find(cellfun(@(s) s.D == p.plot.jacobianDegree,results),1);
if isempty(selected)
    fig = gobjects(0);
    return;
end

current = results{selected};
mask = current.k >= p.id.Nid;
fig = new_figure('Optional forward-Euler Jacobian diagnostic',p);

ax1 = subplot(2,1,1,'Parent',fig);
plot(ax1,current.time(mask),current.Ahat(mask),'LineWidth',1.1);
hold(ax1,'on');
plot(ax1,current.time(mask),current.Afe(mask),'k--','LineWidth',1.1);
ylabel(ax1,'$A$');
grid(ax1,'on');
legend(ax1,'Identified','Analytical FE','Location','best');
title(ax1,sprintf('Optional FE diagnostic, $D = %d$',current.D));
configure_axes(ax1);

ax2 = subplot(2,1,2,'Parent',fig);
plot(ax2,current.time(mask),current.Bhat(mask),'LineWidth',1.1);
hold(ax2,'on');
plot(ax2,current.time(mask),current.Bfe(mask),'k--','LineWidth',1.1);
xlabel(ax2,'$t$ (s)');
ylabel(ax2,'$B$');
grid(ax2,'on');
legend(ax2,'Identified','Analytical FE','Location','best');
configure_axes(ax2);
save_figure(fig,p,'jacobian_comparison.png');
end


function fig = new_figure(name,p)

fig = figure('Name',name,'Color','w', ...
    'Visible',p.output.figureVisible, ...
    'Position',p.plot.figurePosition, ...
    'Scrollable','off', ...
    'Renderer',p.plot.renderer);
end


function configure_axes(ax)

set(ax,'TickLabelInterpreter','latex','FontSize',14,'LineWidth',1.0);
ax.XLabel.Interpreter = 'latex';
ax.YLabel.Interpreter = 'latex';
ax.Title.Interpreter = 'latex';
if ~isempty(ax.Legend)
    ax.Legend.Interpreter = 'latex';
    ax.Legend.FontSize = 13;
end
end


function save_figure(fig,p,filename)

if p.output.save && isgraphics(fig)
    drawnow;
    exportgraphics(fig,fullfile(p.output.folder,filename), ...
        'Resolution',p.plot.resolution,'BackgroundColor','white');
end
end
