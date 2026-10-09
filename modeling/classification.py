from pathlib import Path
PROJECT_ROOT = Path(__file__).resolve().parents[1]
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import numpy as np
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_predict, StratifiedKFold, cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from joblib import dump
from sklearn.svm import SVC
# 读取数据
file_path = PROJECT_ROOT / 'data' / 'testdata_summary.xlsx'
xls = pd.ExcelFile(file_path)

# 合并三个数据表
sheets = ['Aim1Pre', 'Aim1Peri' ,'Aim1Post']
dfs = [pd.read_excel(xls, sheet)[['VET', 'BVD', 'VSQ', 'AGE']] for sheet in sheets]
data = pd.concat(dfs, ignore_index=True)

# 按照分类标准转换VSQ为类别
# def categorize_vsq(vsq):
#     if vsq <= 3:
#         return 'excellent'
#     elif 3 < vsq <= 7:
#         return 'good'
#     elif 7 < vsq <= 20:
#         return 'bad'
#     else:
#         return 'serious'
def categorize_vsq(vsq):
    if vsq <= 4:
        return 'healthy'
    else:
        return 'symptomatic' \
        ''

data['VSQ_category'] = data['VSQ'].apply(categorize_vsq)

X = data[['VET', 'BVD','AGE']]
y = data['VSQ_category']

# 当前版本：多项式核支持向量分类器
clf = SVC(kernel='poly', random_state=42)
clf.fit(X,y)
# 五折交叉验证预测
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
y_pred = cross_val_predict(clf, X, y, cv=cv)

# 评估模型
cm = confusion_matrix(y, y_pred)
accuracy = accuracy_score(y, y_pred)

# 得到每折准确率
scores = cross_val_score(clf, X, y, cv=cv, scoring='accuracy')

# 输出每折准确率
for fold_idx, acc in enumerate(scores, 1):
    print(f"Fold {fold_idx} Accuracy: {acc:.2f}")

clf.fit(X, y)

model_dir = PROJECT_ROOT / 'artifacts'
model_dir.mkdir(exist_ok=True)
dump(clf, model_dir / 'classification.joblib')
print('Model saved to artifacts/classification.joblib')


# 输出平均准确率和标准差
print(f"\nAverage Accuracy: {scores.mean():.2f}")
print(f"Standard Deviation: {scores.std():.2f}")
# 混淆矩阵可视化
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', xticklabels=clf.classes_, yticklabels=clf.classes_, cmap='Blues')
plt.ylabel('Actual')
plt.xlabel('Predicted')
plt.title(f'Confusion Matrix (Accuracy: {accuracy:.2f})')
plt.show()

