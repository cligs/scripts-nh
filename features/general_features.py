#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: general_features.py

"""
@author: Ulrike Henny-Krahmer

Serves to generate general word, word n-gram and character n-gram based feature sets for the corpus.
"""

from os.path import join
import glob
import pandas as pd
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
import csv


def create_stopword_list(wdir, indir, filenames, outfile):
	"""
	Create a list of stopwords for the MFW. Reuse lists of named entities from the orthography check.
	Merge the source lists and sort alphabetically.
	
	Arguments:
	
	wdir (str): path to the working directory
	indir (str): relative path to the input directory containing source lists of exception words
	filenames (list): set of filenames for the source exception word lists
	outfile (str): relative path to the output stopword file
	"""
	stopwords = []
	for f in filenames:
		with open(join(wdir, indir, f), "r", newline="", encoding="UTF-8") as infile:
			reader = csv.reader(infile)
			data = list(reader)
			for i in data:
				stopwords.append(i)
			
	stopwords = sorted(stopwords)
	
	with open(join(wdir, outfile), "w", newline="", encoding="UTF-8") as outfile:
		wr = csv.writer(outfile)
		wr.writerows(stopwords)
	
	print("done: created stopword list")
			


def normalize_bow_model(wdir, bow_file, mode):
	"""
	Normalize the absolute counts of the bow model.
	
	Arguments:
	
	wdir (str): path to the working directory
	bow_file (str): relative path to the bow file
	mode (str): how to normalize. Possible values: tf, tfidf, zscore
	"""
	print("normalizing bow model...")
	
	bow = pd.read_csv(join(wdir, bow_file), index_col=0)
	
	# tf: term frequency, relative frequency, the absolute number of the term t in the document D is divided by the maximum frequency of a term in D
	if mode == "tf":
		# get the maximum frequencies of terms in the documents
		max_counts = bow.max(axis=1)
		# divide the counts of each document by its maximum count
		new_counts = bow.div(max_counts,axis=0)
		
	# tf-idf: term frequency * inverse document frequency. idf: how specific is the term for all the documents, log(number of all docs / number of docs containing the term)
	elif mode == "tfidf":
		tfidf_model = TfidfTransformer(use_idf=True).fit(bow)
		new_counts = tfidf_model.transform(bow).toarray()
		new_counts = pd.DataFrame(new_counts, columns=bow.columns, index=bow.index)
		
	# zscore: standard score, number of standard deviations by which the value of a raw score is above (positive) or below (negative) the mean
	# (raw score - population mean) / population std
	elif mode == "zscore":
		means = bow.mean(axis=0)
		stds = bow.std(axis=0)
		new_counts = (bow - means) / stds
		
	# save new frame
	new_file = bow_file[:-4] + "_" + mode + ".csv"
	new_counts.to_csv(join(wdir, new_file), sep=",", encoding="utf-8")
	
	print("done")





def create_bow_model(wdir, corpusdir, outfile, **kwargs):
	"""
	Creates a bow model (a matrix of absolute token counts) from a collection of full text files.
	
	Arguments:
	
	wdir (str): path to the working directory
	corpusdir (str): relative path to the input directory (the collection of text files)
	outfile (str): relative path to the output file (the bow matrix)
	
	optional:
	mfw (int): how many of the most frequent terms to use, if this is 0, all the terms are used
	vocab_file (bool): if True, the vocabulary of the corpus is stored as a list in a text file
	stopword_file (str): relative path to a file containing a list of stop words
	ngram (int): type of ngram, e.g. "2" for 2-grams
	ngram_unit (str): unit of ngrams, "w" (words) or "c" (characters)
	"""
	
	print("creating bow model...")
	
	mfw = kwargs.get("mfw", None)
	vocab_file = kwargs.get("vocab_file", False)
	stopword_file = kwargs.get("stopword_file")
	ngram = kwargs.get("ngram")
	ngram_unit = kwargs.get("ngram_unit")
	
	# default parameter values (that can be overwritten):
	stopwords = None
	analyzer = "word"
	ngramrange = (1,1)
	
	if stopword_file:
		stopwords = pd.read_csv(join(wdir, stopword_file), header=None)
		stopwords = list(stopwords.iloc[:,0])
		
	if ngram_unit == "c":
		analyzer = "char_wb"
		
	if ngram:
		ngramrange = (ngram,ngram)
	
		
	vectorizer = CountVectorizer(input='filename', stop_words=stopwords, max_features=mfw, analyzer=analyzer, ngram_range=ngramrange)

	filenames = sorted(glob.glob(join(wdir, corpusdir,"*.txt")))
	
	
	# bow: sparse representation
	bow = vectorizer.fit_transform(filenames)
	bow = bow.toarray()
	#print(bow.size)
	#print(bow.shape)
	
	vocab = vectorizer.get_feature_names()
	
	if (vocab_file == True):
		vocab_fr = pd.DataFrame(data=vocab)
		vocab_fr.to_csv(join(wdir, "vocab.txt"), encoding="UTF-8", header=False, index=False)
		print("created vocabulary file...")
	#print(vocab[:100])
	
	# save to file
	idnos = [re.split(r"\.", re.split(r"/", f)[-1])[0] for f in filenames]
	
	bow_frame = pd.DataFrame(columns=vocab, index=idnos, data=bow)
	bow_frame.to_csv(join(wdir, outfile), sep=",", encoding="utf-8")
	
	print("Done! Number of documents and vocabulary: ", bow.shape)
	print("Number of tokens: ", bow.sum())
	
	
	

	
#### call functions ####

'''
Generate general features:
100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000 MFW
absolute word counts, relative word couts, tf-idf-scores, z-scores
words: 2-grams, 3-grams, 4-grams
characters: 4-grams, 5-grams, 6-grams
stopwords: reuse exception lists of named entities from orthography check
'''


mfws = [100,200,300,400,500,1000,2000,3000,4000,5000]
ngram_words = [2,3,4]
ngram_chars = [4,5,6]

'''
# create stopword list for the word analyzer
create_stopword_list("/home/ulrike/Git/", "data-nh/corpus/text-treatment/exception-words/", ["exceptions-proper-names_ext.txt", "exceptions-surnames_ext.txt", "exceptions-countries_ext.txt", "exceptions-capitals.txt", "exceptions-places.txt"], "data-nh/analysis/features/stopwords/mfw_stopwords.txt")
'''


# create bow models with absolute counts:
for m in mfws:
	# tokens
	create_bow_model("/home/ulrike/Git/", "conha19/txt", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + ".csv", mfw=m, stopword_file="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
	# word ngrams
	for ngw in ngram_words:
		create_bow_model("/home/ulrike/Git/", "conha19/txt", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngw) + "gram_words.csv", mfw=m, ngram=ngw, ngram_unit="w", stopword_file="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
	# character ngrams
	for ngc in ngram_chars:
		create_bow_model("/home/ulrike/Git/", "conha19/txt", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars.csv", mfw=m, ngram=ngc, ngram_unit="c")


# normalize bow models:
norm_mode = ["tf","tfidf","zscore"]

for m in mfws:
	for n in norm_mode:
		# tokens
		normalize_bow_model("/home/ulrike/Git/", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + ".csv", n)
		# word ngrams
		for ngw in ngram_words:
			normalize_bow_model("/home/ulrike/Git/", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngw) + "gram_words.csv", n)
		# character ngrams
		for ngc in ngram_chars:
			normalize_bow_model("/home/ulrike/Git/", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars.csv", n)
		
	
