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
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import make_scorer

############### FUNCTIONS ##################

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
	
	
def plot_overview_theme_primary(wdir, mdfile, outdir, outfile):
	"""
	creates a donut chart displaying the proportion of the different primary thematic subgenres in the corpus
	
	Arguments:
	wdir (str): path to the working directory
	mdfile (str): relative path to the metadata csv file containing the subgenre labels
	outdir (str): relative path to the output directory
	outfile (str): name of the output file (withouth extension)
	"""

	md = pd.read_csv(join(wdir, mdfile), index_col=0)
	# which subgenres to display by name in the chart (the others as one group named "other"):
	subgenres_selected = ["novela histórica", "novela sentimental", "novela de costumbres", "novela social", "novela política",
	"novela criminal", "novela científica", "novela abolicionista"]
	md.loc[np.logical_not(md["subgenre-theme"].isin(subgenres_selected)),"subgenre-theme"]  = "other"
	subgenres = md["subgenre-theme"]
	subgenres_counts = subgenres.value_counts()
	subgenres_set = list(subgenres_counts.index)
	subgenres_values = list(subgenres_counts.values)

	labels = subgenres_set
	values = subgenres_values
	#colors = ["rgb(214, 39, 40)","rgb(227, 119, 194)","rgb(44, 160, 44)","rgb(31, 119, 180)","rgb(255, 127, 14)"]

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=0.4, direction="clockwise")])
	#fig.update_traces(marker=dict(colors=colors))
	fig.update_layout(autosize=False, width=500, height=400, title="Primary thematic subgenres in the corpus", legend_font=dict(size=14))

	fig.write_image(join(wdir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)

	#fig.show()
	
	print("done: overview primary thematic subgenres")



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
	returns X, y, idnos
	
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
	
	idnos = md.index
		
	return X,y,idnos
	
	
	
def select_data_topics(wdir, md_inpath, feature_inpath, sb_set, num_topics, optimize_interval, md_rep, topic_rep, cl):
	"""
	prepare data for classifier as X (np data array), y (labels)
	for mfw
	returns X, y, idnos
	
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
	y = md[level].to_numpy()
		
	# values
	if cl == "SVM":
		scale = "_MinMax"
	else:
		scale = ""
	folder_name = str(num_topics) + "tp-5000it-" + str(optimize_interval) + "in-" + str(topic_rep)
	feature_path = join(wdir, feature_inpath, folder_name, "avgtopicscores_by-idno" + scale + ".csv")
	data = pd.read_csv(join(wdir, feature_path), index_col=0)
	X = data.loc[md.index].to_numpy()
		
	idnos = md.index
		
	return X,y,idnos
	
	

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
							X, y, idnos = select_data_mfw(wdir, "data-nh/analysis/classification/data_selection/preliminary/", "data-nh/analysis/features/mfw/", sb_set, mfw, unit, no, rep, cl)
						
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
							X, y, idnos = select_data_topics(wdir, "data-nh/analysis/classification/data_selection/preliminary/", "data-nh/analysis/features/topics/4_aggregates/", sb_set, t, oi, rep, topic_rep, cl)
					
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


def get_rank1_counts(df, param, param_value):
	"""
	Get the number of times a specific parameter value reached rank 1
	
	Arguments:
	df (DataFrame): data frame containing the parameter study results
	param (str): which parameter to evaluate (e.g. "C")
	param_value (str/int): which parameter value to look for
	"""
	# get the rows which have this parameter value
	rows_param_value = df.loc[df[param] == param_value]
	if rows_param_value.empty == False:
		rows_param_value = rows_param_value["counts"].values[0]
	else:
		rows_param_value = 0
	return rows_param_value



def evaluate_parameter_study(wdir, outdir, clf, param):
	"""
	count how often each parameter value is on rank 1 for the test score
	
	Arguments:
	wdir (str): path to the working directory
	outdir (str): relative path to the output directory
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
	
	'''
	# inspect results:
	print("general:")
	print(df.shape)
	print(df_grouped)
	print("mfw:")
	print(df_mfw.shape)
	print(df_mfw_grouped)
	print("topics:")
	print(df_topics.shape)
	print(df_topics_grouped)
	'''
	# get the different parameter values
	param_values = sorted(df_grouped[param].tolist())
	
	
	# create a grouped bar chart showing how often which parameter value reached rank 1 in the different feature sets
	
	fig = go.Figure()
	
	# add bars for each parameter value
	for p_val in param_values:
		value_all = get_rank1_counts(df_grouped, param, p_val)
		value_mfw = get_rank1_counts(df_mfw_grouped, param, p_val)
		value_topics = get_rank1_counts(df_topics_grouped, param, p_val)
		
		y = [value_all, value_mfw, value_topics]
		fig.add_trace(go.Bar(name=str(p_val), x=["all", "mfw", "topics"], y=y))
	
	fig.update_layout(autosize=False, width=600, height=500, title="Grid search results for " + clf, barmode="group")

	fig.write_image(join(wdir, outdir, "ranks1_" + clf + "_" + param + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, "ranks1_" + clf + "_" + param + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)

	print("done")
	
	
def get_estimator(cl, feature_type):
	"""
	Get an instance of the chosen classifier, setting the parameters that were determined in the preliminary parameter study.
	
	Arguments:
	cl (str): name of the classifier: KNN, SVC, RF
	feature_type (str): main feature type, mfw or topics
	"""
	if feature_type == "mfw":
		n_neighbors = 3
	elif feature_type == "topics":
		n_neighbors = 5
	
	if cl == "KNN":
		clf = neighbors.KNeighborsClassifier(n_neighbors=n_neighbors, weights="distance", metric="manhattan")
		
	elif cl == "SVM":
		clf = svm.SVC(kernel="linear", C=1)
		
	elif cl == "RF":
		clf = ensemble.RandomForestClassifier(random_state=0, max_features="sqrt")
		
	return clf
	

def get_scores(estimator, X, y, class1, cv):
	"""
	Get the cross validation scores for the chosen classifier and data
	
	Arguments:
	estimator (object): the classifier
	X (nparray): data
	y (list): labels
	class1 (str): label of the positive class
	cv (int): number of cross validation folds to use
	"""
					
	scoring = {"accuracy": make_scorer(accuracy_score), 
	"precision": make_scorer(precision_score, average="binary", pos_label=class1),
	"recall": make_scorer(recall_score, average="binary", pos_label=class1),
	"f1": make_scorer(f1_score, average="binary", pos_label=class1)}
	scores = cross_validate(estimator, X, y, cv=cv, scoring=scoring, return_train_score=True, return_estimator=True)
	
	return scores


def get_score_frame(scores):
	"""
	Convert the dictionary of scores into a data frame.
	
	Arguments:
	scores (dict): dictionary of scores returned from cross validation
	"""
	
	score_frame = pd.DataFrame.from_dict(scores)
	score_frame = score_frame.reset_index()
	score_frame = score_frame.rename(columns={"index":"call"})
	
	return score_frame
	

def store_features(cl, scores, cv, feature_names):
	"""
	Store feature importances for each cv run
	and return a data frame containing all of them
	
	Arguments:
	cl (str): which classifier was used (SVM or RF)
	scores (dict): dictionary of scores returned from cross validation
	cv (int): number of cv volds
	feature_names (list): the names of the features (the topic numbers or the words or ngrams)
	"""
	columns = ["cv_call"] + feature_names
	
	feature_frame = pd.DataFrame(columns=columns)
	
	for run in range(cv):
		if cl == "SVM":
			coef = scores["estimator"][run].coef_.tolist()[0]
		elif cl == "RF":
			coef = scores["estimator"][run].feature_importances_.tolist()
		data = [run] + coef
		coef = pd.Series(index=columns, data=data)
		
		feature_frame = feature_frame.append(coef, ignore_index=True)
	
	return feature_frame


def store_labels(scores, cv, X, y, idnos):
	"""
	Store true labels and predicted labels for each cv run
	and return a data frame containing all of them.
	
	Arguments:
	scores (dict): dictionary of scores returned from cross validation
	cv (int): number of cv folds
	X (nparray): data
	y (nparray): true labels
	idnos (nparray): identifiers of the data
	"""		
			
	label_frame = pd.DataFrame()
	label_frame["idno"] = idnos
	label_frame["y_true"] = list(y)
	
	for run in range(cv):
		predicted_labels = scores["estimator"][run].predict(X)
		label_frame["y_" + str(run)] = predicted_labels
	
	return label_frame
	
	
def get_feature_names_mfw(wdir, feature_dir, mfw, unit, no):
	"""
	Get the names of the features in the chosen feature set.
	
	Arguments:
	wdir (str): path to the working directory
	feature_dir (str): relative path to the feature directory
	mfw (int): number of most frequent words
	unit (str): token unit, e.g. "word" or "4gram_words" or "3gram_chars_affix-punct"
	no (str): kind of normalization, "tf", "tfidf", or "zscore"
	"""
	if unit == "word":
		unit = ""
	else:
		unit = "_" + unit
	
	features = pd.read_csv(join(wdir, feature_dir, "bow_mfw" + str(mfw) + unit + "_" + no + ".csv"), index_col=0)
	feature_names = features.columns
	return feature_names
	

def set_frame_metadata_mfw(frame, level, class1, class2, mfw, unit, no, data_rep):
	"""
	Set metadata columns for classification results frame (MFW).
	
	Arguments:
	frame (DataFrame): Data frame for the results
	level (str): subgenre level that is analyzed, e.g. "theme"
	class1 (str): the positive class, e.g."novela histórica"
	class2 (str): the negative class, e.g. "other"
	mfw (int): number of mfw
	unit (str): token unit, e.g. "3gram_chars"
	no (str): normalization technique, e.g. "tf-idf"
	data_rep (int): number of the data repetition
	"""
							
	frame["subgenre_level"] = level
	frame["class1"] = class1
	frame["class2"] = class2
	frame["mfw"] = mfw
	frame["token_unit"] = unit
	frame["normalization"] = no
	frame["data_repetition"] = data_rep
	
	return frame
	
	
def set_frame_metadata_topics(frame, level, class1, class2, num_topics, optimize_interval, data_rep, topic_rep):
	"""
	Set metadata columns for classification results frame (topics).
	
	Arguments:
	frame (DataFrame): Data frame for the results
	level (str): subgenre level that is analyzed, e.g. "theme"
	class1 (str): the positive class, e.g."novela histórica"
	class2 (str): the negative class, e.g. "other"
	num_topics (int): number of topics
	optimize_interval (int): in which interval the hyperparameters should be optimized
	data_rep (int): number of the data repetition
	topic_rep (int): number of the topic modeling repetition
	"""
							
	frame["subgenre_level"] = level
	frame["class1"] = class1
	frame["class2"] = class2
	frame["num_topics"] = num_topics
	frame["optimize_interval"] = optimize_interval
	frame["data_repetition"] = data_rep
	frame["topic_repetition"] = topic_rep
	
	return frame
	
	
def get_results_subgenres_topics(wdir, data_dir, clf, num_topics, oi, subgenre_1, subgenre_2):
	"""
	Get the top and mean results for a certain subgenre constellation (e.g. "novela histórica" vs. "other",
	given the classifier (e.g. "SVM"), the number of topics, and the optimize interval.
	Returns the following numbers: top accuracy, mean accuracy, standard deviation accuracy,
	top F1, mean F1, std.dev. F1
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing the classification results files
	clf (str): the classifier used, e.g. "SVM"
	num_topics (int): the number of topics
	oi (int): the optimize interval parameter
	subgenre_1 (str): the positive class
	subgenre_2 (str): the negative class 
	"""
	print("get results subgenres topics...")
	print("subgenre 1: " + subgenre_1)
	print("subgenre 2: " + subgenre_2)
	
	accuracy_collected = []
	f1_collected = []
	
	result_file = "results-" + clf + "-topics" + str(num_topics) + "_" + str(oi) + "in.csv"
	results = pd.read_csv(join(wdir, data_dir, result_file), index_col=0)
	# select only the results for the subgenre constellation
	print(len(results))
	results_sub = results.loc[results["class1"]==subgenre_1][results["class2"]==subgenre_2]
	print(len(results_sub))
	
	'''
	acc = results["test_accuracy"].tolist()
	for acc_value in acc:
		accuracy_collected.append(acc_value)
		
	f1 = results["test_f1"].tolist()
	for f1_value in f1:
		if f1_value != 0:
			f1_collected.append(f1_value)
			
				
	top_acc = max(accuracy_collected)
	mean_acc = np.mean(accuracy_collected)
	std_acc = np.std(accuracy_collected)
	
	top_f1 = max(f1_collected)
	mean_f1 = np.mean(f1_collected)
	std_f1 = np.std(f1_collected)
		
	print("num values: " + str(len(accuracy_collected)))	
		
	print("top acc: " + str(top_acc))
	print("mean acc: " + str(mean_acc))
	print("std acc: " + str(std_acc))
	
	print("top f1: " + str(top_f1))
	print("mean f1: " + str(mean_f1))
	print("std f1: " + str(std_f1))
	'''
	print("done")
	

def get_results_classifier(wdir, data_dir, classifier, feature_type):
	"""
	Get the top and mean results for a certain classifier and on a determined subgenre level (through the data_dir).
	Returns the following numbers: top accuracy, mean accuracy, standard deviation accuracy,
	top F1, mean F1, std.dev. F1
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing the classification results files
	classifier (str): shortcut for the classifier (KNN, SVM, RF)
	feature_type (str): which feature type to consider, e.g. "MFW" (MFW with word unit), "MFW word n-grams", "MFW character n-grams", "topics"
	"""
	print("get classifier results for " + classifier + "...")
	
	# general set of feature parameters
	mfws = [100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000]
	units_word_ngrams = ["2gram_words", "3gram_words", "4gram_words"]
	units_char_ngrams = ["3gram_chars", "4gram_chars", "5gram_chars", 
	"3gram_chars_word", "4gram_chars_word", "5gram_chars_word", "3gram_chars_affix-punct", "4gram_chars_affix-punct", "5gram_chars_affix-punct"]
	norms = ["tf", "tfidf", "zscore"]

	num_topics = [50, 60, 70, 80, 90, 100]
	optimize_intervals = [50, 100, 250, 500, 1000, 2500, 5000, None]
	topic_repetitions = 5
	
	accuracy_collected = []
	f1_collected = []
	
	if feature_type == "topics":
		# collect all relevant results
		# results file name e.g.: results-SVM-topics100_250in.csv
		for t in num_topics:
			for oi in optimize_intervals:
				result_file = "results-" + classifier + "-topics" + str(t) + "_" + str(oi) + "in.csv"
				collect_results(wdir, data_dir, result_file, accuracy_collected, f1_collected)
				
	else:
		# results file name e.g.: results-KNN-mfw2000_3gram_chars_tfidf.csv
		for mfw in mfws:
			for n in norms:
				if feature_type == "MFW":
					result_file = "results-" + classifier + "-mfw" + str(mfw) + "_word_" + n + ".csv"
					collect_results(wdir, data_dir, result_file, accuracy_collected, f1_collected)
				elif feature_type == "MFW word n-grams":
					for unit in units_word_ngrams:
						result_file = "results-" + classifier + "-mfw" + str(mfw) + "_" + unit + "_" + n + ".csv"
						collect_results(wdir, data_dir, result_file, accuracy_collected, f1_collected)
				elif feature_type == "MFW character n-grams":
					for unit in units_char_ngrams:
						result_file = "results-" + classifier + "-mfw" + str(mfw) + "_" + unit + "_" + n + ".csv"
						collect_results(wdir, data_dir, result_file, accuracy_collected, f1_collected)
				
	top_acc = max(accuracy_collected)
	mean_acc = np.mean(accuracy_collected)
	std_acc = np.std(accuracy_collected)
	
	top_f1 = max(f1_collected)
	mean_f1 = np.mean(f1_collected)
	std_f1 = np.std(f1_collected)
	
	return len(accuracy_collected), top_acc, mean_acc, std_acc, top_f1, mean_f1, std_f1
	
	'''
	print("num values: " + str(len(accuracy_collected)))	
		
	print("top acc: " + str(top_acc))
	print("mean acc: " + str(mean_acc))
	print("std acc: " + str(std_acc))
	
	print("top f1: " + str(top_f1))
	print("mean f1: " + str(mean_f1))
	print("std f1: " + str(std_f1))
	
	print("done")
	'''

def collect_results(wdir, data_dir, result_file, accuracy_collected, f1_collected):
	"""
	Add classification results (accuracy and f1) from frame to list.
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the data directory
	result_file (str): path to the result file
	accuracy_collected (list): list for accuracy results
	f1_collected (list): list for f1 results
	"""
				
	results = pd.read_csv(join(wdir, data_dir, result_file), index_col=0)
	
	acc = results["test_accuracy"].tolist()
	for acc_value in acc:
		accuracy_collected.append(acc_value)
		
	f1 = results["test_f1"].tolist()
	for f1_value in f1:
		if f1_value != 0:
			f1_collected.append(f1_value)
		

def plot_mfw_results(wdir, data_dir, clf):
	"""
	Create a scatter plot showing the mean accuracy for the different numbers of mfw and normalization techniques.
	The classifier is chosen beforehand for the subgenre level in question.
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing the classification results
	clf (str): which classifier to use (KNN, SVM, RF)
	"""
	print("plot mfw results...")
	
	# output directory for plots (relative to data dir)
	outdir = "visuals"
	
	mfws = [100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000]
	norms = ["tfidf", "zscore"] #tf is equal to zscore
	
	# example results file name: results-KNN-mfw2000_3gram_chars_tfidf.csv
	# create scatter plot
	
	# collect all values
	val_fr = pd.DataFrame(index=mfws)
	
	fig = go.Figure()
	
	for n in norms:
		values = []
		for mfw in mfws:
			results_file = "results-" + clf + "-mfw" + str(mfw) + "_word_" + n + ".csv"
			results = pd.read_csv(join(wdir, data_dir, results_file),index_col=0)
			acc_list = results["test_accuracy"].tolist()
			acc_mean = np.mean(acc_list)
			values.append(acc_mean)
		
		fig.add_trace(go.Scatter(x=mfws, y=values,
                    mode='lines+markers',
                    line=dict(shape='spline'),
                    name=n))
		val_fr[n] = values
	
	# add another line for the mean for each mfw
	means = val_fr.mean(axis=1).tolist()
	fig.add_trace(go.Scatter(x=mfws, y=means,
                    mode='lines+markers',
                    line=dict(shape='spline',color='black',dash='dash'),
                    name="mean"))
    
	fig.update_layout(autosize=False, width=800, height=500, title="Classification results (MFW, " + clf + ")", legend_font=dict(size=14))
	fig.update_xaxes(title="number of MFW",tickfont=dict(size=14))
	fig.update_yaxes(title="mean accuracy")

	outfile = "plot_scatter_" + clf + "_MFW"
	fig.write_image(join(wdir, data_dir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, data_dir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	print("done")

	
	
def plot_mfw_ngram_results(wdir, data_dir, clf, unit):
	"""
	Create a scatter plot showing the mean accuracy for the different numbers of mfw ngrams and normalization techniques.
	The classifier is chosen beforehand for the subgenre level in question.
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing the classification results
	clf (str): which classifier to use (KNN, SVM, RF)
	unit (str): which ngram unit to use, "words" or "chars"
	"""
	print("plot mfw ngram results...")
	
	# output directory for plots (relative to data dir)
	outdir = "visuals"
	
	mfws = [100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000]
	units_word_ngrams = ["2gram_words", "3gram_words", "4gram_words"]
	units_char_ngrams = ["3gram_chars", "4gram_chars", "5gram_chars", 
	"3gram_chars_word", "4gram_chars_word", "5gram_chars_word", "3gram_chars_affix-punct", "4gram_chars_affix-punct", "5gram_chars_affix-punct"]
	norms = ["tfidf", "zscore"] #tf is equal to zscore
	
	# example results file name: results-KNN-mfw2000_3gram_chars_tfidf.csv
	# create scatter plot
	
	if unit == "words":
		# collect all values
		val_fr = pd.DataFrame(index=mfws)
	
		fig = go.Figure()
		for n in norms:
			for u in units_word_ngrams:
				values = []
				for mfw in mfws:
			
					results_file = "results-" + clf + "-mfw" + str(mfw) + "_" + u + "_" + n + ".csv"
					results = pd.read_csv(join(wdir, data_dir, results_file),index_col=0)
					acc_list = results["test_accuracy"].tolist()
					acc_mean = np.mean(acc_list)
					values.append(acc_mean)
		
				fig.add_trace(go.Scatter(x=mfws, y=values,
                    mode='lines+markers',
                    line=dict(shape='spline'),
                    name=u + " (" + n + ")"))
                
				val_fr[u + "_" + n] = values
        
        # add another line for the mean for each mfw
		means = val_fr.mean(axis=1).tolist()
		fig.add_trace(go.Scatter(x=mfws, y=means,
                    mode='lines+markers',
                    line=dict(shape='spline',color='black',dash='dash'),
                    name="mean"))
                
		fig.update_layout(autosize=False, width=900, height=500, title="Classification results (MFW, " + clf + ", ngrams " + unit + ")", legend_font=dict(size=14))
		fig.update_xaxes(title="number of MFW",tickfont=dict(size=14))
		fig.update_yaxes(title="mean accuracy")

		outfile = "plot_scatter_" + clf + "_MFW_ngrams_" + unit
		fig.write_image(join(wdir, data_dir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
		fig.write_html(join(wdir, data_dir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
		
	if unit == "chars":
	# create three different charts for the different types of char ngrams (standard, word-group, affix-punct-group)
		for i in range(3):
			# collect all values
			val_fr = pd.DataFrame(index=mfws)
			
			fig = go.Figure()
			for n in norms:
				start_pos = i*3
				end_pos = start_pos + 3
				for u in units_char_ngrams[start_pos:end_pos]:
					values = []
					for mfw in mfws:
				
						results_file = "results-" + clf + "-mfw" + str(mfw) + "_" + u + "_" + n + ".csv"
						results = pd.read_csv(join(wdir, data_dir, results_file),index_col=0)
						acc_list = results["test_accuracy"].tolist()
						acc_mean = np.mean(acc_list)
						values.append(acc_mean)
			
					fig.add_trace(go.Scatter(x=mfws, y=values,
						mode='lines+markers',
						line=dict(shape='spline'),
						name=u + " (" + n + ")"))
						
					val_fr[u + "_" + n] = values	
					
			# add another line for the mean for each mfw
			means = val_fr.mean(axis=1).tolist()
			fig.add_trace(go.Scatter(x=mfws, y=means,
                    mode='lines+markers',
                    line=dict(shape='spline',color='black',dash='dash'),
                    name="mean"))
			
			fig.update_layout(autosize=False, width=900, height=500, title="Classification results (MFW, " + clf + ", ngrams " + unit + ")", legend_font=dict(size=14))
			fig.update_xaxes(title="number of MFW",tickfont=dict(size=14))
			fig.update_yaxes(title="mean accuracy")

			outfile = "plot_scatter_" + clf + "_MFW_ngrams_" + unit + "_" + str(i)
			fig.write_image(join(wdir, data_dir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
			fig.write_html(join(wdir, data_dir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	print("done")	


			
def plot_topic_results(wdir, data_dir, clf):
	"""
	Create a scatter plot showing the mean accuracy for the different numbers of topics and optimize intervals.
	The classifier is chosen beforehand for the subgenre level in question.
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing the classification results
	clf (str): which classifier to use (KNN, SVM, RF)
	"""
	print("plot topic results...")
	
	# output directory for plots (relative to data dir)
	outdir = "visuals"
	
	num_topics = [50, 60, 70, 80, 90, 100]
	optimize_intervals = [50, 100, 250, 500, 1000, 2500, 5000, None]
	topic_repetitions = 5
	
	# example results file name: results-SVM-topics100_250in.csv
	
	# create scatter plot
	fig = go.Figure()
	
	# collect all values
	val_fr = pd.DataFrame(index=num_topics)
	
	for oi in optimize_intervals:
		values = []
		for t in num_topics:
			results_file = "results-" + clf + "-topics" + str(t) + "_" + str(oi) + "in.csv"
			results = pd.read_csv(join(wdir, data_dir, results_file),index_col=0)
			acc_list = results["test_accuracy"].tolist()
			acc_mean = np.mean(acc_list)
			values.append(acc_mean)
		
		fig.add_trace(go.Scatter(x=num_topics, y=values,
                    mode='lines+markers',
                    line=dict(shape='spline'),
                    name=str(oi)))
                    
		val_fr[oi] = values
	
	# add another line for the mean for each t
	means = val_fr.mean(axis=1).tolist()
	fig.add_trace(go.Scatter(x=num_topics, y=means,
                    mode='lines+markers',
                    line=dict(shape='spline',color='black',dash='dash'),
                    name="mean"))
        
	fig.update_layout(autosize=False, width=800, height=500, title="Classification results (topics, " + clf + ")", legend_font=dict(size=14))
	fig.update_xaxes(title="number of topics",tickfont=dict(size=14))
	fig.update_yaxes(title="mean accuracy")

	outfile = "plot_scatter_" + clf + "_topics"
	fig.write_image(join(wdir, data_dir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, data_dir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	print("done")
	
	
def get_result_table_classifier(wdir, data_dir, feature_type):
	"""
	Create an overview of the classification results for the three classifiers.
	Returns a CSV table containing accuracy and f1 scores for each classifier 
	and main type of feature set. 
	
	Arguments:
	wdir (str): Path to the working directory
	data_dir (str): Relative path to the directory where all the classification results are stored
	feature_type (str): "mfw" or "topics"
	"""
	print("get result table classifier for " + feature_type + "...")
	
	# relative path to the output directory where the table is stored (relative to data_dir)
	outdir = "results_summaries"
	clfs = ["KNN", "SVM", "RF"]
	feature_sets_mfw = ["MFW", "MFW word n-grams", "MFW character n-grams"]
	
	columns = ["classifier", "feature_type", "num_runs", "top_acc", "mean_acc", "sd_acc", "top_f1", "mean_f1", "sd_f1"]
	summary_fr = pd.DataFrame(columns=columns)
	
	for cl in clfs:
		if feature_type == "mfw":
			# prepare a frame to calculate average scores for the three feature sets later
			avg_fr = pd.DataFrame(index=columns)
			
			for feature_set in feature_sets_mfw:
				# fetch the results
				res = get_results_classifier(wdir, data_dir, cl, feature_set)
				
				data = [cl, feature_set] + res
				res_ser = pd.Series(index=columns, data=data)
				# append to overall summary
				summary_fr = summary_fr.append(res_ser) # ignore_index = True?
				# append to avg frame
				avg_fr = avg_fr.append(res_ser) # ignore_index = True?
			
			runs_sum = avg_fr["num_runs"].sum()
			avg_scores = []
			score_cols = ["top_acc", "mean_acc", "sd_acc", "top_f1", "mean_f1", "sd_f1"]
			
			for score in score_cols:
				avg_sc = avg_fr[score].mean(axis=0)
				avg_scores.append(avg_sc)
			
			avg_data = [cl, "all", runs_sum] + avg_scores
			avg_ser = pd.Series(index=columns, data=avg_data)
			# append avg to overall summary
			summary_fr = summary_fr.append(avg_ser)
		
		elif feature_type == "topics":
			# fetch the results
			res = get_results_classifier(wdir, data_dir, cl, feature_type)
			data = [cl, feature_type] + res
			res_ser = pd.Series(index=columns, data=data)
			# append to overall summary
			summary_fr = summary_fr.append(res_ser) # ignore_index = True?
	
	# save result summary
	summary_fr.to_csv(join(wdir, data_dir, outdir, "results_classifier_" + feature_type + ".csv"))
	
	print("done")

	
def plot_feature_set_results(wdir, data_dir, cl_mfw, cl_topics):
	"""
	Create a set of plots to check which feature sets worked best for a chosen classifier.
	
	Arguments:
	wdir (str): path to the working directory
	data_dir (str): relative path to the directory containing all the classification results
	cl_mfw (str): best classifier chosen for mfw feature sets
	cl_topics (str): best classifier chosen for topic feature sets
	"""
	print("plot feature set results...")
	
	plot_mfw_results(wdir, data_dir, cl_mfw) 
	plot_mfw_ngram_results(wdir, data_dir, cl_mfw, "words")
	plot_mfw_ngram_results(wdir, data_dir, cl_mfw, "chars")
	plot_topic_results(wdir, data_dir, cl_topics)	

	print("done")
	

#################### FUNCTION CALLS ####################

wdir = "/home/ulrike/Git"


# get relative paths to feature sets
#feature_set_paths = get_feature_paths(wdir)
'''
# write to a csv file for later use
df = pd.DataFrame(data=feature_set_paths)
df.to_csv(join(wdir, "data-nh/analysis/features/feature_sets.csv"), index=False, header=False)
'''


# prepare the feature sets for use with SVM: scale to [0,1]
#scale_feature_sets(wdir, feature_set_paths)


###################### preliminary parameter study #####################

#parameter_study(wdir)

#evaluate_parameter_study(wdir, "data-nh/analysis/classification/parameter_study", "KNN", "param_n_neighbors")
#evaluate_parameter_study(wdir, "data-nh/analysis/classification/parameter_study", "KNN", "param_metric")
#evaluate_parameter_study(wdir, "data-nh/analysis/classification/parameter_study", "KNN", "param_weights")
#evaluate_parameter_study(wdir, "data-nh/analysis/classification/parameter_study", "SVM", "param_C")
#evaluate_parameter_study(wdir, "data-nh/analysis/classification/parameter_study", "RF", "param_max_features")				
	



##################### main classification tasks #####################

# parameters that are set for the classifiers based on the results in the preliminary parameter study:
# KNN, mfw: n_neighbors = 3, weight = distance, metric = manhattan
# KNN, topics: n_neighbors = 5, weight = distance, metric = manhattan
# SVM, C: 1
# FR: max_features: sqrt

#### primary literary currents ####

#plot_overview_literary_currents_primary("/home/ulrike/Git/", "conha19/metadata.csv", "data-nh/analysis/classification/literary-currents/", "overview-primary-currents-corp")

# chosen subgenre constellations
subgenre_sets_currents = [{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela realista", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela naturalista", "class 2": "other"},
{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "novela realista"},
{"level": "subgenre-current", "class 1": "novela romántica", "class 2": "novela naturalista"},
{"level": "subgenre-current", "class 1": "novela realista", "class 2": "novela naturalista"}]

# select metadata
#select_metadata(wdir, "conha19/metadata.csv", subgenre_sets_currents, "data-nh/analysis/classification/data_selection/main/")

#### primary thematic labels ####

#plot_overview_theme_primary("/home/ulrike/Git/", "conha19/metadata.csv", "data-nh/analysis/classification/themes/", "overview-primary-themes-corp")


subgenre_sets_theme = [{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela sentimental", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela de costumbres", "class 2": "other"},
{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "novela sentimental"},
{"level": "subgenre-theme", "class 1": "novela histórica", "class 2": "novela de costumbres"},
{"level": "subgenre-theme", "class 1": "novela sentimental", "class 2": "novela de costumbres"}]

#select_metadata(wdir, "conha19/metadata.csv", subgenre_sets_theme, "data-nh/analysis/classification/data_selection/main/")


#### novelas ####
subgenre_sets_novela = [{"level": "subgenre-novela", "class 1": "novela", "class 2": "other"}]

#select_metadata(wdir, "conha19/metadata.csv", subgenre_sets_novela, "data-nh/analysis/classification/data_selection/main/")



#### ALL levels ####

# how often was the data selection (with undersampling) repeated?
repetitions = 10

# chosen feature parameters # 400mfw, 4gram_chars_affix-punct, tf
mfws = [500, 1000, 2000, 3000, 4000, 5000] #100, 200, 300, 400, 
token_units = ["word", "2gram_words", "3gram_words", "4gram_words", "3gram_chars", "4gram_chars", "5gram_chars", 
"3gram_chars_word", "4gram_chars_word", "5gram_chars_word", "3gram_chars_affix-punct", "4gram_chars_affix-punct", "5gram_chars_affix-punct"]
norms = ["tf", "tfidf", "zscore"]

num_topics = [50, 60, 70, 80, 90, 100]
optimize_intervals = [50, 100, 250, 500, 1000, 2500, 5000, None]
topic_repetitions = 5

subgenre_sets = {"themes": subgenre_sets_theme, "literary-currents": subgenre_sets_currents, "novelas": subgenre_sets_novela}
# classifiers
classifiers = ["KNN", "SVM", "RF"]
# number of cv folds
cv = 10


for level in ["themes", "literary-currents", "novelas"]:
	
	print("doing level " + level + "...")
	
	outpath = join("data-nh/analysis/classification/", level, "results_data")
	
	
	
	
	###### MFW ######
	
	print("doing MFW...")
	
	feature_dir_mfw = "data-nh/analysis/features/mfw/"
	
	for mfw in mfws:
		for unit in token_units:
			for no in norms:
				print("params: " + str(mfw) + "mfw, " + unit + ", " + no)
				
				## choose classifier
				for cl in classifiers:
					print("doing " + cl + "...")
					
					feature_params = str(mfw) + "_" + unit + "_" + no
					
					# prepare data frames for classification results
					fr_knn_mfw = pd.DataFrame()
					fr_svm_mfw = pd.DataFrame()
					fr_rf_mfw = pd.DataFrame()
					
					# prepare collection of feature importances
					if cl == "SVM" or cl == "RF":
						label_columns = ["subgenre_level", "class1", "class2", "mfw", "token_unit", "normalization", "data_repetition", "cv_call"]
						feature_names = get_feature_names_mfw(wdir, feature_dir_mfw, mfw, unit, no)
						feature_names = list(feature_names)
						columns = label_columns + feature_names
						features_frame = pd.DataFrame(columns=columns)
				
					# prepare collection of true and predicted labels
					label_columns = ["subgenre_level", "class1", "class2", "mfw", "token_unit", "normalization", "data_repetition", "idno", "y_true"]
					for label_rep in range(repetitions):
						label_columns.append("y_" + str(label_rep))
					label_frame = pd.DataFrame(columns=label_columns)
					
					for sb_set in subgenre_sets[level]:
						class1 = re.sub(r"\s", r"-", sb_set["class 1"])
						class2 = re.sub(r"\s", r"-", sb_set["class 2"])
				
						for data_rep in range(repetitions):
						
							# select data corresponding to the chosen features and classifier
							X,y,idnos = select_data_mfw(wdir, "data-nh/analysis/classification/data_selection/main/", feature_dir_mfw, sb_set, mfw, unit, no, data_rep, cl)
						
							# get an instance of the classifier with the chosen parameter settings
							estimator = get_estimator(cl, "mfw")
							
							# run cross validation and collect results
							scores = get_scores(estimator, X, y, sb_set["class 1"], cv)
							score_frame = get_score_frame(scores)
							score_frame = set_frame_metadata_mfw(score_frame, sb_set["level"], sb_set["class 1"], sb_set["class 2"], mfw, unit, no, data_rep)
							score_frame = score_frame.drop("estimator", axis=1)
							
							if cl == "SVM":
								fr_svm_mfw = fr_svm_mfw.append(score_frame, sort=False, ignore_index=True)
							elif cl == "KNN":
								fr_knn_mfw = fr_knn_mfw.append(score_frame, sort=False, ignore_index=True)
							elif cl == "RF":
								fr_rf_mfw = fr_rf_mfw.append(score_frame, sort=False, ignore_index=True)
							
							# collect true labels and predicted labels for each cv run
							label_frame_cv = store_labels(scores, cv, X, y, idnos)
							label_frame_cv = set_frame_metadata_mfw(label_frame_cv, sb_set["level"], sb_set["class 1"], sb_set["class 2"], mfw, unit, no, data_rep)
							label_frame = label_frame.append(label_frame_cv, sort=False, ignore_index=True)
							
							# collect feature importances
							if cl == "SVM" or cl == "RF":
								feature_frame_cv = store_features(cl, scores, cv, feature_names)
								feature_frame_cv = set_frame_metadata_mfw(feature_frame_cv, sb_set["level"], sb_set["class 1"], sb_set["class 2"], mfw, unit, no, data_rep)
								features_frame = features_frame.append(feature_frame_cv, sort=False, ignore_index=True)
							
							
					# store classification results
					if cl == "SVM":
						fr_svm_mfw.to_csv(join(wdir, outpath, "results-SVM-mfw" + feature_params + ".csv"))
					elif cl == "KNN":
						fr_knn_mfw.to_csv(join(wdir, outpath, "results-KNN-mfw" + feature_params + ".csv"))
					elif cl == "RF":
						fr_rf_mfw.to_csv(join(wdir, outpath, "results-RF-mfw" + feature_params + ".csv"))
					
					# store label information
					label_filename = "labels_" + cl + "-mfw" + feature_params + ".csv"
					label_frame.to_csv(join(wdir, outpath, label_filename))
					
					# store feature importances
					if cl == "SVM" or cl == "RF":
						features_filename = "features-" + cl + "-mfw" + feature_params + ".csv"
						features_frame.to_csv(join(wdir, outpath, features_filename))
						
'''
	###### TOPICS ######
	print("doing topics...")
	
	feature_dir_topics = "data-nh/analysis/features/topics/4_aggregates/"
	
	for t in num_topics:
		for oi in optimize_intervals:
			print("params: " + str(t) + " topics, " + str(oi) + "in")
			
			## choose classifier
			for cl in classifiers:
				print("doing " + cl + "...")
				
				feature_params = str(t) + "_" + str(oi) + "in"
				
				# prepare data frames for classification results
				fr_knn_topics = pd.DataFrame()
				fr_svm_topics = pd.DataFrame()
				fr_rf_topics = pd.DataFrame()
				
				for topic_rep in range(topic_repetitions):
					
					# prepare collection of feature importances
					if cl == "SVM" or cl == "RF":
						label_columns = ["subgenre_level", "class1", "class2", "num_topics", "optimize_interval", "data_repetition", "topic_repetition", "call"]
						topic_numbers = list(range(t))
						columns = label_columns + topic_numbers
						features_frame = pd.DataFrame(columns=columns)
						
					# prepare collection of true and predicted labels
					label_columns = ["subgenre_level", "class1", "class2", "num_topics", "optimize_interval", "data_repetition", "topic_repetition", "idno", "y_true"]
					for label_rep in range(repetitions):
						label_columns.append("y_" + str(label_rep))
					label_frame = pd.DataFrame(columns=label_columns)
					
					for sb_set in subgenre_sets[level]:
						class1 = re.sub(r"\s", r"-", sb_set["class 1"])
						class2 = re.sub(r"\s", r"-", sb_set["class 2"])
					
						for data_rep in range(repetitions):
						
							# select data corresponding to the chosen features and classifier
							X,y,idnos = select_data_topics(wdir, "data-nh/analysis/classification/data_selection/main/", feature_dir_topics, sb_set, t, oi, data_rep, topic_rep, cl)
					
							# get an instance of the classifier with the chosen parameter settings
							estimator = get_estimator(cl, "topics") 
					
							# run cross validation and collect results
							scores = get_scores(estimator, X, y, sb_set["class 1"], cv)
							score_frame = get_score_frame(scores)
							score_frame = set_frame_metadata_topics(score_frame, sb_set["level"], sb_set["class 1"], sb_set["class 2"], t, oi, data_rep, topic_rep)
							score_frame = score_frame.drop("estimator", axis=1)
							
							if cl == "SVM":
								fr_svm_topics = fr_svm_topics.append(score_frame, sort=False, ignore_index=True)
							elif cl == "KNN":
								fr_knn_topics = fr_knn_topics.append(score_frame, sort=False, ignore_index=True)
							elif cl == "RF":
								fr_rf_topics = fr_rf_topics.append(score_frame, sort=False, ignore_index=True)
							
							
							# collect true labels and predicted labels for each cv run
							label_frame_cv = store_labels(scores, cv, X, y, idnos)
							label_frame_cv = set_frame_metadata_topics(label_frame_cv, sb_set["level"], sb_set["class 1"], sb_set["class 2"], t, oi, data_rep, topic_rep)
							label_frame = label_frame.append(label_frame_cv, sort=False, ignore_index=True)
							
							# collect feature importances
							if cl == "SVM" or cl == "RF":
								feature_frame_cv = store_features(cl, scores, cv, topic_numbers)
								feature_frame_cv = set_frame_metadata_topics(feature_frame_cv, sb_set["level"], sb_set["class 1"], sb_set["class 2"], t, oi, data_rep, topic_rep)
								features_frame = features_frame.append(feature_frame_cv, sort=False, ignore_index=True)
							
					# store label information
					label_filename = "labels-" + cl + "-topics" + feature_params + "-topic-rep_" + str(topic_rep) + ".csv"
					label_frame.to_csv(join(wdir, outpath, label_filename))
					
					# store feature importances
					if cl == "SVM" or cl == "RF":
						features_filename = "features-" + cl + "-topics" + feature_params + "-topic-rep_" + str(topic_rep) + ".csv"
						features_frame.to_csv(join(wdir, outpath, features_filename))
						
				# store classification results
				if cl == "SVM":
					fr_svm_topics.to_csv(join(wdir, outpath, "results-SVM-topics" + feature_params + ".csv"))
				elif cl == "KNN":
					fr_knn_topics.to_csv(join(wdir, outpath, "results-KNN-topics" + feature_params + ".csv"))
				elif cl == "RF":
					fr_rf_topics.to_csv(join(wdir, outpath, "results-RF-topics" + feature_params + ".csv"))
'''

print("done!")


##################### analysis and visualization of results #####################
data_dir_themes = "data-nh/analysis/classification/themes/results_data"
data_dir_currents = "data-nh/analysis/classification/literary-currents/results_data"
data_dir_novelas = "data-nh/analysis/classification/novelas/results_data"

## CHOOSE CLASSIFIER:
# get the top and mean results for the different classifier types, for certain subgenre levels
# just MFW = word unit, "MFW word n-grams", "MFW character n-grams"


# THEME LEVEL:
#get_result_table_classifier(wdir, data_dir_themes, "mfw")
#get_result_table_classifier(wdir, data_dir_themes, "topics")

# OLD:
#get_results_classifier(wdir, data_dir_themes, "KNN", "MFW")
#get_results_classifier(wdir, data_dir_themes, "KNN", "MFW word n-grams")
#get_results_classifier(wdir, data_dir_themes, "KNN", "MFW character n-grams")

#get_results_classifier(wdir, data_dir_themes, "SVM", "MFW")
#get_results_classifier(wdir, data_dir_themes, "SVM", "MFW word n-grams")
#get_results_classifier(wdir, data_dir_themes, "SVM", "MFW character n-grams")

#get_results_classifier(wdir, data_dir_themes, "RF", "MFW")
#get_results_classifier(wdir, data_dir_themes, "RF", "MFW word n-grams")
#get_results_classifier(wdir, data_dir_themes, "RF", "MFW character n-grams")

#get_results_classifier(wdir, data_dir_themes, "KNN", "topics")
#get_results_classifier(wdir, data_dir_themes, "SVM", "topics")
#get_results_classifier(wdir, data_dir_themes, "RF", "topics")



# LITERARY CURRENT LEVEL:
#get_result_table_classifier(wdir, data_dir_currents, "mfw")
#get_result_table_classifier(wdir, data_dir_currents, "topics")


# NOVELAS LEVEL:
#get_result_table_classifier(wdir, data_dir_novelas, "mfw")
#get_result_table_classifier(wdir, data_dir_novelas, "topics")


############################################

## CHOOSE FEATURE SET:
# for the chosen classifier on each subgenre level: which feature set works best?
# and how do the results vary for different feature sets?

# THEME LEVEL:
#plot_feature_set_results(wdir, data_dir_themes, "RF", "SVM") # OBS: das sind mit den neuen Ergebnissen vermutlich andere Classifier!!! Anpassen!!!

# OLD:
#plot_mfw_results(wdir, data_dir_themes, "RF") 
#plot_mfw_ngram_results(wdir, data_dir_themes, "RF", "words")
#plot_mfw_ngram_results(wdir, data_dir_themes, "RF", "chars")
#plot_topic_results(wdir, data_dir_themes, "SVM")

# LITERARY CURRENT LEVEL:
#plot_feature_set_results(wdir, data_dir_currents, "SVM", "SVM")

# NOVELAS LEVEL:
#plot_feature_set_results(wdir, data_dir_currents, "RF", "RF")



############################################


## ANALYZE SUBGENRE CLASSIFICATIONS:
# with the best classifier and feature sets for each subgenre label:
# analyze the classification results for the different subgenre constellations
# analyze feature importances and misclassifications

# THEME LEVEL:

# für jede der 6 Konstellationen: Tabelle mit Ergebnissen wie bei Cl.-Auswahl
# topics: 100, oi: 250, SVM
#get_results_subgenres_topics(wdir, data_dir_themes, "SVM", 100, 250, "novela histórica", "other")

# LITERARY CURRENT LEVEL:

# NOVELAS LEVEL:



############################################


## ANALYZE FEATURE IMPORTANCES:


############################################


## ANALYZE MISCLASSIFICATIONS:




############################################
# NOTES:

# bei MFW features: am Ende die Spalten "call" umbennenen in "cv_call"!!! (überall, wo sie noch nicht so heißen) es gab da einen Konflikt, weil 
# auch ein char-4gram "call" hieß

# scores["estimator"][0].predict(X) : predicted labels
# scores["estimator"][0].classes_ : which classes are there in general
# scores["test_f1"] 
# scores["estimator"][0].coef_  : only for SVM
# scores["estimator"][0].feature_importances_ (only for RF, misleading? see documentation 
# - should be no problem since all features are numerical), derived from training data sets)
# for KNN there is no feature importance/coef, only the information which were the neighbors 
# instead one could make a contrastive analysis using the selected feature set (e.g. calculate zeta-scores)
