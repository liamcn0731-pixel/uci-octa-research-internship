function runMyGUI()
    % --- 用户配置区域 ---
    % 在这里为每个子文件夹 "1", "2", "3" 设置对应的 vertical_start_position
    % 格式: { '文件夹名', vertical_start_position; ... }
    CONFIG.folder_settings = { ...
        '1', 25; ...  
        '2', 25; ...  
        '3', 25  ...  
    };
    % 您处理代码中的固定参数
    CONFIG.Width = 600;
    CONFIG.bscan = 400;
    CONFIG.threshold = 0.2;
    CONFIG.faverage = 6;
    CONFIG.result_path = '';
    % --- 配置结束 ---
    
    % --- GUI 界面创建 ---
    fig = uifigure('Name', 'OCT Images Processing', 'Position', [100 100 700 500]);
    
    % 将配置存储在 figure 中，方便所有函数调用
    fig.UserData.CONFIG = CONFIG;

    ax = uiaxes(fig, 'Position', [20 80 450 460]);
    title(ax, 'show image');
    xticklabels(ax, {}); yticklabels(ax, {});

    selectBtn = uibutton(fig, 'push', 'Text', '1. choose the path', ...
                       'Position', [500, 420, 150, 40], ...
                       'ButtonPushedFcn', @selectFolder_Callback);

    processBtn = uibutton(fig, 'push', 'Text', '2. start process', ...
                        'Position', [500, 360, 150, 40], 'Enable', 'off', ...
                        'ButtonPushedFcn', @processing_Callback);

    openBtn = uibutton(fig, 'push', 'Text', 'Open selected folder', ...
                       'Position', [500, 300, 150, 40], ... 
                       'ButtonPushedFcn', @openResultFolder_Callback); 

    pathLabel = uilabel(fig, 'Text', '当前路径:', 'Position', [20 50 80 22]);
% ... (后面代码不变) ...
    pathLabel = uilabel(fig, 'Text', 'path:', 'Position', [20 50 80 22]);
    pathDisplay = uitextarea(fig, 'Value', {'no path exist'}, ...
                                 'Position', [100 20 550 60], 'Editable', 'off');

    handles.ax = ax;
    handles.processBtn = processBtn;
    handles.selectBtn = selectBtn;
    handles.pathDisplay = pathDisplay;
    fig.UserData.handles = handles;
end

% --- "选择文件夹" 按钮的回调函数 (与之前版本基本相同) ---
function selectFolder_Callback(src, event)
    fig = src.Parent;
    handles = fig.UserData.handles;
    basePath = uigetdir('', 'Choose the root path include folder "1", "2", "3" ');
    if basePath == 0, return; end
    figure(fig);
    previewFolderPath = fullfile(basePath, '1', 'OCT Images');
    if ~isfolder(previewFolderPath)
        uialert(fig, ['error: Cannot find folder "1\OCT Images": ' basePath], 'Invalid path');
        handles.processBtn.Enable = 'off';
        handles.pathDisplay.Value = {'Invalid folder path'};
        cla(handles.ax); title(handles.ax, 'iamge');
        return;
    end
    
    handles.pathDisplay.Value = {basePath};
    handles.basePath = basePath;
    fig.UserData.CONFIG.result_path = basePath;
    fig.UserData.handles = handles;
    handles.processBtn.Enable = 'on';

    % 预览图片，注意这里文件名和格式需要匹配您的文件
    previewImagePath = fullfile(previewFolderPath, '10000.bmp'); % <-- 修改为您预览文件的准确名称
    if isfile(previewImagePath)
        try
            img = imread(previewImagePath);
            imshow(img, 'Parent', handles.ax);
            title(handles.ax, 'Load: .../1/OCT Images/10000.bmp');
        catch ME
            uialert(fig, ['Cannot load the image: ' ME.message], 'Failed');
        end
    else
        uialert(fig, 'Cannot find the image 10000.bmp', 'Failed');
    end
end

function processing_Callback(src, event)
    fig = src.Parent;
    handles = fig.UserData.handles;
    CONFIG = fig.UserData.CONFIG;
    

    cleanupObj = onCleanup(@() setButtonsState(handles, 'on'));
    
    % 一开始就禁用按钮
    setButtonsState(handles, 'off');
    
    basePath = handles.basePath;
    % crop图片的统一输出根目录
    output_root = fullfile(basePath, 'Cropped_Images_Output'); 
    if ~exist(output_root, 'dir'), mkdir(output_root); end
    
    h_dialog = uiprogressdlg(fig, 'Title', 'Wait', 'Message', 'Start processing...', 'Cancelable', 'on');
    
    try
        paths_to_process = CONFIG.folder_settings;
        total_folders = size(paths_to_process, 1);


        folder_to_check = 'OCT Images';

        for idx = 1:total_folders
            if h_dialog.CancelRequested
                break;
            end
            
            subFolderName = paths_to_process{idx, 1};
            vertical_start_position = paths_to_process{idx, 2};
            
            inPath = fullfile(basePath, subFolderName, folder_to_check);
            
            if ~isfolder(inPath)
                warning(['Warning: Cannot find folder ', inPath, ', skipped.']);
                continue;
            end
            
            safeName = regexprep(inPath, '[:*?"<>|\\\/]', '_');
            out_dir = fullfile(output_root, safeName);
            if ~exist(out_dir, 'dir'), mkdir(out_dir); end
            
            fprintf('\n>>> Processing folder %d/%d: %s\n', idx, total_folders, inPath);
            h_dialog.Message = sprintf('Processing  folder %d/%d...', idx, total_folders);
            
            processOCTFolder_adapted(inPath, vertical_start_position, out_dir, h_dialog, CONFIG);
        end
        
        % 在处理结束后，根据对话框状态给出提示
        if h_dialog.CancelRequested
            close(h_dialog);
            uialert(fig, '处理被用户取消。', '操作取消');
        else
            close(h_dialog);
            uialert(fig, '所有文件夹处理完成!', 'Success');
        end

    catch ME
        if isvalid(h_dialog)
            close(h_dialog);
        end
        uialert(fig, ['处理过程中发生致命错误: ' ME.message], 'Error');
        % 注意：因为有cleanupObj，这里不再需要手动重置按钮状态
    end
end

% 一个辅助函数，用于统一管理按钮状态，避免重复代码
function setButtonsState(handles, state)
    handles.processBtn.Enable = state;
    handles.selectBtn.Enable = state;
end

% --- 您适配后的图像处理核心函数 ---
function processOCTFolder_adapted(path, vertical_start_position, out_dir, h_dialog, CONFIG)
    % 从CONFIG结构体中获取参数
    Width = CONFIG.Width;
    bscan = CONFIG.bscan;
    threshold = CONFIG.threshold;
    faverage = CONFIG.faverage;
    save_flag = 1;
    frame = bscan * faverage;
    
    % 为 "OCTA_zhengli" 创建输出目录，路径更安全
    parent_dir = fileparts(path); 
    zhengli_out_dir = fullfile(parent_dir, 'OCTA_zhengli');
    if ~exist(zhengli_out_dir, 'dir'), mkdir(zhengli_out_dir); end


    % 预读取一张图像确认尺寸
    [im1, ~] = imread(fullfile(path, '11000.bmp')); % 使用 fullfile
    im1 = im1(vertical_start_position:vertical_start_position + Width - 1, :);
    [height, width] = size(im1);
    stack = zeros(height, width, faverage);
    
    total_frames_to_process = frame - faverage + 1;
    
    for i = 1:faverage:total_frames_to_process
        % 检查用户是否点击了取消按钮
        if h_dialog.CancelRequested, break; end

        for n = 1:faverage
            % 文件名从 10000 开始，所以是 i+n-2+10000-1 = i+n+9998
            % 您的命名 '1%.4d' 从 i=1, n=1 时生成 '10000'
            % i+n-2 = 0 -> 10000, i+n-2=1 -> 10001
            % sprintf('1%.4d', i + n - 2) 会产生 10000, 10001...
            % 这里假设您的文件名是 10000.bmp, 10001.bmp ...
            fname_num = 10000 + i + n - 2;
            fname = sprintf('%d.bmp', fname_num);
            
            % --- 关键改动：使用 fullfile 读取 ---
            full_fname_path = fullfile(path, fname);
            if ~isfile(full_fname_path)
                warning('文件不存在，跳过: %s', full_fname_path);
                continue;
            end

            [im1, ~] = imread(full_fname_path);
            im1 = im1(vertical_start_position:vertical_start_position + Width - 1, :);
            
            % 保存裁剪后的图片
            outname = sprintf('%d_cropped.bmp', fname_num);
            imwrite(im1, fullfile(out_dir, outname));
            stack(:,:,n) = im1;
        end
   
        I = double(im1);
        I_uint8 = uint8(mat2gray(I) * 255);
        level = graythresh(I_uint8);
        high_edge = edge(I_uint8, 'Canny', level);
        low_edge = edge(I_uint8, 'Canny', 0.5 * level);
        
        cc = bwconncomp(low_edge, 8);
        final_edge = false(size(low_edge));
        for j = 1:cc.NumObjects
            pixel_idx = cc.PixelIdxList{j};
            if any(high_edge(pixel_idx))
                final_edge(pixel_idx) = true;
            end
        end
        
        edges = final_edge;
        l1s = zeros(1, size(edges, 2));
        for k = 1:size(edges, 2)
            idx = find(edges(:, k), 1, 'first');
            if ~isempty(idx)
                l1s(k) = idx;
            else
                l1s(k) = round(size(edges, 1) / 2);
            end
        end
        
        stack2 = zeros(size(im1));
        img_avg = stack(:,:,1);
        for n = 1:faverage - 1
            stack2 = stack2 + abs(stack(:,:,n) - stack(:,:,n + 1));
            img_avg = img_avg + stack(:,:,n + 1);
        end
        
        im2 = stack2 .* img_avg;
        im3 = im2 ./ max(im2(:));
        im3(im3 < threshold) = 0;

        I_flat = zeros(size(im1));
        for k = 1:width
            if l1s(k) > 0 && l1s(k) <= height
                len = height - l1s(k) + 1;
                I_flat(1:len, k) = im3(l1s(k):end, k);
            end
        end
        
        if save_flag
            % --- 关键改动：使用 fullfile 保存到 zhengli_out_dir ---
            fname2_num = 10000 + i - 1;
            fname2 = sprintf('%d.bmp', fname2_num);
            imwrite(I_flat, fullfile(zhengli_out_dir, fname2));
        end
        

        progress = i / total_frames_to_process;
        h_dialog.Value = progress;
        h_dialog.Message = sprintf('processing... (%d%%)', round(progress*100));
    end
    fprintf('Done processing folder: %s\n', path);
end

function openResultFolder_Callback(src, event)
    % 获取 figure 对象
    fig = src.Parent;
    
    % 从 UserData 中读取我们配置好的固定路径
    CONFIG = fig.UserData.CONFIG;
    folderPath = CONFIG.result_path;

    % 安全检查：首先确认这个文件夹是否存在
    if ~isfolder(folderPath)
        % 如果文件夹不存在，给用户一个清晰的错误提示
        uialert(fig, ['错误: 无法找到指定的文件夹: ' folderPath], '路径不存在');
        return; % 结束函数，不做任何事
    end

    % 如果文件夹存在，就用系统对应的命令打开它
    % 这段代码可以兼容 Windows, Mac 和 Linux
    try
        if ispc % 如果是 Windows 系统
            winopen(folderPath);
        elseif ismac % 如果是 Mac 系统
            system(['open "' folderPath '"']);
        else % 如果是 Linux 系统
            system(['xdg-open "' folderPath '"']);
        end
    catch ME
        % 如果打开失败，也给一个提示
        uialert(fig, ['尝试打开文件夹时出错: ' ME.message], '操作失败');
    end
end