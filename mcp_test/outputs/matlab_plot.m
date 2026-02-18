%% MATLAB Engineering Dashboard — 6 Subplot Advanced Demo
%  Showcases: 3D surface, FFT spectrum, ODE45 phase portrait,
%  bimodal histogram, correlation heatmap, polar radar chart

figure('visible','off','Position',[100 100 1600 1000]);

%% 1. 3D Surface — Thermal Field
subplot(2,3,1);
[X,Y] = meshgrid(-3:0.15:3, -3:0.15:3);
Z = peaks(X,Y);
surf(X,Y,Z,'EdgeColor','none');
colormap(subplot(2,3,1), jet); colorbar;
title('Thermal Field Distribution');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Temp (C)');

%% 2. FFT Spectrum Analysis
subplot(2,3,2);
Fs = 1000; t = 0:1/Fs:1-1/Fs;
sig = 0.7*sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.3*randn(size(t));
Y_fft = abs(fft(sig)/length(sig));
Y_fft = Y_fft(1:length(sig)/2+1);
Y_fft(2:end-1) = 2*Y_fft(2:end-1);
f = Fs*(0:(length(sig)/2))/length(sig);
plot(f, Y_fft, 'b-', 'LineWidth', 0.8);
[pks, locs] = findpeaks(Y_fft, f, 'MinPeakHeight', 0.15);
hold on; plot(locs, pks, 'rv', 'MarkerFaceColor','r', 'MarkerSize', 8);
for k=1:length(locs)
    text(locs(k)+5, pks(k), sprintf('%.0f Hz', locs(k)), 'Color','r', 'FontSize',9);
end
title('FFT Spectrum Analysis'); xlabel('Freq (Hz)'); ylabel('|P1(f)|');
xlim([0 200]); grid on;

%% 3. ODE45 Phase Portrait
subplot(2,3,3);
mu = 1.5;
vdp = @(t,y) [y(2); mu*(1-y(1)^2)*y(2)-y(1)];
colors = lines(5);
for k = 1:5
    y0 = [0.5*k; 0];
    [~, y_sol] = ode45(vdp, [0 20], y0);
    plot(y_sol(:,1), y_sol(:,2), 'Color', colors(k,:), 'LineWidth', 1.2);
    hold on;
end
title('Van der Pol Phase Portrait (\mu=1.5)');
xlabel('x'); ylabel('dx/dt'); grid on;

%% 4. Bimodal Histogram + Gaussian Fit
subplot(2,3,4);
rng(42);
data1 = 50 + 8*randn(600,1);
data2 = 80 + 6*randn(400,1);
all_data = [data1; data2];
histogram(all_data, 40, 'Normalization','pdf', 'FaceColor',[0.3 0.6 0.9], 'FaceAlpha',0.6);
hold on;
x_range = linspace(20,110,200);
pd1 = makedist('Normal','mu',50,'sigma',8);
pd2 = makedist('Normal','mu',80,'sigma',6);
plot(x_range, 0.6*pdf(pd1,x_range)+0.4*pdf(pd2,x_range), 'r-', 'LineWidth',2);
title('Bimodal Distribution + Gaussian Fit');
xlabel('Value'); ylabel('Density'); grid on;

%% 5. Correlation Heatmap
subplot(2,3,5);
rng(7);
raw = randn(100,8);
raw(:,2) = raw(:,1)*0.8 + 0.6*randn(100,1);
raw(:,5) = raw(:,3)*-0.7 + 0.7*randn(100,1);
C = corrcoef(raw);
imagesc(C); colorbar; colormap(subplot(2,3,5), parula);
caxis([-1 1]);
labels = {'Temp','Press','Flow','Voltage','Torque','Vibr','RPM','Power'};
set(gca, 'XTick',1:8, 'XTickLabel',labels, 'XTickLabelRotation',45);
set(gca, 'YTick',1:8, 'YTickLabel',labels);
for i=1:8
    for j=1:8
        text(j,i, sprintf('%.2f',C(i,j)), 'HorizontalAlignment','center', 'FontSize',7);
    end
end
title('Sensor Correlation Matrix');

%% 6. Polar Radar Chart
subplot(2,3,6);
categories = {'Throughput','Quality','Uptime','Safety','Energy','Cost'};
values = [0.92 0.88 0.95 0.78 0.85 0.91];
theta = linspace(0, 2*pi, length(values)+1);
rho = [values values(1)];
polarplot(theta, rho, 'b-o', 'LineWidth',2, 'MarkerFaceColor','b');
hold on;
fill_theta = theta; fill_rho = rho;
polarplot(fill_theta, fill_rho, 'b-', 'LineWidth',1);
ax = gca; ax.ThetaTick = rad2deg(theta(1:end-1));
ax.ThetaTickLabel = categories;
ax.RLim = [0 1.1];
title('Factory KPI Radar');

sgtitle('Engineering Analysis Dashboard', 'FontSize', 16, 'FontWeight', 'bold');
print(gcf, 'D:\MCP\mcp_test\outputs\matlab_dashboard.png', '-dpng', '-r200');
fprintf('MATLAB dashboard saved.\n');
exit;