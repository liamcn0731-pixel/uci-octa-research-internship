from pathlib import Path
DATA_FILE = Path(__file__).resolve().parents[1] / "data" / "testdata_summary.xlsx"
import pickle
import pandas as pd
import statsmodels.api as sm

# 假设 df 是您包含所有数据的 DataFrame
try:
    df1 = pd.read_excel(DATA_FILE,sheet_name='Aim1Pre')
    df2 = pd.read_excel(DATA_FILE,sheet_name='Aim1Peri')
    df3 = pd.read_excel(DATA_FILE,sheet_name='Aim1Post')
except FileNotFoundError:
    print("错误：找不到指定的Excel文件。请确保文件名正确，并且文件与脚本在同一目录下。")
    exit()
feature_cols = ['VET', 'BVD'] # 这里是您的自变量
target_col = 'VSQ'                 # 这里是您的因变量

# --- 多因素分析 ---
# 准备数据
y = df3[target_col]
X = df3[feature_cols]
# statsmodels 需要手动添加截距项
X = sm.add_constant(X)

# 建立并拟合模型 (OLS: 普通最小二乘法，即线性回归)
model = sm.OLS(y, X)
results = model.fit()

# 打印非常详细的、类似于图中表格的分析结果
print(results.summary())

