#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: general_features.py

"""
@author: Ulrike Henny-Krahmer

Serves to generate general word, word n-gram and character n-gram based feature sets for the corpus.
"""

from os.path import join
from os.path import isfile
import glob
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
import csv



def create_ngram_feature_set(wdir, ngram, ngram_types, mfw, outfile):
	"""
	create an ngram feature set by choosing a number of mfw and optionally combining several feature sets
	
	Arguments:
	wdir (str): path to the working directory
	ngram (int): which ngrams to use, e.g. 3 for 3-grams
	ngram_types (list): list of strings describing which ngram type of types to use. Can have the values: "mid-word", "multi-word", "prefix", and "end-punct"
	mfw (int): the number of most frequent items to use
	outfile (str): relative path to the output file for the resulting feature set
	"""

	# get ngram data
	features = pd.DataFrame()
	
	for idx, val in enumerate(ngram_types):
		nfr = pd.read_csv(join(wdir, "data-nh/analysis/features/mfw/vocab_" + str(ngram) + "_chars_" + val + ".csv"))
		if idx == 0:
			features.append(ngt_fr)
		else:
			features.join(ngt_fr)
			
	print(features.head())
	
	# get the mfw
	# sum the counts for each feature
	sums = features.sum().sort_values(ascending=False)
	# get requested token range
	mfw_vocab = list(sums[:mfw].index)
	
	print(mfw_vocab)
	# select mfw from data
	features = features.loc[:,[mfw_vocab]]
	
	print(features.head())
	
	# store feature set
	features.to_csv(join(wdir, outfile))
	
	print("done")


def count_vocab(wdir, inpath, stopwords, vocab, outfile):
	"""
	use a predefined vocabulary and count how often each token occurs in a collection of texts
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the input directory
	stopwords (str): list of stopwords to apply to the full text files before counting tokens
	vocab (str): relative path to the vocabulary file
	outfile (str): relative path to the output file for the vocabulary
	"""
	print("counting vocabulary...")
	
	# get stopwords
	stopwords = pd.read_csv(join(wdir, stopwords), header=None)
	stopwords = stopwords.iloc[:,0].tolist()
	
	# get vocabulary
	vocab = pd.read_csv(join(wdir, vocab), header=None)
	vocab = vocab.iloc[:,0].tolist()
	
	if not isfile(join(wdir, outfile)):
		# create data frame for results
		# get idnos
		idnos = [f[-10:-4] for f in glob.glob(join(wdir, inpath, "*.txt"))]
		idnos = sorted(idnos)
		bow = pd.DataFrame(index=idnos,columns=vocab)
		bow.to_csv(join(wdir, outfile))
	
	
	# read the documents
	for filepath in glob.glob(join(wdir, inpath, "*.txt")):
		filename = filepath[-10:]
		idno = filename[:-4]
		print("doing " + filename + "...")
		
		# read data frame for results
		bow = pd.read_csv(join(wdir, outfile), index_col=0)
		
		with open(filepath, "r", encoding="UTF-8") as infile:
			text = infile.read()
			# convert to lower case
			text = text.lower()
			
			# remove stopwords
			for st in stopwords:
				text = re.sub(r"\b" + st + r"\b", "", text)
				
			# count: how often does each item from the vocabulary occur in the text?
			print(len(vocab))
			for w in vocab:
				results = re.findall(str(w), text)
				num_w = len(results)
				
				# store result in frame
				bow.loc[idno,w] = num_w
	
		# store bow file
		bow.to_csv(join(wdir, outfile))
	
	print("done")


def create_vocabulary(wdir, inpath, stopwords, outfile):
	"""
	create the vocabulary of the entire text corpus
	store it in a csv file, as an ordered set of words
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the input directory
	outfile (str): relative path to the output file for the vocabulary
	"""
	print("creating vocabulary...")
	
	all_words = []
	
	# get stopwords
	stopwords = pd.read_csv(join(wdir, stopwords), header=None)
	stopwords = stopwords.iloc[:,0].tolist()
	
	# check the tokens of each document
	for filepath in glob.glob(join(wdir, inpath, "*.txt")):
		filename = filepath[-10:]
		
		with open(filepath, "r", encoding="UTF-8") as infile:
			text = infile.read()
			# convert to lower case
			text = text.lower()
			
			# get set of words and remove stopwords
			words = re.findall(r"\b\w+\b", text)
			words = set(words) - set(stopwords)
			
			# append to overall word list
			for w in words:
				if w not in all_words:
					all_words.append(w)
			
	all_words = pd.DataFrame(all_words).sort_values(by=0)
	all_words.to_csv(join(wdir, outfile), header=None, index=False)
	
	print("done")


def create_ngram_vocab(wdir, ngram, ngram_type, outfile, **kwargs):
	"""
	create a vocabulary of character ngrams
	
	possible values for ngram_type (see https://www.aclweb.org/anthology/N15-1010.pdf):
	
	mid-word: a character n-gram that covers n characters of a word that is at least n+2 characters long, 
	and that covers neither the first nor the last character of the word
	
	multi-word: n-grams that span multiple words, identified by the presence of a space in the middle of the n-gram
	(here, words separated by punctuation are not included in this type, so, only phrase-level word sequences)
	
	prefix: a character n-gram that covers the first n characters of a word that is at least n+1 characters long
	
	end-punct: a character n-gram whose last character is punctuation, but middle characters are not
	
	Arguments, positional:
	wdir (str): path to the working directory
	ngram (int): type of ngram, e.g. "2" for 2-grams
	ngram_type (str): type of ngram, e.g. "mid-word"
	outfile (str): relative path to the output file for the vocabulary
	
	Arguments, keywords:
	inpath (str): relative path to the input directory containing the full text files
	stopwords (str): relative path to a file with a list of stopwords to remove from the full texts before processing them further
	vocab (str): relative path to the vocabulary used for the creation of word-based ngrams
	"""
	
	print("creating n-ngram vocabulary...")
	
	inpath = kwargs.get("inpath", None)
	stopwords = kwargs.get("stopwords", None)
	vocab = kwargs.get("vocab", None)
	
	all_ngrams = []
	
	# create word-based ngram types
	min_length = 0
	w_range = 0
	start_pos = 0
	
	if ngram_type == "mid-word" or ngram_type == "prefix":

		print(ngram_type + "...")
		
		# get the word vocabulary as a list
		vocab = pd.read_csv(join(wdir, vocab), header=None)
		vocab = vocab.iloc[:,0].tolist()
		
		# remove all words that are too short
		if ngram_type == "mid-word":
			min_length = ngram + 2
		elif ngram_type == "prefix":
			min_length = ngram + 1
		
		vocab = [str(w) for w in vocab if len(str(w)) >= min_length]
		# create ngrams
		for w in vocab:
			
			# how many ngrams can be extracted from this word? (depending on word length)
			if ngram_type == "mid-word":
				w_range = len(w) - 2
			elif ngram_type == "prefix":
				w_range = len(w) - 1
				
			ngram_range = w_range - ngram + 1
			
			for i in range(ngram_range):
				if ngram_type == "mid-word":
					start_pos = i + 1
				elif ngram_type == "prefix":
					start_pos = i
				end_pos = start_pos + ngram
				ngram_token = w[start_pos:end_pos]
				
				if ngram_token not in all_ngrams:
					all_ngrams.append(ngram_token)
	
	
	# create multi-word and end-punct ngrams
	
	if ngram_type == "multi-word" or ngram_type == "end-punct":
		
		print(ngram_type + "...")
		
		# get stopwords
		stopwords = pd.read_csv(join(wdir, stopwords), header=None)
		stopwords = stopwords.iloc[:,0].tolist()
		
		# check the tokens of each document
		for filepath in glob.glob(join(wdir, inpath, "*.txt")):
			filename = filepath[-10:]
		
			with open(filepath, "r", encoding="UTF-8") as infile:
				text = infile.read()
				# convert to lower case
				text = text.lower()
				
				# remove stopwords
				for st in stopwords:
					text = re.sub(r"\b" + st + r"\b", "", text)
				
				# go through the text and create ngrams
				for i in range(len(text)):
					ngram_cand = text[i:i+ngram]
				
					if ngram_type == "multi-word":
						ngram_regex = r"^\w+\b\s\b\w+$"
					elif ngram_type == "end-punct":
						ngram_regex = r"^\w+[,.!?:;»”]$"
						
					if re.match(ngram_regex, ngram_cand) is not None:
						ngram_token = ngram_cand
					
						if ngram_token not in all_ngrams:
							all_ngrams.append(ngram_token)
					
	
	# save resulting ngram vocabulary
	all_ngrams = pd.DataFrame(all_ngrams).sort_values(by=0)
	all_ngrams.to_csv(join(wdir, outfile), header=None, index=False)
	
	print("done")
	
	

def prepare_fulltexts(wdir, inpath, outpath):
	"""
	prepare the annotated full texts for the generation of character n-grams:
	- remove whitespace before , . ! ? : ; » ”
	- remove whitespace after ¿ ¡ « “
	- replace _ with whitespace
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the input directory
	outpath (str): relative path to the output directory
	"""
	print("cleaning annotated full text files...")
	
	for filepath in glob.glob(join(wdir, inpath, "*.txt")):
		filename = filepath[-10:]
		with open(filepath, "r", encoding="UTF-8") as infile:
			text = infile.read()
			text = re.sub(r"\s+([,\.!?:;»”])", r"\1", text)
			text = re.sub(r"([¿¡«“])\s+", r"\1", text)
			text = re.sub(r"_", r" ", text)
			with open(join(wdir, outpath, filename), "w", encoding="UTF-8") as outfile:
				outfile.write(text)
	
	print("done")


def get_mfw(wdir, features, token_start, token_range):
	"""
	get the most frequent tokens of a certain type
	
	Arguments:
	wdir (str): path to the working directory
	features (str): relative path to the file containing the feature set
	token_start (int): start position (the rank of the first token to consider), e.g. 1 = first most frequent token
	token_range (int): how many tokens to consider from the start token on, e.g. 10 = 10 most frequent tokens
	"""
	
	print("get mfw" + str(token_start) + "-" + str(token_start + token_range - 1) + "...")
	
	
	features = pd.read_csv(join(wdir, features), index_col=0)
	# sum the counts for each feature
	sums = features.sum().sort_values(ascending=False)
	# get requested token range
	token_start = token_start - 1
	token_end = token_start + token_range
	tokens = list(sums[token_start:token_end].index)
	for t in tokens:
		print(re.sub(r"\s",r"_",t))
		

def plot_variances(wdir, features, outfile):
	"""
	Create a histogram showing the variances of the features
	
	Arguments:
	wdir (str): path to the working directory
	features (str): relative path to the file containing the feature set
	outfile (str): relative path to the output file for the plot (without file extension)
	"""
	print("plot variances...")
	
	features = pd.read_csv(join(wdir, features), index_col=0)
	
	# get the variance for each feature
	stds = features.std(axis=0) #.apply(np.log)
	
	# plot
	fig = go.Figure(data=[go.Histogram(x=stds)])
	
	fig.update_layout(autosize=False, width=800, height=500, title="Variances in feature set", xaxis_title="variance", yaxis_title="number of features")

	fig.write_image(join(wdir, outfile + "_hist.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_hist.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	
	#fig.show()
	
	print("done: plot variances")



def plot_zero_values(wdir, features, outfile):
	"""
	Create a histogram showing how many features have zero values how often, 
	and a donut chart showing the overall proportion of zero-values in the feature set.
	
	Arguments:
	wdir (str): path to the working directory
	features (str): relative path to the file containing the feature set
	outfile (str): relative path to the output file for the plot (without file extension)
	"""
	print("plot zero values ...")
	
	features = pd.read_csv(join(wdir, features), index_col=0)
	
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
	
	# plot
	fig = go.Figure(data=[go.Histogram(x=x)])
	
	fig.update_layout(autosize=False, width=800, height=500, title="Zero values in feature set", xaxis_title="number of times a feature is zero", yaxis_title="number of features")

	fig.write_image(join(wdir, outfile + "_hist.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_hist.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	fig2 = go.Figure(data=[go.Pie(labels=["zero","non-zero"], values=[zero_count,value_count - zero_count], hole=0.4, direction="clockwise")])
	fig2.update_layout(autosize=False, width=500, height=400, title="Zero values in feature set")
	
	fig2.write_image(join(wdir, outfile + "_pie.png")) # scale=2 (increase physical resolution)
	fig2.write_html(join(wdir, outfile + "_pie.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done: plot zero values")
	


def store_vocabulary(wdir, features, outfile):
	"""
	Store the vocabulary of a feature set to check for additional stop words
	
	Arguments:
	wdir (str): path to the working directory
	features (str): relative path to the file containing the feature set
	outfile (str): relative path to the output file for the vocabulary
	"""
	
	features = pd.read_csv(join(wdir, features), index_col=0)
	vocab = list(features.columns)
	vocab_fr = pd.DataFrame(data=vocab)
	vocab_fr.to_csv(join(wdir, outfile), encoding="UTF-8", header=False, index=False)
	
	print("done: created vocabulary file")



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
	# (relative score - population mean) / population std
	elif mode == "zscore":
		# get the maximum frequencies of terms in the documents
		max_counts = bow.max(axis=1)
		# divide the counts of each document by its maximum count
		rel_counts = bow.div(max_counts,axis=0)
		
		means = bow.mean(axis=0)
		stds = bow.std(axis=0)
		new_counts = (rel_counts - means) / stds
		
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
	stopword_file (str): relative path to a file containing a list of stop words
	ngram (int): type of ngram, e.g. "2" for 2-grams
	ngram_unit (str): unit of ngrams, "w" (words) or "c" (characters)
	"""
	
	print("creating bow model...")
	
	mfw = kwargs.get("mfw", None)
	stopword_file = kwargs.get("stopword_file")
	ngram = kwargs.get("ngram")
	ngram_unit = kwargs.get("ngram_unit")
	
	# default parameter values (that can be overwritten):
	stopwords = None
	analyzer = "word"
	ngramrange = (1,1)
	tokenpattern = "(?u)\b\w+\b"
	
	if stopword_file:
		stopwords = pd.read_csv(join(wdir, stopword_file), header=None)
		stopwords = list(stopwords.iloc[:,0])
		
	if ngram_unit == "c":
		analyzer = "char"
		
	if ngram:
		ngramrange = (ngram,ngram)
	
		
	vectorizer = CountVectorizer(input='filename', stop_words=stopwords, max_features=mfw, analyzer=analyzer, ngram_range=ngramrange, token_pattern=tokenpattern)

	filenames = sorted(glob.glob(join(wdir, corpusdir,"*.txt")))
	
	
	# bow: sparse representation
	bow = vectorizer.fit_transform(filenames)
	bow = bow.toarray()
	#print(bow.size)
	#print(bow.shape)
	
	vocab = vectorizer.get_feature_names()
	
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
ngram_chars = [3,4,5]
ngram_chars_type = ["word", "affix-punct", "all"]
ngram_chars_subtype = ["multi-word", "prefix", "end-punct"] #"mid-word"
norm_mode = ["tf","tfidf","zscore"]



'''
# prepare full texts for character n-grams
prepare_fulltexts("/home/ulrike/Git/", "conha19/txt_annotated/", "conha19/txt_annotated_corr/")
'''

'''
# create stopword list for the word analyzer
create_stopword_list("/home/ulrike/Git/", "data-nh/corpus/text-treatment/exception-words/", ["exceptions-proper-names_ext.txt", "exceptions-surnames_ext.txt", "exceptions-countries_ext.txt", "exceptions-capitals.txt", "exceptions-places.txt"], "data-nh/analysis/features/stopwords/mfw_stopwords.txt")
'''

''' TO DO: create again with new token_pattern
# create bow models with absolute counts:
for m in mfws:
	
	# tokens
	create_bow_model("/home/ulrike/Git/", "conha19/txt_annotated", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + ".csv", mfw=m, stopword_file="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
	# word ngrams
	for ngw in ngram_words:
		create_bow_model("/home/ulrike/Git/", "conha19/txt_annotated", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngw) + "gram_words.csv", mfw=m, ngram=ngw, ngram_unit="w", stopword_file="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
	# character ngrams ("all" = classical approach TO DO: hier auch vorher stop words aus den Textdateien rauswerfen?)
	for ngc in ngram_chars:
		create_bow_model("/home/ulrike/Git/", "conha19/txt_annotated", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars.csv", mfw=m, ngram=ngc, ngram_unit="c")
'''


# create special character n-gram feature sets
# do this for: 3,4,5; mid-word, multi-word, prefix, end-punct, and for the different mfw
# combine mid-word and multi-word to a "word" set and prefix and end-punct to an "affix-punct" set

#create_vocabulary("/home/ulrike/Git/", "conha19/txt_annotated_corr", "data-nh/analysis/features/stopwords/mfw_stopwords.txt", "data-nh/analysis/features/mfw/vocab_all.csv")

'''
# create ngram vocabularies:
for ngc in ngram_chars:
	create_ngram_vocab("/home/ulrike/Git/", ngc, "mid-word", "data-nh/analysis/features/mfw/vocab_" + str(ngc) + "gram_chars_mid-word.csv", vocab="data-nh/analysis/features/mfw/vocab_all.csv")
	create_ngram_vocab("/home/ulrike/Git/", ngc, "prefix", "data-nh/analysis/features/mfw/vocab_" + str(ngc) + "gram_chars_prefix.csv", vocab="data-nh/analysis/features/mfw/vocab_all.csv")
	create_ngram_vocab("/home/ulrike/Git/", ngc, "multi-word", "data-nh/analysis/features/mfw/vocab_" + str(ngc) + "gram_chars_multi-word.csv", inpath="conha19/txt_annotated_corr", stopwords="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
	create_ngram_vocab("/home/ulrike/Git/", ngc, "end-punct", "data-nh/analysis/features/mfw/vocab_" + str(ngc) + "gram_chars_end-punct.csv", inpath="conha19/txt_annotated_corr", stopwords="data-nh/analysis/features/stopwords/mfw_stopwords.txt")
'''


# count ngram vocabularies:
for ngc in ngram_chars:
	for ngs in ngram_chars_subtype:
		count_vocab("/home/ulrike/Git", "conha19/txt_annotated_corr", "data-nh/analysis/features/stopwords/mfw_stopwords.txt", "data-nh/analysis/features/mfw/vocab_" + str(ngc) + "gram_chars_" + ngs + ".csv", "data-nh/analysis/features/mfw/bow_all_" + str(ngc) + "gram_chars_" + ngs + ".csv")
	


#create_ngram_feature_set("/home/ulrike/Git", 3, ["mid-word","multi-word"], 100, "data-nh/analysis/features/mfw/bow_mfw100_3gram_chars_word.csv")





'''
# check vocabulary of mfw for additional stop words	
store_vocabulary("/home/ulrike/Git/", "data-nh/analysis/features/mfw/bow_mfw5000.csv", "data-nh/analysis/features/mfw/vocab_bow_mfw5000.csv")
'''


'''
# normalize bow models:

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
'''

'''
#  visualize characteristics of feature sets

for m in mfws:
	
	plot_zero_values("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + ".csv", "data-nh/analysis/features/mfw/overviews/zeros_bow_mfw" + str(m))
	plot_variances("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + ".csv", "data-nh/analysis/features/mfw/overviews/variances_bow_mfw" + str(m))
	
	for n in norm_mode:
		
		# tokens:
		plot_zero_values("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/zeros_bow_mfw" + str(m) + "_" + n)
		plot_variances("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/variances_bow_mfw" + str(m) + "_" + n)
		# word ngrams:
		for ngw in ngram_words:
			plot_zero_values("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngw) + "gram_words_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/zeros_bow_mfw" + str(m) + "_" + str(ngw) + "gram_words_" + n)
			plot_variances("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngw) + "gram_words_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/variances_bow_mfw" + str(m) + "_" + str(ngw) + "gram_words_" + n)
		
		# character ngrams:
		for ngc in ngram_chars:
			plot_zero_values("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/zeros_bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars_" + n)
			plot_variances("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars_" + n + ".csv", "data-nh/analysis/features/mfw/overviews/variances_bow_mfw" + str(m) + "_" + str(ngc) + "gram_chars_" + n)
'''

'''
# get most frequent tokens of a certain type and range
get_mfw("/home/ulrike/Git", "data-nh/analysis/features/mfw/bow_mfw5000_5gram_chars.csv", 101, 200) #_2gram_words, _5gram_chars
'''


