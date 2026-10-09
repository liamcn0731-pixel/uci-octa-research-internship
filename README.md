# UCI 暑期科研实习：OCT/OCTA 图像处理与健康指标建模

**Zheng Li · University of California, Irvine · Faculty mentor: Zhongping Chen**

本项目整理暑期实习中围绕内窥 OCT/OCTA 的图像处理与统计建模工作：改进组织上边界检测与展平流程，开发 MATLAB 处理界面，并探索影像特征与 VHI、VSQ 的关系。

## 我的工作

| 工作方向 | 实现内容 | 仓库入口 |
|---|---|---|
| OCTA 图像处理 | 采用 Otsu 阈值、两次 Canny 边缘提取和连通域筛选构造上边界，进行组织展平与重复帧差分处理 | [V2.m](octa/V2.m) |
| MATLAB GUI | 文件夹选择、B-scan 预览、多组扫描处理、进度显示与取消处理 | [runMyGUI.m](octa/runMyGUI.m) |
| ImageJ 自动化 | 将 Reslice 与 Grouped Z Project 操作组合成宏 | [reslice_group.ijm](octa/reslice_group.ijm) |
| 统计与机器学习 | 相关性分析、OLS 探索、LSBoost 回归、基于影像特征和年龄的 VSQ 分类 | [modeling](modeling) |
| 预测界面 | Tkinter 原型，用 VET、BVD、AGE 调用训练后的 VSQ 分类器 | [vsq_gui.py](modeling/vsq_gui.py) |

更完整的工作背景、结果依据与版本差异见 [实习工作总结](docs/internship_summary.md)。

## 处理流程

```text
重复 B-scan 序列
  → 按起始行裁剪
  → Canny 与连通域边界提取
  → 相邻重复帧差分与信号加权
  → 按组织上边界展平
  → ImageJ Reslice / 分组平均投影
  → 配合 OCTAVA 等工具分析影像特征
  → 探索 VHI 回归与 VSQ 分类
```

原流程处理 400 个扫描位置，每个位置 6 帧，共 2400 张 B-scan。相关默认参数是特定采集流程的设置，需按实际数据调整。

## 报告中的结果

补充说明记录，在所检查数据中，新方法修复了 12 组旧方法边界识别错误，并将一次处理耗时由约 200 s 降至 72 s。按这两个时间计算，耗时减少约 **64%**，约为原速度的 **2.78 倍**。

这些是当时报告记录，未在本次整理中重新测量，也不代表所有数据上的性能。模型结果与验证限制详见 [结果与版本核对](docs/results_and_limitations.md)。

## 目录

```text
octa/       MATLAB OCTA 处理与 ImageJ 宏
modeling/   统计分析、分类、回归与 Tkinter GUI
docs/       实习总结、运行指南、结果核对及来源说明
data/       本地数据准备说明（不包含患者数据）
```

## 运行

- OCTA：MATLAB 与 Image Processing Toolbox。将 `octa/` 加入路径，运行 `runMyGUI`。需要按 [运行指南](docs/running.md) 配置自己的图像目录。
- VHI：MATLAB 与 Statistics and Machine Learning Toolbox，运行 `modeling/EnsembleRegression.m`。
- Python：建议在独立环境安装 `pip install -r requirements.txt`，然后运行 `python modeling/classification.py` 或 `python modeling/vsq_gui.py`。GUI 需桌面环境和 Tkinter。

仓库包含研究代码和文档，运行完整流程需要自行准备符合格式的数据。原始患者图像、临床表格与模型文件保留在本地。

## 归属与使用边界

OCTAVA、ImageJ/Fiji 和原始研究流程来自第三方或实验室，本仓库展示基于这些流程完成的改进与整合。仓库未复制 OCTAVA/Fiji 分发包，见 [来源与归属](docs/provenance.md)。

模型属于探索性研究原型，尚不能作为临床诊断工具。保留原有核心算法，并明确记录有限验证、数据划分和指标解释问题。
