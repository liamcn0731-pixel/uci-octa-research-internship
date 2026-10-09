from pathlib import Path
DATA_FILE = Path(__file__).resolve().parents[1] / "data" / "testdata_summary.xlsx"
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

try:
    df1 = pd.read_excel(DATA_FILE,sheet_name='Sheet1')

except FileNotFoundError:
    print("错误：找不到指定的Excel文件。请确保文件名正确，并且文件与脚本在同一目录下。")
    exit()
#print("Excel中实际的列名是:", df.columns) 

# --- 2. 准备数据 ---
# 定义自变量 (X) 和因变量 (y)
# 请将 ['X1', 'X2'] 和 'Y' 替换为您Excel中的实际列名。
# 先定义好要选择的列
feature_cols = ['VET3','BVD3','VSQ3','VET2','BVD2',	'VHI2', 'VSQ2', 'VET1',	'BVD1',	'VHI1',	'VSQ1',	'AGE']
target_col = 'VHI'

# 步骤1：将所有需要的列名合并成一个列表
all_cols = feature_cols + [target_col] 
# all_cols 的结果是 ['VET', 'BVD', 'AGE', 'BMI', 'VHI']

# 步骤2：使用这个合并后的列表来选取数据
# 为了不覆盖原始数据，建议使用新的变量名，例如 df1_subset
df1_subset = df1[all_cols]


# -----------------------------------------------------

# 1. 现在可以在新的、只包含所需列的数据框上计算相关系数
pearson_corr1 = df1_subset.corr(method='pearson')

# 2. 计算斯皮尔曼相关系数
spearman_corr1 = df1_subset.corr(method='spearman')



# 3. 使用热力图可视化皮尔逊相关系数矩阵
plt.figure(figsize=(10, 8))
sns.heatmap(pearson_corr1, annot=True, cmap='coolwarm', fmt='.2f')
plt.title('Pearson Correlation Heatmap')
plt.show()

# 您也可以直接查看 VHI 与其他变量的相关性
print("与 VHI 的皮尔逊相关性:\n", pearson_corr1[target_col].sort_values(ascending=False))
print("\n与 VHI 的斯皮尔曼相关性:\n", spearman_corr1[target_col].sort_values(ascending=False))