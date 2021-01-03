#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: topics.py

"""
@author: Ulrike Henny-Krahmer

Serves to generate topic-based feature sets for the corpus.
"""

from os.path import join
from os.path import isfile
import glob
import pandas as pd
import numpy as np
from lxml import etree
import plotly.graph_objects as go
from tmw import prepare
from tmw import model
from tmw import postprocess
from tmw import visualize


########## FUNCTIONS ##########

def clean_stoplist(wdir, stopwordsfile):
	"""
	Clean the stopword list by removing double entries and sorting it in alphabetical order.
	
	Arguments:
	wdir (str): path to the working directory
	stopwordsfile (str): relative path to the stopword file
	"""
	print("cleaning stopword list...")
	
	# read stopword list
	stopwords = pd.read_csv(join(wdir, stopwordsfile), header=None)
	stopwords = stopwords.drop_duplicates()
	stopwords = stopwords.sort_values(by=0)
	
	# write stopword list
	stopwords.to_csv(join(wdir, stopwordsfile), header=False, index=False)
	
	print("done")
	
	

def plot_zero_values_bar(wdir, feature_dir, num_topics, optimization_intervals, topic_rep, outfile):
	"""
	Create a bar chart for zero value analysis of all combinations of topic numbers and optimization intervals.
	Average the numbers for the different repetitions of models.
	
	Arguments:
	wdir (str): path to the working directory
	feature_dir (str): relative path to the directory containing the topic model data
	num_topics (list): list with numbers of topics used for the various models
	optimization_intervals (list): list with values for optimization intervals
	topic_rep (int): number of repetitions for topic models
	outfile (str): relative path to the output file
	"""
	
	print("plot zero values bar...")
	
	labels = []
	
	zero_counts_all = []
	non_zero_counts_all = []
	zero_counts_rel_all = []
	non_zero_counts_rel_all = []
			
	
	# collect zero and non-zero values for all settings
	for t in num_topics:
		for oi in optimization_intervals:
			
			labels.append(str(t) + "tp_" + str(oi) + "int")
			
			zero_counts = []
			non_zero_counts = []
			zero_counts_rel = []
			non_zero_counts_rel = []
			
			for rep in range(topic_rep):
				folder_name = str(t) + "tp-5000it-" + str(oi) + "in-" + str(rep)
				file_name = "avgtopicscores_by-idno.csv"
				 
				features = pd.read_csv(join(wdir, feature_dir, folder_name, file_name), index_col=0)
	
				# get number of zero values for each column
				x = []
				for col in features:
					col_counts = features[col].value_counts()
					if 0 in col_counts.index:
						x.append(col_counts[0])
					else:
						x.append(0)
		
				# overall number of zero values
				zero_count = sum(x)
				# overall number of values
				value_count = features.shape[0] * features.shape[1]
				non_zero_count = value_count - zero_count
		
				zero_counts.append(zero_count)
				zero_counts_rel.append(zero_count / value_count)
				non_zero_counts.append(non_zero_count)
				non_zero_counts_rel.append(non_zero_count / value_count)
			
			# sum the counts for all topic modeling repetitions and divide by number of repetitions to get average values
			zero_counts = sum(zero_counts) / topic_rep
			non_zero_counts = sum(non_zero_counts) / topic_rep
			zero_counts_rel = sum(zero_counts_rel) / topic_rep
			non_zero_counts_rel = sum(non_zero_counts_rel) / topic_rep
	
			zero_counts_all.append(zero_counts)
			non_zero_counts_all.append(non_zero_counts)
			zero_counts_rel_all.append(zero_counts_rel)
			non_zero_counts_rel_all.append(non_zero_counts_rel)
	
	
	print("plot with absolute values...")
	# absolute
	fig = go.Figure(data=[
		go.Bar(name="non-zero", x=labels, y=non_zero_counts_all),
		go.Bar(name="zero", x=labels, y=zero_counts_all)
		])
	fig.update_layout(autosize=False, width=800, height=500, title="Zero values in feature sets", barmode="stack")
	fig.update_xaxes(type='category', title="number of topics_optimize interval")
	fig.update_yaxes(title="value counts (relative)")
	
	fig.write_image(join(wdir, outfile + "_abs_bar.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_abs_bar.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	print("plot with relative values...")
	# relative to value counts
	fig2 = go.Figure(data=[
		go.Bar(name="non-zero", x=labels, y=non_zero_counts_rel_all),
		go.Bar(name="zero", x=labels, y=zero_counts_rel_all)
		])
	fig2.update_layout(autosize=False, width=800, height=500, title="Zero values in feature sets", barmode="stack")
	fig2.update_xaxes(type='category', title="number of topics_optimize interval")
	fig2.update_yaxes(title="value counts (relative)")
	
	fig2.write_image(join(wdir, outfile + "_rel_bar.png")) # scale=2 (increase physical resolution)
	fig2.write_html(join(wdir, outfile + "_rel_bar.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig2.show()

	print("done: plot zero values")
	
	

def plot_topic_coherence_scatter(wdir, diagnostics_dir, num_topics, optimization_intervals, topic_rep, outfile):
	"""
	How is the average topic coherence for the different feature sets?
	
	Arguments:
	wdir (str): path to the working directory
	diagnostics_dir (str): relative path to the directory containing mallet diagnostics
	num_topics (list): list with numbers of topics used for the various models
	optimization_intervals (list): list with values for optimization intervals
	topic_rep (int): number of repetitions for topic models
	outfile (str): relative path to the output file
	"""
	
	print("plot topic coherences...")
	
	labels = []
	
	coherences_all = []
	
	# collect coherences for all settings
	for t in num_topics:
		for oi in optimization_intervals:
			
			labels.append(str(t) + "tp_" + str(oi) + "int")
			
			average_coherence = []
			
			for rep in range(topic_rep):
				coherences = []
				file_name = "diagnostics_" + str(t) + "tp-5000it-" + str(oi) + "in-" + str(rep) + ".xml"
				xml = etree.parse(join(wdir, diagnostics_dir, file_name))
				topic_cos = xml.xpath("//topic/@coherence")
				
				for co in topic_cos:
					coherences.append(float(co))
				
				avg_co = sum(coherences) / t
				average_coherence.append(avg_co)
			
			average_coherence = sum(average_coherence) / topic_rep
			coherences_all.append(average_coherence)
	
	# plot
	fig = go.Figure(data=[
		go.Scatter(x=labels, y=coherences_all, mode="markers")
		])
	fig.update_layout(autosize=False, width=1000, height=500, title="Topic coherences in feature sets")
	fig.update_xaxes(type='category', title="parameters")
	fig.update_yaxes(title="coherence (mean)")
	
	fig.write_image(join(wdir, outfile + "_scatter.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_scatter.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()

	print("done: plot topic coherences")
	


########## MAIN FUNCTION CALLS: ##########
	
########## PREPROCESSING ##########
	
#clean_stoplist("/home/ulrike/Git/", "data-nh/analysis/features/stopwords/topics_stopwords.txt")


wdir="/home/ulrike/Git/"


### Segmenter
### Split entire texts into smaller segments.
inpath = join(wdir, "conha19/txt_annotated_nouns/", "*.txt")
outfolder = join(wdir, "data-nh/analysis/features/topics/", "1_segments", "")
target = 1000
sizetolerancefactor = 1 # 1 = exact target; >1 = with some tolerance (1.1 = +/- 10%).
preserveparagraphs = False # True|False
#prepare.segmenter(inpath, outfolder, target, sizetolerancefactor, preserveparagraphs)




########## TOPIC MODELING ##########

### Shared parameters
MalletPath = "/home/ulrike/Programme/mallet-2.0.8RC3/bin/mallet"
TextFolder = join(wdir, "data-nh/analysis/features/topics/", "1_segments")
MalletFolder = join(wdir, "data-nh/analysis/features/topics/", "2_mallet") 
CorpusFile = join(MalletFolder, "conha19.mallet")


### Import parameters (call_mallet_import)
StoplistProject = join(wdir, "data-nh/analysis/features/stopwords/", "topics_stopwords.txt")
#model.call_mallet_import(MalletPath, TextFolder, MalletFolder, CorpusFile, StoplistProject)


### Modeling parameters (call_mallet_model)
NumTopics = [50,60,70,80,90,100]
NumIterations = [5000]
OptimizeIntervals = [50,100,250,500,1000,2500,5000,None]
NumRepetitions = 5 # how many models with the same settings to build # 5
NumTopWords = 50
NumThreads = 4
ModelFolder = join(wdir, "data-nh/analysis/features/topics/", "3_models")

#model.call_mallet_modeling(MalletPath, CorpusFile, ModelFolder, NumTopics, NumIterations, OptimizeIntervals, NumRepetitions, NumTopWords, NumThreads)




########## POSTPROCESSING ##########


### Set parameters as used in the topic model
NumIterations = 5000

'''
# call postprocessing functions for all types of parameter combinations
for RP in range(NumRepetitions):
	for NT in NumTopics:
		for OI in OptimizeIntervals:
			param_settings = str(NT) + "tp-" + str(NumIterations) + "it-" + str(OI) + "in-" + str(RP)

			### create_mastermatrix
			### Creates the mastermatrix with all information in one place.
			corpuspath = join(wdir, "data-nh/analysis/features/topics/", "1_segments", "*.txt")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			mastermatrixfile = "mastermatrix.csv"
			metadatafile = join(wdir, "conha19/", "metadata.csv")
			topics_in_texts = join(wdir, "data-nh/analysis/features/topics/", "3_models", "topics-in-texts_" + param_settings + ".csv")
			number_of_topics = NT
			useBins = False
			binDataFile = ""
			version  = "208+" # which MALLET version is in use?
			postprocess.create_mastermatrix(corpuspath, outfolder, mastermatrixfile, metadatafile, topics_in_texts, number_of_topics, useBins, binDataFile, version)

			### calculate_averageTopicScores
			### Based on the mastermatrix, calculates various average topic score datasets.
			mastermatrixfile = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings, "mastermatrix.csv")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			# targets: one or several:author|decade|subgenre|author-gender|idno|segmentID|narration|narrative-perspective (according to available metadata)
			targets = ["idno"]
			postprocess.calculate_averageTopicScores(mastermatrixfile, targets, outfolder)

			### save_firstWords
			### Saves the first words of each topic to a separate file.
			topicWordFile = join(wdir, "data-nh/analysis/features/topics/", "3_models", "topics-with-words_" + param_settings + ".csv")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			filename = "firstWords.csv"
			postprocess.save_firstWords(topicWordFile, outfolder, filename)

			### Save topic ranks
			topicWordFile = join(wdir, "data-nh/analysis/features/topics/", "3_models", "topics-with-words_" + param_settings + ".csv")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			filename = "topicRanks.csv"
			postprocess.save_topicRanks(topicWordFile, outfolder, filename)
'''

########## EVALUATION and VISUALIZATION ##########

# create word clouds for the topics of selected models

'''
### Set parameters as used in the topic model
NumTopics = [50,100]
NumIterations = 5000
OptimizeIntervals = [50,1000,None]
NumRepetitions = 1

for RP in range(NumRepetitions):
	for NT in NumTopics:
		for OI in OptimizeIntervals:
			param_settings = str(NT) + "tp-" + str(NumIterations) + "it-" + str(OI) + "in-" + str(RP)

			### make_wordle_from_mallet
			### Creates a wordle for each topic.
			word_weights_file = join(wdir, "data-nh/analysis/features/topics/", "3_models", "word-weights_" + param_settings + ".csv")
			words = 40
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "5_visuals", param_settings, "wordles")
			font_path = join(wdir, "data-nh/analysis/features/topics/extras", "AlegreyaSans-Regular.otf")
			dpi = 300
			TopicRanksFile = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings, "topicRanks.csv")
			visualize.make_wordle_from_mallet(word_weights_file, NT, words, TopicRanksFile, outfolder, dpi) # ggf. font_path
'''

# analyze characteristics of the topic feature sets
# are there zero values (at all?)
#plot_zero_values_bar("/home/ulrike/Git", "data-nh/analysis/features/topics/4_aggregates", NumTopics, OptimizeIntervals, NumRepetitions, "data-nh/analysis/features/topics/overviews/zeros_topics_all")

# how is the average topic coherence for the different feature sets?
#plot_topic_coherence_scatter("/home/ulrike/Git", "data-nh/analysis/features/topics/3_models", NumTopics, OptimizeIntervals, NumRepetitions, "data-nh/analysis/features/topics/overviews/coherence_topics_all")



# how does the weight of individual topics in the whole corpus change with different optimize interval values?
# (e.g. for a model with 70 topics)
# how does it change inside of an individual example text?

