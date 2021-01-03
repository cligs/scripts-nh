#!/usr/bin/env python3
# Submodule name: bow.py

"""
Submodule to create a bow representation of a collection of texts.

@author: Ulrike Henny-Krahmer

"""

from os.path import join
from os import listdir
import pandas as pd
import numpy as np
import glob
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
# http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html
# Tokenize the documents and count the occurrences of token and return them as a sparse matrix
# see also http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfVectorizer and 
# http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfTransformer
# Apply Term Frequency Inverse Document Frequency normalization to a sparse matrix of occurrence counts
from nltk.probability import FreqDist
from nltk.corpus import PlaintextCorpusReader


def create_bow_model(wdir, corpusdir, outfile, **kwargs):
	"""
	Creates a bow model (a matrix of token counts) from a collection of full text files.
	
	Arguments:
	
	wdir (str): path to the working directory
	corpusdir (str): relative path to the input directory (the collection of text files)
	outfile (str): relative path to the output file (the bow matrix)
	
	optional:
	mfw (int): how many of the most frequent terms to use, if this is 0, all the terms are used 
	mode (str): should the counts be normalized? options: "count" (default), "tf-idf"
	vocab_file (bool): if True, the vocabulary of the corpus is stored as a list in a text file
	stopword_file (str): relative path to a file containing a list of stop words
	"""
	
	print("creating bow model...")
	
	mfw = kwargs.get("mfw", 0)
	mode = kwargs.get("mode", "count")
	vocab_file = kwargs.get("vocab_file", False)
	stopword_file = kwargs.get("stopword_file")
	
	if stopword_file:
		stopwords = pd.read_csv(join(wdir, stopword_file), header=None)
		stopwords = list(stopwords.iloc[:,0])
	
	
	if mode == "tf-idf":
		if mfw == 0:
			if stopword_file:
				vectorizer = TfidfVectorizer(input='filename', stop_words=stopwords)
			else:
				vectorizer = TfidfVectorizer(input='filename')
		else:
			if stopword_file:
				vectorizer = TfidfVectorizer(input='filename', max_features=mfw, stop_words=stopwords)
			else:
				vectorizer = TfidfVectorizer(input='filename', max_features=mfw)
	else:
		if mfw == 0:
			if stopword_file:
				vectorizer = CountVectorizer(input='filename', stop_words=stopwords)
			else:
				vectorizer = CountVectorizer(input='filename')
		else:
			if stopword_file:
				vectorizer = CountVectorizer(input='filename', max_features=mfw, stop_words=stopwords)
			else:
				vectorizer = CountVectorizer(input='filename', max_features=mfw)
	
	
	
	# possible parameters and attributes for the CountVectorizer:
	# lowercase by default
	# stop_words: for a list of stop words
	# token_pattern: regex denoting what constitutes a token
	# ngram_range: tuple (min_n,max_n)
	# analyzer: word, char, char_wb
	# max_df: default 1.0, float in range 0.1.-1.0 or integer (absolute counts), ignore terms that have a document frequency higher than this
	# min_df: default 1, float or integer (absolute counts), ignore terms that have a document frequency lower than this, "cut-off"
	# max_features: only top max features ordered by term frequency across the corpus
	# vocabulary
	# attributes:
	# vocabulary_: a mapping of terms to feature indices
	# stop_words_: terms that were ignored because of max_features, max_df or min_df
	
	
	
	# possible parameters and attributes for the TfidfVectorizer:
	# see also above
	# use_idf: Enable inverse-document-frequency reweighting. Default: true
	# smooth_idf: Smooth idf weights by adding one to document frequencies, as if an extra document was seen containing every term in the collection exactly once. Prevents zero divisions. Default: true
	# sublinear_tf: Apply sublinear tf scaling, i.e. replace tf with 1 + log(tf).
	# idf_: The inverse document frequency (IDF) vector
	
	
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
	#exit()
	#print(vocab[:100])
	
	# save to file
	idnos = [re.split(r"\.", re.split(r"/", f)[-1])[0] for f in filenames]
	
	bow_frame = pd.DataFrame(columns=vocab, index=idnos, data=bow)
	bow_frame.to_csv(join(wdir, outfile), sep=",", encoding="utf-8")
	
	print("Done! Number of documents and vocabulary: ", bow.shape)
	print("Number of tokens: ", bow.sum())
	
	
	
	
def corpus_to_lower(wdir, corpus_dir, outdir):
	"""
	Convert a full text corpus to lower case.
	
	Arguments:
	wdir (str): path to the workind directory
	corpus_dir (str): relative path to the full text corpus directory
	outdir (str): relative path to the output directory
	"""
	

	for filename in listdir(join(wdir, corpus_dir)):
		if filename.endswith(".txt"):
			
			print("doing " + filename + "...")
			
			with open(join(wdir, corpus_dir, filename), 'r', encoding="UTF-8") as infile:
				text = infile.read()
			
				with open(join(wdir, outdir, filename), 'w', encoding="UTF-8") as outfile:
					outfile.write(text.lower())	
	
	print("Done")
	
	
	
	
	
def get_mfw_ranks(wdir, feat_matrix, corpus_path, outfile):
	"""
	Get the ranks of the MFW listed in the BOW feature matrix and store them in a CSV file.
	
	(It does not seem possible to get this information directly from the Vectorizer, so I use NLTK in parallel to get the information.)
	
	Arguments:
	wdir (str): path to the working directory
	feat_matrix (str): relative path to the feature matrix file
	corpus_path (str): relative path to the full text corpus
	outfile (str): relative path to the output file (the mfw ranking)
	"""
	
	# apparently the CorpusReader is not able to convert the texts to lower case, so the corpus has to be prepared for that beforehand
	corpus = PlaintextCorpusReader(join(wdir, corpus_path), ".*")
	print("words in the corpus: " + str(len(corpus.words())))
	# calculate the frequency distribution of the words in the corpus
	fdist_corpus = FreqDist(corpus.words())
	
	
	# get the list of mfw from the BOW feature matrix
	feat = pd.read_csv(join(wdir, feat_matrix), index_col=0)
	mfw = list(feat.columns)
	
	# set up a frame for the words and ranks
	freq_frame = pd.DataFrame(index=mfw, columns=["rank", "frequency"])
	freq_frame.index.name = "word"
	
	# add the frequencies of the mfw to the rank frame
	for word in mfw:
		freq_frame.loc[word,"frequency"] = fdist_corpus[word]
	
	# sort the frame and add the ranks
	freq_frame=freq_frame.sort_values("frequency", ascending=False)
	num_mfw = len(mfw)
	ranks = range(1, num_mfw + 1)
	freq_frame["rank"] = ranks
	
	# save as CSV file
	freq_frame.to_csv(join(wdir, outfile))
	
	print("Done")
	
	
#create_bow_model("/home/ulrike/Git/papers/family_resemblance_dsrom19/", "texts/txt_full", "features/mfw_1000_tfidf_full.csv", mfw=1000, mode="tf-idf", vocab_file=True, stopword_file="features/mfw_stopwords.txt")

#corpus_to_lower("/home/ulrike/Git/papers/family_resemblance_dsrom19/", "texts/txt_full/", "texts/txt_full_lower")

#get_mfw_ranks("/home/ulrike/Git/papers/family_resemblance_dsrom19/", "features/mfw_1000_tfidf_full.csv", "texts/txt_full_lower/", "features/mfw_ranks.csv")

