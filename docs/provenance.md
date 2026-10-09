# 来源、归属与整理记录

## 本地来源

| 整理后文件 | 原始位置 |
|---|---|
| octa/runMyGUI.m | Zhengli/runMyGUI.m，与 Zheng Li/runMyGUI.m 字节相同 |
| octa/V2.m | Zhengli/V2.m，与 Zheng Li/OCTA code/V2.m 字节相同 |
| octa/reslice_group.ijm | Try.ijm.ijm.ijm |
| modeling/*.py、EnsembleRegression.m | VHI_GUI/ 中对应源码 |
| modeling/vsq_gui.py | VHI_GUI/GUI.ipynb 的代码单元，去除输出后导出 |
| docs/ 中的总结 | work report、data analysis PPT、补充说明及现有源码 |

两份 work report PPT SHA-256 相同，只作为同一份证据。Processing flow PPT 署名 Wenqi，属于提供的流程参考，不作为本人原创成果。

OCT测量.pdf 的实际内容为 Tomlins 与 Wang（2005）的综述论文 *Theory, developments and applications of optical coherence tomography*，DOI 10.1088/0022-3727/38/15/002。仅记录文献身份，不上传论文全文，不将其作为实习测量报告。

## 第三方工具

本地 OCTAVA README 标明 MIT 许可，并列出以下引用：

- Untracht et al., OCTAVA: An open-source toolbox for quantitative analysis of optical coherence tomography angiography images（2021），DOI 10.1371/journal.pone.0261052。
- Untracht et al., Towards standardising retinal OCT angiography image analysis with open-source toolbox OCTAVA（2024），DOI 10.1038/s41598-024-53501-6。

OCTAVA/Fiji 安装包、第三方脚本及复制目录未上传。不将已有工具、原始采集流程和实验室数据归为个人原创。

## 本次修改

移除机器绝对路径与患者目录示例，统一到本地 data/artifacts 目录；MATLAB GUI 主函数名与文件名统一；目录按钮改为实际的打开目录功能；补充分类模型导出以匹配 GUI 路径；移除未使用的 LightGBM 导入；未更改核心算法和模型超参数。

原始患者图像、临床表格、模型、MATLAB live scripts、报告原件和 Office 临时文件保留在桌面。报告中有逐样本表格与研究图像，因此上传的是重新整理的文字总结。没有新增开源许可证，归属和许可方式留给作者及相关研究机构确认。
