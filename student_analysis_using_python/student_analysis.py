# This notebook explores the relationship between student demographics, study habits, and academic performance using Python.
# Visualizations and basic regression analysis are included.

# Data Source: [Kaggle - Students Exam Scores: Extended Dataset](https://www.kaggle.com/datasets/desalegngeb/students-exam-scores/data)

# Libraries used

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import seaborn as sns
import statsmodels.api as sm

# Data loading

df = pd.read_csv('expanded_data_with_more_features.csv')

# Exploratory Data Analysis (EDA)

# Shape of the dataset

df.shape

# First 5 rows of the dataset

df.head()

# Final 5 rows of the dataset

df.tail()

# 5 random rows of the dataset

df.sample(5)

# Title of each column of the dataset

df.columns

# Variable type of each column of the dataset

df.dtypes

# Seeking for duplicated values in the dataset

df[df.duplicated()]

# Seeking for empty cells in the dataset

df.isnull().sum()

# Removing rows with empty cells

df = df.dropna()
df.isnull().sum()

# Changing the format of the "NrSiblings" from decimal to integer

df['NrSiblings'] = df['NrSiblings'].astype('int64')

# Creating a new dataframe with the columns from df that will be used in this project

df2 = df[['Gender','EthnicGroup','ParentEduc','TestPrep','ParentMaritalStatus','NrSiblings','WklyStudyHours','MathScore','ReadingScore','WritingScore']]

# Resetting the index column for the new dataset

df2 = df2.reset_index(drop=True)

# Adding an extra column to calculate the average score and another one to rank the students based on the final score

df2['FinalScore'] = df2[['MathScore','ReadingScore','WritingScore']].mean(axis=1).round(2)
df2['Rank'] = df2['FinalScore'].rank(ascending = False, method = 'min').astype('int64')

# Sorting the dataframe by the "Rank" column and by the other "Scores" columns

df2.sort_values(by = ['Rank','MathScore','ReadingScore','WritingScore'], inplace = True)
df2

# Adding an extra column to calculate the letter grade for each student

conditions = [df2['FinalScore'] >= 90, df2['FinalScore'] >= 80, df2['FinalScore'] >= 60, df2['FinalScore'] >= 50, df2['FinalScore'] < 50]
grades = ['A','B','C','D','F']
df2['Grade'] = np.select(conditions, grades)

# Shape of the dataset

df2.shape

# First 5 rows of the dataset

df2.head()

# Final 5 rows of the dataset

df2.tail()

# 10 random rows of the dataset

df2.sample(10)

# Title of each column of the dataset

df2.columns

# Variable type of each column of the dataset

df2.dtypes

# Summary of statistics for the numerical columns of the dataset

df2.describe()

# Correlation between the columns of the dataset

df2.corr()

# Saving the dataframe to a file

df2.to_csv('students.csv', index = False)

# Creation of visuals

# Counting of men and women in a table format

counts = df2['Gender'].value_counts()
percentages = df2['Gender'].value_counts(normalize = True) * 100
Table = pd.DataFrame({'Count': counts, 'Percentage': percentages.round(2)})
Table

# Histogram: number of students falling into each ethnic group

plt.figure(figsize = (10, 6))
hist = df2['EthnicGroup'].value_counts().sort_index().plot(kind = 'bar', width = 1, edgecolor = 'black')
hist.bar_label(hist.containers[0], labels = [f"{v.get_height():,d}" for v in hist.containers[0]])
plt.xticks(rotation = 0)
plt.grid(False)
plt.title('Number of Students per Ethnic Group', fontsize = 16, pad = 32)
plt.show()

# Pie chart: parents education percentages

counts2 = df2['ParentEduc'].value_counts()
plt.figure(figsize = (10, 6))
plt.pie(counts2, labels = counts2.index, autopct = '%1.2f%%', explode = [0.1, 0, 0, 0, 0, 0], startangle = 90)
plt.axis('equal')
plt.title('Parents Education', fontsize = 16, pad = 32)
plt.show()

# Radar chart: average scores for students who took the preparation test and students who did not

groups = df2.groupby('TestPrep')['MathScore', 'ReadingScore', 'WritingScore', 'FinalScore'].mean()

labels = ['Math Score', 'Reading Score', 'Writing Score', 'Final Score']
angles = np.linspace(0, 2 * np.pi, 4, endpoint = False).tolist()
angles.append(angles[0])

fig, ax = plt.subplots(figsize = (10, 6), subplot_kw = dict(polar = True))
label_map = {'completed':'completed', 'none':'not completed'}

for i in groups.index:
    values = groups.loc[i].tolist()
    values.append(values[0])
    ax.plot(angles, values, label = label_map[i])
    ax.fill(angles, values, alpha = 0.25)

ax.set_xticks([])
radius = [90, 80, 95, 80]
for label, angle, r in zip(labels, angles[:-1], radius):
    ax.text(angle, r, label, ha = 'center', va = 'center', fontsize = 10)

ax.set_title('Average Scores for Students by Test Preparation Completion', size = 16, pad = 40)
ax.legend(loc = 'upper right', bbox_to_anchor = (1.25,1))

plt.table(cellText = groups.round(2).values.tolist(),
          rowLabels = groups.round(2).index.tolist(),
          colLabels = groups.round(2).columns.tolist(),
          cellLoc = 'center', rowLoc = 'center', loc = 'bottom right')

plt.show()

# Funnel chart: average number of siblings per parent marital status
# Column chart: average final score by weekly study hours

groups2 = df2.groupby('ParentMaritalStatus')['NrSiblings'].mean().round(2)
groups2 = groups2.sort_values(axis = 0, ascending = False)
groups2 = groups2.reset_index()

groups3 = df2.groupby('WklyStudyHours')['FinalScore'].mean().round(2)
groups3 = groups3.reindex(['< 5','5 - 10','> 10'])
groups3 = groups3.reset_index()

fig = make_subplots(rows = 1, cols = 2,
    subplot_titles = ('Average Number of Siblings per Parents Marital Status', 'Final Score by Weekly Study Hours'),
    specs = [[{'type': 'funnel'}, {'type': 'xy'}]])
for i in fig['layout']['annotations']:
    i['y'] += 0.05

fig.add_trace(go.Funnel(y = groups2['ParentMaritalStatus'], x = groups2['NrSiblings'], textinfo = 'value'),
    row = 1, col = 1)
fig.add_trace(go.Bar(x = groups3['WklyStudyHours'], y = groups3['FinalScore'], text = groups3['FinalScore'], textposition ='outside'),
    row = 1, col = 2)
fig.update_layout(height = 600, width = 950, showlegend = False)
fig.show()

# Gauge charts: average scores for each subject

fig2 = make_subplots(rows = 1, cols = 3, specs = [[{'type': 'indicator'}, {'type': 'indicator'}, {'type': 'indicator'}]])

fig2.add_trace(go.Indicator(mode = 'gauge+number', value = df2['MathScore'].mean(),
    title = {'text': 'Math Scores', 'font': {'size': 14}}, gauge = {'axis': {'range': [0,100]}}), row = 1, col = 1)
fig2.add_trace(go.Indicator(mode = 'gauge+number', value = df2['ReadingScore'].mean(),
    title = {'text': 'Reading Scores', 'font': {'size': 14}}, gauge = {'axis': {'range': [0,100]}}), row = 1, col = 2)
fig2.add_trace(go.Indicator(mode = 'gauge+number', value = df2['WritingScore'].mean(),
    title = {'text': 'Writing Scores', 'font': {'size': 14}}, gauge = {'axis': {'range': [0,100]}}), row = 1, col = 3)

fig2.update_layout(width = 950, height = 350,
    title_text = 'Average Score for Each Subject', title_x = 0.5, title_font = dict(size = 20))
fig2.show()

# Treemap chart: overall number and percentage of students per final grade

groups4 = df2.groupby('Grade').size().reset_index(name = 'Count')
groups4['Percentage'] = groups4['Count']/groups4['Count'].sum() * 100

fig3 = px.treemap(groups4, path = ['Grade'], values = 'Count', color = 'Grade')
fig3.update_traces(customdata = groups4[['Count', 'Percentage']],
    texttemplate = ('<b>%{label}</b><br>'+'Count: %{customdata[0]:,}<br>'+'Percentage: %{customdata[1]:.2f}%'),
    textfont_size = 14)
fig3.update_layout(width = 950, height = 600,
    title_text = 'Overall Number and Percentage of Students per Final Grade', title_x = 0.5, title_font = dict(size = 20))
fig3.show()

# Linear regression: comparison between the reading score and the writing score

df2[['ReadingScore', 'WritingScore']].describe()

df2[['ReadingScore', 'WritingScore']].corr()

sns.set(rc = {'figure.figsize': (10,6)})
s = sns.scatterplot(data = df2, x = 'ReadingScore', y = 'WritingScore')
s.set_title("Relationship Between Reading and Writing Scores\n", fontsize = 16);

x = df2['ReadingScore']
y = df2['WritingScore']
x = sm.add_constant(x)

model = sm.OLS(y, x).fit()

intercept = model.params['const']
slope = model.params['ReadingScore']
r_squared = model.rsquared

equation = f"y = {slope:.2f}x - {intercept * -1:.2f}"
r2 = f"$R^2$ = {r_squared:.3f}"

sns.set(rc = {'figure.figsize': (10,6)})
s = sns.scatterplot(data = df2, x = 'ReadingScore', y = 'WritingScore')
s.set_title("Relationship Between Reading and Writing Scores\n", fontsize = 16)
sns.regplot(data = df2, x = 'ReadingScore', y = 'WritingScore', line_kws = {'color': 'red'}, scatter = False);
s.text(df2['ReadingScore'].min() + 10, df2['WritingScore'].max() - 20, f"{equation}\n{r2}", fontsize = 12,
      bbox = dict(facecolor = 'white', edgecolor = 'black', boxstyle = 'round, pad = 0.5'));