#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: classification.py

"""
@author: Ulrike Henny-Krahmer

Classify the novels using different feature sets, types of subgenre labels, and classifiers.
"""

import pandas as pd
import numpy as np
import re
from os.path import join
import plotly.graph_objects as go
from sklearn import svm
from sklearn import neighbors
from sklearn import ensemble
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import cross_validate
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
	
	
def get_feature_paths(wdir):
	"""
	collect the filepaths to all the different feature sets, relative to the working directory
	
	Argument:
	wdir (str): path to the working directory
	"""
	mfw_path = "data-nh/analysis/features/mfw/"
	topics_path = "data-nh/analysis/features/topics/4_aggregates/"
	
	# different feature constellations that were produced:
	mfws = [100,200,300,400,500,1000,2000,3000,4000,5000]
	ngram_words = [2,3,4]
	ngram_chars = [3,4,5]
	ngram_chars_type = ["word", "affix-punct"]
	norm_mode = ["tf","tfidf","zscore"]
	
	num_topics = [50,60,70,80,90,100]
	optimize_intervals = [50,100,250,500,1000,2500,5000,None]
	num_repetitions = 5
	
	paths = []
	
	for mfw in mfws:
		for nm in norm_mode:
			# word features
			file_name = "bow_mfw" + str(mfw) + "_" + nm + ".csv"
			file_path = join(mfw_path, file_name)
			paths.append(file_path)
			# word n-grams
			for ngw in ngram_words:
				file_name = "bow_mfw" + str(mfw) + "_" + str(ngw) + "gram_words_" + nm + ".csv"
				file_path = join(mfw_path, file_name)
				paths.append(file_path)
			# general character n-grams
			for ngc in ngram_chars:
				file_name = "bow_mfw" + str(mfw) + "_" + str(ngc) + "gram_chars_" + nm + ".csv"
				file_path = join(mfw_path, file_name)
				paths.append(file_path)
				# character n-gram subtypes
				for ngt in ngram_chars_type:
					file_name = "bow_mfw" + str(mfw) + "_" + str(ngc) + "gram_chars_" + ngt + "_" + nm + ".csv"
					file_path = join(mfw_path, file_name)
					paths.append(file_path)
	
	
	for t in num_topics:
		for oi in optimize_intervals:
			for rep in range(num_repetitions):
				folder_name = str(t) + "tp-5000it-" + str(oi) + "in-" + str(rep) 
				file_name = "avgtopicscores_by-idno.csv"
				file_path = join(topics_path, folder_name, file_name)
				paths.append(file_path)
	return paths
	
	
def scale_feature_sets(wdir, feature_set_paths):
	"""
	For use with SVM: scale the feature sets to [0,1]
	
	Arguments:
	wdir (str): path to the working directory
	feature_set_paths (list): list of relative paths to the different feature sets
	"""
	print("scaling feature sets...")
	
	
	for fs in feature_set_paths:
		df = pd.read_csv(join(wdir, fs), index_col=0)
		
		# scale the features
		scaler = MinMaxScaler()
		new_data = scaler.fit_transform(df.to_numpy())
		new_df = pd.DataFrame(index=df.index, columns=df.columns, data=new_data)
		
		# store the scaled feature set in a new file
		new_path = fs[:-4] + "_MinMax.csv"
		new_df.to_csv(join(wdir, new_path))
	
	print("done")



def select_metadata(wdir, md_file, subgenre_sets, outpath):
	"""
	select metadata for specific subgenre constellations to analyze
	save the metadata subsets
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	subgenre_sets (list): list of dicts describing which subgenre constellations to choose, e.g. [{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"}]
	outpath (str): relative path to the output directory for the metadata selection files
	"""
	print("select metadata...")
	
	
	for sb_set in subgenre_sets:
		md = pd.read_csv(join(wdir, md_file), index_col=0)
		
		level = sb_set["level"]
		class1 = sb_set["class 1"]
		class2 = sb_set["class 2"]
		
		print("selecting metadata for " + level + ", " + class1 + " vs. " + class2, "...")
		
		
		# get the instances of the first subgenre
		sub1 = md.loc[md[level] == class1]
		
		# get the instances of the second subgenre
		if class2 == "other":
			md.loc[np.logical_not(md[level].isin([class1, "unknown"])),level]  = "other"
			
		sub2 = md.loc[md[level] == class2]
			
		
		# is one class bigger than the other? if yes, undersample (select random samples from the bigger class)
		num_sub1 = len(sub1)
		num_sub2 = len(sub2)
		
		print("Size of class 1: " + str(len(sub1)))
		print("Size of class 2: " + str(len(sub2)))
		
		# repeat the sampling process 10 times
		for i in range(10):
			if num_sub1 > num_sub2:
				sub1 = sub1.sample(n=num_sub2)
			elif num_sub2 > num_sub1:
				sub2 = sub2.sample(n=num_sub1)
				
			# create new metadata frame with selected entries
			new_md = sub1.append(sub2)
			# sort by idno
			new_md = new_md.sort_values(by="idno")
			# store new metadata selection
			outfile = "metadata_" + level + "_" + re.sub(r"\s", r"_", class1) + "_" + re.sub(r"\s", r"_", class2) + "_" + str(i) + ".csv"
			new_md.to_csv(join(wdir, outpath, outfile))

	
	print("done")
	

def select_data_mfw(wdir, md_inpath, feature_inpath, sb_set, mfw, unit, no, rep, cl):
	"""
	prepare data for classifier as X (np data array), y (labels)
	for mfw
	returns X, y
	
	Arguments:
	wdir (str): path to the working directory
	md_inpath (str): relative path to the directory containing selected metadata for subgenre constellations
	feature_inpath (str): relative path to the directory containing the feature sets
	sb_set (dict): dictionary describing the subgenre constellation to analyze, e.g. {"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"}
	mfw (int): number of mfw
	unit (str): token unit ("word", "word 3gram", "char 3gram", etc.)
	no (str): normalization mode ("tf", "tfidf", "zscore")
	rep (int): number of the data selection repetition to use
	cl (str): the type of classifier to select data for: SVM, RF, KNN
	"""	
	# which type of subgenre is analyzed?
	level = sb_set["level"]
	class1 = re.sub(r"\s", r"_", sb_set["class 1"])
	class2 = re.sub(r"\s", r"_", sb_set["class 2"])
	
	# load the metadata file corresponding to the selected subgenre constellation and feature set
	md_path = join(wdir, md_inpath, "metadata_" + level + "_" + class1 + "_" + class2 + "_" + str(rep) + ".csv")
	md = pd.read_csv(md_path, index_col=0)
	
	# prepare the data to return
	# labels
	y = md[level]
		
	# values
	if unit == "word":
		token_unit = ""
	else:
		token_unit = unit + "_"
	if cl == "SVM":
		scale = "_MinMax"
	else:
		scale = ""
	feature_path = join(wdir, feature_inpath, "bow_mfw" + str(mfw) + "_" + token_unit + no + scale + ".csv")
	data = pd.read_csv(join(wdir, feature_path), index_col=0)
	X = data.loc[md.index].to_numpy()
		
	return X,y
	
	
	
def select_data_topics(wdir, md_inpath, feature_inpath, sb_set, num_topics, optimize_interval, md_rep, topic_rep, cl):
	"""
	prepare data for classifier as X (np data array), y (labels)
	for mfw
	returns X, y
	
	Arguments:
	wdir (str): path to the working directory
	md_inpath (str): relative path to the directory containing selected metadata for subgenre constellations
	feature_inpath (str): relative path to the directory containing the feature sets
	sb_set (dict): dictionary describing the subgenre constellation to analyze, e.g. {"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"}
	num_topics (int): number of topics
	optimize_interval (str): optimize interval parameter value
	md_rep (int): number of the data selection repetition to use
	topic_rep (int): number of the topic model repetition to use
	cl (str): the type of classifier to select data for: SVM, RF, KNN
	"""	
	# which type of subgenre is analyzed?
	level = sb_set["level"]
	class1 = re.sub(r"\s", r"_", sb_set["class 1"])
	class2 = re.sub(r"\s", r"_", sb_set["class 2"])
	
	# load the metadata file corresponding to the selected subgenre constellation and feature set
	md_path = join(wdir, md_inpath, "metadata_" + level + "_" + class1 + "_" + class2 + "_" + str(md_rep) + ".csv")
	md = pd.read_csv(md_path, index_col=0)
	
	# prepare the data to return
	# labels
	y = md[level]
		
	# values
	if cl == "SVM":
		scale = "_MinMax"
	else:
		scale = ""
	folder_name = str(num_topics) + "tp-5000it-" + str(optimize_interval) + "in-" + str(topic_rep)
	feature_path = join(wdir, feature_inpath, folder_name, "avgtopicscores_by-idno" + scale + ".csv")
	data = pd.read_csv(join(wdir, feature_path), index_col=0)
	X = data.loc[md.index].to_numpy()
		
	return X,y
	
	

def parameter_study(wdir):
	"""
	test different subgenre constellations and selected feature sets
	do grid searches for the three types of classifiers (SVM, KNN, RF) to see which parameters work best
	
	Argument:
	wdir (str): path to the working directory
	"""
	
	print("running parameter study...")
	
	# chosen subgenre constellations
	subgenre_sets = [{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"},
	{"level": "subgenre-current", "class 1": "novela realista", "class 2": "novela naturalista"},
	{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "other"},
	{"level": "subgenre-theme", "class 1": "novela sentimental", "class 2": "novela de costumbres"}]

	# how often should the data selection (with undersampling) be repeated?
	repetitions = 10

	# chosen feature parameters
	mfws = [100, 1000, 5000]
	token_units = ["word", "3gram_words", "3gram_chars"]
	norms = ["tfidf", "zscore"]

	num_topics = [50, 100]
	optimize_intervals = [100, 1000]
	topic_repetitions = 5

	# select metadata for subgenre constellations
	#select_metadata(wdir, "conha19/metadata.csv", subgenre_sets, "data-nh/analysis/classification/data_selection/preliminary/")
	
	
	# classifiers
	classifiers = ["SVM", "KNN", "RF"]
	# data frames for results
	fr_svm = pd.DataFrame()
	fr_knn = pd.DataFrame()
	fr_rf = pd.DataFrame()

	for sb_set in subgenre_sets:
		# mfw
		for mfw in mfws:
			for unit in token_units:
				for no in norms:
					for rep in range(repetitions):
						
						# do grid searches for the different classifiers
						## choose classifier
						for cl in classifiers:
							X, y = select_data_mfw(wdir, "data-nh/analysis/classification/data_selection/preliminary/", "data-nh/analysis/features/mfw/", sb_set, mfw, unit, no, rep, cl)
						
							results = do_grid_searches(X,y,cl)
							
							results["subgenre_level"] = sb_set["level"]
							results["class1"] = sb_set["class 1"]
							results["class2"] = sb_set["class 2"]
							results["mfw"] = mfw
							results["token_unit"] = unit
							results["normalization"] = no
							results["repetition"] = rep
							
							if cl == "SVM":
								fr_svm = fr_svm.append(results, sort=False)
							elif cl == "KNN":
								fr_knn = fr_knn.append(results, sort=False)
							elif cl == "RF":
								fr_rf = fr_rf.append(results, sort=False)
		# topics
		for t in num_topics:
			for oi in optimize_intervals:
				for rep in range(repetitions):
					for topic_rep in range(topic_repetitions):
					# do grid searches for the different classifiers
						## choose classifier
						for cl in classifiers:
							X,y = select_data_topics(wdir, "data-nh/analysis/classification/data_selection/preliminary/", "data-nh/analysis/features/topics/4_aggregates/", sb_set, t, oi, rep, topic_rep, cl)
					
							results = do_grid_searches(X,y,cl)
							
							results["subgenre_level"] = sb_set["level"]
							results["class1"] = sb_set["class 1"]
							results["class2"] = sb_set["class 2"]
							results["num_topics"] = t
							results["optimize_interval"] = oi
							results["repetition"] = rep
							results["topic_repetition"] = topic_rep
							
							if cl == "SVM":
								fr_svm = fr_svm.append(results, sort=False)
							elif cl == "KNN":
								fr_knn = fr_knn.append(results, sort=False)
							elif cl == "RF":
								fr_rf = fr_rf.append(results, sort=False)
	# store results
	outpath = "data-nh/analysis/classification/parameter_study"
		
	fr_svm.to_csv(join(wdir, outpath, "grid-searches-SVM.csv"))
	fr_knn.to_csv(join(wdir, outpath, "grid-searches-KNN.csv"))
	fr_rf.to_csv(join(wdir, outpath, "grid-searches-RF.csv"))
	

	print("done")


def do_grid_searches(X,y,cl):
	"""
	Do grid searches for different classifiers and parameter settings.
	
	Arguments:
	X (nparray): data to use
	y (list): labels to use
	cl (str): the classifier to use: SVM, KNN, or RF
	"""
	if cl == "SVM":
		clf = svm.SVC(kernel="linear")
		param_grid = [{"C": [1,10,100,1000]}]
	elif cl == "KNN":
		clf = neighbors.KNeighborsClassifier()
		param_grid = [{"n_neighbors": [3,5,7], "weights": ["uniform", "distance"], "metric": ["euclidean", "manhattan"]}]
	elif cl == "RF":
		clf = ensemble.RandomForestClassifier(random_state=0)
		param_grid = [{"max_features": ["sqrt", "log2"]}]
	
	grid_search = GridSearchCV(clf, param_grid=param_grid, cv=10)
	grid_search.fit(X,y)
	results = grid_search.cv_results_
	results = pd.DataFrame.from_dict(results)
	return results
	
def get_rank1_groups(df, param):
	"""
	Check the results of the parameter study and keep only rows with rank 1.
	Return these rows grouped by the different values of the selected parameter.
	
	Arguments:
	df (DataFrame): data frame containing the parameter study results
	param (str): which parameter to evaluate (e.g. "C")
	"""
	# keep only rows with rank_test_score = 1
	df_1 = df.loc[df["rank_test_score"] == 1]
	# group these by the values of the selected parameter
	df_grouped = df_1.groupby(by=param).size().reset_index(name="counts").sort_values(by="counts", ascending=False)
	return df_grouped


def evaluate_parameter_study(wdir, clf, param):
	"""
	count how often each parameter value is on rank 1 for the test score
	
	Arguments:
	wdir (str): path to the working directory
	clf (str): type of classifier ("SVM", "KNN" or "RF")
	param (str): which parameter to evaluate (e.g. "C")
	"""
	print("evaluating parameter study for " + clf + "...")
	
	# load results
	df = pd.read_csv(join(wdir, "data-nh/analysis/classification/parameter_study/grid-searches-" + clf + ".csv"))
	df_grouped = get_rank1_groups(df, param)
	
	df_mfw = df.loc[df["mfw"].notnull()]
	df_mfw_grouped = get_rank1_groups(df_mfw, param)
	
	df_topics = df.loc[df["num_topics"].notnull()]
	df_topics_grouped = get_rank1_groups(df_topics, param)
	
	print("general:")
	print(df.shape)
	print(df_grouped)
	print("mfw:")
	print(df_mfw.shape)
	print(df_mfw_grouped)
	print("topics:")
	print(df_topics.shape)
	print(df_topics_grouped)
	
	


#################### FUNCTION CALLS ####################

wdir = "/home/ulrike/Git"


# get relative paths to feature sets
feature_set_paths = get_feature_paths(wdir)
'''
# write to a csv file for later use
df = pd.DataFrame(data=feature_set_paths)
df.to_csv(join(wdir, "data-nh/analysis/features/feature_sets.csv"), index=False, header=False)
'''


# prepare the feature sets for use with SVM: scale to [0,1]
#scale_feature_sets(wdir, feature_set_paths)


# preliminary parameter study

#parameter_study(wdir)

evaluate_parameter_study(wdir, "SVM", "param_C")				
	



##################### main classification tasks #####################
#### primary literary currents ####
'''
#plot_overview_literary_currents_primary("/home/ulrike/Git/", "conha19/metadata.csv", "data-nh/analysis/classification/literary-currents/", "overview-primary-currents-corp")

# chosen subgenre constellations
subgenre_sets = [{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela realista", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela naturalista", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "novela realista"},
{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "novela naturalista"},
{"level": "subgenre-current", "class 1": "novela realista", "class 2": "novela naturalista"}]

# make a test with one constellation and feature type:
# https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.cross_validate.html#sklearn.model_selection.cross_validate
sb_set = subgenre_sets[0]
mfw = 100
unit = "word"
no = "tfidf"
rep = 0
X, y = select_data_mfw(wdir, "data-nh/analysis/classification/data_selection/preliminary/", "data-nh/analysis/features/mfw/", sb_set, mfw, unit, no, rep)
clf = svm.SVC(kernel="linear", C=1000)
scores = cross_validate(clf, X, y, cv=10, scoring=["accuracy", "precision", "recall", "f1"], return_train_score=True, return_estimator=True)
						
# erstmal angucken, was da zurückkommt...

#print(clf.classes_)
#print(clf.coef_)


#### primary thematic labels ####
subgenre_sets = [{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela sentimental", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela de costumbres", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "novela sentimental"},
{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "novela de costumbres"},
{"level": "subgenre-theme", "class 1": "novela sentimental", "class 2": "novela de costumbres"}]



#### novelas ####
subgenre_sets = [{"level": "subgenre-novela", "class 1": "novela", "class 2": "none"}]

'''
##################### analysis and visualization of results #####################





