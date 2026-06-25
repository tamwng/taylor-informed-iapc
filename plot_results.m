function plot_results(results,p)
labels = cellfun(@(s) sprintf('D = %d',s.D),results, ...
    'UniformOutput',false);
activationTime = p.id.Nid*p.plant.Ts;

if p.output.save && ~exist(p.output.folder,'dir')
    mkdir(p.output.folder);
end

figure('Name','State tracking','Color','w');
hold on;
plot(results{1}.time,results{1}.reference,'k--', ...
    'LineWidth',1.5,'DisplayName','Reference');
for i = 1:numel(results)
    plot(results{i}.time,results{i}.x,'LineWidth',1.1, ...
        'DisplayName',labels{i});
end
yline(p.constraints.xMax,':','HandleVisibility','off');
yline(-p.constraints.xMax,':','HandleVisibility','off');
xline(activationTime,':','MPC on','HandleVisibility','off');
xlabel('Time (s)'); ylabel('State x'); grid on;
legend('Location','best');
if p.output.save
    saveas(gcf,fullfile(p.output.folder,'state_tracking.png'));
end

figure('Name','Control input','Color','w');
hold on;
for i = 1:numel(results)
    stairs(results{i}.time,results{i}.u,'LineWidth',1.1, ...
        'DisplayName',labels{i});
end
yline(p.constraints.uMax,':','HandleVisibility','off');
yline(-p.constraints.uMax,':','HandleVisibility','off');
xline(activationTime,':','MPC on','HandleVisibility','off');
xlabel('Time (s)'); ylabel('Input u'); grid on;
legend('Location','best');
if p.output.save
    saveas(gcf,fullfile(p.output.folder,'control_input.png'));
end

figure('Name','Absolute tracking error','Color','w');
hold on;
for i = 1:numel(results)
    errorMagnitude = abs(results{i}.x - results{i}.reference);
    semilogy(results{i}.time,max(errorMagnitude,1e-12), ...
        'LineWidth',1.1,'DisplayName',labels{i});
end
xline(activationTime,':','MPC on','HandleVisibility','off');
xlabel('Time (s)'); ylabel('|x-r|'); grid on;
legend('Location','best');
if p.output.save
    saveas(gcf,fullfile(p.output.folder,'tracking_error_log.png'));
end

selected = find(cellfun(@(s) s.D == p.plot.jacobianDegree,results),1);
if ~isempty(selected)
    current = results{selected};
    mask = current.k >= p.id.Nid;
    figure('Name','Jacobian comparison','Color','w');
    subplot(2,1,1);
    plot(current.time(mask),current.Ahat(mask),'LineWidth',1.1); hold on;
    plot(current.time(mask),current.Afe(mask),'k--','LineWidth',1.1);
    ylabel('A'); grid on;
    legend('Identified','Analytical FE','Location','best');
    title(sprintf('Jacobian comparison, D = %d',current.D));

    subplot(2,1,2);
    plot(current.time(mask),current.Bhat(mask),'LineWidth',1.1); hold on;
    plot(current.time(mask),current.Bfe(mask),'k--','LineWidth',1.1);
    xlabel('Time (s)'); ylabel('B'); grid on;
    legend('Identified','Analytical FE','Location','best');
    if p.output.save
        saveas(gcf,fullfile(p.output.folder,'jacobian_comparison.png'));
    end
end
end
