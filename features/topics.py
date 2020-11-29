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
import plotly.graph_objects as go
from tmw import prepare
from tmw import model


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
NumRepetitions = 5 # how many models with the same settings to build
NumTopWords = 50
NumThreads = 4
ModelFolder = join(wdir, "data-nh/analysis/features/topics/", "3_models")

model.call_mallet_modeling(MalletPath, CorpusFile, ModelFolder, NumTopics, NumIterations, OptimizeIntervals, NumRepetitions, NumTopWords, NumThreads)



'''
########## POSTPROCESSING ##########


### Set parameters as used in the topic model
NumIterations = 5000

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
			topics_in_texts = join(wdir, "data-nh/analysis/features/topics/", "2_mallet", "topics-in-texts_" + param_settings + ".csv")
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
			topicWordFile = join(wdir, "data-nh/analysis/features/topics/", "2_mallet", "topics-with-words_" + param_settings + ".csv")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			filename = "firstWords.csv"
			postprocess.save_firstWords(topicWordFile, outfolder, filename)

			### Save topic ranks
			topicWordFile = join(wdir, "data-nh/analysis/features/topics/", "2_mallet", "topics-with-words_" + param_settings + ".csv")
			outfolder = join(wdir, "data-nh/analysis/features/topics/", "4_aggregates", param_settings)
			filename = "topicRanks.csv"
			postprocess.save_topicRanks(topicWordFile, outfolder, filename)


########## VISUALIZATION ##########

# create word clouds for the topics of selected models
'''
