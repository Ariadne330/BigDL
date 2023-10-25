import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 设置随机数种子，确保每次运行结果一致
np.random.seed(0)

# 生成一个3行10列的随机整数数组
data = np.random.randint(0, 100, (3, 10))

# 将数组转换为pandas DataFrame
df = pd.DataFrame(data)

# 计算每一行的平均值
row_means = df.mean(axis=1)

# 使用where函数筛选出大于平均值的元素为0，其余元素保留
filtered_df = df.where(df >= row_means[:, np.newaxis], 0)

# 创建一个包含3个子图的figure对象
fig, axs = plt.subplots(1, 3, figsize=(12, 4))

# 遍历DataFrame的每一行，使用hist函数生成直方图
for i, row in enumerate(df.values):
    axs[i].hist(row, bins=5, alpha=0.7, label=f'{i + 1}')

# 设置子图的间距
plt.tight_layout()

# 显示图形
plt.show()