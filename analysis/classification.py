#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: classification.py

"""
@author: Ulrike Henny-Krahmer

Classify the novels using different feature sets and types of subgenre labels.
"""

import pandas as pd
import numpy as np
from os.path import join
import plotly.graph_objects as go
from sklearn import svm
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV


def plot_overview_literary_currents_primary(wdir, mdfile, outdir, outfile):
	"""
	creates a donut chart displaying the proportion of the different primary literary currents in the corpus
	
	Arguments:
	wdir (str): path to the working directory
	mdfile (str): relative path to the metadata csv file containing the subgenre labels
	outdir (str): relative path to the output directory
	outfile (str): name of the output file (withouth extension)
	"""

	md = pd.read_csv(join(wdir, mdfile), index_col=0)
	subgenres = md["subgenre-current"]
	subgenres_counts = subgenres.value_counts()
	subgenres_set = list(subgenres_counts.index)
	subgenres_values = list(subgenres_counts.values)

	labels = subgenres_set
	values = subgenres_values
	colors = ["rgb(214, 39, 40)","rgb(227, 119, 194)","rgb(44, 160, 44)","rgb(31, 119, 180)","rgb(255, 127, 14)"]

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=0.4, direction="clockwise")])
	fig.update_traces(marker=dict(colors=colors))
	fig.update_layout(autosize=False, width=500, height=400, title="Primary literary currents in the corpus")

	fig.write_image(join(wdir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)

	#fig.show()
	
	print("done: overview primary literary currents")



def select_data(wdir, mdfile, subgenre_type, subgenre1, subgenre2, features):
	"""
	select a subset of data (X) and labels (y) for classification
	returns X and y
	
	Arguments:
	wdir (str): path to the working directory
	mdfile (str): relative path to the metadata file
	subgenre_type (str): the kind of subgenre label to choose (the name of the column in the metadata table)
	subgenre1 (str): label of the first subgenre class
	subgenre2 (str): label of the second subgenre class, can also be "other" to select all that are not subgenre1 or "unknown", and None for no second group
	features (str): relative path to the file containing the feature set
	"""
	print("selecting data for " + subgenre1 + " vs. " + str(subgenre2) + "...")
	
	md = pd.read_csv(join(wdir, mdfile), index_col=0)
	# get the instances of the first subgenre
	sub1 = md.loc[md[subgenre_type] == subgenre1]
	
	# get the instances of the second subgenre
	if subgenre2 == "other":
		md.loc[np.logical_not(md[subgenre_type].isin([subgenre1, "unknown"])),subgenre_type]  = "other"
		
	if subgenre2 is not None:
		sub2 = md.loc[md[subgenre_type] == subgenre2]
		
	
	# is one class bigger than the other? if yes, undersample (select random samples from the bigger class)
	if subgenre2 is not None:
		num_sub1 = len(sub1)
		num_sub2 = len(sub2)
		
		if num_sub1 > num_sub2:
			sub1 = sub1.sample(n=num_sub2)
		elif num_sub2 > num_sub1:
			sub2 = sub2.sample(n=num_sub1)
			
	print("Number of samples: " + str(len(sub1)))
	
	# prepare the data to return
	# labels
	y = sub1[subgenre_type]
	
	if subgenre2 is not None:
		y = y.append(sub2[subgenre_type])
		
	# values
	data = pd.read_csv(join(wdir, features), index_col=0)
	X = data.loc[sub1.index].to_numpy()
	
	if subgenre2 is not None:
		X = np.concatenate((X, data.loc[sub2.index].to_numpy()))
		
	return X,y



# FUNCTION CALLS

# primary literary currents

#plot_overview_literary_currents_primary("/home/ulrike/Git/", "conha19/metadata.csv", "data-nh/analysis/classification/literary-currents/", "overview-primary-currents-corp")

# prepare the data: "novela romántica" vs. "other", mfw100_tfidf
X, y = select_data("/home/ulrike/Git/", "conha19/metadata.csv", "subgenre-current", "novela romántica", "other", "data-nh/analysis/features/mfw/bow_mfw100_tfidf.csv")


## choose classifier
clf = svm.SVC(kernel="linear", C=100)

'''
## standard
# split randomly into training and test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1)
# train the model
clf.fit(X_train, y_train)
# evaluate, default: accuracy
train_score = clf.score(X_train, y_train)
test_score = clf.score(X_test, y_test)
print(train_score)
print(test_score)
print(clf.predict(X_test))
'''

'''
## cross validation
scores = cross_val_score(clf, X, y, cv=10, scoring="f1_macro") # default: accuracy
print(scores)
print(scores.mean())
'''

## grid search
param_grid = [{'C': [0.1, 1, 10, 100, 1000]}]
grid_search = GridSearchCV(clf, param_grid=param_grid, cv=10)
grid_search.fit(X, y)  
results = grid_search.cv_results_
results = pd.DataFrame.from_dict(results)
results.to_csv("/home/ulrike/Git/data-nh/analysis/classification/literary-currents/grid-search.csv")

print("done")

#print(clf.classes_)
#print(clf.coef_)



