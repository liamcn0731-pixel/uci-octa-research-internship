clear all;  
close all; 
clc;
tic
project_root = fileparts(fileparts(mfilename('fullpath')));
paths = {
    fullfile(project_root, 'data', 'example_scan', 'OCT Images'), 25;
};

output_root = fullfile(project_root, 'outputs', 'cropped');
if ~exist(output_root, 'dir')
    mkdir(output_root);
end

for idx = 1:size(paths,1)
    path = paths{idx,1};
    vertical_start_position = paths{idx,2};
    inPath = regexprep(path, '[\\/]+$', '');
    safeName = regexprep(inPath, '[:*?"<>|\\\/]', '_');

    out_dir = fullfile(output_root, safeName);
    if ~exist(out_dir, 'dir'), mkdir(out_dir); end

    fprintf('\n>>> Processing folder %d/%d: %s\n', idx, size(paths,1), inPath);
    
    processOCTFolder(path, vertical_start_position, out_dir);
end

function processOCTFolder(path, vertical_start_position, out_dir)

% ----------- 固定参数 -----------
Width = 600;
bscan = 400;
threshold = 0.2;
faverage = 6;
filt_s = [3 3];
save_flag = 1;

frame = bscan * faverage;
cd(path);
mkdir ../OCTA_zhengli

% 预读取一张图像确认尺寸
[im1, ~] = imread('11000.bmp');
im1 = im1(vertical_start_position:vertical_start_position + Width - 1, :);
[height, width] = size(im1);
stack = zeros(height, width, faverage);

% 等待条
status = waitbar(0, 'Please wait...');
h = fspecial('average', [10 10]);

for i = 1:faverage:frame - faverage + 1
    for n = 1:faverage
        fname = sprintf('1%.4d', i + n - 2);
        [im1, ~] = imread(fname, 'bmp');
        im1 = im1(vertical_start_position:vertical_start_position + Width - 1, :);
        outname = sprintf('1%.4d_cropped.bmp', i + n - 2);
        imwrite(im1, fullfile(out_dir, outname));
        % im1 = medfilt2(im1,filt_s);
        stack(:,:,n) = im1;
    end

    % I = double(im1);
    % I_flat = zeros(height, width);
    % [~, Id2] = gradient(I, 20);
    % Idn = Id2 ./ max(max(Id2));
    % [~, l1] = dynamicProgramming(Idn, 1.0, 'none', 'none');
    % l1s = l1';
    I = double(im1);
    I_flat = zeros(height, width);
    I_uint8 = uint8(mat2gray(I) * 255);
    % --- 使用 Canny 提取边界 ---
    % 使用 Otsu 生成高阈值
    level = graythresh(I_uint8);
    high_thresh = level;
    low_thresh = 0.5 * level;
    
    % 得到高、低阈值下的边缘图（binary map）
    high_edge = edge(I_uint8, 'Canny', high_thresh);
    low_edge = edge(I_uint8, 'Canny', low_thresh);
    % 标记弱边缘图中所有连通区域
    cc = bwconncomp(low_edge, 8);  % 8邻域连通
    % 创建空图保存最终边缘
    final_edge = false(size(low_edge));
    
    for j = 1:cc.NumObjects
        pixel_idx = cc.PixelIdxList{j};
        
        % 检查这一簇是否与强边缘有交集
        if any(high_edge(pixel_idx))
            % 如果有连接，则整个弱边缘簇保留
            final_edge(pixel_idx) = true;
        end
    end
    
    % % 最终边缘图像
    %imshow(final_edge);

    edges=final_edge;
    l1s = zeros(1, size(edges, 2));
    for k = 1:size(edges, 2)
        col = edges(:, k);
        idx = find(col, 1, 'first');
        if ~isempty(idx)
            l1s(k) = idx;
        else
            l1s(k) = round(size(edges, 1) / 2); % fallback
        end
    end

    stack2 = zeros(size(im1));
    img_avg = stack(:,:,1);
    for n = 1:faverage - 1
        stack2 = stack2 + abs(stack(:,:,n) - stack(:,:,n + 1));
        img_avg = img_avg + stack(:,:,n + 1);
    end
    im2 = stack2 .* img_avg;
    im3 = im2 ./ max(max(im2));

    im3(im3 < threshold) = 0;

    fname2 = sprintf('../OCTA_zhengli/1%.4d.bmp', i - 1);
    for k = 1:width
        I_flat(1:(height - l1s(k) + 1), k) = im3(l1s(k):end, k);
    end

    if save_flag
        imwrite(I_flat, fname2);
    end

    waitbar((i + 1) / frame, status, ...
        sprintf('Processing Frame %d of %d', i - 1, frame));
end
toc
close(status);
fprintf('Done processing folder: %s\n', path);

end
