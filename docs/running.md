# 运行与数据配置

## OCTA

MATLAB 中将 `octa/` 加入路径后运行 `runMyGUI`。选择包含 `1/`、`2/`、`3/` 子目录的本地扫描目录，每个子目录下应有 `OCT Images/10000.bmp` 至 `12399.bmp`。预览读取 `10000.bmp`，尺寸检查读取 `11000.bmp`。

在 `CONFIG.folder_settings` 设置各组的起始裁剪行。默认裁剪高度为 600，输入必须有足够行数，且应为灰度图。处理输出在扫描子目录旁的 `OCTA_zhengli/`，裁剪图在所选目录中的 `Cropped_Images_Output/`。Open selected folder 按钮只打开目录，重切片需在 ImageJ 中执行宏。

`V2.m` 保留批处理版本，需先修改 `paths` 中的示例目录与起始行。该历史脚本会改变 MATLAB 当前工作目录，建议单独会话运行。

## Python 分析与 VSQ GUI

在仓库根目录安装依赖。`data/testdata_summary.xlsx` 需要 Aim1Pre/Aim1Peri/Aim1Post 工作表，分类脚本使用 VET、BVD、VSQ、AGE 列。

```bash
python modeling/classification.py
python modeling/vsq_gui.py
```

分类脚本将模型写入 `artifacts/classification.joblib`，GUI 使用特征顺序 `[VET, BVD, AGE]`。未提供预训练模型，因此先用适当授权的数据训练。

`Correlation.py` 是历史宽表分析脚本，需要 Sheet1 及 VET1/2/3、BVD1/2/3、VHI1/2、VSQ1/2/3、AGE、VHI 等列，不能直接替换为阶段长表。`res_analysis.py` 当前目标为 VSQ，只拟合 Aim1Post 的 VET/BVD，不是报告中 VHI 线性方程的复现脚本。

## MATLAB VHI

`data/mydata.xlsx` 需有 Aim1Pre/Aim1Peri/Aim1Post 工作表及 VET、BVD、VHI 列。脚本读取 A1:H32，需按自己的表格范围调整。模型及图表写入 `artifacts/`，训练模型未与 Python GUI 集成。
