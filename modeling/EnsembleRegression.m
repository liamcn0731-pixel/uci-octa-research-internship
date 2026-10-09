clear;
clc;
project_root = fileparts(fileparts(mfilename('fullpath')));
artifact_dir = fullfile(project_root, 'artifacts');
if ~exist(artifact_dir, 'dir'), mkdir(artifact_dir); end

filename = fullfile(project_root, 'data', 'mydata.xlsx');
sheets = {'Aim1Pre', 'Aim1Peri', 'Aim1Post'};
colors = {'r','g','b'};
labels = {'Pre', 'Peri', 'Post'};

X_all = [];
y_all = [];
group_all = [];
clean_counts = zeros(length(sheets), 1);

for i = 1:length(sheets)
    T = readtable(filename, 'Sheet', sheets{i}, 'Range', 'A1:H32');

    VET = T.VET;
    BVD = T.BVD;
    VHI = T.VHI;

    % IQR-based cleaning
    Q1_VET = quantile(VET, 0.25); Q3_VET = quantile(VET, 0.75);
    IQR_VET = Q3_VET - Q1_VET;
    vet_mask = VET >= (Q1_VET - 1.5 * IQR_VET) & VET <= (Q3_VET + 1.5 * IQR_VET);

    Q1_BVD = quantile(BVD, 0.25); Q3_BVD = quantile(BVD, 0.75);
    IQR_BVD = Q3_BVD - Q1_BVD;
    bvd_mask = BVD >= (Q1_BVD - 1.5 * IQR_BVD) & BVD <= (Q3_BVD + 1.5 * IQR_BVD);

    mask = vet_mask & bvd_mask;
    clean_counts(i) = sum(mask);
    fprintf('%s group: %d samples remain after IQR cleaning.\n', labels{i}, clean_counts(i));

    % Predictors
    X = [VET(mask), BVD(mask), VET(mask).^2];  % You can expand this if desired
    y = VHI(mask);

    X_all = [X_all; X];
    y_all = [y_all; y];
    group_all = [group_all; repmat(i, length(y), 1)];
end

% Fit ensemble regression model using LSBoost
rng(1); % for reproducibility
Mdl = fitrensemble(X_all, y_all, ...
    'Method', 'LSBoost', ...
    'NumLearningCycles', 100, ...
    'LearnRate', 0.1);

% Predict and evaluate
y_pred = predict(Mdl, X_all);
y_pred = min(max(y_pred, 0), 25);  % Clip to [0, 25] range

% Correlation and MAE
R = corr(y_pred, y_all);
MAE = mean(abs(y_pred - y_all));
fprintf('\nEnsemble Regression (LSBoost) - Pearson r = %.3f\n', R);
fprintf('Mean Absolute Error = %.2f\n', MAE);
%save and load: data = load('trainedEnsembleModel.mat', 'Mdl');

save(fullfile(artifact_dir, 'trainedEnsembleModel.mat'), 'Mdl');

figure; hold on;
for i = 1:length(sheets)
    idx = group_all == i;
    scatter(y_all(idx), y_pred(idx), 70, colors{i}, 'filled', ...
        'MarkerEdgeColor', 'k', ...
        'DisplayName', sprintf('%s (%d)', labels{i}, clean_counts(i)));
end
plot([5 25], [5 25], 'k-', 'LineWidth', 1.5, 'DisplayName', 'Ideal Line');

xlabel('Actual VHI', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Predicted VHI', 'FontSize', 14, 'FontWeight', 'bold');

% 调整 axes 位置（图往下缩）
ax = gca;
ax.Position(4) = ax.Position(4) * 0.9;  % 减少高度

% 再抬高标题
t = title('Predicted vs. Actual VHI using Ensemble Model', ...
    'FontSize', 14, 'FontWeight', 'bold');
t.Units = 'normalized';
t.Position(2) = t.Position(2) + 0.07;

legend('Location', 'southeast', 'FontSize', 12, 'Box', 'off');
xlim([0 25]); ylim([0 25]); axis square;
grid on;
set(gca, 'FontSize', 12, 'FontWeight', 'bold');
set(gcf, 'Color', 'w');

exportgraphics(gcf, fullfile(artifact_dir, 'Predicted_vs_Actual_VHI.png'), 'Resolution', 600);

